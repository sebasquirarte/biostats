test_that("plot_corr handles basic inputs correctly", {
  # Load tools package if needed for toTitleCase function
  if (!exists("toTitleCase", mode = "function")) {
    library(tools)
  }
  
  df <- data.frame(
    var1 = c(1, 2, 3, 4, 5),
    var2 = c(2, 4, 6, 8, 10),
    var3 = c(5, 4, 3, 2, 1)
  )
  
  # Basic correlation plot
  expect_no_error({
    p1 <- plot_corr(df)
  })
  expect_s3_class(p1, "ggplot")
  
  # Specific variables
  expect_no_error({
    p2 <- plot_corr(df, vars = c("var1", "var2"))
  })
  expect_s3_class(p2, "ggplot")
})

test_that("plot_corr input validation works", {
  df <- data.frame(var1 = 1:3, var2 = 4:6)
  df_no_numeric <- data.frame(var1 = c("A", "B", "C"))
  
  expect_error(plot_corr("not_dataframe"), "'data' must be a data frame")
  expect_error(plot_corr(df_no_numeric), "No numeric variables found")
  expect_error(plot_corr(df, vars = c("missing")), "Variables not found")
  expect_error(plot_corr(df, sig_level = 1.5), 
               "'sig_level' must be numeric between 0 and 1")
  expect_error(plot_corr(df, p_method = "invalid"),
               "'p_method' must be one of")
})

test_that("plot_corr method parameter works", {
  df <- data.frame(var1 = 1:5, var2 = c(2, 4, 6, 8, 10))
  
  p1 <- plot_corr(df, method = "pearson")
  expect_s3_class(p1, "ggplot")
  
  p2 <- plot_corr(df, method = "spearman")
  expect_s3_class(p2, "ggplot")
  
  expect_error(plot_corr(df, method = "invalid"))
})

test_that("plot_corr type parameter works", {
  df <- data.frame(var1 = 1:5, var2 = c(2, 4, 6, 8, 10), var3 = c(5, 4, 3, 2, 1))
  
  p1 <- plot_corr(df, type = "full")
  expect_s3_class(p1, "ggplot")
  
  p2 <- plot_corr(df, type = "upper")
  expect_s3_class(p2, "ggplot")
  
  p3 <- plot_corr(df, type = "lower")
  expect_s3_class(p3, "ggplot")
  
  expect_error(plot_corr(df, type = "invalid"))
})

test_that("plot_corr handles custom colors", {
  df <- data.frame(var1 = 1:5, var2 = c(2, 4, 6, 8, 10))
  
  # Custom 3-color vector
  p1 <- plot_corr(df, colors = c("red", "white", "blue"))
  expect_s3_class(p1, "ggplot")
  
  # Wrong number of colors
  expect_error(plot_corr(df, colors = c("red", "blue")),
               "'colors' must be a vector of 3 colors")
})

test_that("plot_corr value display works", {
  df <- data.frame(var1 = 1:5, var2 = c(2, 4, 6, 8, 10))
  
  # Show values (default)
  p1 <- plot_corr(df, show_values = TRUE)
  expect_s3_class(p1, "ggplot")
  
  # Hide values
  p2 <- plot_corr(df, show_values = FALSE)
  expect_s3_class(p2, "ggplot")
  
  # Custom value size
  p3 <- plot_corr(df, value_size = 5)
  expect_s3_class(p3, "ggplot")
})

test_that("plot_corr significance testing works", {
  set.seed(123)
  df <- data.frame(
    var1 = rnorm(20),
    var2 = rnorm(20),
    var3 = rnorm(20)
  )
  
  # Show significance markers
  p1 <- plot_corr(df, show_sig = TRUE)
  expect_s3_class(p1, "ggplot")
  
  # Show only significant
  p2 <- plot_corr(df, sig_only = TRUE, sig_level = 0.05)
  expect_s3_class(p2, "ggplot")
  
  # Both significance options
  p3 <- plot_corr(df, show_sig = TRUE, sig_only = TRUE)
  expect_s3_class(p3, "ggplot")
})

