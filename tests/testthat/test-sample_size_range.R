test_that("sample_size_range basic functionality", {
  res <- NULL
  capture.output({
    res <- sample_size_range(
      x1_range = c(0.65, 0.75), x2 = 0.65, step = 0.05,
      sample = "two-sample", design = "parallel",
      outcome = "proportion", type = "non-inferiority", delta = -0.1
    )
  }, file = NULL)
  
  expect_type(res, "list")
  expect_named(res, c("data", "plot"))
  expect_s3_class(res$data, "data.frame")
  expect_s3_class(res$plot, "ggplot")
})

test_that("sample_size_range data frame structure", {
  res <- NULL
  capture.output({
    res <- sample_size_range(
      x1_range = c(0.10, 0.30), x2 = 0.20, step = 0.10,
      sample = "one-sample", outcome = "mean", type = "equality", SD = 0.1
    )
  }, file = NULL)
  
  df <- res$data
  expect_equal(ncol(df), 7)
  expect_named(df, c("power", "x1", "x2", "diff", "n1", "n2", "total"))
  expect_setequal(unique(df$power), c(70, 80, 90))
  expect_equal(unique(df$x2), 0.20)
  expect_true(all(df$x1 %in% c(0.10, 0.20, 0.30)))
})

test_that("sample_size_range plot labels", {
  res <- NULL
  capture.output({
    res <- sample_size_range(
      x1_range = c(0.50, 0.60), x2 = 0.50, step = 0.05,
      sample = "two-sample", design = "parallel",
      outcome = "proportion", type = "equality"
    )
  }, file = NULL)
  
  p <- res$plot
  expect_s3_class(p, "ggplot")
  expect_equal(p$labels$x, "x1 (Treatment Effect)")
  expect_equal(p$labels$y, "Total Sample Size")
})

