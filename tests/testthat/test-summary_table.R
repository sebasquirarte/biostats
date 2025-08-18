test_that("summary_table works without grouping variable", {
  set.seed(123)
  clinical_df <- clinical_data(n = 50, visits = 2)
  
  result <- summary_table(clinical_df, exclude = c("subject_id", "visit"))
  
  expect_s3_class(result, "gt_tbl")
  result_data <- result$`_data`
  expect_true(nrow(result_data) > 0)
  expect_true("variable" %in% names(result_data))
  expect_false("subject_id" %in% result_data$variable)
  expect_true("age" %in% result_data$variable)
})

test_that("summary_table works with grouping variable", {
  set.seed(123)
  clinical_df <- clinical_data(n = 50, visits = 2)
  
  result <- summary_table(clinical_df, group_var = "treatment", 
                          exclude = c("subject_id", "visit"))
  
  expect_s3_class(result, "gt_tbl")
  result_data <- result$`_data`
  expect_true("p_value" %in% names(result_data))
})

test_that("summary_table handles all_stats parameter", {
  set.seed(123)
  clinical_df <- clinical_data(n = 30, visits = 1)
  
  result_basic <- summary_table(clinical_df, exclude = c("subject_id", "visit"))
  result_detailed <- summary_table(clinical_df, exclude = c("subject_id", "visit"), 
                                   all_stats = TRUE)
  
  expect_s3_class(result_basic, "gt_tbl")
  expect_s3_class(result_detailed, "gt_tbl")
})

test_that("summary_table handles effect_size parameter", {
  set.seed(123)
  clinical_df <- clinical_data(n = 50, visits = 2)
  
  result_no_effect <- summary_table(clinical_df, group_var = "treatment",
                                    exclude = c("subject_id", "visit"))
  result_with_effect <- summary_table(clinical_df, group_var = "treatment",
                                      exclude = c("subject_id", "visit"), 
                                      effect_size = TRUE)
  
  expect_false("effect_size" %in% names(result_no_effect$`_data`))
  expect_true("effect_size" %in% names(result_with_effect$`_data`))
})

test_that("summary_table validates inputs", {
  expect_error(summary_table("not_a_dataframe"), "Data must be a dataframe")
  
  clinical_df <- clinical_data(n = 20, visits = 1)
  expect_error(summary_table(clinical_df, group_var = "nonexistent"))
  
  clinical_df$three_groups <- sample(c("A", "B", "C"), nrow(clinical_df), replace = TRUE)
  expect_error(summary_table(clinical_df, group_var = "three_groups"))
})

test_that("summary_table handles edge cases", {
  set.seed(123)
  clinical_df <- clinical_data(n = 20, visits = 1)
  
  expect_warning(summary_table(clinical_df, exclude = names(clinical_df)))
  
  small_df <- clinical_df[1:5, ]
  result <- summary_table(small_df, exclude = c("subject_id", "visit"))
  expect_s3_class(result, "gt_tbl")
})

test_that("summary_table excludes variables", {
  set.seed(123)
  clinical_df <- clinical_data(n = 30, visits = 1)
  
  result <- summary_table(clinical_df, exclude = c("subject_id", "visit", "age"))
  result_data <- result$`_data`
  
  expect_false("age" %in% result_data$variable)
  expect_true(nrow(result_data) > 0)
})