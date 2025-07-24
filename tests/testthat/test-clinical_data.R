test_that("clinical_data creates basic dataset correctly", {
  set.seed(123)
  result <- clinical_data()

  # Check structure
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 300)  # 100 subjects * 3 visits
  expect_equal(ncol(result), 8)

  # Check column names
  expected_cols <- c("subject_id", "visit", "sex", "treatment",
                     "age", "weight", "biomarker", "response")
  expect_named(result, expected_cols)

  # Check basic data types
  expect_type(result$subject_id, "character")
  expect_type(result$visit, "integer")
  expect_s3_class(result$sex, "factor")
  expect_s3_class(result$treatment, "factor")
  expect_s3_class(result$response, "factor")
})

test_that("clinical_data handles different parameters", {
  # Different sample size
  set.seed(123)
  result1 <- clinical_data(n = 10)
  expect_equal(length(unique(result1$subject_id)), 10)

  # Different visit count
  set.seed(123)
  result2 <- clinical_data(visits = 5)
  expect_equal(max(result2$visit), 5)
  expect_equal(nrow(result2), 100 * 5)

  # Different treatment arms
  set.seed(123)
  result3 <- clinical_data(arms = c("A", "B", "C"))
  expect_equal(levels(result3$treatment), c("A", "B", "C"))
  expect_true(all(result3$treatment %in% c("A", "B", "C")))
})

test_that("clinical_data produces consistent results with set.seed", {
  set.seed(42)
  result1 <- clinical_data()
  set.seed(42)
  result2 <- clinical_data()
  expect_identical(result1, result2)

  # Different seeds produce different results
  set.seed(43)
  result3 <- clinical_data()
  expect_false(identical(result1, result3))
})

test_that("clinical_data handles dropout correctly", {
  set.seed(123)
  result_no_dropout <- clinical_data(dropout_rate = 0)
  expect_true(all(!is.na(result_no_dropout$biomarker)))

  set.seed(123)
  result_with_dropout <- clinical_data(dropout_rate = 0.2, visits = 4)
  expect_true(any(is.na(result_with_dropout$biomarker)))
  expect_true(any(is.na(result_with_dropout$response)))
})

test_that("clinical_data handles missing data correctly", {
  set.seed(123)
  result_no_missing <- clinical_data(na_rate = 0)
  expect_true(all(!is.na(result_no_missing$biomarker)))

  set.seed(123)
  result_with_missing <- clinical_data(na_rate = 0.1)
  expect_true(any(is.na(result_with_missing$biomarker)))
  expect_true(any(is.na(result_with_missing$response)))
})

test_that("clinical_data validates inputs correctly", {
  # n validation
  expect_error(clinical_data(n = 0), "n must be an integer between 1 and 999")
  expect_error(clinical_data(n = 1000), "n must be an integer between 1 and 999")
  expect_error(clinical_data(n = 1.5), "n must be an integer between 1 and 999")
  expect_error(clinical_data(n = "100"), "n must be an integer between 1 and 999")
  expect_error(clinical_data(n = 1e12), "n must be an integer between 1 and 999")

  # visits validation
  expect_error(clinical_data(visits = 0), "visits must be a positive integer")
  expect_error(clinical_data(visits = 1.5), "visits must be a positive integer")

  # arms validation
  expect_error(clinical_data(arms = character(0)), "arms must be a character vector with at least one element")
  expect_error(clinical_data(arms = 123), "arms must be a character vector with at least one element")

  # rates validation
  expect_error(clinical_data(dropout_rate = -0.1), "dropout_rate must be between 0 and 1")
  expect_error(clinical_data(dropout_rate = 1.1), "dropout_rate must be between 0 and 1")
  expect_error(clinical_data(na_rate = 1.5), "na_rate must be between 0 and 1")
})

test_that("clinical_data maintains data integrity", {
  set.seed(123)
  result <- clinical_data(n = 50, visits = 4)

  # Check subject ID format
  expect_true(all(nchar(result$subject_id) == 3))
  expect_true(all(grepl("^\\d{3}$", result$subject_id)))

  # Check value ranges
  expect_true(all(result$age >= 18 & result$age <= 85))
  expect_true(all(result$weight >= 45 & result$weight <= 120))

  # Check factor levels
  expect_equal(levels(result$sex), c("Male", "Female"))
  expect_equal(levels(result$response), c("Complete", "Partial", "None"))

  # Check visit sequence
  for (subj in unique(result$subject_id)[1:5]) {  # Test first 5 subjects
    subj_visits <- result$visit[result$subject_id == subj]
    expect_equal(subj_visits, seq_along(subj_visits))
  }
})

test_that("clinical_data shows treatment effects", {
  set.seed(123)
  result <- clinical_data(n = 100, arms = c("Placebo", "Low", "High"))

  # Calculate mean biomarker by treatment
  biomarker_means <- aggregate(biomarker ~ treatment,
                               data = result[!is.na(result$biomarker), ],
                               FUN = mean)

  # Should see decreasing biomarker: Placebo > Low > High
  placebo_mean <- biomarker_means$biomarker[biomarker_means$treatment == "Placebo"]
  high_mean <- biomarker_means$biomarker[biomarker_means$treatment == "High"]

  expect_gt(placebo_mean, high_mean)
})

test_that("clinical_data works with edge cases", {
  # Single subject
  set.seed(123)
  result_small <- clinical_data(n = 1, visits = 1)
  expect_equal(nrow(result_small), 1)
  expect_equal(unique(result_small$subject_id), "001")

  # Maximum n
  set.seed(123)
  expect_silent(clinical_data(n = 999, visits = 1))

  # High dropout rate
  set.seed(123)
  result_high_dropout <- clinical_data(dropout_rate = 0.9, visits = 3)
  expect_gt(mean(is.na(result_high_dropout$biomarker)), 0.4)

  # Single visit (no dropout possible)
  set.seed(123)
  result_single_visit <- clinical_data(visits = 1, dropout_rate = 0.5)
  expect_true(all(!is.na(result_single_visit$biomarker)))
})
