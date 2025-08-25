#' Descriptive and Visual Outlier Assessment
#'
#' Identifies outliers using Tukey's interquartile range (IQR) method and provides
#' descriptive statistics and visualizations for outlier assessment in numeric data.
#'
#' @param data Dataframe containing the variables to be analyzed.
#' @param x Character string indicating the variable to be analyzed.
#' @param threshold Numeric value multiplying the IQR to define outlier boundaries. Default: 1.5.
#' @param color Character string indicating the color for non-outlier data points. Default: "#79E1BE".
#'
#' @return 
#' Prints results to console and invisibly returns a list with outlier statistics and ggplot objects.
#'
#' @examples
#' # Simulated clinical data
#' clinical_df <- clinical_data()
#' 
#' # Basic outlier detection
#' outliers(clinical_df, "biomarker")
#' 
#' # Using custom threshold
#' outliers(clinical_df, "biomarker", threshold = 1.0)
#'
#' @importFrom stats quantile
#' @importFrom ggplot2 ggplot aes geom_point geom_text scale_color_manual
#' @importFrom ggplot2 labs theme_minimal stat_boxplot geom_boxplot theme element_text element_blank margin
#' @importFrom gridExtra grid.arrange
#' @export

outliers <- function(data,
                     x,
                     threshold = 1.5,
                     color = "#79E1BE") {
  
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
  if (!is.character(x)) stop("'x' must be a character string.", call. = FALSE)
  if (length(x) != 1) stop("'x' must be a single character string.", call. = FALSE)
  if (!x %in% names(data)) stop("'x' must be a valid column name in 'data'.", call. = FALSE)
  if (!is.numeric(data[[x]])) stop("Column '", x, "' must be numeric.", call. = FALSE)
  if (!is.numeric(threshold)) stop("'threshold' must be numeric.", call. = FALSE)
  if (length(threshold) != 1) stop("'threshold' must be a single value.", call. = FALSE)
  if (threshold <= 0) stop("'threshold' must be positive.", call. = FALSE)
  if (!is.character(color)) stop("'color' must be a character string.", call. = FALSE)
  if (length(color) != 1) stop("'color' must be a single character string.", call. = FALSE)
  
  # Clean data and validate minimum requirements
  x_values <- data[[x]]
  orig_indices <- which(!is.na(x_values))
  clean_values <- x_values[orig_indices]
  n_missing <- length(x_values) - length(clean_values)
  
  if (length(clean_values) < 4) {
    stop("Need at least 4 non-missing observations for outlier detection, found ", 
         length(clean_values), ".", call. = FALSE)
  }
  
  # Calculate outlier bounds using Tukey's method
  quartiles <- stats::quantile(clean_values, c(0.25, 0.75), names = FALSE)
  iqr_value <- quartiles[2] - quartiles[1]
  bounds <- c(lower = quartiles[1] - threshold * iqr_value, 
              upper = quartiles[2] + threshold * iqr_value)
  
  # Identify outliers
  is_outlier <- clean_values < bounds["lower"] | clean_values > bounds["upper"]
  outlier_indices <- orig_indices[is_outlier]
  n_outliers <- length(outlier_indices)
  
  # Create data frame for plotting
  plot_data <- data.frame(
    index = seq_along(clean_values),
    value = clean_values,
    is_outlier = is_outlier,
    stringsAsFactors = FALSE
  )
  
  # Create scatter plot with outlier highlighting
  scatter_plot <- ggplot2::ggplot(plot_data, ggplot2::aes(x = .data$index, y = .data$value)) +
    ggplot2::geom_point(ggplot2::aes(color = .data$is_outlier), size = 2, alpha = 0.7) +
    ggplot2::scale_color_manual(values = c("FALSE" = color, "TRUE" = "red"), guide = "none") +
    ggplot2::labs(
      title = "Outlier Detection by Index",
      subtitle = sprintf("Outliers: %d / %d (%.1f%%)", n_outliers, length(clean_values), 
                         round(n_outliers / length(clean_values) * 100, 1)),
      x = "Index", y = x
    ) +
    ggplot2::theme_minimal()
  
  # Add labels for outliers if manageable number
  if (n_outliers > 0 && n_outliers <= 10) {
    scatter_plot <- scatter_plot + ggplot2::geom_text(
      data = plot_data[is_outlier, ],
      ggplot2::aes(label = outlier_indices),
      vjust = -0.8, size = 3, color = "red"
    )
  }
  
  # Create boxplot with custom whiskers
  box_plot <- ggplot2::ggplot(data.frame(value = clean_values), 
                              ggplot2::aes(x = "", y = .data$value)) +
    ggplot2::stat_boxplot(geom = "errorbar", width = 0.1, coef = threshold) +
    ggplot2::geom_boxplot(outlier.color = "red", fill = color, alpha = 0.7, 
                          coef = threshold, width = 0.5) +
    ggplot2::labs(
      title = "Distribution with Outliers",
      subtitle = sprintf("Tukey's method (IQR x %.1f)", threshold),
      x = " ", y = x
    ) +
    ggplot2::theme_minimal() +
    ggplot2::scale_x_discrete(labels = " ")
  
  # Print comprehensive summary
  missing_pct <- round(n_missing / length(x_values) * 100, 1)
  outlier_pct <- round(n_outliers / length(clean_values) * 100, 1)
  
  cat(sprintf("\nOutlier Analysis\n\nVariable: '%s'\n", x))
  cat(sprintf("n: %d\nMissing: %d (%.1f%%)\n", length(clean_values), n_missing, missing_pct))
  cat(sprintf("Method: Tukey's IQR x %.1f\n", threshold))
  cat(sprintf("Bounds: [%.3f, %.3f]\n", bounds["lower"], bounds["upper"]))
  cat(sprintf("Outliers detected: %d (%.1f%%)\n\n", n_outliers, outlier_pct))
  
  # Display outlier indices with smart truncation
  if (n_outliers > 0) {
    shown_indices <- if (n_outliers <= 20) outlier_indices else outlier_indices[1:10]
    cat(sprintf("Outlier indices: %s%s\n\n",
                paste(sort(shown_indices), collapse = ", "),
                ifelse(n_outliers > 20, " (...)", "")))
  }
  
  # Display plots
  gridExtra::grid.arrange(scatter_plot, box_plot, ncol = 2)
  
  # Return essential results
  invisible(list(
    outliers = outlier_indices,
    bounds = bounds,
    stats = c(q1 = quartiles[1], q3 = quartiles[2], iqr = iqr_value),
    scatter_plot = scatter_plot,
    boxplot = box_plot
  ))
}
