# Run post-hoc tests for omnibus_test
.post_hoc <- function(name, y, x, paired_var, method, alpha, model, data,
                      normality_key, variance_key, sphericity_key) {
  if (grepl("ANOVA", name)) {
    tryCatch({
      if(grepl("One-way ANOVA", name)) {
        post_hoc <- TukeyHSD(model, conf.level = 1 - alpha)
        # Print Tukey results
        comparisons <- post_hoc[[1]]
        cat(sprintf("Tukey HSD (\u03b1 = %.3f):\n", alpha))
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
      } else if (grepl("Repeated measures ANOVA", name)) {
        # Pairwise comparison w/ emmeans
        options(contrasts = c("contr.sum", "contr.poly"))
        fit.emmeans <- emmeans(model, as.formula(paste("~", x)))
        post_hoc <- as.data.frame(pairs(fit.emmeans, adjust = "tukey"))
        cat("Pairwise comparison (Method: Tukey)\n")
        cat(sprintf("%-20s %10s\n", "Contrast", "p-value"))
        group_names <- post_hoc[, "contrast"]
        p_values <- post_hoc[, "p.value"]

        # Print results
        for (i in seq_along(group_names)) {
          p_val <- p_values[i]
          sig_flag <- ifelse(!is.na(p_val) && p_val < alpha, "*", "")
          cat(sprintf("%-20s %9s%s\n", group_names[i], .format_p(p_val), sig_flag))
        }
      }
    },  # Try catch error
    error = function(e) {
      warning("Post-hoc test failed: ", e$message)
    })
  } else {
    # Non ANOVA tests
    condition <- if (is.null(paired_var)) {
      normality_key == "non_significant" && variance_key == "non_significant"
    } else {
      normality_key == "non_significant" && variance_key == "non_significant" &&
        isTRUE(sphericity_key == "non_significant")
    }
    tryCatch({
      if (condition == TRUE) {
        # Parametric pairwise tests (t-tests)
        if (is.null(paired_var)) {
          # Pairwise t-tests with specified adjustment
          post_hoc <- suppressWarnings(pairwise.t.test(data[[y]], data[[x]], p.adjust.method = method))
          cat(sprintf("Pairwise t-tests (Correction: %s):\n", tools::toTitleCase(method)))
        } else {
          # Paired pairwise t-tests with specified adjustment
          post_hoc <- suppressWarnings(pairwise.t.test(data[[y]], data[[x]], paired = TRUE,p.adjust.method = method))
          cat(sprintf("Paired pairwise t-tests (Correction: %s):\n", tools::toTitleCase(method)))
        }
      } else {
        # Non parametric pairwise tests (Wilcoxon test)
        if (is.null(paired_var)) {
          # Pairwise Wilcoxon tests with specified adjustment
          post_hoc <- suppressWarnings(pairwise.wilcox.test(data[[y]], data[[x]], p.adjust.method = method))
          cat(sprintf("Pairwise Wilcoxon-tests (Correction: %s):\n", tools::toTitleCase(method)))
        } else {
          # Paired pairwise Wilcoxon tests with specified adjustment
          post_hoc <- suppressWarnings(pairwise.wilcox.test(data[[y]], data[[x]], paired = TRUE, p.adjust.method = method))
          cat(sprintf("Paired pairwise Wilcoxon-tests (Correction: %s):\n", tools::toTitleCase(method)))
        }
      }
    }, # Try catch error
    error = function(e) {
      warning("Post-hoc test failed: ", e$message)
    })

    # Format the results of previous tests
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
}
