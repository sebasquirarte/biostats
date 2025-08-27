test_that("plot_hist basic functionality", {
  set.seed(123)
  df <- data.frame(x = rnorm(50), y = rnorm(50))
  
  p <- plot_hist(df, x = "x")
  expect_s3_class(p, "ggplot")
})

test_that("plot_hist with grouping", {
  set.seed(123)
  df <- data.frame(x = rnorm(40), group = rep(c("A", "B"), each = 20))
  
  p <- plot_hist(df, x = "x", group = "group")
  expect_s3_class(p, "ggplot")
})

test_that("plot_hist with faceting", {
  set.seed(123)
  df <- data.frame(x = rnorm(40), facet_var = rep(c("F1", "F2"), each = 20))
  
  p <- plot_hist(df, x = "x", facet = "facet_var")
  expect_s3_class(p, "ggplot")
  expect_true("FacetWrap" %in% class(p$facet))
})

test_that("plot_hist input validation", {
  df <- data.frame(x = rnorm(20), group = rep(c("A", "B"), 10))
  df_char <- data.frame(x = letters[1:10], y = 1:10)
  
  expect_error(plot_hist("not_dataframe", x = "x"), "'data' must be a data frame")
  expect_error(plot_hist(df, x = "missing"), "Variables not found")
  expect_error(plot_hist(df, x = "x", group = "missing"), "Variables not found")
  expect_error(plot_hist(df_char, x = "x"), "'x' variable must be numeric")
})

test_that("plot_hist group constraints", {
  set.seed(123)
  df_three <- data.frame(x = rnorm(60), group = rep(c("A", "B", "C"), each = 20))
  
  expect_error(plot_hist(df_three, x = "x", group = "group"),
               "Mirror histograms only support 2 groups")
})

test_that("plot_hist bins parameter", {
  set.seed(123)
  df <- data.frame(x = rnorm(50), y = 1:50)
  
  p1 <- plot_hist(df, x = "x", bins = 10)
  expect_s3_class(p1, "ggplot")
  
  p2 <- plot_hist(df, x = "x", bins = 20)
  expect_s3_class(p2, "ggplot")
})

test_that("plot_hist binwidth parameter", {
  set.seed(123)
  df <- data.frame(x = rnorm(50), y = 1:50)
  
  p1 <- plot_hist(df, x = "x", binwidth = 0.5)
  expect_s3_class(p1, "ggplot")
  
  p2 <- plot_hist(df, x = "x", binwidth = 1.0)
  expect_s3_class(p2, "ggplot")
  
  expect_error(plot_hist(df, x = "x", binwidth = -1))
})

test_that("plot_hist statistical lines", {
  set.seed(123)
  df <- data.frame(x = rnorm(50), y = 1:50)
  
  p1 <- plot_hist(df, x = "x", stat = "mean")
  expect_s3_class(p1, "ggplot")
  
  p2 <- plot_hist(df, x = "x", stat = "median")
  expect_s3_class(p2, "ggplot")
  
  expect_error(plot_hist(df, x = "x", stat = "invalid"))
})

test_that("plot_hist custom colors", {
  set.seed(123)
  df <- data.frame(x = rnorm(40), group = rep(c("A", "B"), each = 20))
  
  p1 <- plot_hist(df, x = "x", group = "group", colors = c("red", "blue"))
  expect_s3_class(p1, "ggplot")
  
  p2 <- plot_hist(df, x = "x", colors = "green")
  expect_s3_class(p2, "ggplot")
})

test_that("plot_hist alpha parameter", {
  set.seed(123)
  df <- data.frame(x = rnorm(40), group = rep(c("A", "B"), each = 20))
  
  p1 <- plot_hist(df, x = "x", alpha = 0.3)
  expect_s3_class(p1, "ggplot")
  
  p2 <- plot_hist(df, x = "x", group = "group", alpha = 0.8)
  expect_s3_class(p2, "ggplot")
})

test_that("plot_hist axis limits", {
  set.seed(123)
  df <- data.frame(x = rnorm(50), y = 1:50)
  
  p1 <- plot_hist(df, x = "x", y_limits = c(0, 15))
  expect_s3_class(p1, "ggplot")
  
  p2 <- plot_hist(df, x = "x", x_limits = c(-2, 2))
  expect_s3_class(p2, "ggplot")
})

test_that("plot_hist labels", {
  set.seed(123)
  df <- data.frame(x = rnorm(50), y = 1:50)
  
  p <- plot_hist(df, x = "x",
                 title = "Test Plot",
                 xlab = "X Variable",
                 ylab = "Count")
  
  expect_s3_class(p, "ggplot")
  expect_equal(p$labels$title, "Test Plot")
  expect_equal(p$labels$x, "X Variable")
  expect_equal(p$labels$y, "Count")
})

test_that("plot_hist missing values", {
  set.seed(123)
  df <- data.frame(
    x = c(rnorm(18), NA, NA),
    group = c(rep(c("A", "B"), 9), NA, NA)
  )
  
  p <- plot_hist(df, x = "x", group = "group")
  expect_s3_class(p, "ggplot")
})

test_that("plot_hist different data types", {
  df_int <- data.frame(x = 1:30, y = letters[1:30])
  p1 <- plot_hist(df_int, x = "x")
  expect_s3_class(p1, "ggplot")
  
  df_same <- data.frame(x = rep(10, 25), y = 1:25)
  p2 <- plot_hist(df_same, x = "x")
  expect_s3_class(p2, "ggplot")
})
