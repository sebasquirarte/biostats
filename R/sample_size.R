#' Sample Size Calculation for Clinical Trials
#'
#' Calculates the sample size needed in a clinical trial based on study design
#' and statistical parameters using standard formulas for hypothesis testing (Chow, S. 2008).
#'
#' @param sample Character string indicating whether one or two samples need to be calculated.
#'   Options: "one-sample" or "two-sample".
#' @param design Character string indicating study design when sample = "two-sample".
#'   Options: "parallel" or "crossover". Default: NULL for one-sample tests.
#' @param outcome Character string indicating the type of outcome variable.
#'   Options: "mean" or "proportion".
#' @param type Character string indicating the type of hypothesis test.
#'   Options: "equality", "equivalence", "non-inferiority", or "superiority".
#' @param alpha Numeric parameter indicating the Type I error rate (significance level). Default: 0.05.
#' @param beta Numeric parameter indicating the Type II error rate (1 - power). Default: 0.20.
#' @param x1 Numeric value of the mean or proportion for group 1 (treatment group).
#' @param x2 Numeric value of the mean or proportion for group 2 (control group or reference value).
#' @param SD Numeric value indicating the standard deviation. Required for mean outcomes and crossover
#'   designs with proportion outcomes. Default: NULL.
#' @param delta Numeric value indicating the margin of clinical interest. Required for non-equality tests.
#'   Must be negative for non-inferiority and positive for superiority/equivalence. Default: NULL.
#' @param dropout Numeric value indicating the discontinuation rate expected in the study.
#'   Must be between 0 and 1. Default: 0.
#' @param k Numeric value indicating the allocation ratio (n1/n2) for two-sample tests. Default: 1.
#'
#' @return 
#' Prints calculation summary to console and invisibly returns a list containing 
#' sample size statistics, study parameters, and calculated z-scores.
#'
#' @references
#' Chow, S., Shao, J., & Wang, H. (2017). Sample Size Calculations in
#' Clinical Research (3rd ed.). Chapman & Hall/CRC.
#'
#' @examples
#' # Two-sample parallel non-inferiority test for means with 10% expected dropout
#' sample_size(sample = 'two-sample', design = 'parallel', outcome = 'mean',
#'             type = 'non-inferiority', x1 = 5.0, x2 = 5.0, 
#'             SD = 0.1, delta = -0.05, k = 1, dropout = 0.1)
#'             
#' # One-sample equivalence test for means
#' sample_size(sample = "one-sample", outcome = "mean", type = "equivalence",
#'             x1 = 0, x2 = 0, SD = 0.1, delta = 0.05)
#'
#' @importFrom stats qnorm
#' @export

