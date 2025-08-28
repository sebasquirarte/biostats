#' Statistical and Visual Normality Assessment 
#'
#' Tests normality using sample size-appropriate methods: Shapiro-Wilk test (n less than or 
#' equal to 50) or Kolmogorov-Smirnov test (n greater than 50) with Q-Q plots and histograms. 
#' Evaluates skewness and kurtosis using z-score criteria based on sample size. Automatically 
#' detects outliers and provides comprehensive visual and statistical assessment.
#'
#' @param data Dataframe containing the variables to be summarized.
#' @param x Character string indicating the variable to be analyzed.
#' @param all Logical parameter that displays all row indices of values outside 95% CI. Default: FALSE.
#' @param color Character string indicating color for plots. Default: "#79E1BE".
#'
#' @return
#' Prints results to console and invisibly returns a list with normality statistics and ggplot objects.
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
#' # Normally assesment of numerical variable
#' normality(clinical_df, "biomarker")
#'
#' # Normally assesment of numerical variable with points outside 95% CI displayed
#' normality(clinical_df, "weight", all = TRUE)
#'
#' @import ggplot2
#' @importFrom stats shapiro.test ks.test ppoints qnorm dnorm density
#' @importFrom rlang .data
#' @importFrom gridExtra grid.arrange
#' @export

