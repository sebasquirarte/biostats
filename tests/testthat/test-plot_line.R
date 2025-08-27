test_that("plot_line handles basic inputs correctly", {
  df <- data.frame(
    x = rep(1:5, 2),
    y = c(1:5, 2:6),
    group = rep(c("A", "B"), each = 5)
  )
  
  # Basic line plot
  p1 <- plot_line(df, x = "x", y = "y")
  expect_s3_class(p1, "ggplot")
  
  # With grouping
  p2 <- plot_line(df, x = "x", y = "y", group = "group")
  expect_s3_class(p2, "ggplot")
})

test_that("plot_line input validation works", {
  df <- data.frame(x = 1:5, y = 1:5, group = rep("A", 5))
  
  expect_error(plot_line("not_dataframe", x = "x", y = "y"), "'data' must be a data frame")
  expect_error(plot_line(df, x = "missing", y = "y"), "Variables not found")
  expect_error(plot_line(df, x = "x", y = "missing"), "Variables not found")
  expect_error(plot_line(df, x = "x", y = "y", group = "missing"), "Variables not found")
  expect_error(plot_line(df, x = "x", y = "y", facet = "missing"), "Variables not found")
})

test_that("plot_line error parameter validation works", {
  df <- data.frame(x = 1:5, y = 1:5)
  
  expect_error(plot_line(df, x = "x", y = "y", error = "invalid"))
  
  # Valid error types
  valid_errors <- c("none", "se", "sd", "ci")
  for (err in valid_errors) {
    p <- plot_line(df, x = "x", y = "y", error = err)
    expect_s3_class(p, "ggplot")
  }
})

test_that("plot_line stat parameter validation works", {
  df <- data.frame(x = rep(1:3, 4), y = 1:12, group = rep(c("A", "B"), 6))
  
  expect_error(plot_line(df, x = "x", y = "y", stat = "invalid"))
  
  # Valid stats
  p1 <- plot_line(df, x = "x", y = "y", stat = "mean")
  expect_s3_class(p1, "ggplot")
  
  p2 <- plot_line(df, x = "x", y = "y", stat = "median")
  expect_s3_class(p2, "ggplot")
})

test_that("plot_line axis limits validation works", {
  df <- data.frame(x = 1:5, y = 1:5)
  
  expect_error(plot_line(df, x = "x", y = "y", y_limits = "invalid"),
               "'y_limits' must be a numeric vector of length 2")
  expect_error(plot_line(df, x = "x", y = "y", y_limits = c(1, 2, 3)),
               "'y_limits' must be a numeric vector of length 2")
  expect_error(plot_line(df, x = "x", y = "y", x_limits = "invalid"),
               "'x_limits' must be a numeric vector of length 2")
  expect_error(plot_line(df, x = "x", y = "y", x_limits = c(1, 2, 3)),
               "'x_limits' must be a numeric vector of length 2")
  
  # Valid limits
  p <- plot_line(df, x = "x", y = "y", y_limits = c(0, 10), x_limits = c(1, 5))
  expect_s3_class(p, "ggplot")
})

test_that("plot_line statistical aggregation works", {
  df <- data.frame(
    x = rep(1:3, 8),
    y = rnorm(24),
    group = rep(c("A", "B"), 12)
  )
  
  # Mean aggregation
  p1 <- plot_line(df, x = "x", y = "y", group = "group", stat = "mean")
  expect_s3_class(p1, "ggplot")
  
  # Median aggregation
  p2 <- plot_line(df, x = "x", y = "y", group = "group", stat = "median")
  expect_s3_class(p2, "ggplot")
  
  # With error bars
  p3 <- plot_line(df, x = "x", y = "y", group = "group", stat = "mean", error = "se")
  expect_s3_class(p3, "ggplot")
  
  p4 <- plot_line(df, x = "x", y = "y", group = "group", stat = "mean", error = "sd")
  expect_s3_class(p4, "ggplot")
  
  p5 <- plot_line(df, x = "x", y = "y", group = "group", stat = "mean", error = "ci")
  expect_s3_class(p5, "ggplot")
})

test_that("plot_line handles colors correctly", {
  df <- data.frame(
    x = rep(1:3, 4),
    y = 1:12,
    group = rep(c("A", "B"), 6)
  )
  
  # Default colors
  p1 <- plot_line(df, x = "x", y = "y")
  expect_s3_class(p1, "ggplot")
  
  # Custom colors with grouping
  p2 <- plot_line(df, x = "x", y = "y", group = "group", colors = c("red", "blue"))
  expect_s3_class(p2, "ggplot")
  
  # Single group
  df_single <- data.frame(x = 1:5, y = 1:5, group = rep("A", 5))
  p3 <- plot_line(df_single, x = "x", y = "y", group = "group")
  expect_s3_class(p3, "ggplot")
})

