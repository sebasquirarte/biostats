# Run post-hoc tests for omnibus_test
.post_hoc <- function(name, dependent_var, independent_var, paired_var, method, alpha, model, data, key1, key2, key3) {
             if (grepl("ANOVA", name)) {
              tryCatch({
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
             }, error = function(e) {
                 warning("Post-hoc test failed: ", e$message)
                })
            } else {
              condition <- if (is.null(paired_var)) {
                              key1 == "non_significant" && key2 == "non_significant"
                            } else {
                              key1 == "non_significant" && key2 == "non_significant" &&
                                isTRUE(key3 == "non_significant")
                            }

                if (condition == TRUE) {
                  if (missing(paired_var)) {
                  # Pairwise t-tests with specified adjustment
                    post_hoc <- pairwise.t.test(data[[dependent_var]], data[[independent_var]], p.adjust.method = method)
                    cat(sprintf("Pairwise t-tests (Correction: %s):\n", tools::toTitleCase(method)))
                  } else {
                    # Paired pairwise t-tests with specified adjustment
                    post_hoc <- pairwise.t.test(data[[dependent_var]], data[[independent_var]], paired = TRUE,p.adjust.method = method)
                    cat(sprintf("Paired pairwise t-tests (Correction: %s):\n", tools::toTitleCase(method)))
                  }
                  } else {
                    if (missing(paired_var)) {
                      # Pairwise Wilcoxon tests with specified adjustment
                      post_hoc <- suppressWarnings(pairwise.wilcox.test(data[[dependent_var]], data[[independent_var]], p.adjust.method = method))
                      cat(sprintf("Pairwise Wilcoxon-tests (Correction: %s):\n", tools::toTitleCase(method)))
                    } else {
                      # Paired pairwise Wilcoxon tests with specified adjustment
                      post_hoc <- suppressWarnings(pairwise.wilcox.test(data[[dependent_var]], data[[independent_var]], paired = TRUE, p.adjust.method = method))
                      cat(sprintf("Paired pairwise Wilcoxon-tests (Correction: %s):\n", tools::toTitleCase(method)))
                    }
                  }

              # Format the p-value
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

  return(post_hoc)
}