sample_size <- function(sample = c("one-sample", "two-sample"),
                        design = NULL,
                        outcome = c("mean", "proportion"),
                        type = c("equality", "equivalence", "non-inferiority", "superiority"),
                        alpha = 0.05,
                        beta = 0.20,
                        x1 = NULL,
                        x2 = NULL,
                        SD = NULL,
                        delta = NULL,
                        dropout = 0,
                        k = 1) {
  
  # Input validation
  sample <- match.arg(sample)
  outcome <- match.arg(outcome)
  type <- match.arg(type)
  if (sample == "two-sample") {
    if (is.null(design)) stop("'design' must be specified for two-sample tests.", call. = FALSE)
    design <- match.arg(design, c("parallel", "crossover"))
  }
  if (is.null(x1) || is.null(x2)) stop("Both 'x1' and 'x2' must be specified.", call. = FALSE)
  if (!is.numeric(c(x1, x2, alpha, beta, dropout, k)) || 
      any(c(length(x1), length(x2), length(alpha), length(beta), length(dropout), length(k)) != 1)) {
    stop("Numeric parameters must be single values.", call. = FALSE)
  }
  if (alpha <= 0 || alpha >= 1) stop("'alpha' must be between 0 and 1.", call. = FALSE)
  if (beta <= 0 || beta >= 1) stop("'beta' must be between 0 and 1.", call. = FALSE)
  if (dropout < 0 || dropout >= 1) stop("'dropout' must be between 0 and 1.", call. = FALSE)
  if (k <= 0) stop("'k' must be positive.", call. = FALSE)
  if (outcome == "proportion" && (x1 < 0 || x1 > 1 || x2 < 0 || x2 > 1)) {
    stop("'x1' and 'x2' must be between 0 and 1 for proportion outcomes.", call. = FALSE)
  }
  needs_sd <- !(sample == "two-sample" && design == "parallel" && outcome == "proportion")
  if (needs_sd && is.null(SD)) stop("'SD' must be specified for this test configuration.", call. = FALSE)
  if (!needs_sd && !is.null(SD)) warning("'SD' is not needed for this test configuration.", call. = FALSE)
  if (!is.null(SD) && (!is.numeric(SD) || length(SD) != 1 || SD <= 0)) {
    stop("'SD' must be a positive single numeric value.", call. = FALSE)
  }
  if (type != "equality") {
    if (is.null(delta)) stop(sprintf("'delta' must be provided for %s tests.", type), call. = FALSE)
    if (!is.numeric(delta) || length(delta) != 1) stop("'delta' must be a single numeric value.", call. = FALSE)
    if (type == "non-inferiority" && delta >= 0) stop("'delta' must be negative for non-inferiority tests.", call. = FALSE)
    if (type %in% c("superiority", "equivalence") && delta <= 0) {
      stop(sprintf("'delta' must be positive for %s tests.", type), call. = FALSE)
    }
  } else if (!is.null(delta)) {
    warning("'delta' is not needed for equality tests.", call. = FALSE)
  }
  
  # Calculate z-scores and sample sizes
  z_alpha <- if (type == "equality") stats::qnorm(1 - alpha/2) else stats::qnorm(1 - alpha)
  z_beta <- if (type == "equivalence") stats::qnorm(1 - beta/2) else stats::qnorm(1 - beta)
  zscore <- (z_alpha + z_beta)^2
  
  diff <- x1 - x2
  margin <- switch(type,
                   equality = diff^2,
                   equivalence = (delta - abs(diff))^2,
                   `non-inferiority` = ,
                   superiority = (diff - delta)^2)
  if (sample == "two-sample" && design == "crossover") margin <- margin * 2
  
  variance <- if (outcome == "proportion" && sample == "two-sample" && design == "parallel") {
    x1 * (1 - x1) / k + x2 * (1 - x2)
  } else if (outcome == "proportion" && sample == "one-sample") {
    x1 * (1 - x1)
  } else if (outcome == "mean" && sample == "two-sample" && design == "parallel") {
    SD^2 * (1 + 1/k)
  } else {
    SD^2
  }
  
  n2 <- ceiling(zscore * variance / margin)
  n1 <- if (sample == "two-sample" && design == "parallel") ceiling(k * n2) else n2
  
  if (dropout > 0) {
    n2 <- ceiling(n2 + (dropout * n2))
    n1 <- ceiling(n1 + (dropout * n1))
  }
  
  total <- if (sample == "one-sample") n2 else if (design == "parallel") n2 + n1 else 2 * n2
  
  if (!is.finite(n1) || !is.finite(n2) || !is.finite(total)) {
    stop("Sample size calculation resulted in infinite value. Check delta and group difference.", call. = FALSE)
  }
  
  # Print results
  cat(sprintf("\nSample Size Calculation\n\nTest type: %s\n", type))
  cat(sprintf("Design: %s\n", if (sample == "two-sample") sprintf("%s, %s", design, sample) else sample))
  cat(sprintf("Outcome: %s\n", outcome))
  cat(sprintf("Alpha (\u03b1): %.3f\n", alpha))
  cat(sprintf("Beta (\u03b2): %.3f\n", beta))
  cat(sprintf("Power: %.1f%%\n\n", (1 - beta) * 100))
  
  cat("Parameters:\n")
  cat(sprintf("x1 (treatment): %.3f\n", x1))
  cat(sprintf("x2 (control/reference): %.3f\n", x2))
  cat(sprintf("Difference (x1 - x2): %.3f\n", diff))
  if (!is.null(SD)) cat(sprintf("Standard Deviation (\u03c3): %.3f\n", SD))
  if (sample == "two-sample" && design == "parallel") cat(sprintf("Allocation Ratio (k): %.2f\n", k))
  if (!is.null(delta)) cat(sprintf("Delta (\u03b4): %.3f\n", delta))
  if (dropout > 0) cat(sprintf("Dropout rate: %.1f%%\n", dropout * 100))
  
  cat("\nRequired Sample Size\n")
  if (sample == "one-sample") {
    cat(sprintf("n = %d\n", total))
  } else {
    cat(sprintf("n1 = %d\nn2 = %d\n", n1, n2))
  }
  cat(sprintf("Total = %d\n", total))
  
  if (dropout > 0) {
    cat(sprintf("\nNote: Sample size increased by %.1f%% to account for potential dropouts.\n", dropout * 100))
  }
  cat("\n")
  
  # Return results invisibly
  invisible(list(n1 = n1, n2 = n2, total = total, sample = sample, design = design,
                 outcome = outcome, type = type, alpha = alpha, beta = beta,
                 x1 = x1, x2 = x2, SD = SD, delta = delta, dropout = dropout,
                 k = k, z_alpha = z_alpha, z_beta = z_beta, zscore = zscore
  ))
}
