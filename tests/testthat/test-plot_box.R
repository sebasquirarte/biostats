test_that("plot_box handles basic inputs correctly", {
  df <- data.frame(
    x = factor(c("A", "B", "C", "A", "B", "C")),
    y = c(10, 15, 8, 12, 18, 6),
    group = factor(c("G1", "G1", "G2", "G2", "G1", "G2"))
  )
  
  # Basic boxplot
  p1 <- plot_box(df, x = "x", y = "y")
  expect_s3_class(p1, "ggplot")
  expect_equal(length(p1$layers), 2) # boxplot + stat_summary
  
  # With grouping
  p2 <- plot_box(df, x = "x", y = "y", group = "group")
  expect_s3_class(p2, "ggplot")
  
  # Without mean
  p3 <- plot_box(df, x = "x", y = "y", show_mean = FALSE)
  expect_s3_class(p3, "ggplot")
  expect_equal(length(p3$layers), 1) # only boxplot
})

test_that("plot_box input validation works", {
  df <- data.frame(x = factor(c("A", "B")), y = c(1, 2))
  
  expect_error(plot_box("not_dataframe", x = "x", y = "y"), 
               "'data' must be a data frame")
  expect_error(plot_box(df, x = "missing", y = "y"), 
               "Variables not found")
  expect_error(plot_box(df, x = "x", y = "missing"), 
               "Variables not found")
  expect_error(plot_box(df, x = "x", y = "y", group = "missing"), 
               "Variables not found")
  expect_error(plot_box(df, x = "x", y = "y", facet = "missing"), 
               "Variables not found")
})

test_that("plot_box y_limits validation works", {
  df <- data.frame(x = c("A", "B"), y = c(1, 2))
  
  expect_error(plot_box(df, x = "x", y = "y", y_limits = "invalid"),
               "'y_limits' must be a numeric vector of length 2")
  expect_error(plot_box(df, x = "x", y = "y", y_limits = c(1, 2, 3)),
               "'y_limits' must be a numeric vector of length 2")
  
  # Valid y_limits should work
  p <- plot_box(df, x = "x", y = "y", y_limits = c(0, 5))
  expect_s3_class(p, "ggplot")
})

test_that("plot_box handles points correctly", {
  df <- data.frame(
    x = rep(c("A", "B"), each = 3),
    y = 1:6,
    group = rep(c("G1", "G2"), 3)
  )
  
  # With points, no grouping
  p1 <- plot_box(df, x = "x", y = "y", points = TRUE)
  expect_s3_class(p1, "ggplot")
  expect_equal(length(p1$layers), 3) # jitter + boxplot + stat_summary
  
  # With points and grouping
  p2 <- plot_box(df, x = "x", y = "y", group = "group", points = TRUE)
  expect_s3_class(p2, "ggplot")
  
  # Without points
  p3 <- plot_box(df, x = "x", y = "y", points = FALSE)
  expect_s3_class(p3, "ggplot")
  expect_equal(length(p3$layers), 2) # boxplot + stat_summary
})

test_that("plot_box point_size parameter works", {
  df <- data.frame(x = c("A", "B"), y = c(1, 2))
  
  p <- plot_box(df, x = "x", y = "y", points = TRUE, point_size = 5)
  expect_s3_class(p, "ggplot")
})

test_that("plot_box handles colors correctly", {
  df <- data.frame(
    x = c("A", "B", "A", "B"),
    y = 1:4,
    group = c("G1", "G1", "G2", "G2")
  )
  
  # Default colors
  p1 <- plot_box(df, x = "x", y = "y")
  expect_s3_class(p1, "ggplot")
  
  # Custom colors with grouping
  p2 <- plot_box(df, x = "x", y = "y", group = "group", 
                 colors = c("red", "blue"))
  expect_s3_class(p2, "ggplot")
  
  # Single group
  df_single <- data.frame(x = c("A", "B"), y = c(1, 2), group = c("G1", "G1"))
  p3 <- plot_box(df_single, x = "x", y = "y", group = "group")
  expect_s3_class(p3, "ggplot")
})

