test_that("Valid inputs", {
  # Invalid x1_range value (not a vector or != 2)
  expect_error(sample_size_range(x1_range = "nonexistent", x2 = 3, step = 0.1),
               "'x1_range' must be a numeric vector of length 2.", fixed = TRUE)
  
  # First value of range > second value of range
  expect_error(sample_size_range(x1_range = c(10, 2), x2 = 5, step = 0.1),
               "'x1_range[1]' must be less than 'x1_range[2]'.", fixed = TRUE)
  
  # x2 is not a single value (not numeric or != 1)
  expect_error(sample_size_range(x1_range = c(1, 3), x2 = c(5, 2), step = 0.1),
               "'x2' must be a single numeric value.", fixed = TRUE)
  
  # 'step' is not a single positive value
  expect_error(sample_size_range(x1_range = c(1, 3), x2 = 4, step = -0.1),
               "'step' must be a positive single numeric value.", fixed = TRUE)
})

test_that("Basic functionality", {
  # Initiate 'result'
  result <- NULL
  
  output <- capture.output({
    result <- sample_size_range(
      x1_range = c(0.65, 0.75), x2 = 0.65, step = 0.05,
      sample = "two-sample", design = "parallel",
      outcome = "proportion", type = "non-inferiority", delta = -0.1
    )
    print(result)
  }, file = NULL)
  
  # Confirm output's structure
  expect_type(result, "list")
  expect_named(result, c("data", "dropout", "step", "plot"))
  expect_s3_class(result$data, "data.frame")
  expect_s3_class(result$plot, "ggplot")
  expect_equal(output[2], "Sample Size Range Analysis")
  expect_match(output[4], "Treatment range (x1): 0.650 to 0.700", fixed = TRUE)
  expect_match(output[5], "Control/Reference (x2): 0.650", fixed = TRUE)
  expect_match(output[6], "Step size: 0.050")
  expect_match(output[8], "70% Power: Total n = 98 to 430")
  expect_match(output[9], "80% Power: Total n = 130 to 564")
  expect_match(output[10], "90% Power: Total n = 178 to 780")
  
  # Example with dropout
  output <- capture.output({
    result <- sample_size_range(
      x1_range = c(0.65, 0.75), x2 = 0.65, step = 0.05,
      sample = "two-sample", design = "parallel",
      outcome = "proportion", type = "non-inferiority", delta = -0.1, dropout = 0.2
    )
    print(result)
  }, file = NULL)
  
  # Confirm output's structure
  expect_type(result, "list")
  expect_named(result, c("data", "dropout", "step", "plot"))
  expect_true(any(grepl("Sample size increased by 20.0% to account for potential dropouts.",
      output, fixed = TRUE)))
})

test_that("Data frame structure", {
  # Initiate 'result'
  result <- NULL
  capture.output({
    result <- sample_size_range(
      x1_range = c(0.10, 0.30), x2 = 0.20, step = 0.10,
      sample = "one-sample", outcome = "mean", type = "equality", SD = 0.1
    )
  }, file = NULL)
  
  # Confirm data frame's structure
  df <- result$data
  expect_equal(ncol(df), 7)
  expect_named(df, c("power", "x1", "x2", "diff", "n1", "n2", "total"))
  expect_setequal(unique(df$power), c(70, 80, 90))
  expect_equal(unique(df$x2), 0.20)
  expect_true(all(df$x1 %in% c(0.10, 0.20, 0.30)))
})

test_that("Plot labels", {
  # Initiate 'result'
  result <- NULL
  capture.output({
    result <- sample_size_range(
      x1_range = c(0.50, 0.60), x2 = 0.50, step = 0.05,
      sample = "two-sample", design = "parallel",
      outcome = "proportion", type = "equality"
    )
  }, file = NULL)
  
  p <- result$plot
  expect_s3_class(p, "ggplot")
  expect_equal(p$labels$x, "x1 (Treatment Effect)")
  expect_equal(p$labels$y, "Total Sample Size")
})
