# Functions that perform statistical tests

# Perform statistical test for numeric variables
.test_numeric <- function(x, group_data, grp) {
  # Clean data by group
  groups <- lapply(grp, function(g) x[group_data == g & !is.na(x)])

  # Check if we have enough data
  if (any(lengths(groups) <= 1)) {
    return(list(
      test_used = "Insufficient data",
      test_p = NA,
      norm_str = "NA",
      is_normal = NA,
      test_statistic = NA,
      groups = groups
    ))
  }

  # Check normality
  norm_p <- sapply(groups, .check_normality)
  norm_str <- paste0("A: ", .format_p(norm_p[1]), ", B: ", .format_p(norm_p[2]))
  is_normal <- all(!is.na(norm_p) & norm_p > 0.05)

  # Perform test
  test_result <- tryCatch({
    if (is_normal) t.test(x ~ group_data) else wilcox.test(x ~ group_data)
  }, error = function(e) list(p.value = NA, statistic = NA))

  list(
    test_used = if (is_normal) "Welch t-test" else "Mann-Whitney U",
    test_p = test_result$p.value,
    norm_str = norm_str,
    is_normal = is_normal,
    test_statistic = test_result$statistic,
    groups = groups
  )
}

# Perform statistical test for categorical variables
.test_categorical <- function(x, group_data) {
  contingency <- table(x, group_data)

  if (min(dim(contingency)) < 2) {
    return(list(test_used = NA, test_p = NA, contingency = contingency))
  }

  # Determine test type
  chi_test <- tryCatch(suppressWarnings(chisq.test(contingency, correct = FALSE)),
                       error = function(e) list(expected = matrix(0), p.value = NA, statistic = NA))

  use_fisher <- any(chi_test$expected < 5)
  is_2x2 <- all(dim(contingency) == c(2, 2))

  # Perform appropriate test
  test_result <- tryCatch({
    if (use_fisher) {
      suppressWarnings(fisher.test(contingency, simulate.p.value = !is_2x2))
    } else chi_test
  }, error = function(e) list(p.value = NA, estimate = NA, statistic = NA))

  list(
    test_used = if (use_fisher) "Fisher" else "Chi-squared",
    test_p = test_result$p.value,
    contingency = contingency,
    use_fisher = use_fisher,
    is_2x2 = is_2x2,
    chi_statistic = chi_test$statistic,
    test_result = test_result
  )
}
