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
#' # Two-sample parallel non-inferiority test for means
#' sample_size(sample = 'two-sample',
#'             design = 'parallel',
#'             outcome = 'mean',
#'             type = 'non-inferiority',
#'             x1 = 5.0,
#'             x2 = 5.0,
#'             SD = 0.1,
#'             delta = -0.05,
#'             k = 1)
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
  needs_sd <- !(sample == 'two-sample' && design == 'parallel' && outcome == 'proportion')
  if (needs_sd && is.null(SD)) stop("SD must be specified for this test configuration.")
  if (type != "equality") {
    if (is.null(delta)) stop(sprintf("delta must be provided for %s tests", type))
    if (type == 'non-inferiority' && delta >= 0) stop("delta must be negative for non-inferiority.")
    if (type %in% c('superiority', 'equivalence') && delta <= 0) stop("delta must be positive.")
  }

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
  total <- if (sample == 'one-sample') n2 else if (design == 'parallel') n2 + n1 else 2 * n2

  # Print results
  cat("\nSample Size Calculation Summary\n\n")
  cat("Test type:", type, "\n")
  cat("Design:", if (sample == 'two-sample') paste(design, ",", sample) else sample, "\n")
  cat("Outcome:", outcome, "\n")
  cat(sprintf("Alpha (\u03b1): %.2f\n", alpha))
  cat(sprintf("Beta (\u03b2): %.2f\n", beta))
  cat(sprintf("Power: %.0f%%\n\n", (1 - beta) * 100))

  cat("Parameters:\n")
  cat(sprintf("x1: %.2f\n", x1))
  cat(sprintf("x2: %.2f\n", x2))
  cat(sprintf("Difference (x1 - x2): %.2f\n", diff))
  if (!is.null(SD)) cat(sprintf("Standard Deviation (\u03c3): %.2f\n", SD))
  if (sample == 'two-sample') cat(sprintf("Allocation Ratio (k): %.2f\n", k))
  if (!is.null(delta)) cat(sprintf("Delta (\u03b4): %.2f\n", delta))

  cat("\nRequired Sample Size:\n")
  if (sample == 'one-sample') {
    cat(sprintf("n = %d\n", total))
  } else {
    cat(sprintf("n1 = %d\n", n1))
    cat(sprintf("n2 = %d\n", n2))
  }
  cat(sprintf("Total = %d\n\n", total))

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
