# Helper functions for summary_table

# Check if a variable is constant
.is_constant <- function(x) length(unique(na.omit(x))) <= 1

# Test normality using specified test
.check_normality <- function(x, test = 'S-W') {
  x_clean <- na.omit(x)
  if (!is.numeric(x) || length(x_clean) < 3 || .is_constant(x)) return(NA)
  
  tryCatch({
    if (test == 'S-W') {
      if (length(x_clean) > 5000) return(NA)
      shapiro.test(x_clean)$p.value
    } else if (test == 'K-S') {
      # K-S test against theoretical normal CDF
      ks.test(x_clean, "pnorm", mean(x_clean), sd(x_clean))$p.value
    } else NA
  }, error = function(e) NA)
}

# Format p-values consistently
.format_p <- function(p) {
  ifelse(is.na(p), "NA", ifelse(p < 0.001, "<0.001", sprintf("%.3f", p)))
}

# Create summary statistics for any variable type
.create_summary <- function(x, all = FALSE, use_median = FALSE) {
  if (length(x) == 0) return("No data")
  
  if (is.numeric(x)) {
    # Calculate only needed statistics
    if (all) {
      stats <- list(mean = mean(x, na.rm = TRUE), sd = sd(x, na.rm = TRUE))
      q <- quantile(x, c(0.25, 0.5, 0.75), na.rm = TRUE)
      r <- range(x, na.rm = TRUE)
      sprintf("Mean (SD): %.2f (%.1f); Median (IQR): %.2f (%.1f,%.1f); Range: %.2f,%.2f",
              stats$mean, stats$sd, q[2], q[1], q[3], r[1], r[2])
    } else if (use_median) {
      sprintf("Median (IQR): %.2f (%.2f)", median(x, na.rm = TRUE), IQR(x, na.rm = TRUE))
    } else {
      sprintf("Mean (SD): %.2f (%.2f)", mean(x, na.rm = TRUE), sd(x, na.rm = TRUE))
    }
  } else {
    # Categorical summary
    tab <- table(x)
    if (length(tab) == 0) return("No data")
    paste0(names(tab), ": ", tab, " (", sprintf("%.1f", 100 * tab / sum(tab)), "%)", collapse = "; ")
  }
}

# Main analysis function for a single variable
.analyze_variable <- function(x, group_data, grp, effect_size = FALSE, normality_test = 'S-W') {
  base_result <- list(test_used = NA, test_p = NA, norm_str = NA, eff_size = NA, eff_param = NA, is_normal = TRUE)
  
  if (.is_constant(x)) return(base_result)
  
  if (is.numeric(x)) {
    num_results <- .test_numeric(x, group_data, grp, normality_test)
    result <- num_results[c("test_used", "test_p", "norm_str", "is_normal")]
    if (effect_size) {
      eff_results <- .calc_effect_size(num_results, "numeric")
      result$eff_size <- eff_results$eff_size
      result$eff_param <- eff_results$eff_param
    }
  } else {
    cat_results <- .test_categorical(x, group_data)
    result <- base_result
    result$test_used <- cat_results$test_used
    result$test_p <- cat_results$test_p
    if (effect_size) {
      eff_results <- .calc_effect_size(cat_results, "categorical")
      result$eff_size <- eff_results$eff_size
      result$eff_param <- eff_results$eff_param
    }
  }
  return(result)
}

# Process single variable for analysis
.process_variable <- function(var, data, group_var = NULL, all = FALSE, 
                              effect_size = FALSE, normality_test = 'S-W') {
  x <- data[[var]]
  
  if (is.null(group_var)) {
    # Overall summary - check normality to decide mean vs median
    clean_x <- na.omit(x)
    if (is.numeric(clean_x) && length(clean_x) >= 3) {
      norm_p <- .check_normality(clean_x, normality_test)
      use_median <- !is.na(norm_p) && norm_p <= 0.05
      norm_value <- .format_p(norm_p)
    } else {
      use_median <- FALSE
      norm_value <- "NA"
    }
    
    data.frame(variable = var, n = length(x), NAs = sum(is.na(x)),
               summary = .create_summary(clean_x, all, use_median), normality = norm_value,
               stringsAsFactors = FALSE)
  } else {
    # Group comparison
    grp <- sort(unique(data[[group_var]]))
    groups <- lapply(grp, function(g) x[data[[group_var]] == g])
    clean_groups <- lapply(groups, function(g) g[!is.na(g)])
    
    test_results <- .analyze_variable(x, data[[group_var]], grp, effect_size, normality_test)
    use_median <- !test_results$is_normal && is.numeric(x)
    
    # Build data frame
    df_base <- data.frame(
      variable = var,
      n = paste0("A:", length(groups[[1]]), ", B:", length(groups[[2]])),
      NAs = paste0("A: ", sum(is.na(groups[[1]])), ", B: ", sum(is.na(groups[[2]]))),
      stringsAsFactors = FALSE
    )
    
    # Add group summaries
    grp_labeled <- paste0(grp, c(" (Group A)", " (Group B)"))
    df_base[[grp_labeled[1]]] <- .create_summary(clean_groups[[1]], all, use_median)
    df_base[[grp_labeled[2]]] <- .create_summary(clean_groups[[2]], all, use_median)
    
    # Add test results
    df_base$normality <- test_results$norm_str
    df_base$test <- test_results$test_used
    df_base$p_value <- .format_p(test_results$test_p)
    
    # Add effect size if requested
    if (effect_size) {
      df_base$effect_size <- if (is.na(test_results$eff_size)) NA else sprintf("%.2f", test_results$eff_size)
      df_base$effect_param <- test_results$eff_param
    }
    
    df_base
  }
}

