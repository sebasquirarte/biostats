test_that("Input validation works correctly", {
  # Test NA handling
  expect_error(effect_measures(NA, 2, 3, 4), "NA values found in data.")
  
  # Test negative values handling
  expect_error(effect_measures(1, 0, 1, -4), "Negative values found in data.")
  
  # Test non-numeric values
  expect_error(effect_measures("a", 2, 3, 4), "Values must be numeric integers.")
  
  # Test non-integer values
  expect_error(effect_measures(1.5, 2, 3, 4), "Values must be numeric integers.")
  
  # Test missing data argument
  expect_error(effect_measures(), "argument \"exposed_event\" is missing")
})

test_that("Alpha validation works", {
  # Test non-numeric alpha
  expect_error(effect_measures(15, 85, 5, 95, alpha = "0.05"), 
               "'alpha' must be between 0 and 1.")
  # Test invalid alpha values
  expect_error(effect_measures(15, 85, 5, 95, alpha = -0.05), 
               "'alpha' must be between 0 and 1.")
})

test_that("Correction parameter validation works", {
  # Test non-logical correction
  expect_error(effect_measures(15, 85, 5, 95, correction = "TRUE"), 
               "'correction' must be TRUE or FALSE.")
  
  # Test multiple values for correction
  expect_error(effect_measures(15, 85, 5, 95, correction = c(TRUE, FALSE)), 
               "'correction' must be TRUE or FALSE.")
})

test_that("Zero values are handled correctly", {
  # Test when b and c are zero (should give error without correction)
  expect_error(capture.output(effect_measures(15, 0, 0, 95, correction = FALSE)), 
               "Cannot calculate.*odds ratio.*One or more zero values found in data")
  
  # Test when only c is zero (should give error for risk ratio without correction)
  expect_error(capture.output(effect_measures(15, 85, 0, 95, correction = FALSE)), 
               "Cannot calculate.*odds ratio.*risk ratio.*One or more zero values found in data")
  
  # Test with correction should work
  expect_no_error(capture.output(effect_measures(15, 0, 0, 95)))
  
  # Test edge case: when totals are zero
  expect_error(effect_measures(0, 0, 5, 95, correction = FALSE), "Cannot calculate risks when totals are zero.")
})

test_that("Basic calculations work with individual parameters", {
  # Classic 2x2 table: a=15, b=85, c=5, d=95
  capture.output(result <- effect_measures(15, 85, 5, 95))
  
  # Test structure
  expect_type(result, "list")
  expect_named(result, c("contingency_table", "odds_ratio", "or_ci", 
                         "risk_ratio", "rr_ci", "exposed_risk", 
                         "unexposed_risk", "absolute_risk_diff", "nnt_nnh",
                         "alpha", "problems", "has_zeroes", "correction"))
  
  # Test class
  expect_s3_class(result, "effect_measures")
  
  # Test contingency table
  expected_table <- matrix(c(15, 5, 85, 95), nrow = 2,
                           dimnames = list(c("Exposed", "Unexposed"),
                                           c("Event", "No Event")))
  expect_equal(result$contingency_table, expected_table)
  
  # Test odds ratio calculation: (15*95)/(85*5) = 1425/425 = 3.35
  expect_equal(result$odds_ratio, (15*95)/(85*5), tolerance = 1e-10)
  
  # Test risk calculations
  expect_equal(result$exposed_risk, 15/100, tolerance = 1e-10)
  expect_equal(result$unexposed_risk, 5/100, tolerance = 1e-10)
  
  # Test risk ratio: (15/100) / (5/100) = 3
  expect_equal(result$risk_ratio, 3, tolerance = 1e-10)
  
  # Test absolute risk difference
  expect_equal(result$absolute_risk_diff, 0.15 - 0.05, tolerance = 1e-10)
  
  # Test NNT/NNH
  expect_equal(result$nnt_nnh, 1/0.1, tolerance = 1e-10)
})

test_that("Different alpha levels work", {
  capture.output(result_90 <- effect_measures(15, 85, 5, 95, alpha = 0.10))  # 90% CI
  capture.output(result_95 <- effect_measures(15, 85, 5, 95, alpha = 0.05))  # 95% CI
  capture.output(result_99 <- effect_measures(15, 85, 5, 95, alpha = 0.01))  # 99% CI
  
  # Check that CI widths increase as expected (99% > 95% > 90%)
  width_90 <- diff(result_90$or_ci)
  width_95 <- diff(result_95$or_ci)
  width_99 <- diff(result_99$or_ci)
  
  expect_true(width_99 > width_95)
  expect_true(width_95 > width_90)
  
  # Point estimates should be the same
  expect_equal(result_90$odds_ratio, result_95$odds_ratio)
  expect_equal(result_95$odds_ratio, result_99$odds_ratio)
})

test_that("Continuity correction works correctly", {
  # Test with zero values and correction
  capture.output(result_corrected <- effect_measures(15, 0, 5, 95))
  
  # With correction: a=15.5, b=0.5, c=5.5, d=95.5
  expected_or <- (15.5 * 95.5) / (0.5 * 5.5)
  expect_equal(result_corrected$odds_ratio, expected_or, tolerance = 1e-10)
  
  # Test that correction doesn't affect results when no zeros present
  capture.output(result_no_correction <- effect_measures(15, 85, 5, 95, correction = FALSE))
  capture.output(result_with_correction <- effect_measures(15, 85, 5, 95))
  
  expect_equal(result_no_correction$odds_ratio, result_with_correction$odds_ratio)
})

test_that("Printed output contains expected elements", {
  output <- capture.output(effect_measures(15, 85, 5, 95))
  output_text <- paste(output, collapse = "\n")
  
  # Check for key elements in output
  expect_true(grepl("Odds/Risk Ratio Analysis", output_text))
  expect_true(grepl("Contingency Table:", output_text))
  expect_true(grepl("Odds Ratio:", output_text))
  expect_true(grepl("Risk Ratio:", output_text))
  expect_true(grepl("Risk in exposed:", output_text))
  expect_true(grepl("Risk in unexposed:", output_text))
  expect_true(grepl("Absolute risk difference:", output_text))
  expect_true(grepl("Number needed to", output_text))
})
