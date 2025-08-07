testthat::test_that("one-sample equivalence test for means example", {
  # Run first example in sample_size's documentation
  capture.output(result <- sample_size(sample = 'one-sample',
                                       outcome = 'mean',
                                       type = 'equivalence',
                                       x1 = 0,
                                       x2 = 0,
                                       SD = 0.1,
                                       delta = 0.05,
                                       alpha = 0.05,
                                       beta = 0.20))

  # Check return structure
  expect_type(result, "list")
  expect_named(result, c("n1", "n2", "total", "sample", "design", "outcome",
                         "type", "alpha", "beta", "x1", "x2", "SD", "delta",
                         "k", "z_alpha", "z_beta", "zscore"))

  # Check specific values
  expect_equal(result$sample, "one-sample")
  expect_equal(result$outcome, "mean")
  expect_equal(result$type, "equivalence")
  expect_equal(result$design, NULL)

  # Check input parameters are preserved
  expect_equal(result$alpha, 0.05)
  expect_equal(result$beta, 0.20)
  expect_equal(result$x1, 0)
  expect_equal(result$x2, 0)
  expect_equal(result$SD, 0.1)
  expect_equal(result$delta, 0.05)

  # Check calculated results
  expect_equal(result$n2, 35)
  expect_equal(result$n1, 35)
  expect_equal(result$total, result$n2)

  # Ensure no missing values in critical components
  expect_false(is.na(result$n2))
  expect_false(is.na(result$total))
  expect_false(is.na(result$z_alpha))
  expect_false(is.na(result$z_beta))
})

testthat::test_that("two-sample parallel non-inferiority test for proportions with 10% dropout example", {
  # Run first example in sample_size's documentation
  capture.output(result <- sample_size(sample = 'two-sample',
                                       design = "parallel",
                                       outcome = 'proportion',
                                       type = 'non-inferiority',
                                       x1 = 0.85,
                                       x2 = 0.65,
                                       alpha = 0.05,
                                       beta = 0.20,
                                       delta = -0.1,
                                       dropout_rate = 0.1))


  # Check calculated results
  expect_equal(result$n2, 28)
  expect_equal(result$n1, 28)
  expect_equal(result$total, result$n2 + result$n1)
})

testthat::test_that("two-sample crossover non-inferiority test for means example", {
  # Run first example in sample_size's documentation
  capture.output(result <-  sample_size(sample = 'two-sample',
                                        design = "crossover",
                                        outcome = 'mean',
                                        type = 'non-inferiority',
                                        x1 = -0.10,
                                        x2 = 0,
                                        SD = 0.20,
                                        delta = -0.20,
                                        alpha = 0.05,
                                        beta = 0.20))

  # Check calculated results
  expect_equal(result$n2, 13)
  expect_equal(result$n1, 13)
  expect_equal(result$total, result$n2 + result$n1)

})

testthat::test_that("input validation - missing required parameters", {
  # Missing x1
  expect_error(
    sample_size(sample = 'one-sample', outcome = 'mean', type = 'equality', x2 = 1),
    "Both x1 and x2 must be specified."
  )

  # Missing x2
  expect_error(
    sample_size(sample = 'one-sample', outcome = 'mean', type = 'equality', x1 = 1),
    "Both x1 and x2 must be specified."
  )

  # Missing design for two-sample
  expect_error(
    sample_size(sample = 'two-sample', outcome = 'mean', type = 'equality', x1 = 1, x2 = 2),
    "design must be specified for two-sample tests."
  )
})

testthat::test_that("input validation - SD requirements", {
  # SD missing when required (one-sample mean)
  expect_error(
    sample_size(sample = 'one-sample', outcome = 'mean', type = 'equality', x1 = 1, x2 = 2),
    "SD must be specified for this test configuration."
  )

  # SD provided when not needed (parallel proportion)
  expect_warning(capture.output(
    sample_size(sample = 'two-sample', design = 'parallel', outcome = 'proportion',
                type = 'equality', x1 = 0.5, x2 = 0.6, SD = 0.1),
    "SD is not needed for this test configuration."
  ))
})

testthat::test_that("input validation - delta requirements and signs", {
  # Delta missing for non-equality tests
  expect_error(
    sample_size(sample = 'one-sample', outcome = 'mean', type = 'equivalence',
                x1 = 1, x2 = 2, SD = 0.5),
    "delta must be provided for equivalence tests."
  )

  # Delta provided when not needed (equality)
  expect_warning(capture.output(
    sample_size(sample = 'one-sample', outcome = 'mean', type = 'equality',
                x1 = 1, x2 = 2, SD = 0.5, delta = 0.1),
    "delta is not needed for equality tests."
  ))


  # Wrong sign for non-inferiority (must be negative)
  expect_error(
    sample_size(sample = 'one-sample', outcome = 'mean', type = 'non-inferiority',
                x1 = 1, x2 = 2, SD = 0.5, delta = 0.1),
    "delta must be negative for non-inferiority tests."
  )

  # Wrong sign for superiority (must be positive)
  expect_error(
    sample_size(sample = 'one-sample', outcome = 'mean', type = 'superiority',
                x1 = 1, x2 = 2, SD = 0.5, delta = -0.1),
    "delta must be positive for superiority tests."
  )

  # Wrong sign for equivalence (must be positive)
  expect_error(
    sample_size(sample = 'one-sample', outcome = 'mean', type = 'equivalence',
                x1 = 1, x2 = 2, SD = 0.5, delta = -0.1),
    "delta must be positive for equivalence tests."
  )

})

testthat::test_that("input validation - dropout rate", {
  # Non-supported dropout rate
  expect_error(
    sample_size(sample = 'one-sample', outcome = 'mean', type = 'equality',
                x1 = 1, x2 = 2, SD = 0.5, alpha = 0.05, beta = 0.20, dropout_rate = 1)
  )

  expect_error(
    sample_size(sample = 'one-sample', outcome = 'mean', type = 'equality',
                x1 = 1, x2 = 2, SD = 0.5, alpha = 0.05, beta = 0.20, dropout_rate = -0.1)
  )
})

testthat::test_that("numerical outputs are always finite and positive", {
  capture.output(result <- sample_size(
    sample = 'one-sample', outcome = 'mean', type = 'equality',
    x1 = 1, x2 = 2, SD = 0.5, alpha = 0.05, beta = 0.20
  ))

  # Sample sizes should be positive integers
  expect_gt(result$n2, 0)
  expect_gt(result$total, 0)
  expect_true(is.finite(result$n2))
  expect_true(is.finite(result$total))

  # Z-scores should be positive and finite
  expect_gt(result$z_alpha, 0)
  expect_gt(result$z_beta, 0)
  expect_gt(result$zscore, 0)
  expect_true(is.finite(result$z_alpha))
  expect_true(is.finite(result$z_beta))
  expect_true(is.finite(result$zscore))
})