normality <- function(data, 
                      x, 
                      all = FALSE, 
                      color = "#79E1BE") {
  
  # Package requirements and input validation
  required_pkgs <- c("ggplot2", "gridExtra")
  missing_pkgs <- required_pkgs[!sapply(required_pkgs, requireNamespace, quietly = TRUE)]
  if (length(missing_pkgs) > 0) {
    stop("Required packages not installed: ", paste(missing_pkgs, collapse = ", "), ".", call. = FALSE)
  }
  if (!is.data.frame(data)) stop("'data' must be a data frame.", call. = FALSE)
  if (!is.character(x)) stop("'x' must be a character string.", call. = FALSE)
  if (!x %in% names(data)) stop("Variable '", x, "' not found in data.", call. = FALSE)
  if (!is.numeric(data[[x]])) stop("Variable '", x, "' must be numeric.", call. = FALSE)
  x_vals <- data[[x]][!is.na(data[[x]])]
  n <- length(x_vals)
  if (n < 5) stop("Need at least 5 observations for complete normality assessment.", call. = FALSE)
  is_constant <- length(unique(x_vals)) == 1
  if (is_constant) stop("Data contains only constant values. Normality tests may be unreliable.", call. = FALSE)
  
  # Calculate basic statistics
  basic_stats <- c(mean = mean(x_vals), sd = sd(x_vals), median = median(x_vals), iqr = IQR(x_vals))
  
  # Perform normality tests with error handling
  sw_test <- tryCatch(shapiro.test(x_vals), error = function(e) {
    list(statistic = NA, p.value = NA, method = "Shapiro-Wilk normality test", data.name = "x")
  })
  
  ks_test <- if (n > 50) {
    tryCatch(suppressWarnings(ks.test(x_vals, "pnorm", mean = basic_stats["mean"], sd = basic_stats["sd"])),
             error = function(e) list(statistic = NA, p.value = NA, method = "Kolmogorov-Smirnov test", data.name = "x"))
  } else NULL
  
  # Calculate moments using standard formulas
  centered <- x_vals - basic_stats["mean"]
  m2 <- sum(centered^2) / n
  skewness <- if (m2 > 0) sum(centered^3) / n / (m2^(3/2)) else 0
  kurtosis <- if (m2 > 0) sum(centered^4) / n / (m2^2) - 3 else 0
  
  # Standard errors and z-scores (Mishra et al. 2019 formulas)
  skewness_se <- if (n >= 3) sqrt(6 * n * (n - 1) / ((n - 2) * (n + 1) * (n + 3))) else NA
  kurtosis_se <- if (n >= 5) sqrt(24 * n * (n - 1)^2 / ((n - 3) * (n - 2) * (n + 3) * (n + 5))) else NA
  skewness_z <- if (!is.na(skewness_se)) skewness / skewness_se else NA
  kurtosis_z <- if (!is.na(kurtosis_se)) kurtosis / kurtosis_se else NA
  
  # Normality assessment (sample size-dependent criteria)
  primary_test <- if (n > 50) ks_test else sw_test
  skew_kurt_normal <- if (n >= 300) {
    abs(skewness) <= 2 && abs(kurtosis) <= 4
  } else {
    z_thresh <- if (n < 50) 1.96 else 3.29
    (!is.na(skewness_z) && abs(skewness_z) <= z_thresh) && (!is.na(kurtosis_z) && abs(kurtosis_z) <= z_thresh)
  }
  normal <- !is.na(primary_test$p.value) && primary_test$p.value > 0.05 && skew_kurt_normal
  
  # Create Q-Q plot data and identify values outside 95% CI
  y <- scale(x_vals)
  if (is_constant) {
    theoretical <- qnorm(ppoints(n))
    qq_data <- data.frame(
      theoretical = theoretical, sample = as.numeric(y), upper = theoretical + 1, lower = theoretical - 1,
      is_outside = rep(FALSE, n), is_extreme = rep(FALSE, n), row_num = seq_len(n)
    )
    outside_indices <- extreme_indices <- integer(0)
  } else {
    p <- ppoints(n)
    theoretical <- qnorm(p)
    se <- sqrt(p * (1 - p) / n) / dnorm(theoretical)
    conf_upper <- theoretical + se * qnorm(0.975)
    conf_lower <- theoretical - se * qnorm(0.975)
    
    sorted_y <- sort(y)
    sorted_indices <- order(x_vals)
    outside_mask <- sorted_y < conf_lower | sorted_y > conf_upper
    outside_indices <- sorted_indices[outside_mask]
    
    extreme_indices <- if (any(outside_mask)) {
      deviation <- abs(sorted_y[outside_mask] - theoretical[outside_mask])
      extreme_positions <- which(outside_mask)[order(deviation, decreasing = TRUE)[1:min(4, sum(outside_mask))]]
      sorted_indices[extreme_positions]
    } else integer(0)
    
    qq_data <- data.frame(
      theoretical = theoretical, sample = sorted_y, upper = conf_upper, lower = conf_lower,
      is_outside = outside_mask, is_extreme = sorted_indices %in% extreme_indices, row_num = sorted_indices
    )
  }
  
  # Format p-values for display
  format_p <- function(p) if (is.na(p)) "NA" else if (p < 0.001) "< 0.001" else sprintf("%.3f", p)
  primary_p_display <- format_p(primary_test$p.value)
  primary_test_name <- if (n > 50) "Kolmogorov-Smirnov" else "Shapiro-Wilk"
  
  # Create Q-Q Plot
  qq_plot <- ggplot(qq_data, aes(x = .data$theoretical, y = .data$sample)) +
    geom_ribbon(aes(ymin = .data$lower, ymax = .data$upper), alpha = 0.2, fill = "grey70") +
    geom_point(aes(color = .data$is_outside), size = 2, alpha = 0.6) +
    geom_abline(intercept = 0, slope = 1, color = "red", linetype = "dashed", linewidth = 1) +
    scale_color_manual(values = c(color, "red"), guide = "none") +
    labs(title = "Normal Q-Q Plot",
                  subtitle = sprintf("Points outside 95%%CI: %d / %d (%.1f%%)",
                                     sum(qq_data$is_outside), n, 100 * sum(qq_data$is_outside) / n),
                  x = "Theoretical Quantiles", y = "Sample Quantiles") +
    theme_minimal()
  
  # Add extreme outside value labels if present
  if (length(extreme_indices) > 0) {
    extreme_data <- qq_data[qq_data$is_extreme, ]
    qq_plot <- qq_plot + geom_text(
      data = extreme_data, aes(x = .data$theoretical, y = .data$sample, label = .data$row_num),
      vjust = -0.8, size = 3
    )
  }
  
  # Create Histogram
  bins <- min(30, max(10, round(n/10)))
  hist_data <- data.frame(x = x_vals)
  
  hist_plot <- ggplot(hist_data, aes(x = .data$x)) +
    geom_histogram(aes(y = after_stat(density)),
                            bins = bins, fill = color, color = "white", alpha = 0.6) +
    stat_function(fun = dnorm, args = list(mean = basic_stats["mean"], sd = basic_stats["sd"]),
                           color = "red", linetype = "dashed", linewidth = 1) +
    scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
    labs(title = "Histogram with Normal Distribution",
                  subtitle = sprintf("%s: %s | Skewness: %.2f | Kurtosis: %.2f",
                                     primary_test_name, primary_p_display, skewness, kurtosis),
                  x = x, y = "Density") +
    theme_minimal()
  
  # Print results to console
  cat(sprintf("\nNormality Test for '%s' \n\n", x))
  cat(sprintf("n = %d \n", n))
  cat(sprintf("mean (SD) = %.2f (%.1f) \n", basic_stats["mean"], basic_stats["sd"]))
  cat(sprintf("median (IQR) = %.2f (%.1f) \n\n", basic_stats["median"], basic_stats["iqr"]))
  
  # Display test results based on sample size
  if (n > 50) {
    cat(sprintf("Kolmogorov-Smirnov: D = %.3f, p = %s \n", ks_test$statistic, format_p(ks_test$p.value)))
  }
  cat(sprintf("Shapiro-Wilk: W = %.3f, p = %s \n", sw_test$statistic, format_p(sw_test$p.value)))
  cat(sprintf("Skewness: %.2f (z = %.2f) \n", skewness, skewness_z))
  cat(sprintf("Kurtosis: %.2f (z = %.2f) \n\n", kurtosis, kurtosis_z))
  cat("Data appears", if (normal) "normally distributed.\n" else "not normally distributed.\n", "\n")
  
  # Display values outside 95% CI information
  if (length(outside_indices) > 0) {
    if (all) {
      cat("VALUES OUTSIDE 95% CI (row indices):", paste(outside_indices, collapse = ", "), "\n\n")
    } else {
      cat(sprintf("\n(Use all = TRUE to see values outside 95%%CI [%d]). \n\n", length(outside_indices)))
    }
  }
  
  # Display plots and return results
  grid.arrange(qq_plot, hist_plot, ncol = 2)
  invisible(list(normal = normal, outside_95CI = outside_indices,
                 qq_plot = qq_plot, hist_plot = hist_plot))
}
