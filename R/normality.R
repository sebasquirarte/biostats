#' Statistical and Visual Normality Assessment
#'
#' Tests normality using Shapiro-Wilk test with Q-Q plots and histograms.
#' Automatically detects outliers and provides comprehensive visual and
#' statistical assessment of data normality.
#'
#' @param x Numeric vector or variable name (if data provided). Missing values removed.
#' @param data Optional data frame containing the variable.
#' @param outliers Logical; if TRUE, displays all outlier row indices. Default FALSE.
#' @param color Color for plots. Default "#7fcdbb".
#'
#' @details
#' Combines Shapiro-Wilk test (p > 0.05) with skewness assessment (|skewness| < 1)
#' for robust normality evaluation. Q-Q plot includes 95% confidence bands for
#' outlier detection.
#'
#' @return
#' Prints results to console and invisibly returns a list with:
#' \item{shapiro}{Shapiro-Wilk test results}
#' \item{skewness}{Sample skewness}
#' \item{kurtosis}{Sample excess kurtosis}
#' \item{normal}{Logical; TRUE if data appears normal}
#' \item{outliers}{Row indices of all outliers}
#' \item{extreme_outliers}{Row indices of most extreme outliers (labeled in plot)}
#' \item{qq_plot}{ggplot Q-Q plot object}
#' \item{hist_plot}{ggplot histogram object}
#'
#' @note
#' Requires ggplot2 and gridExtra packages. Minimum 3 observations needed.
#' For n > 5000, consider alternative normality tests.
#'
#' @examples
#' clinical_df <- clinical_data()
#'
#' # Normal distribution (age)
#' normality("age", data = clinical_df)
#'
#' # Non-normal distribution (visit)
#' normality("visit", data = clinical_df)
#'
#' # With outliers displayed
#' normality("biomarker", data = clinical_df, outliers = TRUE)
#'
#' @importFrom stats shapiro.test ppoints qnorm dnorm density
#' @importFrom utils packageVersion
#' @importFrom rlang .data
#' @importFrom ggplot2 ggplot aes geom_ribbon geom_point geom_abline scale_color_manual labs theme_minimal geom_histogram stat_function scale_y_continuous expansion geom_text after_stat
#' @importFrom gridExtra grid.arrange
#' @export
normality <- function(x,
                      data = NULL,
                      outliers = FALSE,
                      color = "#7fcdbb") {

  # Check required packages
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required but not installed. Please install it with: install.packages('ggplot2')")
  }
  if (!requireNamespace("gridExtra", quietly = TRUE)) {
    stop("Package 'gridExtra' is required but not installed. Please install it with: install.packages('gridExtra')")
  }

  # Handle input and process data
  if (!is.null(data) && is.character(x)) {
    if (!x %in% names(data)) stop("Variable not found in data")
    x_name <- x; x <- data[[x]]
  } else {
    x_name <- deparse(substitute(x))
  }

  x <- x[!is.na(x)]
  n <- length(x)
  if (n < 3) stop("Need at least 3 observations")

  # Calculate basic statistics and tests
  mean_val <- mean(x); sd_val <- sd(x); median_val <- median(x); iqr_val <- IQR(x)
  sw_test <- shapiro.test(x)

  # Calculate skewness and kurtosis (simplified)
  centered <- x - mean_val
  m2 <- sum(centered^2) / n
  skewness <- sum(centered^3) / n / (m2^(3/2))
  kurtosis <- sum(centered^4) / n / (m2^2) - 3

  # Assessment and formatting
  normal <- sw_test$p.value > 0.05 && abs(skewness) < 1
  p_display <- if (sw_test$p.value < 0.001) "< 0.001" else sprintf("%.3f", sw_test$p.value)

  # QQ plot data with confidence bands and outlier detection
  y <- scale(x); p <- ppoints(n); theoretical <- qnorm(p)
  se <- sqrt(p * (1 - p) / n) / dnorm(theoretical)
  conf_upper <- theoretical + se * qnorm(0.975)
  conf_lower <- theoretical - se * qnorm(0.975)

  # Find outliers and extreme outliers
  sorted_y <- sort(y); sorted_indices <- order(x)
  outlier_mask <- sorted_y < conf_lower | sorted_y > conf_upper
  outlier_indices <- sorted_indices[outlier_mask]

  # Get up to 4 most extreme outliers for labeling
  extreme_indices <- if (any(outlier_mask)) {
    deviation <- abs(sorted_y[outlier_mask] - theoretical[outlier_mask])
    extreme_positions <- which(outlier_mask)[order(deviation, decreasing = TRUE)[1:min(4, sum(outlier_mask))]]
    sorted_indices[extreme_positions]
  } else integer(0)

  # Create QQ plot data
  qq_data <- data.frame(
    theoretical = theoretical, sample = sorted_y,
    upper = conf_upper, lower = conf_lower,
    is_outlier = outlier_mask,
    is_extreme = sorted_indices %in% extreme_indices,
    row_num = sorted_indices
  )

  # Create QQ plot using explicit .data$ notation
  qq_plot <- ggplot2::ggplot(qq_data, ggplot2::aes(x = .data$theoretical, y = .data$sample)) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = .data$lower, ymax = .data$upper),
                         alpha = 0.2, fill = "grey70") +
    ggplot2::geom_point(ggplot2::aes(color = .data$is_outlier), size = 2, alpha = 0.6) +
    ggplot2::geom_abline(intercept = 0, slope = 1, color = "red", linetype = "dashed", size = 1) +
    ggplot2::scale_color_manual(values = c(color, "red"), guide = "none") +
    ggplot2::labs(title = "Normal Q-Q Plot",
                  subtitle = sprintf("Points outside 95%%CI: %d / %d (%.1f%%)",
                                     sum(outlier_mask), n, 100 * sum(outlier_mask) / n),
                  x = "Theoretical Quantiles", y = "Sample Quantiles") +
    ggplot2::theme_minimal()

  # Add extreme outlier labels
  if (length(extreme_indices) > 0) {
    extreme_data <- qq_data[qq_data$is_extreme, ]
    qq_plot <- qq_plot +
      ggplot2::geom_text(data = extreme_data,
                         ggplot2::aes(x = .data$theoretical, y = .data$sample,
                                      label = .data$row_num),
                         vjust = -0.8, size = 3)
  }

  # Create histogram with normal overlay
  bins <- min(30, max(10, round(n/10)))

  # Create data frame for histogram
  hist_data <- data.frame(x = x)

  hist_plot <- ggplot2::ggplot(hist_data, ggplot2::aes(x = .data$x)) +
    ggplot2::geom_histogram(ggplot2::aes(y = ggplot2::after_stat(density)),
                            bins = bins, fill = color, color = "white", alpha = 0.6) +
    ggplot2::stat_function(fun = dnorm, args = list(mean = mean_val, sd = sd_val),
                           color = "red", linetype = "dashed", size = 1) +
    ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0, 0.05))) +
    ggplot2::labs(title = "Histogram with Normal Distribution",
                  subtitle = sprintf("Shapiro-Wilk: %s | Skewness: %.2f | Kurtosis: %.2f",
                                     p_display, skewness, kurtosis),
                  x = x_name, y = "Density") +
    ggplot2::theme_minimal()

  # Print results to console
  cat(sprintf("\nNormality Test for '%s' \n\n", x_name))
  cat(sprintf("n = %d \n", n))
  cat(sprintf("mean (SD) = %.2f (%.1f) \n", mean_val, sd_val))
  cat(sprintf("median (IQR) = %.2f (%.1f) \n\n", median_val, iqr_val))
  cat(sprintf("Shapiro-Wilk: W = %.3f, p = %s \n", sw_test$statistic, p_display))
  cat(sprintf("Skewness: %.2f \n", skewness))
  cat(sprintf("Kurtosis: %.2f \n\n", kurtosis))
  cat("Data is ", if (normal) "normally distributed." else "not normally distributed.", "\n")

  # Display outliers information
  if (length(outlier_indices) > 0) {
    if (outliers) {
      cat("\nOUTLIERS (row indices):", paste(outlier_indices, collapse = ", "), "\n\n")
    } else {
      cat(sprintf("(Use outliers = TRUE to see outliers [%d]). \n\n", length(outlier_indices)))
    }
  }

  # Display plots and return results
  gridExtra::grid.arrange(qq_plot, hist_plot, ncol = 2)

  invisible(list(
    shapiro = sw_test, skewness = skewness, kurtosis = kurtosis, normal = normal,
    outliers = outlier_indices, extreme_outliers = extreme_indices,
    qq_plot = qq_plot, hist_plot = hist_plot
  ))
}
