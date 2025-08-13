# Evaluate assumptions
.assumptions <- function(formula, y, x, data, paired_var, alpha, num_levels) {
  tryCatch({
  # Normality assessment using Shapiro-Wilk
  shapiroResults <- lapply(split(data[[y]], data[[x]]), shapiro.test)
  
  normality_key <- if (any(sapply(shapiroResults, function(x) x$p.value < alpha))) "significant" else "non_significant"
  
  # Homogeneity of variances assessment
  bartlett_results <- bartlett.test(formula, data = data)
  leveneResults <- leveneTest(formula, data = data)
  
  if (normality_key == "significant") {
    variance_key <- if (leveneResults$`Pr(>F)`[1] < alpha) "significant" else "non_significant"
    var.test <- "Levene"
  } else {
    variance_key <- if (bartlett_results$p.value < alpha) "significant" else "non_significant"
    var.test <- "Bartlett"
  }
  
  # Sphericity assessment
  sphericity_key <- NULL
  if (!is.null(paired_var)) {
    order_eval <- data[[x]][1:num_levels]
    byrow_setting <- if (length(unique(order_eval)) == num_levels) TRUE else FALSE
    matrix <- matrix(data[[y]], ncol = num_levels, byrow = byrow_setting)
    mauchlyResults <- mauchly.test(lm(matrix ~ 1), X = ~ 1)
    
    sphericity_key <- if (mauchlyResults$p.value < alpha) "significant" else "non_significant"
  } 
  
  return(list(
          normality_key = normality_key,
          variance_key = variance_key,
          sphericity_key = sphericity_key,
          var.test = var.test
         ))
  
  }, # Try catch error
    error = function(e) {
    warning("Assumption evaluation failed: ", e$message)
  })
}

# Run post-hoc tests for omnibus_test
.post_hoc <- function(name, y, x, paired_var, method, alpha, model, data) {
  tryCatch({
      if(name == "One-way ANOVA") {
        post_hoc <- TukeyHSD(model, conf.level = 1 - alpha)
        # Print Tukey results
        comparisons <- post_hoc[[1]]
        cat(sprintf("Tukey Honest Significant Differences (\u03b1 = %.3f):\n", alpha))
        cat(sprintf("%-20s %8s %8s %8s %8s\n",
                    "Comparison", "Diff", "Lower", "Upper", "p-adj"))
        cat(strrep("-", 60), "\n")
        for (i in 1:nrow(comparisons)) {
          sig_flag <- ifelse(comparisons[i, "p adj"] < alpha, "*", " ")
          # Format comparison name with spaces around dash
          comparison_name <- gsub("-", " - ", rownames(comparisons)[i])
          cat(sprintf("%-20s %8.3f %8.3f %8.3f %8s%s\n",
                      comparison_name,
                      comparisons[i, "diff"],
                      comparisons[i, "lwr"],
                      comparisons[i, "upr"],
                      .format_p(comparisons[i, "p adj"]),
                      sig_flag))
        }
      } else {
        if (name == "Repeated measures ANOVA") {
            # Pairwise comparison w/ emmeans
            post_hoc <- suppressWarnings(pairwise.t.test(data[[y]], 
                                                            data[[x]], 
                                                            paired = FALSE, 
                                                            p.adjust.method = method))
        }
    
        if (name %in% c("Kruskal-Wallis", "Friedman")) {
           paired <- if (name == "Friedman") TRUE else FALSE
           # Pairwise Wilcoxon tests with specified adjustment (paired and unpaired is possible)
           post_hoc <- suppressWarnings(pairwise.wilcox.test(data[[y]], 
                                                             data[[x]], 
                                                             paired = paired, 
                                                             p.adjust.method = method))
        }
              
        if (name == "Friedman") {
          cat(sprintf("Paired pairwise Wilcoxon-tests (\u03b1 = %.3f) (Method: %s):\n", alpha, method))
        } else {
          cat(sprintf("Pairwise Wilcoxon-tests (\u03b1 = %.3f) (Method: %s):\n", alpha, method))
        }
          
        p_matrix <- post_hoc$p.value
        group_names <- rownames(p_matrix)
        col_names <- colnames(p_matrix)
        cat(sprintf("%-12s", ""))
        for (col in col_names) cat(sprintf("%12s", col))
          cat("\n")
        for (i in 1:nrow(p_matrix)) {
            cat(sprintf("%-12s", group_names[i]))
        for (j in 1:ncol(p_matrix)) {
          if (is.na(p_matrix[i, j])) {
            cat(sprintf("%12s", "-"))
          } else {
            p_val <- p_matrix[i, j]
            sig_flag <- ifelse(p_val < alpha, "*", "")
            cat(sprintf("%11s%s", .format_p(p_val), sig_flag))
          }
        }
    cat("\n")
      }
    }
  # Return results to main function
return(post_hoc)
}, # Try catch error
    error = function(e) {
      warning("Post-hoc test failed: ", e$message)
})
}
