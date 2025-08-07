#' Sample size calculation for clinical trials
#'
#' Calculates the sample size needed in a clinical trial based on study design
#' and statistical parameters.
#'
#' @param sample Character string. Whether one or two samples need to be calculated
#'   ("one-sample" or "two-sample").
#' @param design Character string. Study design when sample = "two-sample".
#'   Options: "parallel" or "crossover". Default is NULL for one-sample tests.
#' @param outcome Character string. Type of outcome variable ("mean" or "proportion").
#' @param type Character string. Type of hypothesis test ("equality", "equivalence",
#'   "non-inferiority", or "superiority").
#' @param alpha Numeric. Type I error rate (significance level). Default is 0.05.
#' @param beta Numeric. Type II error rate (1 - power). Default is 0.20.
#' @param x1 Numeric. Value of the mean or proportion for group 1 (treatment group).
#' @param x2 Numeric. Value of the mean or proportion for group 2 (control group
#'   or reference value).
#' @param SD Numeric. Standard deviation. Required for mean outcomes and crossover
#'   designs with proportion outcomes. Default is NULL.
#' @param delta Numeric. Margin of clinical interest. Required for non-equality tests.
#'   Must be negative for non-inferiority and positive for superiority/equivalence.
#'   Default is NULL.
#' @param dropout_rate Numeric. Study discontinuation rate expected in the study. Default is 0.
#' @param k Numeric. Allocation ratio (n1/n2) for two-sample tests. Default is 1.
#'
#' @return Invisibly returns a list containing:
#'   \item{n1}{Integer. Sample size for group 1 (or total sample size for one-sample tests).}
#'   \item{n2}{Integer. Sample size for group 2 (same as n for crossover designs).}
#'   \item{total}{Integer. Total sample size across all groups.}
#'   \item{sample}{Character string. Type of sampling method used ("one-sample" or "two-sample").}
#'   \item{design}{Character string. Study design for two-sample tests, such as "parallel" or "crossover".}
#'   \item{outcome}{Character string. Type of outcome variable ("mean" or "proportion").}
#'   \item{type}{Character string. Type of hypothesis test ("equality", "equivalence", "non-inferiority", or "superiority").}
#'   \item{alpha}{Numeric. Type I error rate (significance level).}
#'   \item{beta}{Numeric. Type II error rate (1 - power).}
#'   \item{x1}{Numeric. Value of the mean or proportion for group 1 (treatment group).}
#'   \item{x2}{Numeric. Value of the mean or proportion for group 2 (control group or reference value).}
#'   \item{SD}{Numeric. Standard deviation.}
#'   \item{delta}{Numeric. Margin of clinical interest.}
#'   \item{dropout_rate}{Numeric. Study discontinuation rate expected in the study.}
#'   \item{k}{Numeric. Allocation ratio (n1/n2) for two-sample tests.}
#'   \item{z_alpha}{Numeric. Z-score corresponding to the significance level alpha.}
#'   \item{z_beta}{Numeric. Z-score corresponding to the Type II error rate beta.}
#'   \item{zscore}{Numeric. Squared sum of z_alpha and z_beta, used for sample size calculation.}
#'
#' @references
#' Chow, S., Shao, J., & Wang, H. (2008). Sample Size Calculations in
#' Clinical Research (2nd ed.). Chapman & Hall/CRC.
#'
#' @examples
#' # One-sample equivalence test for means
#' sample_size(sample = 'one-sample',
#'             outcome = 'mean',
#'             type = 'equivalence',
#'             x1 = 0,
#'             x2 = 0,
#'             SD = 0.1,
#'             delta = 0.05,
#'             alpha = 0.05,
#'             beta = 0.20)
#' # Two-sample parallel non-inferiority test for proportions w/ 10% dropout rate
#' sample_size(sample = 'two-sample',
#'             design = "parallel",
#'             outcome = 'proportion',
#'             type = 'non-inferiority',
#'             x1 = 0.85,
#'             x2 = 0.65,
#'             alpha = 0.05,
#'             beta = 0.20,
#'             delta = -0.1,
#'             dropout_rate = 0.1)
#' # Two-sample crossover non-inferiority test for means
#' sample_size(sample = 'two-sample',
#'             design = "crossover",
#'             outcome = 'mean',
#'             type = 'non-inferiority',
#'             x1 = -0.10,
#'             x2 = 0,
#'             SD = 0.20,
#'             delta = -0.20,
#'             alpha = 0.05,
#'             beta = 0.20)
#' @export
sample_size <- function(sample = c('one-sample', 'two-sample'),
                        design = NULL,
                        outcome = c('mean', 'proportion'),
                        type = c('equality', 'equivalence', 'non-inferiority', 'superiority'),
                        alpha = 0.05,
                        beta = 0.20,
                        x1 = NULL,
                        x2 = NULL,
                        SD = NULL,
                        delta = NULL,
                        dropout_rate = 0,
                        k = 1) {
  # Input validation
  sample <- match.arg(sample)
  outcome <- match.arg(outcome)
  type <- match.arg(type)

  if (is.null(x1) || is.null(x2)) stop("Both x1 and x2 must be specified.")
  if (length(x1) > 1) stop("x1 must be a single value.")
  if (sample == "two-sample") {
    if (is.null(design)) stop("design must be specified for two-sample tests.")
  design <- match.arg(design, c('parallel', 'crossover'))
  }
  if (!(sample == 'two-sample' && design == 'parallel' && outcome == 'proportion') && is.null(SD)) stop("SD must be specified for this test configuration.")
  if ((sample == 'two-sample' && design == 'parallel' && outcome == 'proportion') && !is.null(SD)) warning("SD is not needed for this test configuration.")
  if (type != "equality") {
    if (is.null(delta)) stop(sprintf("delta must be provided for %s tests.", type))
    if (type == 'non-inferiority' && delta >= 0) stop("delta must be negative for non-inferiority tests.")
    if (type %in% c('superiority', 'equivalence') && delta <= 0) stop(sprintf("delta must be positive for %s tests.", type))
  } else {
    if (!is.null(delta)) {
      warning("delta is not needed for equality tests.")
    }
  }
  if (!is.numeric(beta) || beta <= 0 || beta >= 1) stop("beta must be a positive decimal bigger than 0 and less than 1.")
  if (!is.numeric(alpha) || alpha <= 0 || alpha >= 1) stop("alpha must be a positive decimal bigger than 0 and less than 1.")
  if (!is.numeric(dropout_rate) || dropout_rate < 0 || dropout_rate >= 1) stop("dropout_rate must be a positive decimal between 0 and 1.")

  # Calculate z-scores
  z_alpha <- if (type == 'equality') qnorm(1 - alpha/2) else qnorm(1 - alpha)
  z_beta <- if (type == 'equivalence') qnorm(1 - beta/2) else qnorm(1 - beta)
  zscore <- (z_alpha + z_beta)^2

  # Calculate margin
  diff <- x1 - x2
  margin <- switch(type,
                   equality = diff^2,
                   equivalence = (delta - abs(diff))^2,
                   `non-inferiority` = ,
                   superiority = (diff - delta)^2
  )
  if (sample == 'two-sample' && design == 'crossover') margin <- margin * 2

  # Calculate variance
  variance <- if (outcome == 'proportion' && sample == 'two-sample' && design == 'parallel') {
    x1 * (1 - x1) / k + x2 * (1 - x2)
  } else if (outcome == 'proportion' && sample == 'one-sample') {
    x1 * (1 - x1)
  } else if (outcome == 'mean' && sample == 'two-sample' && design == 'parallel') {
    SD^2 * (1 + 1/k)
  } else {
    SD^2
  }

  # Calculate sample sizes
  n2 <- ceiling(zscore * variance / margin)
  n1 <- if (sample == 'two-sample' && design == 'parallel') ceiling(k * n2) else n2

  if (dropout_rate != 0) {
    n2 <- ceiling(n2 + (dropout_rate * n2))
    n1 <- ceiling(n1 + (dropout_rate * n1))
  }

  total <- if (sample == 'one-sample') n2 else if (design == 'parallel') n2 + n1 else 2 * n2

  # Check for infinite and stop early
  if (!is.finite(n1) || !is.finite(n2) || !is.finite(total)) stop("Sample size calculation resulted in infinite or undefined value. Check delta and group difference.")

  # Print results
  cat("\nSample Size Calculation Summary\n\n")
  cat("Test type:", type, "\n")
  cat("Design:", if (sample == 'two-sample') sprintf("%s, %s\n", design, sample) else sprintf("%s\n", sample))
  cat("Outcome:", outcome, "\n")
  cat(sprintf("Alpha (\u03b1): %.2f\n", alpha))
  cat(sprintf("Beta (\u03b2): %.2f\n", beta))
  cat(sprintf("Power: %.0f%%\n\n", (1 - beta) * 100))

  cat("Parameters:\n")
  cat(sprintf("x1 (treatment): %.2f\n", x1))
  cat(sprintf("x2 (control/reference): %.2f\n", x2))
  cat(sprintf("Difference (x1 - x2): %.2f\n", diff))
  if (dropout_rate != 0) cat(sprintf("Dropout rate: %.0f%%\n", dropout_rate * 100))
  if (!is.null(SD)) cat(sprintf("Standard Deviation (\u03c3): %.2f\n", SD))
  if (sample == 'two-sample') cat(sprintf("Allocation Ratio (k): %.2f\n", k))
  if (!is.null(delta)) cat(sprintf("Delta (\u03b4): %.2f\n", delta))

  if (dropout_rate == 0) {
    cat("\nRequired Sample Size\n")
    if (sample == 'one-sample') {
      cat(sprintf("n = %d\n", total))
    } else {
      cat(sprintf("n1 = %d\n", n1))
      cat(sprintf("n2 = %d\n", n2))
    }
    cat(sprintf("Total = %d\n", total))
  } else {
    cat("\nRequired Sample Size*\n")
    if (sample == 'one-sample') {
      cat(sprintf("n = %.0f\n", n2))
    } else {
      cat(sprintf("n1 = %.0f\n", n1))
      cat(sprintf("n2 = %.0f\n", n2))
    }
    cat(sprintf("Total = %.0f\n\n", total))
    cat(sprintf("*Sample size inflated by %.0f%% to account for potential dropout.\n\n", dropout_rate * 100))
  }

  invisible(list(
    n1 = n1,
    n2 = n2,
    total = total,
    sample = sample,
    design = design,
    outcome = outcome,
    type = type,
    alpha = alpha,
    beta = beta,
    x1 = x1,
    x2 = x2,
    SD = SD,
    delta = delta,
    k = k,
    z_alpha = z_alpha,
    z_beta = z_beta,
    zscore = zscore
    )
  )
}
