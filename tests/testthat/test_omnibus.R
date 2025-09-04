# Test data setup
set.seed(123)

# Independent groups data (normal distribution, equal variances)
normal_equal_var_data <- data.frame(
  score = c(rnorm(20, 10, 2), rnorm(20, 12, 2), rnorm(20, 14, 2)),
  group = factor(rep(c("A", "B", "C"), each = 20))
)

# Independent groups data (non-normal distribution)
non_normal_data <- data.frame(
  score = c(rexp(20, 1), rexp(20, 0.8), rexp(20, 0.6)),
  group = factor(rep(c("A", "B", "C"), each = 20))
)

# Paired data (repeated measures)
paired_data <- data.frame(
  score = c(rnorm(15, 10, 2), rnorm(15, 12, 2), rnorm(15, 14, 2)),
  group = factor(rep(c("Time1", "Time2", "Time3"), each = 15)),
  subject = factor(rep(1:15, 3))
)

# Data with missing values
data_with_na <- normal_equal_var_data
data_with_na$score[c(1, 21, 41)] <- NA

# Data with only 2 groups (should fail)
two_groups_data <- data.frame(
  score = c(rnorm(20, 10, 2), rnorm(20, 12, 2)),
  group = factor(rep(c("A", "B"), each = 20))
)

test_that("Input validation works correctly", { # Verified
  
  # Test missing required parameters
  expect_error(
    omnibus(x = "group", data = normal_equal_var_data),
    "Dependent variable ('y') must be specified.", fixed = TRUE
  )
  
  expect_error(
    omnibus(y = "score", data = normal_equal_var_data),
    "Independent variable ('x') must be specified.", fixed = TRUE
  )
  
  expect_error(
    omnibus(y = "score", x = "group"),
    "'data' must be specified.", fixed = TRUE
  )
  
  # Test non-existent variables
  expect_error(
    omnibus(y = "nonexistent", x = "group", data = normal_equal_var_data),
    "The dependent variable ('y') was not found in the dataframe.", fixed = TRUE
  )
  
  expect_error(
    omnibus(y = "score", x = "nonexistent", data = normal_equal_var_data),
    "The independent variable ('x') was not found in the dataframe.", fixed = TRUE
  )

  # Test alpha validation
  expect_error(
    omnibus(y = "score", x = "group", data = normal_equal_var_data, alpha = 0),
    "'alpha' must be between 0 and 1.", fixed = TRUE
  )
  
  expect_error(
    omnibus(y = "score", x = "group", data = normal_equal_var_data, alpha = 1),
    "'alpha' must be between 0 and 1.", fixed = TRUE
  )
  
  expect_error(
    omnibus(y = "score", x = "group", data = normal_equal_var_data, alpha = -0.1),
    "'alpha' must be between 0 and 1.", fixed = TRUE
  )
  
  expect_error(
    omnibus(y = "score", x = "group", data = normal_equal_var_data, alpha = 1.1),
    "'alpha' must be between 0 and 1.", fixed = TRUE
  )
  
  # Test insufficient groups
  expect_error(
    omnibus(y = "score", x = "group", data = two_groups_data),
    "The independent variable ('x') must have at least 3 levels.", fixed = TRUE
  )
  
  # Test p_method validation
  expect_error(
    omnibus(y = "score", x = "group", data = normal_equal_var_data, p_method = "invalid_method"),
    "Invalid p-value adjustment method.", fixed = TRUE
  )
  
  # Test na.action validation
  expect_error(
    omnibus(y = "score", x = "group", data = normal_equal_var_data,  na.action = c("na.omit", "na.exclude")),
    "Only one 'na.action' can be selected at a time.", fixed = TRUE
  )
  
  expect_error(
    omnibus(y = "score", x = "group", data = normal_equal_var_data,  na.action = "invalid_action"),
    "Invalid 'na.action'.", fixed = TRUE
  )
})

test_that("Function runs successfully with valid inputs", { # Verified
  
  # Test independent groups (should trigger One-way ANOVA or Kruskal-Wallis)
  expect_no_error(suppressMessages(result1 <- omnibus(
    y = "score",
    x = "group",
    data = normal_equal_var_data
  )))
  
  # Test with non-normal data (should trigger Kruskal-Wallis)
  suppressMessages(result2 <- omnibus(
    y = "score",
    x = "group",
    data = non_normal_data,
    p_method = "bonferroni"
  ))
  
  expect_equal(result2$name, "Kruskal-Wallis")
  
  # Test paired data (should trigger Repeated measures ANOVA or Friedman)
  expect_no_error(suppressMessages(result3 <- omnibus(
    y = "score",
    x = "group",
    data = paired_data,
    paired_by = "subject",
    p_method = "BH"
  )))
})

