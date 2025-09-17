# Data organization
.data_organization <- function(data, y, x, paired_by) {
  
  # Arrange according to paired/unpaired study
  if (is.null(paired_by)) {
    # Independent groups: sort by 'x'
    data <- data[order(data[[x]]), , drop = FALSE]
  } else {
    # Repeated measures: sort by 'paired_by', then by 'x'
    data <- data[order(data[[paired_by]], data[[x]]), , drop = FALSE]
  }
  rownames(data) <- NULL
  return(data)
}

# Assumption evaluation with detailed output
.assumptions <- function(formula, y, x, data, paired_by, alpha, num_levels) {
  tryCatch({
    # Normality assessment using Shapiro-Wilk
    shapiroResults <- lapply(split(data[[y]], data[[x]]), shapiro.test)
    
    ## Calculate the test statistic and p value of the present normality
    normality_test.stat <- sapply(shapiroResults, function(x) as.numeric(x$statistic))
    normality_pvals <- sapply(shapiroResults, function(x) x$p.value)
    
    normality_key <- if (any(normality_pvals < alpha)) "significant" else "non_significant"
    
    # Homogeneity of variances assessment
    bartlett_results <- bartlett.test(formula, data = data)
    leveneResults <- leveneTest(formula, data = data)
    
    ## Calculate the test statistic and p value of the present homogeneity of variances
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
      #Cramer's V approximation for Bartlett's test
      n_total <- nrow(data)
      var_effect <- sqrt(var_stat / (n_total * (num_levels - 1)))
    }
    
    # Sphericity assessment
    sphericity_key <- NULL
    sph_stat <- NULL
    sph_pval <- NULL
    sph_effect <- NULL
    sph_df <- NULL
    
    ## Calculate the test statistic and p value of sphericity when possible
    if (!is.null(paired_by)) {
      order_eval <- data[[x]][1:num_levels]
      matrix <- matrix(data[[y]], ncol = num_levels, byrow = TRUE)
      mauchlyResults <- mauchly.test(lm(matrix ~ 1), X = ~ 1)
      
      sphericity_key <- if (mauchlyResults$p.value < alpha) "significant" else "non_significant"
      sph_stat <- mauchlyResults$statistic
      sph_pval <- mauchlyResults$p.value
      sph_df <- mauchlyResults$parameter
    }
    
    return(list(
      normality_key = normality_key,
      variance_key = variance_key,
      sphericity_key = sphericity_key,
      var.test = var.test,
      ### Detailed assumption results
      normality_results = list(
        test = "Shapiro-Wilk",
        statistics = normality_test.stat,
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
      sphericity_results = if (!is.null(paired_by)) list(
        test = "Mauchly",
        statistic = sph_stat,
        p_value = sph_pval,
        df = sph_df,
        key = sphericity_key
      ) else NULL
    ))
    
  }, # Try catch error
  error = function(e) {
    warning("Assumption evaluation failed: ", e$message)
  })
}

# Run post-hoc tests for omnibus_test
.post_hoc <- function(name, y, x, paired_by, p_method, alpha, model, data) {
  tryCatch({
    if(name == "One-way ANOVA") {
      post_hoc <- TukeyHSD(model, conf.level = 1 - alpha)
    } else {
      if (name == "Repeated measures ANOVA") {
        ## Paired pairwise comparison w/ t tests
        post_hoc <- suppressWarnings(pairwise.t.test(data[[y]], 
                                                     data[[x]], 
                                                     paired = TRUE, 
                                                     p.adjust.method = p_method))
      }
      
      if (name %in% c("Kruskal-Wallis", "Friedman")) {
        paired <- if (name == "Friedman") TRUE else FALSE
        ## Pairwise Wilcoxon tests with specified adjustment (paired and unpaired is possible)
        post_hoc <- suppressWarnings(pairwise.wilcox.test(data[[y]], 
                                                          data[[x]], 
                                                          paired = paired, 
                                                          p.adjust.method = p_method))
      }
    }
    
    post_hoc <- list(
                     post_hoc = post_hoc,
                     p_method = p_method
                    )
    
    return(post_hoc)
    
  }, # Try catch error
  error = function(e) {
    warning("Assumption evaluation failed: ", e$message)
  })
}

