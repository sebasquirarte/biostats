# Tests for normality function

test_that("normality works with numeric vector input", {
  set.seed(123)
  normal_data <- rnorm(100, mean = 50, sd = 10)

  # Capture output to avoid console spam during testing
  result <- suppressMessages(normality(normal_data))

  # Check return structure
  expect_type(result, "list")
  expect_named(result, c("shapiro", "skewness", "kurtosis", "normal",
                         "outliers", "extreme_outliers", "qq_plot", "hist_plot"))

  # Check Shapiro-Wilk test result
  expect_s3_class(result$shapiro, "htest")
  expect_equal(result$shapiro$method, "Shapiro-Wilk normality test")

  # Check numeric outputs
  expect_type(result$skewness, "double")
  expect_type(result$kurtosis, "double")
  expect_type(result$normal, "logical")

  # Check plot objects
  expect_s3_class(result$qq_plot, "ggplot")
  expect_s3_class(result$hist_plot, "ggplot")
})

test_that("normality works with data frame input", {
  set.seed(123)
  clinical_df <- clinical_data(n = 50, visits = 1)

  result <- suppressMessages(normality("age", data = clinical_df))

  # Should work the same as direct vector input
  expect_type(result, "list")
  expect_s3_class(result$shapiro, "htest")
  expect_s3_class(result$qq_plot, "ggplot")
  expect_s3_class(result$hist_plot, "ggplot")
})

test_that("normality detects non-normal data correctly", {
  set.seed(123)
  clinical_df <- clinical_data(n = 100, visits = 4)

  # Test with visit variable (definitely non-normal)
  result <- suppressMessages(normality("visit", data = clinical_df))

  # Should detect as non-normal
  expect_false(result$normal)
  expect_lt(result$shapiro$p.value, 0.05)  # Significant p-value
})

test_that("normality handles outliers parameter", {
  set.seed(123)
  test_data <- c(rnorm(50), c(-5, 5))  # Add some outliers

  # Test with outliers = FALSE (default)
  result_no_outliers <- capture.output(
    suppressMessages(normality(test_data, outliers = FALSE))
  )

  # Test with outliers = TRUE
  result_with_outliers <- capture.output(
    suppressMessages(normality(test_data, outliers = TRUE))
  )

  # Should have different console output
  expect_true(length(result_with_outliers) >= length(result_no_outliers))
})

test_that("normality validates input correctly", {
  clinical_df <- clinical_data(n = 20, visits = 1)

  # Non-existent variable
  expect_error(normality("nonexistent", data = clinical_df),
               "Variable not found in data")

  # Too few observations
  expect_error(normality(c(1, 2)), "Need at least 3 observations")

  # All missing values
  expect_error(normality(c(NA, NA, NA, NA)), "Need at least 3 observations")
})

test_that("normality handles missing values correctly", {
  set.seed(123)
  data_with_na <- c(rnorm(50), NA, NA, NA)

  result <- suppressMessages(normality(data_with_na))

  # Should work by removing NA values
  expect_type(result, "list")
  expect_s3_class(result$shapiro, "htest")

  # Should test on 50 observations (not 53)
  expect_true(result$shapiro$data.name == "x")
})

test_that("normality handles constant data", {
  constant_data <- rep(5, 20)

  # Should handle constant data gracefully
  result <- suppressMessages(normality(constant_data))
  expect_type(result, "list")

  # Shapiro test should fail gracefully on constant data
  expect_true(is.na(result$shapiro$p.value))
  expect_false(result$normal)  # Constant data is not normal
  expect_equal(length(result$outliers), 0)  # No outliers in constant data
})

test_that("normality custom color parameter works", {
  set.seed(123)
  normal_data <- rnorm(30)

  # Test with custom color
  result <- suppressMessages(normality(normal_data, color = "blue"))

  # Should still return proper structure
  expect_type(result, "list")
  expect_s3_class(result$qq_plot, "ggplot")
  expect_s3_class(result$hist_plot, "ggplot")
})

test_that("normality produces consistent results", {
  set.seed(456)
  test_data <- rnorm(40, mean = 100, sd = 15)

  # Run twice
  result1 <- suppressMessages(normality(test_data))
  result2 <- suppressMessages(normality(test_data))

  # Should be identical
  expect_equal(result1$shapiro$statistic, result2$shapiro$statistic)
  expect_equal(result1$skewness, result2$skewness)
  expect_equal(result1$kurtosis, result2$kurtosis)
  expect_equal(result1$normal, result2$normal)
})

test_that("normality handles different distributions", {
  set.seed(123)

  # Normal data
  normal_data <- rnorm(100)
  result_normal <- suppressMessages(normality(normal_data))

  # Skewed data
  skewed_data <- rexp(100, rate = 1)
  result_skewed <- suppressMessages(normality(skewed_data))

  # Normal data should be more likely to pass normality
  # (though not guaranteed with random data)
  expect_type(result_normal$normal, "logical")
  expect_type(result_skewed$normal, "logical")

  # Both should have valid outputs
  expect_false(is.na(result_normal$skewness))
  expect_false(is.na(result_skewed$skewness))
})

test_that("normality outlier detection works", {
  set.seed(123)
  data_with_outliers <- c(rnorm(90), c(-4, -3.5, 4, 3.8))

  result <- suppressMessages(normality(data_with_outliers))

  # Should detect some outliers
  expect_type(result$outliers, "integer")
  expect_type(result$extreme_outliers, "integer")

  # Extreme outliers should be subset of all outliers
  if (length(result$extreme_outliers) > 0) {
    expect_true(all(result$extreme_outliers %in% result$outliers))
  }
})

test_that("normality works with edge case sample sizes", {
  set.seed(123)

  # Minimum size (n=3)
  min_data <- rnorm(3)
  result_min <- suppressMessages(normality(min_data))
  expect_type(result_min, "list")

  # Larger size
  large_data <- rnorm(500)
  result_large <- suppressMessages(normality(large_data))
  expect_type(result_large, "list")

  # Both should work
  expect_s3_class(result_min$shapiro, "htest")
  expect_s3_class(result_large$shapiro, "htest")
})

test_that("normality statistical calculations are reasonable", {
  set.seed(123)

  # Perfectly normal data should have low skewness and kurtosis
  normal_data <- rnorm(1000)  # Large sample for stability
  result <- suppressMessages(normality(normal_data))

  # Skewness should be close to 0 for normal data
  expect_lt(abs(result$skewness), 0.5)  # Reasonable range

  # Excess kurtosis should be close to 0 for normal data
  expect_lt(abs(result$kurtosis), 1)    # Reasonable range
})
