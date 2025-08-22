# Assumption evaluation with detailed output
.assumptions <- function(formula, y, x, data, paired_var, alpha, num_levels) {
  tryCatch({
    # Normality assessment using Shapiro-Wilk
    shapiroResults <- lapply(split(data[[y]], data[[x]]), shapiro.test)
    
    # Calculate effect sizes for normality (W statistic as effect size proxy)
    normality_effects <- sapply(shapiroResults, function(x) x$statistic)
    normality_pvals <- sapply(shapiroResults, function(x) x$p.value)
    
    normality_key <- if (any(normality_pvals < alpha)) "significant" else "non_significant"
    
    # Homogeneity of variances assessment
    bartlett_results <- bartlett.test(formula, data = data)
    leveneResults <- leveneTest(formula, data = data)
    
    if (normality_key == "significant") {
      variance_key <- if (leveneResults$`Pr(>F)`[1] < alpha) "significant" else "non_significant"
      var.test <- "Levene"
      var_stat <- leveneResults$`F value`[1]
      var_pval <- leveneResults$`Pr(>F)`[1]
      var_df1 <- leveneResults$Df[1]
      var_df2 <- leveneResults$Df[2]
      # Eta-squared as effect size for Levene's test
      var_effect <- var_stat * var_df1 / (var_stat * var_df1 + var_df2)
    } else {
      variance_key <- if (bartlett_results$p.value < alpha) "significant" else "non_significant"
      var.test <- "Bartlett"
      var_stat <- bartlett_results$statistic
      var_pval <- bartlett_results$p.value
      var_df <- bartlett_results$parameter
      # Cramér's V approximation for Bartlett's test
      n_total <- nrow(data)
      var_effect <- sqrt(var_stat / (n_total * (num_levels - 1)))
    }
    
    # Sphericity assessment
    sphericity_key <- NULL
    sph_stat <- NULL
    sph_pval <- NULL
    sph_effect <- NULL
    sph_df <- NULL
    
    if (!is.null(paired_var)) {
      order_eval <- data[[x]][1:num_levels]
      matrix <- matrix(data[[y]], ncol = num_levels, byrow = TRUE)
      mauchlyResults <- mauchly.test(lm(matrix ~ 1), X = ~ 1)
      
      sphericity_key <- if (mauchlyResults$p.value < alpha) "significant" else "non_significant"
      sph_stat <- mauchlyResults$statistic
      sph_pval <- mauchlyResults$p.value
      sph_df <- mauchlyResults$parameter
      # W statistic itself serves as effect size measure for sphericity
      sph_effect <- sph_stat
    }
    
    return(list(
      normality_key = normality_key,
      variance_key = variance_key,
      sphericity_key = sphericity_key,
      var.test = var.test,
      # Detailed assumption results
      normality_results = list(
        test = "Shapiro-Wilk",
        statistics = normality_effects,
        p_values = normality_pvals,
        overall_key = normality_key
      ),
      variance_results = list(
        test = var.test,
        statistic = var_stat,
        p_value = var_pval,
        effect_size = var_effect,
        df = if (var.test == "Levene") c(var_df1, var_df2) else var_df,
        key = variance_key
      ),
      sphericity_results = if (!is.null(paired_var)) list(
        test = "Mauchly",
        statistic = sph_stat,
        p_value = sph_pval,
        effect_size = sph_effect,
        df = sph_df,
        key = sphericity_key
      ) else NULL
    ))
    
  }, # Try catch error
  error = function(e) {
    warning("Assumption evaluation failed: ", e$message)
  })
}

# Enhanced assumption output function
.print_assumptions <- function(results_assumptions, alpha) {
  cat("Assumption Testing Results:\n\n")
  
  # Sphericity (if applicable)
  if (!is.null(results_assumptions$sphericity_results)) {
    sph <- results_assumptions$sphericity_results
    cat(sprintf("  Sphericity (%s Test):\n", sph$test))
    cat(sprintf("  W = %.4f, df = %d, p = %s\n", 
                sph$statistic, sph$df, .format_p(sph$p_value)))
    cat(sprintf("  Effect size (W) = %.4f\n", sph$effect_size))
    cat(sprintf("  Result: %s\n\n", 
                ifelse(sph$p_value < alpha, "Sphericity violated", "Sphericity assumed")))
  }
  
  # Normality
  norm <- results_assumptions$normality_results
  cat(sprintf("  Normality (%s Test):\n", norm$test))
  group_names <- names(norm$statistics)
  for (i in seq_along(group_names)) {
    cat(sprintf("  %s: W = %.4f, p = %s\n", 
                group_names[i], norm$statistics[i], .format_p(norm$p_values[i])))
  }
  min_p <- min(norm$p_values)
  cat(sprintf("  Overall result: %s)\n\n", 
              ifelse(norm$overall_key == "significant", "Non-normal distribution detected", "Normal distribution assumed")))
  
  # Homogeneity of variance
  var <- results_assumptions$variance_results
  cat(sprintf("  Homogeneity of Variance (%s Test):\n", var$test))
  if (var$test == "Levene") {
    cat(sprintf("  F(%d,%d) = %.4f, p = %s\n", 
                var$df[1], var$df[2], var$statistic, .format_p(var$p_value)))
    cat(sprintf("  Effect size (η²) = %.4f\n", var$effect_size))
  } else {
    cat(sprintf("  χ²(%d) = %.4f, p = %s\n", 
                var$df, var$statistic, .format_p(var$p_value)))
    cat(sprintf("  Effect size (Cramér's V) = %.4f\n", var$effect_size))
  }
  cat(sprintf("  Result: %s\n\n", 
              ifelse(var$key == "significant", "Heterogeneous variances", "Homogeneous variances")))
}
