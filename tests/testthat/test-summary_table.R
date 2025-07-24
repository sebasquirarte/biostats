# Tests for summary_table function

test_that("summary_table works without grouping variable", {
  set.seed(123)
  clinical_df <- clinical_data(n = 50, visits = 2)

  result <- summary_table(clinical_df, exclude = c("subject_id", "visit"))

  # Check structure
  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true("variable" %in% names(result))
  expect_true("summary" %in% names(result))

  # Check that excluded variables are not present
  expect_false("subject_id" %in% result$variable)
  expect_false("visit" %in% result$variable)

  # Check that included variables are present
  expect_true("age" %in% result$variable)
  expect_true("treatment" %in% result$variable)
})

test_that("summary_table works with grouping variable", {
  set.seed(123)
  clinical_df <- clinical_data(n = 50, visits = 2)

  result <- summary_table(clinical_df,
                          group_var = "treatment",
                          exclude = c("subject_id", "visit"))

  # Check structure
  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true("variable" %in% names(result))
  expect_true("p_value" %in% names(result))
  expect_true("test" %in% names(result))

  # Should have columns for both treatment groups
  group_cols <- names(result)[grepl("Group", names(result))]
  expect_equal(length(group_cols), 2)
})

test_that("summary_table handles all_stats parameter", {
  set.seed(123)
  clinical_df <- clinical_data(n = 30, visits = 1)

  # Without all_stats
  result_basic <- summary_table(clinical_df, exclude = c("subject_id", "visit"))

  # With all_stats
  result_detailed <- summary_table(clinical_df,
                                   exclude = c("subject_id", "visit"),
                                   all_stats = TRUE)

  # Both should work
  expect_s3_class(result_basic, "data.frame")
  expect_s3_class(result_detailed, "data.frame")
  expect_equal(nrow(result_basic), nrow(result_detailed))
})

test_that("summary_table handles effect_size parameter", {
  set.seed(123)
  clinical_df <- clinical_data(n = 50, visits = 2)

  # Without effect size
  result_no_effect <- summary_table(clinical_df,
                                    group_var = "treatment",
                                    exclude = c("subject_id", "visit"))

  # With effect size
  result_with_effect <- summary_table(clinical_df,
                                      group_var = "treatment",
                                      exclude = c("subject_id", "visit"),
                                      effect_size = TRUE)

  # Check effect size columns
  expect_false("effect_size" %in% names(result_no_effect))
  expect_true("effect_size" %in% names(result_with_effect))
})

test_that("summary_table validates inputs correctly", {
  # Non-data frame input
  expect_error(summary_table("not_a_dataframe"), "Data must be a dataframe")

  # Invalid grouping variable
  clinical_df <- clinical_data(n = 20, visits = 1)
  expect_error(summary_table(clinical_df, group_var = "nonexistent"),
               "not found in the data")

  # More than 2 groups
  clinical_df$three_groups <- sample(c("A", "B", "C"), nrow(clinical_df), replace = TRUE)
  expect_error(summary_table(clinical_df, group_var = "three_groups"),
               "exactly two groups")
})

test_that("summary_table handles edge cases", {
  set.seed(123)
  clinical_df <- clinical_data(n = 20, visits = 1)

  # Empty data after exclusions
  expect_warning(
    summary_table(clinical_df, exclude = names(clinical_df)),
    "No variables remain"
  )

  # Very small dataset
  small_df <- clinical_df[1:5, ]
  result <- summary_table(small_df, exclude = c("subject_id", "visit"))
  expect_s3_class(result, "data.frame")
})

test_that("summary_table produces consistent results", {
  set.seed(456)
  clinical_df <- clinical_data(n = 40, visits = 2)

  # Run twice with same seed
  set.seed(789)
  result1 <- summary_table(clinical_df,
                           group_var = "treatment",
                           exclude = c("subject_id", "visit"))

  set.seed(789)
  result2 <- summary_table(clinical_df,
                           group_var = "treatment",
                           exclude = c("subject_id", "visit"))

  # Results should be identical
  expect_identical(result1, result2)
})

test_that("normality handles different variable types from clinical data", {
  set.seed(123)
  clinical_df <- clinical_data(n = 60, visits = 3)

  # Test with continuous variable (should work)
  result_age <- suppressMessages(normality("age", data = clinical_df))
  expect_type(result_age, "list")

  # Test with discrete variable (should work but likely non-normal)
  result_visit <- suppressMessages(normality("visit", data = clinical_df))
  expect_type(result_visit, "list")

  # Both should have valid results (even if Shapiro test fails)
  expect_type(result_age$shapiro, "list")
  expect_type(result_visit$shapiro, "list")
})

test_that("summary_table excludes variables correctly", {
  set.seed(123)
  clinical_df <- clinical_data(n = 30, visits = 1)

  # Test excluding multiple variables
  result <- summary_table(clinical_df,
                          exclude = c("subject_id", "visit", "age", "sex"))

  excluded_vars <- c("subject_id", "visit", "age", "sex")
  for (var in excluded_vars) {
    expect_false(var %in% result$variable)
  }

  # Should still have some variables
  expect_true(nrow(result) > 0)
})

test_that("summary_table group comparison produces expected output", {
  set.seed(123)
  clinical_df <- clinical_data(n = 60, visits = 1)

  result <- summary_table(clinical_df,
                          group_var = "treatment",
                          exclude = c("subject_id", "visit"))

  # Check required columns for group comparison
  required_cols <- c("variable", "n", "test", "p_value")
  for (col in required_cols) {
    expect_true(col %in% names(result),
                info = paste("Missing column:", col))
  }

  # Should have p-values (even if some are NA)
  expect_true("p_value" %in% names(result))

  # Should have test information
  expect_true("test" %in% names(result))
})
