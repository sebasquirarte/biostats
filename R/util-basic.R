# Basic utility functions used throughout the package

# Check if a variable is constant
.is_constant <- function(x) length(unique(x[!is.na(x)])) == 1

# Test normality using Shapiro-Wilk test
.check_normality <- function(x) {
  if (!is.numeric(x) || length(x) < 3 || length(x) > 5000 || .is_constant(x)) return(NA)
  tryCatch(shapiro.test(x)$p.value, error = function(e) NA)
}

# Format p-values consistently
.format_p <- function(p) {
  if (is.na(p)) "NA" else if (p < 0.001) "< 0.001" else sprintf("%.3f", p)
}
