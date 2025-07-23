# Functions that calculate effect sizes

# Calculate effect size for numeric variables
.calc_numeric_effect_size <- function(num_results) {
  groups <- num_results$groups
  if (any(lengths(groups) <= 1)) return(list(eff_size = NA, eff_param = NA))

  if (num_results$is_normal) {
    # Cohen's d
    n <- lengths(groups)
    vars <- sapply(groups, var)
    s_pooled <- sqrt(sum((n - 1) * vars) / sum(n - 2))
    d <- diff(sapply(groups, mean)) / s_pooled
    list(eff_size = abs(d), eff_param = "Cohen's d")
  } else {
    # Mann-Whitney U effect size (r)
    n_total <- sum(lengths(groups))
    W_val <- as.numeric(num_results$test_statistic)
    U_val <- W_val - lengths(groups)[1] * (lengths(groups)[1] + 1) / 2
    mean_U <- prod(lengths(groups)) / 2
    sd_U <- sqrt(prod(lengths(groups)) * (n_total + 1) / 12)
    z <- abs((U_val - mean_U) / sd_U)
    r <- z / sqrt(n_total)
    list(eff_size = r, eff_param = "r")
  }
}

# Calculate effect size for categorical variables
.calc_categorical_effect_size <- function(cat_results) {
  if (is.na(cat_results$test_p)) return(list(eff_size = NA, eff_param = NA))

  if (cat_results$use_fisher && cat_results$is_2x2) {
    # Odds ratio for 2x2 Fisher's exact test
    or <- tryCatch(as.numeric(cat_results$test_result$estimate), error = function(e) NA)
    list(eff_size = or, eff_param = "Odds Ratio")
  } else {
    # Cramer's V
    chi_val <- if (cat_results$use_fisher) cat_results$chi_statistic else cat_results$test_result$statistic
    n_total <- sum(cat_results$contingency)
    dims <- dim(cat_results$contingency)
    cramers_v <- sqrt(as.numeric(chi_val) / n_total / min(dims - 1))
    list(eff_size = cramers_v, eff_param = "Cramer's V")
  }
}
