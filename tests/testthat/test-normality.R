test_that("normality basic functionality works", {
  set.seed(123)
  normal_data <- rnorm(100, mean = 50, sd = 10)

  # Test basic functionality - capture output but get return value
  capture.output({
    result <- normality(normal_data)
  })

  # Check return structure
  expect_type(result, "list")
  expect_named(result, c("shapiro", "skewness", "kurtosis", "normal",
                         "outliers", "extreme_outliers", "qq_plot", "hist_plot"))

  # Check individual components
  expect_s3_class(result$shapiro, "htest")
  expect_equal(result$shapiro$method, "Shapiro-Wilk normality test")
  expect_type(result$skewness, "double")
  expect_type(result$kurtosis, "double")
  expect_type(result$normal, "logical")
  expect_type(result$outliers, "integer")
  expect_type(result$extreme_outliers, "integer")
  expect_s3_class(result$qq_plot, "ggplot")
  expect_s3_class(result$hist_plot, "ggplot")
})

test_that("normality works with data frame input", {
  set.seed(123)
  clinical_df <- clinical_data(n = 50, visits = 1)

  # Test with data frame and variable name
  capture.output({
    result <- normality("age", data = clinical_df)
  })

  expect_type(result, "list")
  expect_s3_class(result$shapiro, "htest")
  expect_s3_class(result$qq_plot, "ggplot")
  expect_s3_class(result$hist_plot, "ggplot")
})

test_that("normality input validation works", {
  clinical_df <- clinical_data(n = 20, visits = 1)

  # Test invalid variable name
  expect_error(normality("nonexistent", data = clinical_df),
               "Variable not found in data")

  # Test insufficient data
  expect_error(normality(c(1, 2)),
               "Need at least 3 observations")

  # Test all missing values
  expect_error(normality(c(NA, NA, NA, NA)),
               "Need at least 3 observations")
})

test_that("normality handles different data types", {
  set.seed(123)

  # Normal-ish data
  normal_data <- rnorm(50)
  capture.output({
    result_normal <- normality(normal_data)
  })
  expect_type(result_normal$normal, "logical")
  expect_false(is.na(result_normal$skewness))

  # Clearly non-normal data (discrete)
  clinical_df <- clinical_data(n = 100, visits = 4)
  capture.output({
    result_nonnormal <- normality("visit", data = clinical_df)
  })
  expect_false(result_nonnormal$normal)
  expect_lt(result_nonnormal$shapiro$p.value, 0.05)

  # Data with missing values
  data_with_na <- c(rnorm(30), NA, NA)
  capture.output({
    result_na <- normality(data_with_na)
  })
  expect_type(result_na, "list")
  expect_s3_class(result_na$shapiro, "htest")
})

test_that("normality handles constant data", {
  constant_data <- rep(5, 20)

  # Should handle constant data without crashing - suppress expected ggplot2 warning
  suppressWarnings({
    capture.output({
      result <- normality(constant_data)
    })
  })

  expect_type(result, "list")
  expect_true(is.na(result$shapiro$p.value))  # Should be NA for constant data
  expect_false(result$normal)  # Constant data is not normal
  expect_equal(length(result$outliers), 0)  # No outliers in constant data
})

test_that("normality custom parameters work", {
  set.seed(123)
  test_data <- c(rnorm(40), 5, -5)  # Add some outliers

  # Test custom color
  capture.output({
    result_color <- normality(test_data, color = "blue")
  })
  expect_s3_class(result_color$qq_plot, "ggplot")
  expect_s3_class(result_color$hist_plot, "ggplot")

  # Test outliers parameter (should produce different console output)
  result_no_outliers <- capture.output({
    normality(test_data, outliers = FALSE)
  })

  result_with_outliers <- capture.output({
    normality(test_data, outliers = TRUE)
  })

  # With outliers = TRUE should produce more output
  expect_true(length(result_with_outliers) >= length(result_no_outliers))
})

test_that("normality produces consistent results", {
  set.seed(456)
  test_data <- rnorm(40, mean = 100, sd = 15)

  # Same data should produce identical results
  capture.output({
    result1 <- normality(test_data)
  })

  capture.output({
    result2 <- normality(test_data)
  })

  expect_equal(result1$shapiro$statistic, result2$shapiro$statistic)
  expect_equal(result1$skewness, result2$skewness)
  expect_equal(result1$kurtosis, result2$kurtosis)
  expect_equal(result1$normal, result2$normal)
})

test_that("normality handles edge cases", {
  set.seed(123)

  # Minimum sample size
  min_data <- rnorm(3)
  capture.output({
    result_min <- normality(min_data)
  })
  expect_type(result_min, "list")
  expect_s3_class(result_min$shapiro, "htest")

  # Large sample size
  large_data <- rnorm(200)
  capture.output({
    result_large <- normality(large_data)
  })
  expect_type(result_large, "list")
  expect_s3_class(result_large$shapiro, "htest")
})

test_that("normality outlier detection works", {
  set.seed(123)
  # Create data with clear outliers
  data_with_outliers <- c(rnorm(50, mean = 0, sd = 1), c(-4, 4, -5, 5))

  capture.output({
    result <- normality(data_with_outliers)
  })

  # Should detect some outliers
  expect_type(result$outliers, "integer")
  expect_type(result$extreme_outliers, "integer")

  # Extreme outliers should be subset of all outliers
  if (length(result$extreme_outliers) > 0) {
    expect_true(all(result$extreme_outliers %in% result$outliers))
  }
})
