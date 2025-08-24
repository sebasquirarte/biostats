#' Statistical and Visual Normality Assessment 
#'
#' Tests normality using sample size-appropriate methods: Shapiro-Wilk test (n ≤ 50) 
#' or Kolmogorov-Smirnov test (n > 50) with Q-Q plots and histograms. Evaluates 
#' skewness and kurtosis using z-score criteria based on sample size. Automatically 
#' detects outliers and provides comprehensive visual and statistical assessment.
#'
#' @param data Data frame containing the variable.
#' @param x Variable name as character string or unquoted column name. Missing values removed.
#' @param outliers Logical; if TRUE, displays all outlier row indices. Default FALSE.
#' @param color Color for plots. Default "#79E1BE".
#'
#' @return
#' Prints results to console and invisibly returns a list with:
#' \item{shapiro}{Shapiro-Wilk test results}
#' \item{ks}{Kolmogorov-Smirnov test results (NULL if n <= 50)}
#' \item{skewness}{Sample skewness}
#' \item{kurtosis}{Sample excess kurtosis}
#' \item{skewness_z}{Z-score for skewness}
#' \item{kurtosis_z}{Z-score for kurtosis}
#' \item{normal}{Logical; TRUE if data appears normal}
#' \item{outliers}{Row indices of all outliers}
#' \item{extreme_outliers}{Row indices of most extreme outliers (labeled in plot)}
#' \item{qq_plot}{ggplot Q-Q plot object}
#' \item{hist_plot}{ggplot histogram object}
#'
#' @references
#' Mishra P, Pandey CM, Singh U, Gupta A, Sahu C, Keshri A. Descriptive statistics 
#' and normality tests for statistical data. Ann Card Anaesth. 2019 Jan-Mar;22(1):67-72. 
#' doi: 10.4103/aca.ACA_157_18. PMID: 30648682; PMCID: PMC6350423.
#'
#' @examples
#' # Simulated clinical data
#' clinical_df <- clinical_data()
#'
#' # Normally distributed variable
#' normality(clinical_df, "biomarker")
#'
#' # Non-normally distributed variable with outliers displayed
#' normality(clinical_df, "weight", outliers = TRUE)
#'
#' @importFrom stats shapiro.test ks.test ppoints qnorm dnorm density
#' @importFrom utils packageVersion
#' @importFrom rlang .data
#' @importFrom ggplot2 ggplot aes geom_ribbon geom_point geom_abline scale_color_manual labs theme_minimal geom_histogram stat_function scale_y_continuous expansion geom_text after_stat
#' @importFrom gridExtra grid.arrange
#' @export

