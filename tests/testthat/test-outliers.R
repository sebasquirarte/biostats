# Helper function to suppress all output from outliers()
quiet_outliers <- function(...) {
  suppressMessages(
    capture.output(
      result <- outliers(...),
      file = nullfile()
    )
  )
  return(result)
}

test_that("outliers detects correct outliers with numeric vector", {
  # Simple case with known outliers
  x <- c(1, 2, 3, 4, 5, 100, -50)
  result <- quiet_outliers(x)

  expect_type(result, "list")
  expect_equal(length(result), 5)
  expect_true(6 %in% result$outliers)  # 100 is outlier
  expect_true(7 %in% result$outliers)  # -50 is outlier
  expect_equal(length(result$outliers), 2)
})

test_that("outliers works with data frame input", {
  df <- data.frame(
    values = c(1:10, 50),
    group = letters[1:11]
  )

  result <- quiet_outliers("values", data = df)

  expect_type(result, "list")
  expect_true(11 %in% result$outliers)  # 50 should be outlier
  expect_s3_class(result$scatter_plot, "gg")
  expect_s3_class(result$boxplot, "gg")
})

test_that("outliers handles missing values correctly", {
  x <- c(1:5, NA, NA, 100, NA)
  result <- quiet_outliers(x)

  # Should exclude NAs and still detect outlier
  expect_true(8 %in% result$outliers)  # Position 8 (100) is outlier
  expect_equal(length(result$outliers), 1)
})

test_that("outliers respects threshold parameter", {
  x <- c(1:10, 15)

  # With default threshold (1.5), 15 might be outlier
  result_default <- quiet_outliers(x, threshold = 1.5)

  # With higher threshold, 15 should not be outlier
  result_high <- quiet_outliers(x, threshold = 3.0)

  expect_true(length(result_default$outliers) >= length(result_high$outliers))
})

test_that("outliers returns correct statistics", {
  x <- c(1, 2, 3, 4, 5)  # Simple data with known quartiles
  result <- quiet_outliers(x)

  expect_equal(result$stats["q1"], c(q1 = 2))
  expect_equal(result$stats["q3"], c(q3 = 4))
  expect_equal(result$stats["iqr"], c(iqr = 2))
  expect_equal(result$bounds["lower"], c(lower = 2 - 1.5 * 2))
  expect_equal(result$bounds["upper"], c(upper = 4 + 1.5 * 2))
})

test_that("outliers handles edge cases", {
  # No outliers case
  x <- 1:10
  result <- quiet_outliers(x)
  expect_equal(length(result$outliers), 0)

  # All same values (no outliers possible)
  x_same <- rep(5, 10)
  result_same <- quiet_outliers(x_same)
  expect_equal(length(result_same$outliers), 0)

  # Minimum required observations (4)
  x_min <- 1:4
  result_min <- quiet_outliers(x_min)
  expect_type(result_min, "list")
})

test_that("outliers validates inputs correctly", {
  # Non-numeric input
  expect_error(outliers("text"), "'x' must be numeric")

  # Invalid threshold
  expect_error(outliers(1:10, threshold = -1), "'threshold' must be a positive number")
  expect_error(outliers(1:10, threshold = 0), "'threshold' must be a positive number")
  expect_error(outliers(1:10, threshold = "high"), "'threshold' must be a positive number")

  # Too few observations
  expect_error(outliers(c(1, 2, 3)), "Need at least 4 non-missing observations")
  expect_error(outliers(c(1, NA, NA, NA, NA)), "Need at least 4 non-missing observations")

  # Invalid column name
  df <- data.frame(a = 1:5)
  expect_error(outliers("b", data = df), "'x' must be a single valid column name")
})

test_that("outliers creates both plots", {
  x <- c(1:10, 50, -20)
  result <- quiet_outliers(x)

  expect_s3_class(result$scatter_plot, "gg")
  expect_s3_class(result$boxplot, "gg")

  # Check plot has expected layers
  expect_true(length(result$scatter_plot$layers) >= 1)
  expect_true(length(result$boxplot$layers) >= 1)
})

test_that("outliers returns invisible result", {
  x <- c(1:10, 100)

  # Function should return invisibly (test with capture.output)
  capture.output(
    expect_invisible(result <- outliers(x)),
    file = nullfile()
  )

  # But result should still be accessible
  expect_type(result, "list")
  expect_true(11 %in% result$outliers)
})

test_that("outliers handles extreme outliers", {
  x <- c(seq(0, 1, 0.1), 1000, -1000)
  result <- quiet_outliers(x)

  # Both extreme values should be detected
  expect_true(12 %in% result$outliers)  # 1000
  expect_true(13 %in% result$outliers)  # -1000
  expect_equal(length(result$outliers), 2)
})
