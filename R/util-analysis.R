# Higher-level analysis functions

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