# Calculate effect sizes
.calc_effect_size <- function(test_results, test_type = "numeric") {
  if (test_type == "numeric") {
    groups <- test_results$groups
    if (any(lengths(groups) <= 1)) return(list(eff_size = NA, eff_param = NA))
    
    if (test_results$is_normal) {
      # Cohen's d
      n <- lengths(groups)
      vars <- sapply(groups, var, na.rm = TRUE)
      s_pooled <- sqrt(sum((n - 1) * vars) / sum(n - 2))
      d <- abs(diff(sapply(groups, mean, na.rm = TRUE))) / s_pooled
      list(eff_size = d, eff_param = "Cohen's d")
    } else {
      # Mann-Whitney U effect size (r)
      n_total <- sum(lengths(groups))
      W_val <- as.numeric(test_results$test_statistic)
      U_val <- W_val - lengths(groups)[1] * (lengths(groups)[1] + 1) / 2
      z <- abs((U_val - prod(lengths(groups)) / 2) / sqrt(prod(lengths(groups)) * (n_total + 1) / 12))
      list(eff_size = z / sqrt(n_total), eff_param = "r")
    }
  } else {
    # Categorical effect sizes
    if (is.na(test_results$test_p)) return(list(eff_size = NA, eff_param = NA))
    
    if (test_results$use_fisher && test_results$is_2x2) {
      or <- tryCatch(as.numeric(test_results$test_result$estimate), error = function(e) NA)
      list(eff_size = or, eff_param = "Odds Ratio")
    } else {
      chi_val <- if (test_results$use_fisher) test_results$chi_statistic else test_results$test_result$statistic
      n_total <- sum(test_results$contingency)
      dims <- dim(test_results$contingency)
      cramers_v <- sqrt(as.numeric(chi_val) / n_total / min(dims - 1))
      list(eff_size = cramers_v, eff_param = "Cramer's V")
    }
  }
}

# Perform statistical test for numeric variables
.test_numeric <- function(x, group_data, grp, normality_test = 'S-W') {
  # Clean and prepare data once
  valid_idx <- !is.na(x) & !is.na(group_data)
  x_clean <- x[valid_idx]
  group_clean <- group_data[valid_idx]
  groups <- lapply(grp, function(g) x_clean[group_clean == g])
  
  # Check sufficient data
  if (any(lengths(groups) <= 1)) {
    return(list(test_used = "Insufficient data", test_p = NA, norm_str = "NA",
                is_normal = NA, test_statistic = NA, groups = groups))
  }
  
  # Test normality and perform appropriate test
  norm_p <- sapply(groups, .check_normality, test = normality_test)
  norm_str <- paste0("A:", .format_p(norm_p[1]), ", B:", .format_p(norm_p[2]))
  is_normal <- all(!is.na(norm_p) & norm_p > 0.05)
  
  test_result <- tryCatch({
    if (is_normal) t.test(x_clean ~ group_clean) else wilcox.test(x_clean ~ group_clean)
  }, error = function(e) list(p.value = NA, statistic = NA))
  
  list(test_used = if (is_normal) "Welch's t-test" else "Mann-Whitney U",
       test_p = test_result$p.value, norm_str = norm_str, is_normal = is_normal,
       test_statistic = test_result$statistic, groups = groups)
}

# Perform statistical test for categorical variables
.test_categorical <- function(x, group_data) {
  contingency <- table(x, group_data)
  
  if (min(dim(contingency)) < 2) {
    return(list(test_used = NA, test_p = NA, contingency = contingency))
  }
  
  # Determine and perform appropriate test
  chi_test <- tryCatch(suppressWarnings(chisq.test(contingency, correct = FALSE)),
                       error = function(e) list(expected = matrix(0), p.value = NA, statistic = NA))
  
  use_fisher <- any(chi_test$expected < 5)
  is_2x2 <- all(dim(contingency) == c(2, 2))
  
  test_result <- tryCatch({
    if (use_fisher) suppressWarnings(fisher.test(contingency, simulate.p.value = !is_2x2)) else chi_test
  }, error = function(e) list(p.value = NA, estimate = NA, statistic = NA))
  
  list(test_used = if (use_fisher) "Fisher" else "Chi-squared", test_p = test_result$p.value,
       contingency = contingency, use_fisher = use_fisher, is_2x2 = is_2x2,
       chi_statistic = chi_test$statistic, test_result = test_result)
}
