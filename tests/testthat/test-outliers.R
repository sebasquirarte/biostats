# Helper function to suppress output
quiet_outliers <- function(...) {
  suppressMessages(
    capture.output(
      result <- outliers(...),
      file = nullfile()
    )
  )
  return(result)
}

# Basic functionality tests
test_that("outliers returns expected structure", {
  df <- data.frame(values = c(1:10, 50))
  result <- quiet_outliers(df, "values")
  
  expect_type(result, "list")
  expect_named(result, c("data", "missing_data", "outlier_data", "outliers", "bounds", "stats", "scatterplot", "boxplot"))
  expect_s3_class(result$scatterplot, "gg")
  expect_s3_class(result$boxplot, "gg")
})

test_that("outliers detects correct outliers", {
  df <- data.frame(test_var = c(1, 2, 3, 4, 5, 100, -50))
  result <- quiet_outliers(df, "test_var")
  
  expect_true(6 %in% result$outliers)  # 100
  expect_true(7 %in% result$outliers)  # -50
  expect_equal(length(result$outliers), 2)
})

test_that("threshold parameter affects outlier detection", {
  df <- data.frame(vals = c(1:10, 15))
  
  result_strict <- quiet_outliers(df, "vals", threshold = 1.0)
  result_loose <- quiet_outliers(df, "vals", threshold = 3.0)
  
  expect_true(length(result_strict$outliers) >= length(result_loose$outliers))
})

test_that("handles missing values correctly", {
  df <- data.frame(x = c(1:5, NA, NA, 100, NA))
  result <- quiet_outliers(df, "x")
  
  expect_true(8 %in% result$outliers)
  expect_equal(length(result$outliers), 1)
})

test_that("returns correct statistics", {
  df <- data.frame(simple = c(1, 2, 3, 4, 5))
  result <- quiet_outliers(df, "simple")
  
  expect_equal(result$stats[["q1"]], 2)
  expect_equal(result$stats[["q3"]], 4)
  expect_equal(result$stats[["iqr"]], 2)
  expect_equal(result$bounds[["lower"]], -1)
  expect_equal(result$bounds[["upper"]], 7)
})

test_that("handles edge cases", {
  # No outliers
  df1 <- data.frame(normal = 1:10)
  result1 <- quiet_outliers(df1, "normal")
  expect_equal(length(result1$outliers), 0)
  
  # Identical values
  df2 <- data.frame(same = rep(5, 10))
  result2 <- quiet_outliers(df2, "same")
  expect_equal(length(result2$outliers), 0)
  
  # Minimum observations
  df3 <- data.frame(min_obs = 1:4)
  result3 <- quiet_outliers(df3, "min_obs")
  expect_type(result3, "list")
})

# Input validation tests
test_that("validates data input", {
  expect_error(outliers("not_df", "x"), "'data' must be a dataframe")
  expect_error(outliers(data.frame(), "x"), "'data' must have at least one row")
  
  empty_df <- data.frame(x = numeric(0))
  expect_error(outliers(empty_df, "x"), "'data' must have at least one row")
})

test_that("validates column specification", {
  df <- data.frame(numeric_col = 1:5, char_col = letters[1:5])
  
  expect_error(outliers(df, c("numeric_col", "char_col")), 
               "'x' must be a single character string")
  expect_error(outliers(df, "nonexistent"), 
               "'x' must be a valid column name")
  expect_error(outliers(df, "char_col"), 
               "Column 'char_col' must be numeric")
  expect_error(outliers(df, 123), "'x' must be a character string")
})

test_that("validates threshold parameter", {
  df <- data.frame(vals = 1:10)
  
  expect_error(outliers(df, "vals", threshold = -1), "'threshold' must be positive")
  expect_error(outliers(df, "vals", threshold = 0), "'threshold' must be positive")
  expect_error(outliers(df, "vals", threshold = "high"), "'threshold' must be numeric")
  expect_error(outliers(df, "vals", threshold = c(1, 2)), 
               "'threshold' must be a single value")
})

test_that("validates color parameter", {
  df <- data.frame(vals = 1:10)
  
  expect_error(outliers(df, "vals", color = 123), "'color' must be a character string")
  expect_error(outliers(df, "vals", color = c("red", "blue")), 
               "'color' must be a single character string")
})

test_that("requires sufficient observations", {
  df1 <- data.frame(x = c(1, 2, 3))
  expect_error(outliers(df1, "x"), "Need at least 4 non-missing observations")
  
  df2 <- data.frame(x = c(1, NA, NA, NA, NA))
  expect_error(outliers(df2, "x"), "Need at least 4 non-missing observations")
})

# Functionality tests
test_that("custom colors work", {
  df <- data.frame(vals = c(1:10, 50))
  result <- quiet_outliers(df, "vals", color = "blue")
  
  expect_type(result, "list")
  expect_true(11 %in% result$outliers)
})

test_that("handles extreme outliers", {
  df <- data.frame(extreme = c(seq(0, 1, 0.1), 1000, -1000))
  result <- quiet_outliers(df, "extreme")
  
  expect_true(12 %in% result$outliers)
  expect_true(13 %in% result$outliers)
  expect_equal(length(result$outliers), 2)
})

test_that("function returns invisibly", {
  df <- data.frame(vals = c(1:10, 100))
  
  capture.output(
    expect_invisible(result <- outliers(df, "vals")),
    file = nullfile()
  )
  
  expect_type(result, "list")
  expect_true(11 %in% result$outliers)
})

test_that("plots contain expected elements", {
  df <- data.frame(data_points = c(1:10, 50, -20))
  result <- quiet_outliers(df, "data_points")
  
  expect_true(length(result$scatterplot$layers) >= 1)
  expect_true(length(result$boxplot$layers) >= 2)
  
  # Check plot titles exist
  expect_false(is.null(result$scatterplot$labels$title))
  expect_false(is.null(result$boxplot$labels$title))
})

test_that("works with different numeric types", {
  df_int <- data.frame(integers = as.integer(c(1:10, 50)))
  df_dbl <- data.frame(doubles = as.double(c(1:10, 50.5)))
  
  result_int <- quiet_outliers(df_int, "integers")
  result_dbl <- quiet_outliers(df_dbl, "doubles")
  
  expect_type(result_int, "list")
  expect_type(result_dbl, "list")
  expect_true(11 %in% result_int$outliers)
  expect_true(11 %in% result_dbl$outliers)
})
