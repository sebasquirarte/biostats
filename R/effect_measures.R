#' Effect Measures
#'
#' Calculates measures of effect: Odds Ratio (OR), Risk Ratio (RR), Risk Reduction (RD)
#' and either Number Needed to Treat (NNT) or Number Needed to Harm (NNH).
#'
#' @param exposed_event numeric. Number of events in the exposed group.
#' @param exposed_no_event numeric. Number of non-events in the exposed group.
#' @param unexposed_event numeric. Number of events in the unexposed group.
#' @param unexposed_no_event numeric. Number of non-events in the unexposed group.
#' @param alpha numeric. Value between 0 and 1 specifying the alpha level for 
#'   confidence intervals (CI). Default: 0.05.
#' @param correction Logical. If TRUE, a continuity correction (0.5) is applied 
#'   when any cell contains 0. Default: TRUE.
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
#' effect_measures(exposed_event = 15, 
#'                 exposed_no_event = 85,
#'                 unexposed_event = 5,
#'                 unexposed_no_event = 95)
#'
#' @export

effect_measures <- function(exposed_event, exposed_no_event,
                            unexposed_event, unexposed_no_event,
                            alpha = 0.05, correction = TRUE) {
  
  # Extract counts
  a <- exposed_event
  b <- exposed_no_event
  c <- unexposed_event
  d <- unexposed_no_event
  
  # Input validation
  data <- c(a, b, c, d)
  if (any(is.na(data))) stop("NA values found in data.")
  if (any(data < 0)) stop("Negative values found in data.")
  if (!is.numeric(data) || any(data != floor(data))) stop("Values must be numeric integers.")
  if (!is.logical(correction) || length(correction) != 1) stop("'correction' must be TRUE or FALSE.")
  
  # Problematic input validation
  problems <- c()
  has.zeroes <- any(data == 0)
  if (correction) {
    if (has.zeroes) {
      a <- a + 0.5 ; b <- b + 0.5
      c <- c + 0.5 ; d <- d + 0.5
    }
  } else {
    if (b == 0 || c == 0) problems <- c(problems, "odds ratio")
    if (c == 0) problems <- c(problems, "risk ratio")
    if (all(c("odds ratio", "risk ratio") %in% problems)) {
      stop(paste0("Cannot calculate: ", 
                  paste(problems, collapse = ", "),
                  ". One or more zero values found in data."))
    }
  }
  
  # CI validation
  if (!is.numeric(alpha) || alpha < 0 || alpha > 1) stop("'alpha' must be between 0 and 1.")
  zval <- qnorm(1 - alpha/2)
  
  # Calculate risks
  if (a + b == 0 || c + d == 0) stop("Cannot calculate risks when totals are zero.")
  exposed_risk <- a / (a + b)
  unexposed_risk <- c / (c + d)
  
  # Effect measures
  or <- (a * d) / (b * c)
  rr <- exposed_risk / unexposed_risk
  arr <- exposed_risk - unexposed_risk
  nnt <- if (arr != 0) 1 / abs(arr) else Inf
  
  # Confidence intervals
  or_ci <- exp(log(or) + c(-1, 1) * zval * sqrt(1/a + 1/b + 1/c + 1/d))
  rr_ci <- exp(log(rr) + c(-1, 1) * zval * sqrt(b/(a*(a+b)) + d/(c*(c+d))))
  
  # Results
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
  
  # Print summary
  cat("\nOdds/Risk Ratio Analysis\n\n")
  margined <- addmargins(results$contingency_table)
  cat("Contingency Table:\n")
  cat(sprintf("%12s %8s %8s %8s\n", "", "Event", "No Event", "Sum"))
  cat(sprintf("%-12s %8g %8g %8.0f\n", "Exposed", margined[1,1], margined[1,2], margined[1,3]))
  cat(sprintf("%-12s %8g %8g %8.0f\n", "Unexposed", margined[2,1], margined[2,2], margined[2,3]))
  cat(sprintf("%-12s %8.0f %8.0f %8.0f\n", "Sum", margined[3,1], margined[3,2], margined[3,3]))
  cat("\n")
  
  if ("odds ratio" %in% problems) {
    cat("Odds Ratio cannot be calculated due to zero values.\n")
  } else {
    cat(sprintf("Odds Ratio: %.3f (%.0f%% CI: %.3f - %.3f)\n",
                or, 100 - (alpha*100), or_ci[1], or_ci[2]))
  }
  
  cat(sprintf("Risk Ratio: %.3f (%.0f%% CI: %.3f - %.3f)\n",
              rr, 100 - (alpha*100), rr_ci[1], rr_ci[2]))
  
  cat(sprintf("\nRisk in exposed: %.1f%%\n", exposed_risk*100))
  cat(sprintf("Risk in unexposed: %.1f%%\n", unexposed_risk*100))
  cat(sprintf("Absolute risk difference: %.1f%%\n", arr*100))
  cat(sprintf("%s: %.1f\n\n",
              ifelse(arr > 0, "Number needed to harm (NNH)",
                     "Number needed to treat (NNT)"),
              abs(nnt)))
  
  if (!has.zeroes && correction) cat("Note: Correction not applied (no zero values).\n")
  if (has.zeroes && correction) cat("Note: Correction (0.5) applied to all cells.\n")
  if (has.zeroes && !correction) cat("Note: Correction (0.5) is recommended when zero values are present.\n")
  
  cat("\n")
  invisible(results)
}
