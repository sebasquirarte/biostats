test_that("normality basic functionality works", {
  set.seed(123)
  clinical_df <- data.frame(normal_data = rnorm(100, mean = 50, sd = 10))
  
  # Test basic functionality - capture output but get return value
  capture.output({
    result <- normality(clinical_df, "normal_data")
  })
  
  # Check return structure (updated with new components)
  expect_type(result, "list")
  expect_named(result, c("shapiro", "ks", "skewness", "kurtosis", "skewness_z", "kurtosis_z", 
                         "normal", "outliers", "extreme_outliers", "qq_plot", "hist_plot"))
  
  # Check individual components
  expect_s3_class(result$shapiro, "htest")
  expect_s3_class(result$ks, "htest")  # Should have KS test for n=100
  expect_equal(result$shapiro$method, "Shapiro-Wilk normality test")
  expect_type(result$skewness, "double")
  expect_type(result$kurtosis, "double")
  expect_type(result$skewness_z, "double")  # New z-score
  expect_type(result$kurtosis_z, "double")  # New z-score
  expect_type(result$normal, "logical")
  expect_type(result$outliers, "integer")
  expect_type(result$extreme_outliers, "integer")
  expect_s3_class(result$qq_plot, "ggplot")
  expect_s3_class(result$hist_plot, "ggplot")
})

test_that("normality sample size-dependent test selection works", {
  set.seed(123)
  
  # Small sample (n < 50) - should use only Shapiro-Wilk
  small_df <- data.frame(data = rnorm(30))
  capture.output({
    result_small <- normality(small_df, "data")
  })
  expect_s3_class(result_small$shapiro, "htest")
  expect_null(result_small$ks)  # No KS test for small samples
  
  # Large sample (n > 50) - should use both tests
  large_df <- data.frame(data = rnorm(100))
  capture.output({
    result_large <- normality(large_df, "data")
  })
  expect_s3_class(result_large$shapiro, "htest")
  expect_s3_class(result_large$ks, "htest")  # KS test for large samples
})

test_that("normality z-score calculations work correctly", {
  set.seed(123)
  clinical_df <- data.frame(test_data = rnorm(50, mean = 10, sd = 2))
  
  capture.output({
    result <- normality(clinical_df, "test_data")
  })
  
  # Z-scores should be calculated
  expect_type(result$skewness_z, "double")
  expect_type(result$kurtosis_z, "double")
  expect_false(is.na(result$skewness_z))
  expect_false(is.na(result$kurtosis_z))
  
  # Z-scores should be finite
  expect_true(is.finite(result$skewness_z))
  expect_true(is.finite(result$kurtosis_z))
})

test_that("normality input validation works", {
  clinical_df <- data.frame(age = rnorm(20), height = rnorm(20))
  
  # Test non-data.frame input
  expect_error(normality(c(1,2,3), "test"), "'data' must be a data frame")
  
  # Test invalid variable name
  expect_error(normality(clinical_df, "nonexistent"),
               "Variable not found in data")
  
  # Test insufficient data
  insufficient_df <- data.frame(small = c(1, 2))
  expect_error(normality(insufficient_df, "small"),
               "Need at least 3 observations")
  
  # Test all missing values
  na_df <- data.frame(missing = c(NA, NA, NA, NA))
  expect_error(normality(na_df, "missing"),
               "Need at least 3 observations")
})

test_that("normality handles different sample sizes appropriately", {
  set.seed(123)
  
  # Small sample - uses different z-score criteria
  small_df <- data.frame(data = rnorm(30))
  capture.output({
    result_small <- normality(small_df, "data")
  })
  expect_null(result_small$ks)  # No KS test
  
  # Medium sample
  medium_df <- data.frame(data = rnorm(100))
  capture.output({
    result_medium <- normality(medium_df, "data")
  })
  expect_s3_class(result_medium$ks, "htest")  # Has KS test
  
  # Large sample (>= 300)
  large_df <- data.frame(data = rnorm(350))
  capture.output({
    result_large <- normality(large_df, "data")
  })
  expect_s3_class(result_large$ks, "htest")  # Still has KS test
})

test_that("normality handles constant data", {
  constant_df <- data.frame(constant = rep(5, 20))
  
  # Should handle constant data without crashing
  suppressWarnings({
    capture.output({
      result <- normality(constant_df, "constant")
    })
  })
  
  expect_type(result, "list")
  expect_true(is.na(result$shapiro$p.value))  # Should be NA for constant data
  expect_false(result$normal)  # Constant data is not normal
  expect_equal(length(result$outliers), 0)  # No outliers in constant data
})

test_that("normality custom parameters work", {
  set.seed(123)
  test_df <- data.frame(data = c(rnorm(40), 5, -5))  # Add some outliers
  
  # Test custom color
  capture.output({
    result_color <- normality(test_df, "data", color = "blue")
  })
  expect_s3_class(result_color$qq_plot, "ggplot")
  expect_s3_class(result_color$hist_plot, "ggplot")
  
  # Test outliers parameter (should produce different console output)
  result_no_outliers <- capture.output({
    normality(test_df, "data", outliers = FALSE)
  })
  
  result_with_outliers <- capture.output({
    normality(test_df, "data", outliers = TRUE)
  })
  
  # With outliers = TRUE should produce more output
  expect_true(length(result_with_outliers) >= length(result_no_outliers))
})

test_that("normality produces consistent results", {
  set.seed(456)
  test_df <- data.frame(data = rnorm(40, mean = 100, sd = 15))
  
  # Same data should produce identical results
  capture.output({
    result1 <- normality(test_df, "data")
  })
  
  capture.output({
    result2 <- normality(test_df, "data")
  })
  
  expect_equal(result1$shapiro$statistic, result2$shapiro$statistic)
  expect_equal(result1$skewness, result2$skewness)
  expect_equal(result1$kurtosis, result2$kurtosis)
  expect_equal(result1$skewness_z, result2$skewness_z)
  expect_equal(result1$kurtosis_z, result2$kurtosis_z)
  expect_equal(result1$normal, result2$normal)
})

test_that("normality outlier detection works", {
  set.seed(123)
  # Create data with clear outliers
  outlier_df <- data.frame(data = c(rnorm(50, mean = 0, sd = 1), c(-4, 4, -5, 5)))
  
  capture.output({
    result <- normality(outlier_df, "data")
  })
  
  # Should detect some outliers
  expect_type(result$outliers, "integer")
  expect_type(result$extreme_outliers, "integer")
  
  # Extreme outliers should be subset of all outliers
  if (length(result$extreme_outliers) > 0) {
    expect_true(all(result$extreme_outliers %in% result$outliers))
  }
})

test_that("normality console output includes z-scores", {
  set.seed(123)
  test_df <- data.frame(data = rnorm(25))
  
  # Capture console output
  output <- capture.output({
    result <- normality(test_df, "data")
  })
  
  # Should include z-scores in output
  output_text <- paste(output, collapse = " ")
  expect_true(grepl("z =", output_text))  # Z-scores should be displayed
  
  # For small sample, should only show Shapiro-Wilk
  expect_false(grepl("Kolmogorov-Smirnov", output_text))
})

test_that("normality large sample shows both tests", {
  set.seed(123)
  test_df <- data.frame(data = rnorm(75))
  
  # Capture console output for large sample
  output <- capture.output({
    result <- normality(test_df, "data")
  })
  
  output_text <- paste(output, collapse = " ")
  # Should show both tests for medium/large samples
  expect_true(grepl("Kolmogorov-Smirnov", output_text))
  expect_true(grepl("Shapiro-Wilk", output_text))
})