test_that("clinical_data creates basic dataset correctly", {
  set.seed(123)
  result <- clinical_data()

  # Check structure and dimensions
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 300)  # 100 subjects * 3 visits
  expect_named(result, c("subject_id", "visit", "sex", "treatment",
                         "age", "weight", "biomarker", "response"))

  # Check data types and factor levels
  expect_type(result$subject_id, "character")
  expect_s3_class(result$sex, "factor")
  expect_equal(levels(result$sex), c("Male", "Female"))
  expect_s3_class(result$treatment, "factor")
  expect_equal(levels(result$treatment), c("Placebo", "Treatment"))
  expect_s3_class(result$response, "factor")
  expect_equal(levels(result$response), c("Complete", "Partial", "None"))
})

test_that("clinical_data handles different parameters correctly", {
  # Test multiple parameters in one call for efficiency
  set.seed(123)
  result <- clinical_data(n = 10, visits = 5, arms = c("A", "B", "C"))

  expect_equal(length(unique(result$subject_id)), 10)
  expect_equal(max(result$visit), 5)
  expect_equal(nrow(result), 50)  # 10 subjects * 5 visits
  expect_equal(levels(result$treatment), c("A", "B", "C"))
  expect_true(all(result$treatment %in% c("A", "B", "C")))
})

test_that("clinical_data produces reproducible results", {
  set.seed(42)
  result1 <- clinical_data()
  set.seed(42)
  result2 <- clinical_data()
  expect_identical(result1, result2)
})

test_that("clinical_data handles dropout and missing data", {
  set.seed(123)

  # Test dropout functionality
  result_dropout <- clinical_data(dropout_rate = 0.2, visits = 4)
  expect_true(any(is.na(result_dropout$biomarker)))
  expect_true(any(is.na(result_dropout$response)))

  # Test missing data functionality
  result_missing <- clinical_data(na_rate = 0.1)
  expect_true(any(is.na(result_missing$biomarker)))
  expect_true(any(is.na(result_missing$response)))
  expect_true(any(is.na(result_missing$weight)))

  # Verify no missing data when rates are 0
  result_no_missing <- clinical_data(dropout_rate = 0, na_rate = 0)
  expect_true(all(!is.na(result_no_missing[c("biomarker", "response", "weight")])))
})

test_that("clinical_data validates inputs correctly", {
  # Test boundary conditions and invalid inputs
  expect_error(clinical_data(n = 0), "n must be an integer between 1 and 999")
  expect_error(clinical_data(n = 1000), "n must be an integer between 1 and 999")
  expect_error(clinical_data(n = 1.5), "n must be an integer between 1 and 999")
  expect_error(clinical_data(visits = 0), "visits must be a positive integer")
  expect_error(clinical_data(visits = 1.5), "visits must be a positive integer")
  expect_error(clinical_data(arms = character(0)), "arms must be a character vector")
  expect_error(clinical_data(dropout_rate = -0.1), "dropout_rate must be between 0 and 1")
  expect_error(clinical_data(dropout_rate = 1.1), "dropout_rate must be between 0 and 1")
  expect_error(clinical_data(na_rate = 1.5), "na_rate must be between 0 and 1")
  expect_error(clinical_data(visits = 1, dropout_rate = 0.1), "Must have more than 1 visit when implementing dropout_rate.")
})

test_that("clinical_data maintains data integrity and shows treatment effects", {
  set.seed(123)
  result <- clinical_data(n = 50, visits = 3, arms = c("Placebo", "Low", "High"))

  # Check value ranges and format
  expect_true(all(nchar(result$subject_id) == 3))
  expect_true(all(grepl("^\\d{3}$", result$subject_id)))
  expect_true(all(result$age >= 18 & result$age <= 85))
  expect_true(all(result$weight >= 45 & result$weight <= 120))

  # Check visit sequence for first subject
  subj_visits <- result$visit[result$subject_id == "001"]
  expect_equal(subj_visits, 1:3)

  # Verify treatment effects (biomarker should decrease with treatment)
  biomarker_means <- aggregate(biomarker ~ treatment,
                               data = result[!is.na(result$biomarker), ],
                               FUN = mean)
  placebo_mean <- biomarker_means$biomarker[biomarker_means$treatment == "Placebo"]
  high_mean <- biomarker_means$biomarker[biomarker_means$treatment == "High"]
  expect_gt(placebo_mean, high_mean)
})

test_that("clinical_data works with edge cases", {
  set.seed(123)

  # Single subject, single visit
  result_minimal <- clinical_data(n = 1, visits = 1)
  expect_equal(nrow(result_minimal), 1)
  expect_equal(result_minimal$subject_id, "001")

  # Maximum n
  expect_silent(clinical_data(n = 999, visits = 1))
})
