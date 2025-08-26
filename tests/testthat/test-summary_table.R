test_that("summary_table basic functionality works", {
  set.seed(123)
  df <- clinical_data(n = 50, visits = 1)
  
  # Without grouping
  result1 <- suppressWarnings(summary_table(df, exclude = c("subject_id", "visit")))
  expect_s3_class(result1, "gt_tbl")
  result1_data <- result1$`_data`
  expect_true("variable" %in% names(result1_data))
  
  # With grouping
  result2 <- suppressWarnings(summary_table(df, group_by = "treatment", exclude = c("subject_id", "visit")))
  expect_s3_class(result2, "gt_tbl")
  result2_data <- result2$`_data`
  expect_true("p_value" %in% names(result2_data))
})

test_that("summary_table parameters work correctly", {
  set.seed(123)
  df <- clinical_data(n = 40, visits = 1)
  exclude_vars <- c("subject_id", "visit")
  
  # Normality tests
  result_sw <- suppressWarnings(summary_table(df, group_by = "treatment", normality_test = "S-W", exclude = exclude_vars))
  result_ks <- suppressWarnings(summary_table(df, group_by = "treatment", normality_test = "K-S", exclude = exclude_vars))
  expect_s3_class(result_sw, "gt_tbl")
  expect_s3_class(result_ks, "gt_tbl")
  
  # Effect sizes
  result_no_eff <- suppressWarnings(summary_table(df, group_by = "treatment", exclude = exclude_vars))
  result_with_eff <- suppressWarnings(summary_table(df, group_by = "treatment", effect_size = TRUE, exclude = exclude_vars))
  expect_false("effect_size" %in% names(result_no_eff$`_data`))
  expect_true("effect_size" %in% names(result_with_eff$`_data`))
  
  # All stats
  result_all <- suppressWarnings(summary_table(df, all = TRUE, exclude = exclude_vars))
  expect_s3_class(result_all, "gt_tbl")
})

test_that("summary_table input validation works", {
  df <- clinical_data(n = 20, visits = 1)
  
  # Data validation
  expect_error(summary_table("not_df"), "'data' must be a dataframe")
  expect_error(summary_table(data.frame()), "'data' cannot be empty")
  
  # Group validation
  expect_error(summary_table(df, group_by = "missing_var"), "not found in the data")
  df$three_groups <- sample(c("A", "B", "C"), nrow(df), replace = TRUE)
  expect_error(summary_table(df, group_by = "three_groups"), "exactly two groups")
  
  # Parameter validation
  expect_error(summary_table(df, normality_test = "invalid"), "must be either")
  expect_error(summary_table(df, exclude = 123), "must be a character vector")
  expect_error(summary_table(df, exclude = names(df)), "No variables remain")
})

test_that("summary_table handles edge cases", {
  set.seed(123)
  
  # Small sample
  small_df <- clinical_data(n = 5, visits = 1)
  result_small <- suppressWarnings(summary_table(small_df, exclude = c("subject_id", "visit")))
  expect_s3_class(result_small, "gt_tbl")
  
  # Missing data cleanup
  df_clean <- clinical_data(n = 30, visits = 1, missing = 0)
  df_missing <- clinical_data(n = 30, visits = 2, missing = 0.1)
  
  result_clean <- suppressWarnings(summary_table(df_clean, group_by = "treatment", exclude = c("subject_id", "visit")))
  result_missing <- suppressWarnings(summary_table(df_missing, group_by = "treatment", exclude = c("subject_id", "visit")))
  
  expect_false("NAs" %in% names(result_clean$`_data`))
  expect_true("NAs" %in% names(result_missing$`_data`))
})