normality <- function(data,
                      x,
                      outliers = FALSE,
                      color = "#79E1BE") {
  
  # Check required packages
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required but not installed. Please install it with: install.packages('ggplot2')")
  }
  if (!requireNamespace("gridExtra", quietly = TRUE)) {
    stop("Package 'gridExtra' is required but not installed. Please install it with: install.packages('gridExtra')")
  }
  
  # Validate data frame input
  if (!is.data.frame(data)) {
    stop("'data' must be a data frame.")
  }
  
  # Handle input and process data
  x_name <- deparse(substitute(x))
  if (is.character(substitute(x))) {
    x_name <- x
  }
  
  if (!x_name %in% names(data)) stop("Variable not found in data.")
  x <- data[[x_name]]
  
  x <- x[!is.na(x)]
  n <- length(x)
  if (n < 3) stop("Need at least 3 observations.")
  
  # Calculate basic statistics and tests
  mean_val <- mean(x); sd_val <- sd(x); median_val <- median(x); iqr_val <- IQR(x)
  
  # Handle constant data gracefully and perform appropriate normality tests
  sw_test <- tryCatch(
    shapiro.test(x),
    error = function(e) {
      if (grepl("identical", e$message)) {
        list(statistic = NA, p.value = NA, method = "Shapiro-Wilk normality test",
             data.name = "x (constant data)")
      } else {
        stop(e)
      }
    }
  )
  
  # Kolmogorov-Smirnov test for larger samples
  ks_test <- if (n > 50) {
    tryCatch(
      suppressWarnings(ks.test(x, "pnorm", mean = mean_val, sd = sd_val)),
      error = function(e) {
        list(statistic = NA, p.value = NA, method = "Kolmogorov-Smirnov test",
             data.name = "x")
      }
    )
  } else NULL
  
  # Calculate skewness and kurtosis with standard errors and z-scores
  centered <- x - mean_val
  m2 <- sum(centered^2) / n
  skewness <- sum(centered^3) / n / (m2^(3/2))
  kurtosis <- sum(centered^4) / n / (m2^2) - 3
  
  # Calculate standard errors and z-scores for skewness and kurtosis
  skewness_se <- sqrt(6 * n * (n - 1) / ((n - 2) * (n + 1) * (n + 3)))
  kurtosis_se <- sqrt(24 * n * (n - 1)^2 / ((n - 3) * (n - 2) * (n + 3) * (n + 5)))
  
  skewness_z <- if (n >= 3) skewness / skewness_se else NA
  kurtosis_z <- if (n >= 5) kurtosis / kurtosis_se else NA
  
  # Assessment and formatting using sample size-dependent criteria
  primary_test <- if (n > 50) ks_test else sw_test
  
  # Sample size-dependent normality assessment
  if (n < 50) {
    # Small samples: use z-score ± 1.96
    skew_kurt_normal <- (!is.na(skewness_z) && abs(skewness_z) <= 1.96) && 
      (!is.na(kurtosis_z) && abs(kurtosis_z) <= 1.96)
  } else if (n >= 50 && n < 300) {
    # Medium samples: use z-score ± 3.29
    skew_kurt_normal <- (!is.na(skewness_z) && abs(skewness_z) <= 3.29) && 
      (!is.na(kurtosis_z) && abs(kurtosis_z) <= 3.29)
  } else {
    # Large samples: use absolute values
    skew_kurt_normal <- abs(skewness) <= 2 && abs(kurtosis) <= 4
  }
  
  normal <- !is.na(primary_test$p.value) && primary_test$p.value > 0.05 && skew_kurt_normal
  
  # Format p-values for display
  sw_p_display <- if (is.na(sw_test$p.value)) "NA" else if (sw_test$p.value < 0.001) "< 0.001" else sprintf("%.3f", sw_test$p.value)
  ks_p_display <- if (n > 50) {
    if (is.na(ks_test$p.value)) "NA" else if (ks_test$p.value < 0.001) "< 0.001" else sprintf("%.3f", ks_test$p.value)
  } else NULL
  
  # Primary test display for plots
  primary_p_display <- if (n > 50) ks_p_display else sw_p_display
  primary_test_name <- if (n > 50) "Kolmogorov-Smirnov" else "Shapiro-Wilk"
  
  # QQ plot data with confidence bands and outlier detection
  y <- scale(x)
  if (length(unique(y)) == 1) {
    # Handle constant data - create minimal Q-Q plot data
    n <- length(x)
    theoretical <- qnorm(ppoints(n))
    qq_data <- data.frame(
      theoretical = theoretical,
      sample = as.numeric(y),
      upper = theoretical + 1,
      lower = theoretical - 1,
      is_outlier = rep(FALSE, n),
      is_extreme = rep(FALSE, n),
      row_num = seq_len(n)
    )
    outlier_indices <- integer(0)
    extreme_indices <- integer(0)
    outlier_mask <- rep(FALSE, n)
  } else {
    # Normal Q-Q plot calculations for variable data
    p <- ppoints(n)
    theoretical <- qnorm(p)
    se <- sqrt(p * (1 - p) / n) / dnorm(theoretical)
    conf_upper <- theoretical + se * qnorm(0.975)
    conf_lower <- theoretical - se * qnorm(0.975)
    
    # Find outliers and extreme outliers
    sorted_y <- sort(y)
    sorted_indices <- order(x)
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
      theoretical = theoretical,
      sample = sorted_y,
      upper = conf_upper,
      lower = conf_lower,
      is_outlier = outlier_mask,
      is_extreme = sorted_indices %in% extreme_indices,
      row_num = sorted_indices
    )
  }
  
  # Create QQ plot
  qq_plot <- ggplot2::ggplot(qq_data, ggplot2::aes(x = .data$theoretical, y = .data$sample)) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = .data$lower, ymax = .data$upper),
                         alpha = 0.2, fill = "grey70") +
    ggplot2::geom_point(ggplot2::aes(color = .data$is_outlier), size = 2, alpha = 0.6) +
    ggplot2::geom_abline(intercept = 0, slope = 1, color = "red", linetype = "dashed", linewidth = 1) +
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
                           color = "red", linetype = "dashed", linewidth = 1) +
    ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0, 0.05))) +
    ggplot2::labs(title = "Histogram with Normal Distribution",
                  subtitle = sprintf("%s: %s | Skewness: %.2f | Kurtosis: %.2f",
                                     primary_test_name, primary_p_display, skewness, kurtosis),
                  x = x_name, y = "Density") +
    ggplot2::theme_minimal()
  
  # Print results to console
  cat(sprintf("\nNormality Test for '%s' \n\n", x_name))
  cat(sprintf("n = %d \n", n))
  cat(sprintf("mean (SD) = %.2f (%.1f) \n", mean_val, sd_val))
  cat(sprintf("median (IQR) = %.2f (%.1f) \n\n", median_val, iqr_val))
  
  # Display appropriate test results based on sample size
  if (n > 50) {
    cat(sprintf("Kolmogorov-Smirnov: D = %.3f, p = %s \n", ks_test$statistic, ks_p_display))
    cat(sprintf("Shapiro-Wilk: W = %.3f, p = %s \n", sw_test$statistic, sw_p_display))
  } else {
    cat(sprintf("Shapiro-Wilk: W = %.3f, p = %s \n", sw_test$statistic, sw_p_display))
  }
  
  cat(sprintf("Skewness: %.2f (z = %.2f) \n", skewness, skewness_z))
  cat(sprintf("Kurtosis: %.2f (z = %.2f) \n\n", kurtosis, kurtosis_z))
  cat("Data appears", if (normal) "normally distributed." else "not normally distributed.", "\n")
  
  # Display outliers information
  if (length(outlier_indices) > 0) {
    if (outliers) {
      cat("\nOUTLIERS (row indices):", paste(outlier_indices, collapse = ", "), "\n\n")
    } else {
      cat(sprintf("\n(Use outliers = TRUE to see outliers [%d]). \n\n", length(outlier_indices)))
    }
  }
  
  # Display plots and return results
  gridExtra::grid.arrange(qq_plot, hist_plot, ncol = 2)
  
  invisible(list(
    shapiro = sw_test, ks = ks_test, skewness = skewness, kurtosis = kurtosis, 
    skewness_z = skewness_z, kurtosis_z = kurtosis_z, normal = normal,
    outliers = outlier_indices, extreme_outliers = extreme_indices,
    qq_plot = qq_plot, hist_plot = hist_plot
  ))
}