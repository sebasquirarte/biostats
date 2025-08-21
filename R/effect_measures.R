#' Effect Measures
#
#' Calculates measures of effect: Odds Ratio (OR), Risk Ratio (RR),
#' Risk Reduction (RD) and either Number Needed to Treat (NNT) or 
#' Number Needed to Harm (NNH).
#'
#' @param data Numeric, data.frame, table, or matrix  
#'   For vectors, values should be provided as c(a, b, c, d) where:
#'   a = exposed with event, b = exposed without event,
#'   c = unexposed with event, d = unexposed without event.
#'   For matrices/tables/data.frames: rows represent exposure status 
#'   (exposed/unexposed), columns represent outcome (event/no event).
#'   
#' @param alpha Numeric.  
#'   Value between 0 and 1 specifying the alpha level for confidence intervals (CI). 
#'   Commonly used values are 0.05 (95% CI), 0.01 (99% CI), and 0.10 (90% CI).
#'   Default is 0.05.
#'
#' @param correction Logical.  
#'   If TRUE, a continuity correction (0.5) is applied when any cell contains 0.
#'   Default is FALSE.
#'
#' @return A list containing:
#' \describe{
#'   \item{contingency_table}{2x2 contingency table with proper labels}
#'   \item{odds_ratio}{Calculated odds ratio}
#'   \item{or_ci}{Named vector with lower and upper bounds of OR confidence interval}
#'   \item{risk_ratio}{Calculated risk ratio}
#'   \item{rr_ci}{Named vector with lower and upper bounds of RR confidence interval}
#'   \item{exposed_risk}{Risk in exposed group}
#'   \item{unexposed_risk}{Risk in unexposed group}
#'   \item{absolute_risk_diff}{Absolute risk difference}
#'   \item{nnt_nnh}{Number needed to treat (NNT) or number needed to harm (NNH)}
#' }
#'
#' @examples
#' \dontrun{
#' odds(data = c(15, 85, 5, 95))
#' }
#'
#' @export
effect_measures <- function(data, alpha = 0.05, correction = FALSE) {
  
  # Input validation
  if (missing(data)) stop("'data' argument is required")
  if (!is.logical(correction) || length(correction) != 1) stop("'correction' argument must be a single logical value (TRUE or FALSE).")
  if (any(is.na(data))) stop("NA values found in data.")
  if (any(data < 0)) stop("Negative values found in data.")
  if (!all(sapply(data, is.numeric)) || any(data != floor(data))) stop("Values in data must be of type numeric and integers.")
  # Extraction of corresponding values from data
  if (is.vector(data)) {
    if (length(data) != 4) stop("The vector must have 4 values (a, b, c, d) listed in that order.")
      a <- data[1] ; b <- data[2]
      c <- data[3] ; d <- data[4]
  } else if (is.data.frame(data) || is.table(data) || is.matrix(data)) {
      if (!all(dim(data) == c(2, 2))) stop("data.frame, table or matrix format must be 2x2.")
      a <- data[1, 1] ; b <- data[1, 2]
      c <- data[2, 1] ; d <- data[2, 2]
  } else {
    stop("'data' must be a numeric vector with 4 values, or a 2x2 data.frame, table or matrix.")
  }
  
  # First determine input type, then validate accordingly
  if (is.vector(data)) {
    if (!is.numeric(data) || any(data != floor(data))) stop("Vector must contain only numeric values")
  } else { 
    if (!all(sapply(as.vector(data), is.numeric)) || any(data != floor(data))) stop("All values must be numeric.")
  }
  # Problematic input validation
  problems <- c()
  has.zeroes <- any(data == 0)
  if (correction == TRUE) {
    if (has.zeroes) {
      a <- a + 0.5 ; b <- b + 0.5
      c <- c + 0.5 ; d <- d + 0.5
    } 
  } else {
      if (b == 0 || c == 0) problems <- c(problems, "odds ratio")
      if (c == 0) problems <- c(problems, "risk ratio")
      if ((all(c("odds ratio", "risk ratio") %in% problems))) {
        stop(paste0("Cannot calculate: ", 
                   paste(problems, collapse = ", "),". One or more zero values found in data."))
      }
  }
  
  # CI validation
  if (!is.numeric(alpha) || alpha < 0 || alpha > 1) stop("'alpha' argument must be a numeric value between 0 and 1.")
  if (is.null(alpha)) stop("No desired confidence level (\u03b1) specified.")
  # Calculate z-value for CI
  zval <- qnorm(1-alpha/2)

  # Calculate relative effect measures
  if (a + b == 0 || c + d == 0) stop("Can not calculate risks when total exposed (a + b) or total unexposed (c + d) equal zero.")
  exposed_risk <- a / (a + b)
  unexposed_risk <- c / (c + d)
  
  # Calculate absolute effect measures
  or <- (a * d) / (b * c)
  rr <- exposed_risk / unexposed_risk
  arr <- exposed_risk - unexposed_risk
  nnt <- if (arr != 0) 1 / abs(arr) else Inf
  
  # Calculate confidence intervals
  or_ci <- exp(log(or) + c(-1, 1) * zval * sqrt(1/a + 1/b + 1/c + 1/d))
  rr_ci <- exp(log(rr) + c(-1, 1) * zval * sqrt(b/(a*(a+b)) + d/(c*(c+d))))

  # Create results
  results <- list(
    contingency_table = matrix(c(a, c, b, d), nrow = 2,
      dimnames = list(c("Exposed", "Unexposed"),
                      c("Event", "No Event"))),
    odds_ratio = or,
    or_ci = setNames(or_ci, c("lower", "upper")),
    risk_ratio = rr,
    rr_ci = setNames(rr_ci, c("lower", "upper")),
    exposed_risk = exposed_risk,
    unexposed_risk = unexposed_risk,
    absolute_risk_diff = arr,
    nnt_nnh = nnt
  )
  
  # Print results
  cat("\nOdds/Risk Ratio Analysis\n\n")
  
  # Contingency table
  margined <- addmargins(results$contingency_table)
  cat("Contingency Table:\n")
  cat(sprintf("%12s %8s %8s %8s\n", "", "Event", "No Event", "Sum"))
  cat(sprintf("%-12s %8g %8g %8.0f\n", "Exposed", margined[1,1], margined[1,2], margined[1,3]))
  cat(sprintf("%-12s %8g %8g %8.0f\n", "Unexposed", margined[2,1], margined[2,2], margined[2,3]))
  cat(sprintf("%-12s %8.0f %8.0f %8.0f\n", "Sum", margined[3,1], margined[3,2], margined[3,3]))
  cat("\n")
  
  # Print measures
   if ("odds ratio" %in% problems) { # Possible for RR to exist when OR is not calculated but not viceversa.
     cat("Odds Ratio can not be calculated due to having one or more values equal 0.\n")
   } else {
     cat(sprintf("Odds Ratio: %.3f (%.0f%% CI: %.3f - %.3f)\n",
                 or, 100-(alpha*100), or_ci[1], or_ci[2]))
   }

  cat(sprintf("Risk Ratio: %.3f (%.0f%% CI: %.3f - %.3f)\n",
                rr, 100-(alpha*100), rr_ci[1], rr_ci[2]))

  
  cat(sprintf("\nRisk in exposed: %.1f%%\n", exposed_risk*100))
  cat(sprintf("Risk in unexposed: %.1f%%\n", unexposed_risk*100))
  cat(sprintf("Absolute risk difference: %.1f%%\n", arr*100))
  cat(sprintf("%s: %.1f\n\n",
              ifelse(arr > 0, "Number needed to harm (NNH)",
                     "Number needed to treat (NNT)"),
              abs(nnt)))
  
  # Notes about continuity correction
  if (!has.zeroes && correction) cat("Note: Continuity correction (0.5) was not applied due to no zero values.\n")
  if (has.zeroes && correction) cat("Note: Continuity correction (0.5) applied to all cells.\n")
  if (has.zeroes && !correction) cat("Note: Continuity correction (0.5) is recommended when one or more zero values are found in data.\n")
  
  cat("\n")
  invisible(results)
}
