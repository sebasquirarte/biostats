#' Descriptive and Visual Missing Value Assessment
#'
#' Provides descriptive statistics and visualizations of missing values in a dataframe.
#'
#' @param data Dataframe containing the variables to be analyzed.
#' @param color Character string indicating the color for missing values. Default: "#79E1BE"
#' @param all Logical parameter that shows all variables including those without missing values. Default: FALSE.
#'
#' @return
#' Prints results to console and invisibly returns a list with descriptive statistics and ggplot objects.
#'
#' @examples
#' # Clinical dataset with missing values
#' clinical_df <- clinical_data(dropout = 0.1, missing = 0.05)
#' 
#' # Missing value analysis of only variables with missing values
#' missing_values(clinical_df)
#' 
#' # Show all variables including those without missing values
#' missing_values(clinical_df, all = TRUE)
#'
#' @importFrom stats complete.cases
#' @importFrom ggplot2 ggplot aes geom_bar geom_text scale_fill_manual coord_flip
#' @importFrom ggplot2 scale_y_continuous expansion labs theme_minimal element_blank element_text margin
#' @importFrom gridExtra grid.arrange
#' @export

missing_values <- function(data, 
                           color = "#79E1BE", 
                           all = FALSE) {
  
  # Package requirements
  required_pkgs <- c("ggplot2", "gridExtra")
  missing_pkgs <- required_pkgs[!sapply(required_pkgs, requireNamespace, quietly = TRUE)]
  if (length(missing_pkgs) > 0) {
    stop("Required packages not installed: ", paste(missing_pkgs, collapse = ", "), ".", call. = FALSE)
  }
  # Input validation
  if (!is.data.frame(data)) stop("'data' must be a dataframe.", call. = FALSE)
  if (nrow(data) == 0) stop("'data' must have at least one row.", call. = FALSE)
  if (ncol(data) == 0) stop("'data' must have at least one column.", call. = FALSE)
  if (!is.character(color)) stop("'color' must be a character string.", call. = FALSE)
  if (length(color) != 1) stop("'color' must be a single character string.", call. = FALSE)
  if (!is.logical(all)) stop("'all' must be a logical value.", call. = FALSE)

  # Calculate statistics
  n_missing <- colSums(is.na(data))
  missing_stats <- data.frame(
    variable = names(data), n_missing = n_missing,
    pct_missing = round(n_missing / nrow(data) * 100, 2),
    stringsAsFactors = FALSE
  )[order(-n_missing), ]
  
  total_missing <- sum(is.na(data))
  complete_cases <- sum(stats::complete.cases(data))
  complete_pct <- round(complete_cases / nrow(data) * 100, 1)
  overall_pct <- round(total_missing / (nrow(data) * ncol(data)) * 100, 1)
  
  # Determine variables to display
  display_vars <- if (all) missing_stats else missing_stats[missing_stats$n_missing > 0, ]
  
  # Early return if no variables to show
  if (nrow(display_vars) == 0) {
    message("No missing values found in the dataframe.")
    return(invisible(list(missing_stats = missing_stats, total_missing = 0,
                          complete_cases = nrow(data), complete_pct = 100, overall_pct = 0)))
  }
  
  # Create plots
  display_vars$variable <- factor(display_vars$variable, levels = rev(display_vars$variable))
  
  # Bar plot
  bar_data <- data.frame(
    variable = rep(display_vars$variable, each = 2),
    status = factor(rep(c("Present", "Missing"), nrow(display_vars)), levels = c("Present", "Missing")),
    value = c(rbind(100 - display_vars$pct_missing, display_vars$pct_missing))
  )
  
  theme_clean <- theme_minimal() + theme(
    panel.grid = element_blank(), panel.border = element_blank(),
    axis.ticks = element_blank(), plot.margin = margin(5, 5, 5, 5),
    legend.position = "none")
  
  bar_plot <- ggplot(bar_data, aes(x = .data$variable, y = .data$value, fill = .data$status)) +
    geom_bar(stat = "identity", width = 1) +
    geom_text(data = display_vars, aes(x = .data$variable, y = 50,
                                                         label = paste0(.data$n_missing, " (", .data$pct_missing, "%) missing")),
                       inherit.aes = FALSE, size = 3) +
    scale_fill_manual(values = c("Present" = "grey98", "Missing" = color),
                               breaks = "Missing", labels = "Missing", name = "") +
    coord_flip() + scale_y_continuous(expand = expansion(mult = c(0, 0)),
                                                        limits = c(0, 100), labels = NULL) +
    labs(title = "Missing Values by Variable",
                  subtitle = sprintf("Complete cases: %d / %d (%.1f%%)", complete_cases, nrow(data), complete_pct),
                  x = "", y = "") + theme_clean +
    theme(axis.text.y = element_text(hjust = 1), axis.text.x = element_blank())
  
  # Heatmap plot
  heatmap_plot <- if (nrow(data) * nrow(display_vars) <= 200000) {
    heat_df <- data[, as.character(display_vars$variable), drop = FALSE]
    heat_data <- data.frame(
      row_id = rep(1:nrow(heat_df), ncol(heat_df)),
      variable = factor(rep(colnames(heat_df), each = nrow(heat_df)), levels = levels(display_vars$variable)),
      is_missing = as.vector(is.na(heat_df)))
    
    ggplot(heat_data, aes(y = .data$variable, x = .data$row_id, fill = .data$is_missing)) +
      geom_tile(color = NA) +
      scale_fill_manual(values = c("FALSE" = "grey98", "TRUE" = color),
                                 breaks = "TRUE", labels = "Missing", name = "") +
      labs(title = "Missing Value Patterns",
                    subtitle = sprintf("Missing values: %d / %d (%.1f%%)", total_missing, nrow(data) * ncol(data), overall_pct),
                    x = "", y = "") + theme_clean +
      theme(axis.text.y = element_text(hjust = 1), axis.text.x = element_blank())
  } else {
    ggplot() + annotate("text", x = 0.5, y = 0.5, label = "Heatmap skipped (too large)") +
      theme_void()
  }
  
  # Print summary and display plots
  cat(sprintf("\nMissing Value Analysis\n\nn: %d, Variables: %d\n", nrow(data), ncol(data)))
  cat(sprintf("Complete cases: %d / %d (%.1f%%)\n", complete_cases, nrow(data), complete_pct))
  cat(sprintf("Missing cells: %d / %d (%.1f%%)\n\n", total_missing, nrow(data) * ncol(data), overall_pct))
  cat(sprintf("Variables with missing values: %d of %d (%.1f%%)\n\n",
              sum(missing_stats$n_missing > 0), ncol(data),
              round(sum(missing_stats$n_missing > 0) / ncol(data) * 100, 1)))
  
  print(if (all) missing_stats[, c("n_missing", "pct_missing")] else
    missing_stats[missing_stats$n_missing > 0, c("n_missing", "pct_missing")])
  cat("\n")
  
  grid.arrange(bar_plot, heatmap_plot, ncol = 2)
  
  invisible(list(missing_stats = missing_stats,
                 total_missing = total_missing,
                 complete_cases = complete_cases,
                 complete_pct = complete_pct,
                 overall_pct = overall_pct,
                 bar_plot = bar_plot,
                 heatmap_plot = heatmap_plot))
}