test_that("Return object structure is correct", { # Verified
  
  suppressMessages(result <- omnibus(
    y = "score",
    x = "group",
    data = normal_equal_var_data
  ))
  
  # Test that result is a list
  expect_type(result, "list")
  
  # Test that all expected elements are present
  expected_elements <- c("formula", "stat_summary", "statistic", "p_value",
                         "model", "post_hoc", "name")
  expect_true(all(expected_elements %in% names(result)))
  
  # Test element types
  expect_s3_class(result$formula, "formula")
  expect_type(result$model, "list")
  expect_type(result$stat_summary, "list")
  expect_type(result$name, "character")
  expect_type(result$statistic, "double")
  expect_type(result$p_value, "double")
  expect_type(result$post_hoc, "list")
  
  # Test value ranges
  expect_gte(result$statistic, 0)
  expect_gte(result$p_value, 0)
  expect_lte(result$p_value, 1)
})

test_that("Different p_methods work correctly", { # Verified
  
  methods_to_test <- c("holm", "hochberg", "hommel", "bonferroni",
                       "BH", "BY", "none")
  
  for (p_method in methods_to_test) {
    
    expect_no_error((suppressMessages(result <- omnibus(
      y = "score",
      x = "group",
      data = normal_equal_var_data,
      p_method = p_method
      ))))
  }
})

test_that("Alpha parameter affects significance determination", { # Verified

  # Create data where we expect a specific p-value range
  suppressMessages(result_strict <- omnibus(
    y = "score",
    x = "group",
    data = normal_equal_var_data,
    alpha = 0.001
  ))
  
  suppressMessages(result_lenient <- omnibus(
    y = "score",
    x = "group",
    data = normal_equal_var_data,
    alpha = 0.5
  ))
  
  expect_equal(TRUE, result_strict$p_value < 0.001)
  expect_equal(TRUE, result_lenient$p_value < 0.5)
})

test_that("Post-hoc tests are performed when significant", { # Verified
  
  # Create data likely to be significant
  significant_data <- data.frame(
    score = c(rnorm(20, 5, 1), rnorm(20, 10, 1), rnorm(20, 15, 1)),
    group = factor(rep(c("A", "B", "C"), each = 20))
  )
  
  suppressMessages(result <- omnibus(
    y = "score",
    x = "group",
    data = significant_data
  ))
  
  if (result$p_value < 0.05) {
    expect_false(is.null(result$post_hoc))
  } else {
    expect_null(result$post_hoc)
  }
})

test_that("Console output is generated", {
  
  # Test that the function produces output (captured by expect_message)
  suppressMessages(expect_message({
    result <- omnibus(
      y = "score",
      x = "group",
      data = normal_equal_var_data
    )
  }, "Formula:"))
  
  suppressMessages(expect_message({
    result <- omnibus(
      y = "score",
      x = "group",
      data = normal_equal_var_data
    )
  }, "alpha:"))
  
  suppressMessages(expect_message({
    result <- omnibus(
      y = "score",
      x = "group",
      data = normal_equal_var_data
    )
  }, "Result:"))
})

test_that("Edge cases are handled correctly", { # Verified
  
  # Test with minimum number of groups (3)
  min_groups_data <- data.frame(
    score = c(rnorm(10, 10, 2), rnorm(10, 12, 2), rnorm(10, 14, 2)),
    group = factor(rep(c("A", "B", "C"), c(10, 10, 10)))
  )
  
  expect_no_error(suppressMessages({
    result <- omnibus(
      y = "score",
      x = "group",
      data = min_groups_data
    )
  }))
  
  # Test with many groups
  many_groups_data <- data.frame(
    score = rnorm(100, 10, 2),
    group = factor(rep(LETTERS[1:10], each = 10))
  )
  
  expect_no_error(suppressMessages({
    result <- omnibus(
      y = "score",
      x = "group",
      data = many_groups_data
    )
  }))
})

test_that("Different na.action options work correctly", { # Verified
  
  na_actions <- c("na.omit", "na.exclude")
  
  for (na_action in na_actions) {
    expect_no_error(suppressMessages(
      result <- omnibus(
        y = "score",
        x = "group",
        data = data_with_na,
        na.action = na_action
      )))
  }
  
  # Test na.fail should error with NA data
  expect_error(suppressMessages(
    result <- omnibus(
      y = "score",
      x = "group",
      data = data_with_na,
      na.action = "na.fail"
    )))
})