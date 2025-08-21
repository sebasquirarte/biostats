# Helper functions for summary_table

# Check if a variable is constant
.is_constant <- function(x) length(unique(x[!is.na(x)])) == 1

# Test normality using Shapiro-Wilk test
.check_normality <- function(x) {
  if (!is.numeric(x) || length(x) < 3 || length(x) > 5000 || .is_constant(x)) return(NA)
  tryCatch(shapiro.test(x)$p.value, error = function(e) NA)
}

# Format p-values consistently
.format_p <- function(p) {
  if (is.na(p)) "NA" else if (p < 0.001) "<0.001" else sprintf("%.3f", p)
}

# Create summary statistics for any variable type
.create_summary <- function(x, all_stats = FALSE, force_median = FALSE) {
  if (length(x) == 0) return("No data")
  
  if (is.numeric(x)) {
    stats <- list(
      mean = mean(x, na.rm = TRUE),
      median = median(x, na.rm = TRUE),
      sd = sd(x, na.rm = TRUE),
      iqr = IQR(x, na.rm = TRUE)
    )
    
    p_norm <- .check_normality(x)
    use_mean <- !force_median && !is.na(p_norm) && p_norm > 0.05
    
    if (all_stats) {
      q <- quantile(x, c(0.25, 0.75), na.rm = TRUE)
      r <- range(x, na.rm = TRUE)
      return(sprintf("Mean (SD): %.2f (%.1f); Median (IQR): %.2f (%.1f,%.1f); Range: %.2f,%.2f",
                     stats$mean, stats$sd, stats$median, q[1], q[2], r[1], r[2]))
    }
    
    if (use_mean) {
      sprintf("Mean (SD): %.2f (%.2f)", stats$mean, stats$sd)
    } else {
      sprintf("Median (IQR): %.2f (%.2f)", stats$median, stats$iqr)
    }
  } else {
    # Categorical summary
    tab <- table(x)
    if (length(tab) == 0) return("No data")
    
    paste(names(tab), ": ", tab, " (", sprintf("%.1f", 100 * tab / sum(tab)), "%)",
          sep = "", collapse = "; ")
  }
}

# Main analysis function for a single variable
.analyze_variable <- function(x, group_data, grp, effect_size = FALSE) {
  base_result <- list(test_used = NA, test_p = NA, norm_str = NA,
                      eff_size = NA, eff_param = NA, is_normal = TRUE)
  
  if (.is_constant(x)) return(base_result)
  
  if (is.numeric(x)) {
    num_results <- .test_numeric(x, group_data, grp)
    result <- num_results[c("test_used", "test_p", "norm_str", "is_normal")]
    
    if (effect_size) {
      eff_results <- .calc_numeric_effect_size(num_results)
      result$eff_size <- eff_results$eff_size
      result$eff_param <- eff_results$eff_param
    }
  } else {
    cat_results <- .test_categorical(x, group_data)
    result <- base_result
    result$test_used <- cat_results$test_used
    result$test_p <- cat_results$test_p
    
    if (effect_size) {
      eff_results <- .calc_categorical_effect_size(cat_results)
      result$eff_size <- eff_results$eff_size
      result$eff_param <- eff_results$eff_param
    }
  }
  
  return(result)
}

# Process single variable for analysis
.process_variable <- function(var, data, group_var = NULL, all_stats = FALSE, effect_size = FALSE) {
  x <- data[[var]]
  
  if (is.null(group_var)) {
    # Overall summary
    clean_x <- x[!is.na(x)]
    norm_value <- if (is.numeric(clean_x)) .format_p(.check_normality(clean_x)) else "NA"
    
    data.frame(
      variable = var,
      n = length(x),
      NAs = sum(is.na(x)),
      summary = .create_summary(clean_x, all_stats),
      normality = norm_value,
      stringsAsFactors = FALSE
    )
  } else {
    # Group comparison
    grp <- sort(unique(data[[group_var]]))
    groups <- lapply(grp, function(g) x[data[[group_var]] == g])
    
    test_results <- .analyze_variable(x, data[[group_var]], grp, effect_size)
    force_median <- !test_results$is_normal && is.numeric(x)
    
    # Create base data frame
    df <- data.frame(
      variable = var,
      n = paste0("A: ", length(groups[[1]]), ", B: ", length(groups[[2]])),
      NAs = paste0("A: ", sum(is.na(groups[[1]])), ", B: ", sum(is.na(groups[[2]]))),
      A = .create_summary(groups[[1]][!is.na(groups[[1]])], all_stats, force_median),
      B = .create_summary(groups[[2]][!is.na(groups[[2]])], all_stats, force_median),
      normality = test_results$norm_str,
      test = test_results$test_used,
      p_value = .format_p(test_results$test_p),
      stringsAsFactors = FALSE
    )
    
    # Add effect size columns if requested
    if (effect_size) {
      df$effect_size <- if (is.na(test_results$eff_size)) NA else sprintf("%.2f", test_results$eff_size)
      df$effect_param <- test_results$eff_param
    }
    
    # Update column names with group labels
    grp_labeled <- paste0(grp, c(" (Group A)", " (Group B)"))
    names(df)[names(df) %in% c("A", "B")] <- grp_labeled
    
    df
  }
}

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