test_that("plot_line points parameter works", {
  df <- data.frame(x = 1:5, y = 1:5)
  
  # With points (default)
  p1 <- plot_line(df, x = "x", y = "y", points = TRUE)
  expect_s3_class(p1, "ggplot")
  
  # Without points
  p2 <- plot_line(df, x = "x", y = "y", points = FALSE)
  expect_s3_class(p2, "ggplot")
})

test_that("plot_line size parameters work", {
  df <- data.frame(x = 1:5, y = 1:5)
  
  p <- plot_line(df, x = "x", y = "y", line_size = 2, point_size = 5)
  expect_s3_class(p, "ggplot")
})

test_that("plot_line faceting works", {
  df <- data.frame(
    x = rep(1:3, 8),
    y = 1:24,
    group = rep(c("A", "B"), 12),
    facet_var = rep(c("F1", "F2"), each = 12)
  )
  
  p <- plot_line(df, x = "x", y = "y", group = "group", facet = "facet_var")
  expect_s3_class(p, "ggplot")
  expect_true("FacetWrap" %in% class(p$facet))
})

test_that("plot_line handles numeric x conversion", {
  df <- data.frame(x = c(1, 2, 1, 2), y = 1:4)
  
  # Should convert to factor when <= 10 unique values
  p <- plot_line(df, x = "x", y = "y")
  expect_s3_class(p, "ggplot")
})

test_that("plot_line handles missing values", {
  df <- data.frame(
    x = c(1, 2, 3, NA, 5),
    y = c(1, 2, NA, 4, 5),
    group = c("A", "B", NA, "A", "B")
  )
  
  p <- plot_line(df, x = "x", y = "y", group = "group")
  expect_s3_class(p, "ggplot")
})

test_that("plot_line error bar width works", {
  df <- data.frame(
    x = rep(1:3, 4),
    y = rnorm(12),
    group = rep(c("A", "B"), 6)
  )
  
  p <- plot_line(df, x = "x", y = "y", group = "group", 
                 stat = "mean", error = "se", error_width = 0.5)
  expect_s3_class(p, "ggplot")
})

test_that("plot_line labels work correctly", {
  df <- data.frame(x = 1:5, y = 1:5)
  
  p <- plot_line(df, x = "x", y = "y",
                 title = "Test Line Plot",
                 xlab = "X Values", 
                 ylab = "Y Values",
                 legend_title = "Groups")
  
  expect_s3_class(p, "ggplot")
  expect_equal(p$labels$title, "Test Line Plot")
  expect_equal(p$labels$x, "X Values")
  expect_equal(p$labels$y, "Y Values")
})

test_that("plot_line handles edge cases", {
  # Single point per group
  df_single <- data.frame(x = c(1, 2), y = c(1, 2), group = c("A", "B"))
  p1 <- plot_line(df_single, x = "x", y = "y", group = "group")
  expect_s3_class(p1, "ggplot")
  
  # All same y values
  df_same <- data.frame(x = 1:5, y = rep(3, 5))
  p2 <- plot_line(df_same, x = "x", y = "y")
  expect_s3_class(p2, "ggplot")
  
  # Single data point
  df_one <- data.frame(x = 1, y = 1)
  p3 <- plot_line(df_one, x = "x", y = "y")
  expect_s3_class(p3, "ggplot")
})

test_that("plot_line median error bars use quartiles", {
  df <- data.frame(
    x = rep(1:3, 8),
    y = rnorm(24),
    group = rep(c("A", "B"), 12)
  )
  
  p <- plot_line(df, x = "x", y = "y", group = "group", 
                 stat = "median", error = "ci")  # Uses quartiles for median
  expect_s3_class(p, "ggplot")
})

test_that("plot_line x_limits with factor conversion warning", {
  df <- data.frame(x = c(1, 2, 1, 2), y = 1:4)  # Will be converted to factor
  
  expect_warning(
    p <- plot_line(df, x = "x", y = "y", x_limits = c(1, 2)),
    "'x_limits' ignored: x variable was converted to factor"
  )
  expect_s3_class(p, "ggplot")
})

test_that("plot_line legend behavior", {
  df <- data.frame(
    x = rep(1:3, 4),
    y = 1:12,
    group = rep(c("A", "B"), 6)
  )
  
  # With grouping - should show legend
  p1 <- plot_line(df, x = "x", y = "y", group = "group")
  expect_s3_class(p1, "ggplot")
  
  # Without grouping - should hide legend
  p2 <- plot_line(df, x = "x", y = "y")
  expect_s3_class(p2, "ggplot")
  
  # Single group - should hide legend
  df_single <- data.frame(x = 1:5, y = 1:5, group = rep("A", 5))
  p3 <- plot_line(df_single, x = "x", y = "y", group = "group")
  expect_s3_class(p3, "ggplot")
})

test_that("plot_line without statistical aggregation", {
  df <- data.frame(x = 1:5, y = c(1, 3, 2, 5, 4))
  
  # Raw data without stat
  p <- plot_line(df, x = "x", y = "y")
  expect_s3_class(p, "ggplot")
})
