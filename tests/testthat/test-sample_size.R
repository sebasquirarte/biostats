testthat::test_that("basic function examples work correctly", {
  # One-sample equivalence test
  capture.output(result1 <- sample_size(sample = "one-sample", outcome = "mean",
                                        type = "equivalence", x1 = 0, x2 = 0,
                                        SD = 0.1, delta = 0.05))
  
  expect_type(result1, "list")
  expect_equal(result1$sample, "one-sample")
  expect_equal(result1$n2, 35)
  expect_equal(result1$total, 35)
  
  # Two-sample parallel test with dropout
  capture.output(result2 <- sample_size(sample = "two-sample", design = "parallel",
                                        outcome = "proportion", type = "non-inferiority",
                                        x1 = 0.85, x2 = 0.65, delta = -0.1, dropout = 0.1))
  
  expect_equal(result2$n1, 28)
  expect_equal(result2$n2, 28)
  expect_equal(result2$total, 56)
  
  # Crossover design
  capture.output(result3 <- sample_size(sample = "two-sample", design = "crossover",
                                        outcome = "mean", type = "non-inferiority",
                                        x1 = -0.10, x2 = 0, SD = 0.20, delta = -0.20))
  
  expect_equal(result3$n2, 13)
  expect_equal(result3$total, 26)
})

testthat::test_that("required parameters validation", {
  expect_error(sample_size(sample = "one-sample", outcome = "mean", type = "equality", x2 = 1),
               "Both 'x1' and 'x2' must be specified")
  
  expect_error(sample_size(sample = "two-sample", outcome = "mean", type = "equality", x1 = 1, x2 = 2),
               "'design' must be specified for two-sample tests")
})

testthat::test_that("alpha and beta validation", {
  expect_error(sample_size(sample = "one-sample", outcome = "mean", type = "equality",
                           x1 = 1, x2 = 2, SD = 0.5, alpha = 0),
               "'alpha' must be between 0 and 1")
  
  expect_error(sample_size(sample = "one-sample", outcome = "mean", type = "equality",
                           x1 = 1, x2 = 2, SD = 0.5, alpha = 1.5),
               "'alpha' must be between 0 and 1")
  
  expect_error(sample_size(sample = "one-sample", outcome = "mean", type = "equality",
                           x1 = 1, x2 = 2, SD = 0.5, beta = 0),
               "'beta' must be between 0 and 1")
  
  expect_error(sample_size(sample = "one-sample", outcome = "mean", type = "equality",
                           x1 = 1, x2 = 2, SD = 0.5, beta = 1.2),
               "'beta' must be between 0 and 1")
})

testthat::test_that("dropout and k validation", {
  expect_error(sample_size(sample = "one-sample", outcome = "mean", type = "equality",
                           x1 = 1, x2 = 2, SD = 0.5, dropout = -0.1),
               "'dropout' must be between 0 and 1")
  
  expect_error(sample_size(sample = "one-sample", outcome = "mean", type = "equality",
                           x1 = 1, x2 = 2, SD = 0.5, dropout = 1),
               "'dropout' must be between 0 and 1")
  
  expect_error(sample_size(sample = "one-sample", outcome = "mean", type = "equality",
                           x1 = 1, x2 = 2, SD = 0.5, k = 0),
               "'k' must be positive")
})

testthat::test_that("proportion bounds validation", {
  expect_error(sample_size(sample = "one-sample", outcome = "proportion", type = "equality",
                           x1 = -0.1, x2 = 0.5),
               "'x1' and 'x2' must be between 0 and 1 for proportion outcomes")
  
  expect_error(sample_size(sample = "one-sample", outcome = "proportion", type = "equality",
                           x1 = 1.1, x2 = 0.5),
               "'x1' and 'x2' must be between 0 and 1 for proportion outcomes")
})

testthat::test_that("SD requirements", {
  expect_error(sample_size(sample = "one-sample", outcome = "mean", type = "equality", 
                           x1 = 1, x2 = 2),
               "'SD' must be specified for this test configuration")
  
  expect_warning(capture.output(sample_size(sample = "two-sample", design = "parallel", 
                                            outcome = "proportion", type = "equality", 
                                            x1 = 0.5, x2 = 0.6, SD = 0.1)),
                 "'SD' is not needed for this test configuration")
  
  expect_error(sample_size(sample = "one-sample", outcome = "mean", type = "equality",
                           x1 = 1, x2 = 2, SD = 0),
               "'SD' must be a positive single numeric value")
})

