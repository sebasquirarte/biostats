test_that("missing_values basic functionality works correctly", {
  # Test data with mixed missing patterns
  test_df <- data.frame(
    some_missing = c(1, NA, 3, NA, 5),     # 2/5 = 40% missing
    few_missing = c(NA, 2, 3, 4, 5),       # 1/5 = 20% missing
    no_missing = c(1, 2, 3, 4, 5)          # 0% missing
  )

  # Suppress both console output AND messages
  suppressMessages({
    capture.output({
      result <- missing_values(test_df)
    })
  })

  # Check return structure and basic statistics
  expect_type(result, "list")
  expect_named(result, c("missing_stats", "total_missing", "complete_cases",
                         "complete_pct", "overall_pct", "bar_plot", "heatmap_plot"))
  expect_equal(result$total_missing, 3)
  expect_equal(result$complete_cases, 2)  # rows 2 and 5 complete
  expect_equal(result$complete_pct, 40)
  expect_s3_class(result$missing_stats, "data.frame")
  expect_equal(nrow(result$missing_stats), 3)
})

test_that("missing_values 'all' parameter and no missing data scenarios", {
  # Test 'all' parameter
  test_df <- data.frame(with_missing = c(1, NA, 3), no_missing = c(1, 2, 3))

  suppressMessages({
    capture.output({
      result_default <- missing_values(test_df, all = FALSE)
    })
  })
  suppressMessages({
    capture.output({
      result_all <- missing_values(test_df, all = TRUE)
    })
  })
  expect_identical(result_default$missing_stats, result_all$missing_stats)

  # Test no missing values behavior
  clean_df <- data.frame(a = 1:3, b = 4:6)

  suppressMessages({
    capture.output({
      result <- missing_values(clean_df, all = FALSE)
    })
  })
  expect_equal(result$total_missing, 0)
  expect_equal(result$complete_pct, 100)

  suppressMessages({
    capture.output({
      result_all <- missing_values(clean_df, all = TRUE)
    })
  })
  expect_equal(result_all$total_missing, 0)
})

test_that("missing_values input validation works", {
  test_df <- data.frame(a = c(1, NA, 3))

  # Test invalid inputs
  expect_error(missing_values(NULL), "non-empty dataframe")
  expect_error(missing_values(data.frame()), "non-empty dataframe")
  expect_error(missing_values(test_df, color = 123), "character string.*logical")
  expect_error(missing_values(test_df, all = "TRUE"), "character string.*logical")
  expect_error(missing_values(test_df, color = c("red", "blue")), "character string.*logical")
})

test_that("missing_values handles data types, colors, and edge cases", {
  # Test different data types
  mixed_df <- data.frame(
    num = c(1.5, NA), int = c(1L, NA), char = c("a", NA),
    factor = factor(c("x", NA)), logical = c(TRUE, NA)
  )
  suppressMessages({
    capture.output({
      result <- missing_values(mixed_df)
    })
  })
  expect_equal(result$total_missing, 5)

  # Test custom colors
  suppressMessages({
    capture.output({
      result1 <- missing_values(data.frame(a = c(1, NA)), color = "red")
    })
  })
  suppressMessages({
    capture.output({
      result2 <- missing_values(data.frame(a = c(1, NA)), color = "#FF0000")
    })
  })
  expect_type(result1, "list")
  expect_type(result2, "list")

  # Test edge cases
  suppressMessages({
    capture.output({
      single_row <- missing_values(data.frame(a = 1, b = NA))
    })
  })
  expect_equal(single_row$complete_cases, 0)

  suppressMessages({
    capture.output({
      all_missing <- missing_values(data.frame(a = c(NA, NA), b = c(NA, NA)))
    })
  })
  expect_equal(all_missing$complete_cases, 0)
  expect_equal(all_missing$complete_pct, 0)
})

test_that("missing_values handles wide datasets and produces consistent results", {
  # Test wide datasets warning - need to capture warning separately
  set.seed(123)
  wide_df <- data.frame(matrix(sample(c(1:5, NA), 55 * 5, replace = TRUE),
                               nrow = 5, ncol = 55))
  expect_warning({
    suppressMessages({
      invisible(capture.output(result <- missing_values(wide_df)))
    })
  }, "many columns")
  expect_type(result, "list")

  # Test consistency
  set.seed(456)
  test_df <- data.frame(a = sample(c(1:3, NA), 5, replace = TRUE))
  suppressMessages({
    capture.output({
      result1 <- missing_values(test_df)
    })
  })
  suppressMessages({
    capture.output({
      result2 <- missing_values(test_df)
    })
  })
  expect_identical(result1$missing_stats, result2$missing_stats)
  expect_identical(result1$total_missing, result2$total_missing)
})