# Assumption output format print function
.print_assumptions <- function(results_assumptions, alpha) {
  cat("Assumption Testing Results:\n\n")
  
  ## Sphericity (when applicable)
  if (!is.null(results_assumptions$sphericity_results)) {
    sph <- results_assumptions$sphericity_results
    cat(sprintf("  Sphericity (%s Test):\n", sph$test))
    cat(sprintf("  W = %.4f, p = %s\n", 
                sph$statistic, .format_p(sph$p_value)))
    cat(sprintf("  Result: %s\n\n", 
                ifelse(sph$p_value < alpha, "Sphericity violated.", "Sphericity assumed.")))
  }
  
  ## Normality
  norm <- results_assumptions$normality_results
  cat(sprintf("  Normality (%s Test):\n", norm$test))
  group_names <- names(norm$statistics)
  for (i in seq_along(group_names)) {
    cat(sprintf("  %s: W = %.4f, p = %s\n", 
                group_names[i], norm$statistics[i], .format_p(norm$p_values[i])))
  }
  min_p <- min(norm$p_values)
  cat(sprintf("  Overall result: %s\n\n", 
              ifelse(norm$overall_key == "significant", "Non-normal distribution detected.", "Normal distribution assumed.")))
  
  ## Homogeneity of variance
  var <- results_assumptions$variance_results
  cat(sprintf("  Homogeneity of Variance (%s Test):\n", var$test))
  if (var$test == "Levene") {
    cat(sprintf("  F(%d,%d) = %.4f, p = %s\n", 
                var$df[1], var$df[2], var$statistic, .format_p(var$p_value)))
    cat(sprintf("  Effect size (eta-squared) = %.4f\n", var$effect_size))
  } else {
    cat(sprintf("  Chi-squared(%d) = %.4f, p = %s\n",
                var$df, var$statistic, .format_p(var$p_value)))
    cat(sprintf("  Effect size (Cramer's V) = %.4f\n", var$effect_size))
  }
  cat(sprintf("  Result: %s\n\n", 
              ifelse(var$key == "significant", "Heterogeneous variances.", "Homogeneous variances.")))
}
      
# Assumption output format print function
.print_post.hoc <- function(post_hoc, alpha, name, p_method) {
  cat("\nPost-hoc Multiple Comparisons\n\n")
  if (name == "One-way ANOVA") {
    ## Print Tukey results
    comparisons <- post_hoc$post_hoc[[1]]
    cat(sprintf("  Tukey Honest Significant Differences (alpha: %.3f):\n", alpha))
    cat(sprintf("  %-20s %8s %8s %8s %8s\n",
                "Comparison", "Diff", "Lower", "Upper", "p-adj"))
    cat(" ", strrep("-", 57), "\n")
    for (i in 1:nrow(comparisons)) {
      sig_flag <- ifelse(comparisons[i, "p adj"] < alpha, "*", " ")
      ### Format comparison name with spaces around dash
      comparison_name <- gsub("-", " - ", rownames(comparisons)[i])
      cat(sprintf("  %-20s %8.3f %8.3f %8.3f %8s%s\n",
                  comparison_name,
                  comparisons[i, "diff"],
                  comparisons[i, "lwr"],
                  comparisons[i, "upr"],
                  .format_p(comparisons[i, "p adj"]),
                  sig_flag))
    }
  } else {
        if (name == "Friedman") {
          cat(sprintf("  Paired pairwise Wilcoxon-tests (alpha: %.3f) (p_method: %s):\n", alpha, post_hoc$p_method))
        } else if (name == "Repeated measures ANOVA") {
          cat(sprintf("  Paired pairwise t-tests (alpha: %.3f) (p_method: %s):\n", alpha, post_hoc$p_method))
        } else {
          cat(sprintf("  Pairwise Wilcoxon-tests (alpha: %.3f) (p_method: %s):\n", alpha, post_hoc$p_method))
        }
      
        p_matrix <- post_hoc$post_hoc$p.value
        group_names <- rownames(p_matrix)
        col_names <- colnames(p_matrix)
        cat(sprintf("  %-12s", ""))
        for (col in col_names) cat(sprintf("%12s", col))
        cat("\n")
        for (i in 1:nrow(p_matrix)) {
          cat(sprintf("  %-12s", group_names[i]))
          for (j in 1:ncol(p_matrix)) {
            if (is.na(p_matrix[i, j])) {
              cat(sprintf("  %12s", "-"))
            } else {
              p_val <- p_matrix[i, j]
              sig_flag <- ifelse(p_val < alpha, "*", "")
              cat(sprintf("  %11s%s", .format_p(p_val), sig_flag))
            }
          }
          cat("\n")
        }
    }
}