testthat::test_that("delta requirements", {
  expect_error(sample_size(sample = "one-sample", outcome = "mean", type = "equivalence",
                           x1 = 1, x2 = 2, SD = 0.5),
               "'delta' must be provided for equivalence tests")
  
  expect_warning(capture.output(sample_size(sample = "one-sample", outcome = "mean", 
                                            type = "equality", x1 = 1, x2 = 2, SD = 0.5, delta = 0.1)),
                 "'delta' is not needed for equality tests")
})

testthat::test_that("delta sign validation", {
  expect_error(sample_size(sample = "one-sample", outcome = "mean", type = "non-inferiority",
                           x1 = 1, x2 = 2, SD = 0.5, delta = 0.1),
               "'delta' must be negative for non-inferiority tests")
  
  expect_error(sample_size(sample = "one-sample", outcome = "mean", type = "superiority",
                           x1 = 1, x2 = 2, SD = 0.5, delta = -0.1),
               "'delta' must be positive for superiority tests")
  
  expect_error(sample_size(sample = "one-sample", outcome = "mean", type = "equivalence",
                           x1 = 1, x2 = 2, SD = 0.5, delta = -0.1),
               "'delta' must be positive for equivalence tests")
})

testthat::test_that("invalid argument choices", {
  expect_error(sample_size(sample = "invalid", outcome = "mean", type = "equality",
                           x1 = 1, x2 = 2, SD = 0.5),
               "'arg' should be one of")
  
  expect_error(sample_size(sample = "one-sample", outcome = "invalid", type = "equality",
                           x1 = 1, x2 = 2, SD = 0.5),
               "'arg' should be one of")
  
  expect_error(sample_size(sample = "two-sample", design = "invalid", outcome = "mean", 
                           type = "equality", x1 = 1, x2 = 2, SD = 0.5),
               "'arg' should be one of")
})

testthat::test_that("vector input validation", {
  expect_error(sample_size(sample = "one-sample", outcome = "mean", type = "equality", 
                           x1 = c(1, 2), x2 = 2, SD = 0.5),
               "Numeric parameters must be single values")
})

testthat::test_that("return list structure", {
  capture.output(result <- sample_size(sample = "one-sample", outcome = "mean", 
                                       type = "equality", x1 = 1, x2 = 2, SD = 0.5))
  
  expected_names <- c('n1', 'n2', 'total', 'sample', 'design', 'outcome', 'type', 'alpha', 'beta', 'x1', 'x2', 'diff', 'SD', 'delta', 'dropout', 'k')
  
  expect_named(result, expected_names)
  expect_gt(result$n2, 0)
  expect_gt(result$total, 0)
  expect_true(is.finite(result$n2))
  expect_true(is.finite(result$total))
})

testthat::test_that("dropout calculation", {
  capture.output(no_dropout <- sample_size(sample = "two-sample", design = "parallel",
                                           outcome = "mean", type = "equality",
                                           x1 = 5, x2 = 5.5, SD = 1, dropout = 0))
  
  capture.output(with_dropout <- sample_size(sample = "two-sample", design = "parallel",
                                             outcome = "mean", type = "equality",
                                             x1 = 5, x2 = 5.5, SD = 1, dropout = 0.1))
  
  expect_gt(with_dropout$n1, no_dropout$n1)
  expect_gt(with_dropout$total, no_dropout$total)
})

testthat::test_that("design differences", {
  capture.output(parallel <- sample_size(sample = "two-sample", design = "parallel",
                                         outcome = "mean", type = "equality",
                                         x1 = 5, x2 = 5.5, SD = 1))
  
  capture.output(crossover <- sample_size(sample = "two-sample", design = "crossover",
                                          outcome = "mean", type = "equality",
                                          x1 = 5, x2 = 5.5, SD = 1))
  
  expect_lt(crossover$total, parallel$total)
})

testthat::test_that("allocation ratio effects", {
  capture.output(equal <- sample_size(sample = "two-sample", design = "parallel",
                                      outcome = "mean", type = "equality",
                                      x1 = 5, x2 = 5.5, SD = 1, k = 1))
  
  capture.output(unequal <- sample_size(sample = "two-sample", design = "parallel",
                                        outcome = "mean", type = "equality",
                                        x1 = 5, x2 = 5.5, SD = 1, k = 2))
  
  expect_equal(unequal$n1, 2 * unequal$n2)
  expect_gt(unequal$total, equal$total)
})

testthat::test_that("console output is suppressible", {
  expect_silent(capture.output(sample_size(sample = "one-sample", outcome = "mean",
                                           type = "equality", x1 = 1, x2 = 2, SD = 0.5)))
})