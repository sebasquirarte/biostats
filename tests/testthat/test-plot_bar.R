test_that("plot_bar handles basic inputs correctly", {
  df <- data.frame(
    x = factor(c("A", "B", "C", "A", "B")),
    y = c(10, 15, 8, 12, 9),
    group = factor(c("G1", "G1", "G2", "G2", "G1"))
  )
  
  # Basic count plot
  p1 <- plot_bar(df, x = "x")
  expect_s3_class(p1, "ggplot")
  expect_equal(length(p1$layers), 1)
  
  # With y variable
  p2 <- plot_bar(df, x = "x", y = "y")
  expect_s3_class(p2, "ggplot")
  
  # With grouping
  p3 <- plot_bar(df, x = "x", group = "group")
  expect_s3_class(p3, "ggplot")
})

test_that("plot_bar input validation works", {
  df <- data.frame(x = 1:3, y = 4:6)
  
  expect_error(plot_bar("not_dataframe", x = "x"), "'data' must be a data frame")
  expect_error(plot_bar(df, x = "missing"), "Variables not found")
  expect_error(plot_bar(df, x = "x", y = "missing"), "Variables not found")
  expect_error(plot_bar(df, x = "x", group = "missing"), "Variables not found")
  expect_error(plot_bar(df, x = "x", facet = "missing"), "Variables not found")
})

test_that("plot_bar position parameter works", {
  df <- data.frame(
    x = rep(c("A", "B"), each = 4),
    group = rep(c("G1", "G2"), 4)
  )
  
  p1 <- plot_bar(df, x = "x", group = "group", position = "dodge")
  expect_s3_class(p1, "ggplot")
  
  p2 <- plot_bar(df, x = "x", group = "group", position = "stack")
  expect_s3_class(p2, "ggplot")
  
  p3 <- plot_bar(df, x = "x", group = "group", position = "fill")
  expect_s3_class(p3, "ggplot")
  
  expect_error(plot_bar(df, x = "x", position = "invalid"))
})

test_that("plot_bar statistical aggregation works", {
  df <- data.frame(
    x = rep(c("A", "B"), each = 4),
    y = c(1:4, 5:8),
    group = rep(c("G1", "G2"), 4)
  )
  
  # Mean aggregation
  p1 <- plot_bar(df, x = "x", y = "y", stat = "mean")
  expect_s3_class(p1, "ggplot")
  
  # Median aggregation  
  p2 <- plot_bar(df, x = "x", y = "y", stat = "median")
  expect_s3_class(p2, "ggplot")
  
  # Error when stat without y
  expect_error(plot_bar(df, x = "x", stat = "mean"), 
               "'y' variable must be specified when using 'stat'")
})

test_that("plot_bar handles colors correctly", {
  df <- data.frame(x = c("A", "B"), group = c("G1", "G2"))
  
  # Default colors
  p1 <- plot_bar(df, x = "x")
  expect_s3_class(p1, "ggplot")
  
  # Custom colors
  p2 <- plot_bar(df, x = "x", group = "group", colors = c("red", "blue"))
  expect_s3_class(p2, "ggplot")
  
  # Single group uses single color
  df_single <- data.frame(x = c("A", "B"), group = c("G1", "G1"))
  p3 <- plot_bar(df_single, x = "x", group = "group")
  expect_s3_class(p3, "ggplot")
})

test_that("plot_bar faceting works", {
  df <- data.frame(
    x = rep(c("A", "B"), 4),
    group = rep(c("G1", "G2"), 4),
    facet_var = rep(c("F1", "F2"), each = 4)
  )
  
  p <- plot_bar(df, x = "x", group = "group", facet = "facet_var")
  expect_s3_class(p, "ggplot")
  expect_true("FacetWrap" %in% class(p$facet))
})

test_that("plot_bar value labels work", {
  df <- data.frame(
    x = rep(c("A", "B"), each = 2),
    group = rep(c("G1", "G2"), 2)
  )
  
  # Count with values
  p1 <- plot_bar(df, x = "x", values = TRUE)
  expect_s3_class(p1, "ggplot")
  
  # Grouped with values
  p2 <- plot_bar(df, x = "x", group = "group", values = TRUE)
  expect_s3_class(p2, "ggplot")
  
  # Fill position with values
  p3 <- plot_bar(df, x = "x", group = "group", position = "fill", values = TRUE)
  expect_s3_class(p3, "ggplot")
})

test_that("plot_bar handles numeric x conversion", {
  df <- data.frame(x = 1:5)
  
  # Should convert to factor when <= 10 unique values
  p1 <- plot_bar(df, x = "x")
  expect_s3_class(p1, "ggplot")
  
  # Many unique values stay numeric (would be converted internally)
  df_many <- data.frame(x = 1:15)
  p2 <- plot_bar(df_many, x = "x")
  expect_s3_class(p2, "ggplot")
})

test_that("plot_bar handles missing values", {
  df <- data.frame(
    x = c("A", "B", NA, "A"),
    group = c("G1", NA, "G2", "G1")
  )
  
  p <- plot_bar(df, x = "x", group = "group")
  expect_s3_class(p, "ggplot")
})

test_that("plot_bar flip coordinate works", {
  df <- data.frame(x = c("A", "B", "C"))
  
  p <- plot_bar(df, x = "x", flip = TRUE)
  expect_s3_class(p, "ggplot")
  expect_true("CoordFlip" %in% class(p$coordinates))
})

test_that("plot_bar labels work correctly", {
  df <- data.frame(x = c("A", "B"))
  
  p <- plot_bar(df, x = "x", 
                title = "Test Title",
                xlab = "X Label", 
                ylab = "Y Label",
                legend_title = "Legend")
  
  expect_s3_class(p, "ggplot")
  expect_equal(p$labels$title, "Test Title")
  expect_equal(p$labels$x, "X Label")
  expect_equal(p$labels$y, "Y Label")
})

test_that("plot_bar handles edge cases", {
  # Empty data frame
  df_empty <- data.frame(x = character(0))
  p1 <- plot_bar(df_empty, x = "x")
  expect_s3_class(p1, "ggplot")
  
  # Single row
  df_single <- data.frame(x = "A")
  p2 <- plot_bar(df_single, x = "x")
  expect_s3_class(p2, "ggplot")
  
  # All same values
  df_same <- data.frame(x = rep("A", 5))
  p3 <- plot_bar(df_same, x = "x")
  expect_s3_class(p3, "ggplot")
})

test_that("plot_bar with y values handles different scenarios", {
  df <- data.frame(
    x = c("A", "B", "A", "B"),
    y = c(10, 20, 15, 25),
    group = c("G1", "G1", "G2", "G2")
  )
  
  # Basic y plot
  p1 <- plot_bar(df, x = "x", y = "y")
  expect_s3_class(p1, "ggplot")
  
  # With grouping
  p2 <- plot_bar(df, x = "x", y = "y", group = "group")
  expect_s3_class(p2, "ggplot")
  
  # With faceting
  p3 <- plot_bar(df, x = "x", y = "y", facet = "group")
  expect_s3_class(p3, "ggplot")
})