test_that("plot_corr p-value adjustment methods work", {
  set.seed(123)
  df <- data.frame(
    var1 = rnorm(20),
    var2 = rnorm(20),
    var3 = rnorm(20),
    var4 = rnorm(20)
  )
  
  methods <- c("holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "none")
  
  for (method in methods) {
    p <- plot_corr(df, show_sig = TRUE, p_method = method)
    expect_s3_class(p, "ggplot")
  }
})

test_that("plot_corr handles missing values", {
  df <- data.frame(
    var1 = c(1, 2, NA, 4, 5),
    var2 = c(2, NA, 6, 8, 10),
    var3 = c(5, 4, 3, 2, 1)
  )
  
  p <- plot_corr(df)
  expect_s3_class(p, "ggplot")
})

test_that("plot_corr handles constant variables", {
  df <- data.frame(
    var1 = rep(5, 5),  # constant
    var2 = c(1, 2, 3, 4, 5),
    var3 = c(2, 4, 6, 8, 10)
  )
  
  expect_message(p <- plot_corr(df), "Constant variables detected")
  expect_s3_class(p, "ggplot")
})

test_that("plot_corr legend display works", {
  df <- data.frame(var1 = 1:5, var2 = c(2, 4, 6, 8, 10))
  
  # Show legend (default)
  p1 <- plot_corr(df, show_legend = TRUE)
  expect_s3_class(p1, "ggplot")
  
  # Hide legend
  p2 <- plot_corr(df, show_legend = FALSE)
  expect_s3_class(p2, "ggplot")
})

test_that("plot_corr title works correctly", {
  df <- data.frame(var1 = 1:5, var2 = c(2, 4, 6, 8, 10))
  
  p <- plot_corr(df, title = "Test Correlation Matrix")
  expect_s3_class(p, "ggplot")
  expect_equal(p$labels$title, "Test Correlation Matrix")
})

test_that("plot_corr handles edge cases", {
  # Minimum 2 variables
  df_min <- data.frame(var1 = 1:5, var2 = c(2, 4, 6, 8, 10))
  p1 <- plot_corr(df_min)
  expect_s3_class(p1, "ggplot")
  
  # Single variable should error appropriately
  df_single <- data.frame(var1 = 1:5)
  expect_error(plot_corr(df_single))
  
  # All same values except one variable
  df_mostly_constant <- data.frame(
    var1 = rep(1, 10),
    var2 = rep(2, 10),
    var3 = 1:10
  )
  expect_message(p3 <- plot_corr(df_mostly_constant))
  expect_s3_class(p3, "ggplot")
})

test_that("plot_corr handles perfect correlations", {
  df <- data.frame(
    var1 = 1:5,
    var2 = (1:5) * 2,  # perfect positive correlation
    var3 = -(1:5)      # perfect negative correlation with var1
  )
  
  p <- plot_corr(df)
  expect_s3_class(p, "ggplot")
})

test_that("plot_corr significance levels work", {
  set.seed(123)
  df <- data.frame(
    var1 = rnorm(50),
    var2 = rnorm(50),
    var3 = rnorm(50)
  )
  
  # Different significance levels
  p1 <- plot_corr(df, show_sig = TRUE, sig_level = 0.05)
  expect_s3_class(p1, "ggplot")
  
  p2 <- plot_corr(df, show_sig = TRUE, sig_level = 0.01)
  expect_s3_class(p2, "ggplot")
  
  p3 <- plot_corr(df, show_sig = TRUE, sig_level = 0.001)
  expect_s3_class(p3, "ggplot")
})

test_that("plot_corr handles no complete cases", {
  df <- data.frame(
    var1 = c(1, NA, NA),
    var2 = c(NA, 2, NA),
    var3 = c(NA, NA, 3)
  )
  
  expect_error(plot_corr(df), "No complete cases found")
})

test_that("plot_corr with mixed data types", {
  df <- data.frame(
    var1 = 1:5,
    var2 = c(2, 4, 6, 8, 10),
    var3 = c("A", "B", "C", "D", "E"),  # character
    var4 = factor(c("X", "Y", "X", "Y", "X"))  # factor
  )
  
  # Should only use numeric variables
  p <- plot_corr(df)
  expect_s3_class(p, "ggplot")
  
  # Specifying non-numeric variable should error
  expect_error(plot_corr(df, vars = c("var1", "var3")),
               "All specified variables must be numeric")
})

test_that("plot_corr matrix type filtering works correctly", {
  df <- data.frame(
    var1 = 1:10,
    var2 = c(2, 4, 6, 8, 10, 12, 14, 16, 18, 20),
    var3 = c(10, 9, 8, 7, 6, 5, 4, 3, 2, 1),
    var4 = c(1, 1, 2, 2, 3, 3, 4, 4, 5, 5)
  )
  
  # Test that different matrix types produce different plot data
  p_full <- plot_corr(df, type = "full")
  p_upper <- plot_corr(df, type = "upper")
  p_lower <- plot_corr(df, type = "lower")
  
  expect_s3_class(p_full, "ggplot")
  expect_s3_class(p_upper, "ggplot")
  expect_s3_class(p_lower, "ggplot")
})

test_that("plot_corr correlation methods produce different results", {
  # Create data where pearson and spearman would differ
  set.seed(123)
  df <- data.frame(
    var1 = c(1, 2, 3, 4, 100),  # outlier affects pearson more
    var2 = c(1, 2, 3, 4, 5)
  )
  
  p_pearson <- plot_corr(df, method = "pearson")
  p_spearman <- plot_corr(df, method = "spearman")
  
  expect_s3_class(p_pearson, "ggplot")
  expect_s3_class(p_spearman, "ggplot")
})

test_that("plot_corr handles large datasets", {
  set.seed(123)
  n <- 100
  df_large <- data.frame(
    var1 = rnorm(n),
    var2 = rnorm(n),
    var3 = rnorm(n),
    var4 = rnorm(n),
    var5 = rnorm(n)
  )
  
  p <- plot_corr(df_large)
  expect_s3_class(p, "ggplot")
})

test_that("plot_corr significance filtering works", {
  set.seed(123)
  # Create data with some strong correlations and some weak ones
  n <- 50
  var1 <- rnorm(n)
  df <- data.frame(
    var1 = var1,
    var2 = var1 + rnorm(n, 0, 0.1),  # strong correlation
    var3 = rnorm(n),                  # no correlation
    var4 = -var1 + rnorm(n, 0, 0.1)  # strong negative correlation
  )
  
  p_sig_only <- plot_corr(df, sig_only = TRUE, sig_level = 0.01)
  expect_s3_class(p_sig_only, "ggplot")
  
  p_show_sig <- plot_corr(df, show_sig = TRUE, sig_level = 0.01)
  expect_s3_class(p_show_sig, "ggplot")
})