test_that("plot_box faceting works", {
  df <- data.frame(
    x = rep(c("A", "B"), 4),
    y = 1:8,
    facet_var = rep(c("F1", "F2"), each = 4)
  )
  
  p <- plot_box(df, x = "x", y = "y", facet = "facet_var")
  expect_s3_class(p, "ggplot")
  expect_true("FacetWrap" %in% class(p$facet))
})

test_that("plot_box handles numeric x conversion", {
  df <- data.frame(x = c(1, 2, 1, 2), y = 1:4)
  
  # Should convert to factor when <= 10 unique values
  p <- plot_box(df, x = "x", y = "y")
  expect_s3_class(p, "ggplot")
})

test_that("plot_box handles missing values", {
  df <- data.frame(
    x = c("A", "B", NA, "A"),
    y = c(1, 2, 3, 4),
    group = c("G1", NA, "G2", "G1")
  )
  
  p <- plot_box(df, x = "x", y = "y", group = "group")
  expect_s3_class(p, "ggplot")
})

test_that("plot_box mean display works", {
  df <- data.frame(x = c("A", "B", "A", "B"), y = 1:4)
  
  # With mean (default)
  p1 <- plot_box(df, x = "x", y = "y", show_mean = TRUE)
  expect_s3_class(p1, "ggplot")
  expect_equal(length(p1$layers), 2) # boxplot + stat_summary
  
  # Without mean
  p2 <- plot_box(df, x = "x", y = "y", show_mean = FALSE)
  expect_s3_class(p2, "ggplot")
  expect_equal(length(p2$layers), 1) # only boxplot
})

test_that("plot_box labels work correctly", {
  df <- data.frame(x = c("A", "B"), y = c(1, 2))
  
  p <- plot_box(df, x = "x", y = "y",
                title = "Test Title",
                xlab = "X Label", 
                ylab = "Y Label",
                legend_title = "Legend")
  
  expect_s3_class(p, "ggplot")
  expect_equal(p$labels$title, "Test Title")
  expect_equal(p$labels$x, "X Label")
  expect_equal(p$labels$y, "Y Label")
})

test_that("plot_box handles edge cases", {
  # Single data point per group
  df_single <- data.frame(x = c("A", "B"), y = c(1, 2))
  p1 <- plot_box(df_single, x = "x", y = "y")
  expect_s3_class(p1, "ggplot")
  
  # All same y values
  df_same <- data.frame(x = c("A", "B", "A", "B"), y = rep(5, 4))
  p2 <- plot_box(df_same, x = "x", y = "y")
  expect_s3_class(p2, "ggplot")
  
  # Large dataset
  set.seed(123)
  df_large <- data.frame(
    x = sample(c("A", "B", "C"), 100, replace = TRUE),
    y = rnorm(100)
  )
  p3 <- plot_box(df_large, x = "x", y = "y")
  expect_s3_class(p3, "ggplot")
})

test_that("plot_box with grouping and faceting combined", {
  df <- data.frame(
    x = rep(c("A", "B"), 8),
    y = 1:16,
    group = rep(c("G1", "G2"), 8),
    facet_var = rep(c("F1", "F2"), each = 8)
  )
  
  p <- plot_box(df, x = "x", y = "y", group = "group", facet = "facet_var")
  expect_s3_class(p, "ggplot")
  expect_true("FacetWrap" %in% class(p$facet))
})

test_that("plot_box legend behavior", {
  df <- data.frame(
    x = c("A", "B", "A", "B"),
    y = 1:4,
    group = c("G1", "G1", "G2", "G2")
  )
  
  # With grouping - should show legend
  p1 <- plot_box(df, x = "x", y = "y", group = "group")
  expect_s3_class(p1, "ggplot")
  
  # Without grouping - should hide legend
  p2 <- plot_box(df, x = "x", y = "y")
  expect_s3_class(p2, "ggplot")
  
  # Single group - should hide legend
  df_single <- data.frame(x = c("A", "B"), y = c(1, 2), group = c("G1", "G1"))
  p3 <- plot_box(df_single, x = "x", y = "y", group = "group")
  expect_s3_class(p3, "ggplot")
})
