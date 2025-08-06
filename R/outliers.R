#' Detect and Visualize Outliers Using Tukey's Method
#'
#' Identifies outliers using Tukey's interquartile range (IQR) method and provides
#' comprehensive visual assessment through scatter plots and boxplots.
#'
#' @param x Numeric vector or character string naming a column in \code{data}.
#' @param data Optional dataframe containing the variable specified in \code{x}.
#'   Default is NULL.
#' @param threshold Numeric. Value multiplying the IQR to define outlier boundaries.
#'   Default is 1.5 (Tukey's standard).
#' @param color Character string specifying plot color. Default is "#7fcdbb".
#'
#' @return Invisibly returns a list with components:
#'   \describe{
#'     \item{outliers}{Integer vector of row indices for detected outliers}
#'     \item{bounds}{Named numeric vector with \code{lower} and \code{upper} bounds}
#'     \item{stats}{Named numeric vector with quartiles (\code{q1}, \code{q3}) and \code{iqr}}
#'     \item{scatter_plot}{ggplot object showing indexed scatter plot with outliers highlighted}
#'     \item{boxplot}{ggplot object showing boxplot with custom whiskers}
#'   }
#'
#' @details
#' The function uses Tukey's method where outliers are defined as observations
#' falling below Q1 - threshold × IQR or above Q3 + threshold × IQR.
#' Missing values are automatically excluded from analysis.
#'
#' @examples
#' clinical_df <- clinical_data(n = 300)
#' outliers(clinical_df$biomarker)
#'
#' @importFrom stats quantile
#' @importFrom ggplot2 ggplot aes geom_point geom_text scale_color_manual
#'   labs theme_minimal stat_boxplot geom_boxplot
#' @importFrom gridExtra grid.arrange
#' @importFrom rlang .data
#'
#' @export
outliers <- function(x,
                     data = NULL,
                     threshold = 1.5,
                     color = "#7fcdbb") {

  # Check required packages
  pkgs <- c("ggplot2", "gridExtra")
  missing <- pkgs[!sapply(pkgs, requireNamespace, quietly = TRUE)]
  if (length(missing) > 0) {
    stop("Install required packages: install.packages(c('",
         paste(missing, collapse = "', '"), "'))", call. = FALSE)
  }

  # Extract values and variable name
  if (!is.null(data) && is.character(x)) {
    if (length(x) != 1 || !x %in% names(data))
      stop("'x' must be a single valid column name in 'data'", call. = FALSE)
    var_name <- x
    x_values <- data[[x]]
  } else {
    if (!is.numeric(x)) stop("'x' must be numeric", call. = FALSE)
    var_name <- deparse(substitute(x))
    x_values <- x
  }

  # Validate threshold
  if (!is.numeric(threshold) || length(threshold) != 1 || threshold <= 0)
    stop("'threshold' must be a positive number.", call. = FALSE)

  # Clean data and check minimum requirements
  orig_indices <- which(!is.na(x_values))
  clean_values <- x_values[orig_indices]
  if (length(clean_values) < 4)
    stop("Need at least 4 non-missing observations, found ", length(clean_values), ".", call. = FALSE)

  # Calculate outlier bounds using Tukey's method
  q <- stats::quantile(clean_values, c(0.25, 0.75), names = FALSE)
  iqr <- q[2] - q[1]
  bounds <- c(lower = q[1] - threshold * iqr, upper = q[2] + threshold * iqr)

  # Identify outliers
  is_outlier <- clean_values < bounds["lower"] | clean_values > bounds["upper"]
  outlier_indices <- orig_indices[is_outlier]
  n_out <- length(outlier_indices)

  # Create data frame for plotting
  plot_df <- data.frame(
    index = seq_along(clean_values),
    value = clean_values,
    is_outlier = is_outlier
  )

  # Create scatter plot with outlier highlighting
  scatter_plot <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$index, y = .data$value)) +
    ggplot2::geom_point(ggplot2::aes(color = .data$is_outlier), size = 2, alpha = 0.7) +
    ggplot2::scale_color_manual(values = c("FALSE" = color, "TRUE" = "red"), guide = "none") +
    ggplot2::labs(
      title = "Outlier Detection",
      subtitle = sprintf("%d/%d (%.1f%%) outlier%s found",
                         n_out,
                         length(clean_values),
                         100 * n_out / length(clean_values),
                         ifelse(n_out == 1, "", "s")),
      x = "Index", y = var_name
    ) +
    ggplot2::theme_minimal()

  # Add labels for outliers if not too many
  if (n_out > 0 && n_out <= 10) {
    scatter_plot <- scatter_plot + ggplot2::geom_text(
      data = plot_df[is_outlier, ],
      ggplot2::aes(label = outlier_indices),
      vjust = -0.8, size = 3, color = "red"
    )
  }

  # Create boxplot
  box_plot <- ggplot2::ggplot(data.frame(value = clean_values), ggplot2::aes(x = "", y = .data$value)) +
    ggplot2::stat_boxplot(geom = "errorbar", width = 0.1, coef = threshold) +
    ggplot2::geom_boxplot(outlier.color = "red", fill = color, alpha = 0.7, coef = threshold) +
    ggplot2::labs(
      title = "Boxplot with Outliers",
      subtitle = sprintf("Tukey's method (IQR x %.1f)", threshold),  # Fixed: removed ×
      x = "", y = var_name
    ) +
    ggplot2::theme_minimal()

  # Print summary
  cat(sprintf("\nOutlier Detection for '%s'\n\n", var_name))
  cat(sprintf("n: %d\n", length(clean_values)))
  cat(sprintf("Missing: %d (%.1f%%)\n", length(x_values) - length(clean_values),
              (length(x_values) - length(clean_values)) / length(x_values) * 100))
  cat(sprintf("Method: Tukey's IQR x %.1f\n", threshold))  # Fixed: removed ×
  cat(sprintf("Bounds: [%.2f, %.2f]\n", bounds["lower"], bounds["upper"]))
  cat(sprintf("Outliers detected: %d (%.1f%%)\n\n", n_out, 100 * n_out / length(clean_values)))

  if (n_out > 0) {
    shown <- if(n_out <= 20) outlier_indices else c(outlier_indices[1:10])
    cat(sprintf("Outlier indices: %s%s\n\n",
                paste(sort(shown), collapse = ", "),
                ifelse(n_out > 10, " (...)", "")))
  }

  # Display plots
  gridExtra::grid.arrange(scatter_plot, box_plot, ncol = 2)

  # Return results
  invisible(list(
    outliers = outlier_indices,
    bounds = bounds,
    stats = c(q1 = q[1], q3 = q[2], iqr = iqr),
    scatter_plot = scatter_plot,
    boxplot = box_plot
  ))
}
