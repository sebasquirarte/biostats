#' Analyze and Visualize Missing Values in a Dataframe
#'
#' Analyzes missing values in a dataframe, providing counts and percentages per
#' column with visualizations.
#'
#' @param df A dataframe to analyze for missing values
#' @param color Character; color for missing values. Default is "#79E1BE"
#' @param all Logical; if TRUE, shows all variables including those without missing values. Default is FALSE.
#'
#' @return Invisibly returns a list with missing value statistics and plots.
#'   Also prints results to console and displays plots.
#'
#' @examples
#' # Clinical dataset with missing values
#' clinical_df <- clinical_data(missing = 0.05)
#' # Missing value analysis of only variables with missing values
#' missing_values(clinical_df)
#' # Show all variables including those without missing values
#' missing_values(clinical_df, all = TRUE)
#'
#' @importFrom stats complete.cases
#' @importFrom ggplot2 ggplot aes geom_bar geom_text scale_fill_manual coord_flip
#' @importFrom ggplot2 scale_y_continuous expansion labs theme_minimal element_blank element_text margin
#' @importFrom gridExtra grid.arrange
#' @export
missing_values <- function(df, color = "#79E1BE", all = FALSE) {

  # Input validation
  if (!is.data.frame(df) || nrow(df) == 0 || ncol(df) == 0)
    stop("Input must be a non-empty dataframe", call. = FALSE)
  if (!is.character(color) || length(color) != 1 || !is.logical(all) || length(all) != 1)
    stop("'color' must be a character string and 'all' must be logical", call. = FALSE)
  if (!requireNamespace("ggplot2", quietly = TRUE) || !requireNamespace("gridExtra", quietly = TRUE))
    stop("Please install 'ggplot2' and 'gridExtra' packages")
  if (ncol(df) > 50)
    warning("Dataset has many columns (", ncol(df), "). Consider using 'all = FALSE' for better performance.", call. = FALSE)

  # Calculate statistics
  n_missing <- colSums(is.na(df))
  missing_stats <- data.frame(
    variable = names(df), n_missing = n_missing,
    pct_missing = round(n_missing / nrow(df) * 100, 2),
    stringsAsFactors = FALSE
  )[order(-n_missing), ]

  total_missing <- sum(is.na(df))
  complete_cases <- sum(stats::complete.cases(df))
  complete_pct <- round(complete_cases / nrow(df) * 100, 1)
  overall_pct <- round(total_missing / (nrow(df) * ncol(df)) * 100, 1)

  # Determine variables to display
  display_vars <- if (all) missing_stats else missing_stats[missing_stats$n_missing > 0, ]

  # Early return if no variables to show
  if (nrow(display_vars) == 0) {
    message("No missing values found in the dataframe.")
    return(invisible(list(missing_stats = missing_stats, total_missing = 0,
                          complete_cases = nrow(df), complete_pct = 100, overall_pct = 0)))
  }

  # Create plots
  display_vars$variable <- factor(display_vars$variable, levels = rev(display_vars$variable))

  # Bar plot
  bar_data <- data.frame(
    variable = rep(display_vars$variable, each = 2),
    status = factor(rep(c("Present", "Missing"), nrow(display_vars)), levels = c("Present", "Missing")),
    value = c(rbind(100 - display_vars$pct_missing, display_vars$pct_missing))
  )

  theme_clean <- ggplot2::theme_minimal() + ggplot2::theme(
    panel.grid = ggplot2::element_blank(), panel.border = ggplot2::element_blank(),
    axis.ticks = ggplot2::element_blank(), plot.margin = ggplot2::margin(5, 5, 5, 5),
    legend.position = "none")

  bar_plot <- ggplot2::ggplot(bar_data, ggplot2::aes(x = .data$variable, y = .data$value, fill = .data$status)) +
    ggplot2::geom_bar(stat = "identity", width = 1) +
    ggplot2::geom_text(data = display_vars, ggplot2::aes(x = .data$variable, y = 50,
                                                         label = paste0(.data$n_missing, " (", .data$pct_missing, "%) missing")),
                       inherit.aes = FALSE, size = 3) +
    ggplot2::scale_fill_manual(values = c("Present" = "grey98", "Missing" = color),
                               breaks = "Missing", labels = "Missing", name = "") +
    ggplot2::coord_flip() + ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0, 0)),
                                                        limits = c(0, 100), labels = NULL) +
    ggplot2::labs(title = "Missing Values by Variable",
                  subtitle = sprintf("Complete cases: %d / %d (%.1f%%)", complete_cases, nrow(df), complete_pct),
                  x = "", y = "") + theme_clean +
    ggplot2::theme(axis.text.y = ggplot2::element_text(hjust = 1), axis.text.x = ggplot2::element_blank())

  # Heatmap plot
  heatmap_plot <- if (nrow(df) * nrow(display_vars) <= 200000) {
    heat_df <- df[, as.character(display_vars$variable), drop = FALSE]
    heat_data <- data.frame(
      row_id = rep(1:nrow(heat_df), ncol(heat_df)),
      variable = factor(rep(colnames(heat_df), each = nrow(heat_df)), levels = levels(display_vars$variable)),
      is_missing = as.vector(is.na(heat_df)))

    ggplot2::ggplot(heat_data, ggplot2::aes(y = .data$variable, x = .data$row_id, fill = .data$is_missing)) +
      ggplot2::geom_tile(color = NA) +
      ggplot2::scale_fill_manual(values = c("FALSE" = "grey98", "TRUE" = color),
                                 breaks = "TRUE", labels = "Missing", name = "") +
      ggplot2::labs(title = "Missing Value Patterns",
                    subtitle = sprintf("Missing values: %d / %d (%.1f%%)", total_missing, nrow(df) * ncol(df), overall_pct),
                    x = "", y = "") + theme_clean +
      ggplot2::theme(axis.text.y = ggplot2::element_text(hjust = 1), axis.text.x = ggplot2::element_blank())
  } else {
    ggplot2::ggplot() + ggplot2::annotate("text", x = 0.5, y = 0.5, label = "Heatmap skipped (too large)") +
      ggplot2::theme_void()
  }

  # Print summary and display plots
  cat(sprintf("\nMissing Value Analysis\n\nn: %d, variables: %d\n", nrow(df), ncol(df)))
  cat(sprintf("Complete cases: %d / %d (%.1f%%)\n", complete_cases, nrow(df), complete_pct))
  cat(sprintf("Missing cells: %d / %d (%.1f%%)\n\n", total_missing, nrow(df) * ncol(df), overall_pct))
  cat(sprintf("Variables with missing values: %d of %d (%.1f%%)\n\n",
              sum(missing_stats$n_missing > 0), ncol(df),
              round(sum(missing_stats$n_missing > 0) / ncol(df) * 100, 1)))

  print(if (all) missing_stats[, c("n_missing", "pct_missing")] else
    missing_stats[missing_stats$n_missing > 0, c("n_missing", "pct_missing")])
  cat("\n")

  gridExtra::grid.arrange(bar_plot, heatmap_plot, ncol = 2)

  invisible(list(missing_stats = missing_stats,
                 total_missing = total_missing,
                 complete_cases = complete_cases,
                 complete_pct = complete_pct,
                 overall_pct = overall_pct,
                 bar_plot = bar_plot,
                 heatmap_plot = heatmap_plot))
}
