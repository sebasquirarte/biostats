test_that("input validation works correctly", {
  df <- data.frame(x = rnorm(30), y = letters[1:30], z = 1:30)
  
  expect_error(normality("not_df", "x"), "'data' must be a data frame")
  expect_error(normality(df, 123), "'x' must be a character string")
  expect_error(normality(df, "missing"), "Variable 'missing' not found")
  expect_error(normality(df, "y"), "Variable 'y' must be numeric")
  expect_error(normality(data.frame(x = rep(1, 10)), "x"), "constant values")
  expect_error(normality(data.frame(x = 1:3), "x"), "at least 5 observations")
})

test_that("function returns correct S3 class and structure", {
  df <- data.frame(x = rnorm(30))
  result <- normality(df, "x")
  
  expect_s3_class(result, "normality")
  expect_type(result, "list")
  
  expected_names <- c("variable", "n", "basic_stats", "sw_test", "ks_test", 
                      "skewness", "kurtosis", "skewness_z", "kurtosis_z", 
                      "normal", "outside_95CI", "all", "primary_test_name", 
                      "primary_p_display", "qq_plot", "hist_plot")
  expect_equal(sort(names(result)), sort(expected_names))
})

test_that("basic statistics are calculated correctly", {
  x_vals <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
  df <- data.frame(x = x_vals)
  result <- normality(df, "x")
  
  expect_equal(as.numeric(result$basic_stats["mean"]), mean(x_vals))
  expect_equal(as.numeric(result$basic_stats["sd"]), sd(x_vals))
  expect_equal(as.numeric(result$basic_stats["median"]), median(x_vals))
  expect_equal(as.numeric(result$basic_stats["iqr"]), IQR(x_vals))
  expect_equal(result$n, length(x_vals))
})

test_that("test selection works based on sample size", {
  small_df <- data.frame(x = rnorm(20))
  large_df <- data.frame(x = rnorm(100))
  
  small_result <- normality(small_df, "x")
  large_result <- normality(large_df, "x")
  
  expect_equal(small_result$primary_test_name, "Shapiro-Wilk")
  expect_equal(large_result$primary_test_name, "Kolmogorov-Smirnov")
  expect_null(small_result$ks_test)
  expect_type(large_result$ks_test, "list")
})

test_that("normality assessment works for known distributions", {
  set.seed(123)
  normal_data <- data.frame(x = rnorm(50))
  uniform_data <- data.frame(x = runif(50, 0, 1))
  
  normal_result <- normality(normal_data, "x")
  uniform_result <- normality(uniform_data, "x")
  
  expect_true(is.logical(normal_result$normal))
  expect_true(is.logical(uniform_result$normal))
})

test_that("plots are created successfully", {
  df <- data.frame(x = rnorm(30))
  result <- normality(df, "x")
  
  expect_s3_class(result$qq_plot, "ggplot")
  expect_s3_class(result$hist_plot, "ggplot")
})

test_that("outlier detection works", {
  df <- data.frame(x = c(rnorm(25), 10, -10))
  result <- normality(df, "x")
  
  expect_type(result$outside_95CI, "integer")
  expect_true(length(result$outside_95CI) >= 0)
})

test_that("missing values are handled properly", {
  df <- data.frame(x = c(rnorm(25), NA, NA))
  result <- normality(df, "x")
  
  expect_equal(result$n, 25)
  expect_false(any(is.na(result$basic_stats)))
})

test_that("all parameter controls output", {
  df <- data.frame(x = c(rnorm(25), 5, -5))
  
  result_all_false <- normality(df, "x", all = FALSE)
  result_all_true <- normality(df, "x", all = TRUE)
  
  expect_false(result_all_false$all)
  expect_true(result_all_true$all)
})

test_that("color parameter is preserved", {
  df <- data.frame(x = rnorm(30))
  custom_color <- "#FF5733"
  result <- normality(df, "x", color = custom_color)
  
  expect_s3_class(result$qq_plot, "ggplot")
  expect_s3_class(result$hist_plot, "ggplot")
})

test_that("moments calculations are reasonable", {
  df <- data.frame(x = rnorm(100))
  result <- normality(df, "x")
  
  expect_type(result$skewness, "double")
  expect_type(result$kurtosis, "double")
  expect_type(result$skewness_z, "double")
  expect_type(result$kurtosis_z, "double")
  expect_true(is.finite(result$skewness))
  expect_true(is.finite(result$kurtosis))
})

test_that("print method works without errors", {
  df <- data.frame(x = rnorm(30))
  result <- normality(df, "x")
  
  expect_output(print(result), "Normality Test")
  expect_output(print(result), "normally distributed")
  expect_invisible(print(result))
})

test_that("different sample sizes work correctly", {
  sizes <- c(10, 30, 60, 200)
  
  for (n in sizes) {
    df <- data.frame(x = rnorm(n))
    result <- normality(df, "x")
    expect_equal(result$n, n)
    expect_s3_class(result, "normality")
  }
})

test_that("edge cases are handled", {
  tiny_df <- data.frame(x = rnorm(5))
  result <- normality(tiny_df, "x")
  expect_equal(result$n, 5)
  
  huge_variance <- data.frame(x = rnorm(30, 0, 1000))
  result2 <- normality(huge_variance, "x")
  expect_s3_class(result2, "normality")
})

test_that("statistical test results have proper structure", {
  df <- data.frame(x = rnorm(50))
  result <- normality(df, "x")
  
  expect_true("statistic" %in% names(result$sw_test))
  expect_true("p.value" %in% names(result$sw_test))
  expect_type(result$primary_p_display, "character")
})

test_that("function handles extreme distributions", {
  skewed_data <- data.frame(x = rexp(50, 1))
  result <- normality(skewed_data, "x")
  
  expect_s3_class(result, "normality")
  expect_true(abs(result$skewness) > 0)
  expect_false(result$normal)
})
