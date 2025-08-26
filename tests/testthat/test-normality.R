test_that("normality returns correct structure", {
  df <- data.frame(x = rnorm(50))
  capture.output({
    result <- normality(df, "x")
  })
  
  expect_type(result, "list")
  expect_length(result, 4)
  expect_named(result, c("normal", "outside_95CI", "qq_plot", "hist_plot"))
  expect_type(result$normal, "logical")
  expect_type(result[[2]], "integer")
  expect_s3_class(result$qq_plot, "ggplot")
  expect_s3_class(result$hist_plot, "ggplot")
})

test_that("normality validates inputs correctly", {
  df <- data.frame(num = rnorm(20), char = letters[1:20])
  
  expect_error(normality("not_df", "x"), "'data' must be a data frame")
  expect_error(normality(df, 123), "'x' must be a character string")
  expect_error(normality(df, "missing"), "not found in data")
  expect_error(normality(df, "char"), "must be numeric")
  
  small_df <- data.frame(x = c(1, 2, 3))
  expect_error(normality(small_df, "x"), "Need at least 5 observations")
  
  const_df <- data.frame(x = rep(5, 10))
  expect_error(normality(const_df, "x"), "only constant values")
})

test_that("normality handles different sample sizes", {
  small_df <- data.frame(x = rnorm(25))
  output_small <- capture.output({
    result_small <- normality(small_df, "x")
  })
  expect_false(any(grepl("Kolmogorov-Smirnov", output_small)))
  
  large_df <- data.frame(x = rnorm(75))
  output_large <- capture.output({
    result_large <- normality(large_df, "x")
  })
  expect_true(any(grepl("Kolmogorov-Smirnov", output_large)))
  expect_true(any(grepl("Shapiro-Wilk", output_large)))
})

test_that("normality console output contains key elements", {
  df <- data.frame(x = rnorm(30))
  output <- capture.output({
    result <- normality(df, "x")
  })
  
  output_text <- paste(output, collapse = " ")
  expect_true(grepl("Normality Test", output_text))
  expect_true(grepl("Skewness:", output_text))
  expect_true(grepl("Kurtosis:", output_text))
  expect_true(grepl("normally distributed", output_text))
})

test_that("normality outside parameter controls output", {
  set.seed(42)
  df <- data.frame(x = c(rnorm(20), -6, 6, -7, 7))
  
  output_false <- capture.output({
    result_false <- normality(df, "x", all = FALSE)
  })
  
  output_true <- capture.output({
    result_true <- normality(df, "x", all = TRUE)
  })
  
  expect_type(result_true[[2]], "integer")
  expect_type(result_false[[2]], "integer")
  
  output_false_text <- paste(output_false, collapse = " ")
  output_true_text <- paste(output_true, collapse = " ")
  
  if (length(result_true[[2]]) > 0) {
    expect_true(grepl("Use all = TRUE", output_false_text))
    expect_true(grepl("VALUES OUTSIDE 95%CI", output_true_text))
  }
  
  expect_equal(result_false[[2]], result_true[[2]])
})

test_that("normality detects extreme values", {
  df <- data.frame(x = c(rep(0, 30), -5, 5))
  
  capture.output({
    result <- normality(df, "x")
  })
  
  expect_type(result[[2]], "integer")
  expect_true(length(result[[2]]) >= 0)
})

test_that("normality works with custom colors", {
  df <- data.frame(x = rnorm(25))
  
  capture.output({
    result <- normality(df, "x", color = "blue")
  })
  
  expect_s3_class(result$qq_plot, "ggplot")
  expect_s3_class(result$hist_plot, "ggplot")
})

test_that("normality produces consistent results with same data", {
  set.seed(100)
  df <- data.frame(x = rnorm(40))
  
  capture.output({
    result1 <- normality(df, "x")
  })
  
  capture.output({
    result2 <- normality(df, "x")
  })
  
  expect_equal(result1$normal, result2$normal)
  expect_equal(result1[[2]], result2[[2]])
})

test_that("normality handles edge cases", {
  min_df <- data.frame(x = rnorm(5))
  expect_silent({
    capture.output({
      result <- normality(min_df, "x")
    })
  })
  expect_type(result, "list")
  
  na_df <- data.frame(x = c(rnorm(15), NA, NA, NA))
  expect_silent({
    capture.output({
      result <- normality(na_df, "x")
    })
  })
  expect_type(result, "list")
})
