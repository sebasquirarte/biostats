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
    omnibus(x = "group", data = normal_equal_var_data, method = "holm", na.action = "na.omit"),
    "Dependent variable \\(y\\) must be specified."
  )

  expect_error(
    omnibus(y = "score", data = normal_equal_var_data, method = "holm", na.action = "na.omit"),
    "Independent variable \\(x\\) must be specified."
  )

  expect_error(
    omnibus(y = "score", x = "group", method = "holm", na.action = "na.omit"),
    "Dataframe must be specified."
  )

  expect_error(
    omnibus(y = "score", x = "group", data = normal_equal_var_data, na.action = "na.omit"),
    "Method must be specified."
  )

  expect_error(
    omnibus(y = "score", x = "group", data = normal_equal_var_data, method = "holm"),
    "na.action must be specified."
  )

  # Test non-existent variables
  expect_error(
    omnibus(y = "nonexistent", x = "group", data = normal_equal_var_data, method = "holm", na.action = "na.omit"),
    "The dependent variable \\(y\\) was not found in the dataframe."
  )

  expect_error(
    omnibus(y = "score", x = "nonexistent", data = normal_equal_var_data, method = "holm", na.action = "na.omit"),
    "The independent variable \\(x\\) was not found in the dataframe."
  )

  # Test alpha validation
  expect_error(
    omnibus(y = "score", x = "group", data = normal_equal_var_data, alpha = 0, method = "holm", na.action = "na.omit"),
    "alpha must be between 0 and 1."
  )

  expect_error(
    omnibus(y = "score", x = "group", data = normal_equal_var_data, alpha = 1, method = "holm", na.action = "na.omit"),
    "alpha must be between 0 and 1."
  )

  expect_error(
    omnibus(y = "score", x = "group", data = normal_equal_var_data, alpha = -0.1, method = "holm", na.action = "na.omit"),
    "alpha must be between 0 and 1."
  )

  expect_error(
    omnibus(y = "score", x = "group", data = normal_equal_var_data, alpha = 1.1, method = "holm", na.action = "na.omit"),
    "alpha must be between 0 and 1."
  )

  # Test insufficient groups
  expect_error(
    omnibus(y = "score", x = "group", data = two_groups_data, method = "holm", na.action = "na.omit"),
    "The independent variable \\(x\\) must have at least 3 levels."
  )

  # Test method validation
  expect_error(
    omnibus(y = "score", x = "group", data = normal_equal_var_data, method = c("holm", "bonferroni"), na.action = "na.omit"),
    "Only one method can be selected at a time."
  )

  expect_error(
    omnibus(y = "score", x = "group", data = normal_equal_var_data, method = "invalid_method", na.action = "na.omit"),
    "Invalid p-value adjustment method."
  )

  # Test na.action validation
  expect_error(
    omnibus(y = "score", x = "group", data = normal_equal_var_data, method = "holm", na.action = c("na.omit", "na.exclude")),
    "Only one na.action can be selected at a time."
  )

  expect_error(
    omnibus(y = "score", x = "group", data = normal_equal_var_data, method = "holm"),
    "na.action must be specified."
  )
})

test_that("Function runs successfully with valid inputs", { # Verified

  # Test independent groups (should trigger One-way ANOVA or Kruskal-Wallis)
    expect_no_error(capture.output(result1 <- omnibus(
      y = "score",
      x = "group",
      data = normal_equal_var_data,
      method = "holm",
      na.action = "na.omit"
    )))

  # Test with non-normal data (should trigger Kruskal-Wallis)
  capture.output(result2 <- omnibus(
      y = "score",
      x = "group",
      data = non_normal_data,
      method = "bonferroni",
      na.action = "na.omit"
    ))

  expect_equal(result2$name, "Kruskal-Wallis")

  # Test paired data (should trigger Repeated measures ANOVA or Friedman)
  expect_no_error(capture.output(result3 <- omnibus(
      y = "score",
      x = "group",
      data = paired_data,
      paired_var = "subject",
      method = "fdr",
      na.action = "na.omit"
    )))
})

test_that("Return object structure is correct", { # Verified

  capture.output(result <- omnibus(
    y = "score",
    x = "group",
    data = normal_equal_var_data,
    method = "holm",
    na.action = "na.omit"
  ))

  # Test that result is a list
  expect_type(result, "list")

  # Test that all expected elements are present
  expected_elements <- c("formula", "summary", "statistic", "p_value",
                         "n_groups", "significant", "alpha", "model",
                         "data", "post_hoc")
  expect_true(all(expected_elements %in% names(result)))

  # Test element types
  expect_s3_class(result$formula, "formula")
  expect_type(result$statistic, "double")
  expect_type(result$p_value, "double")
  expect_type(result$n_groups, "integer")
  expect_type(result$significant, "logical")
  expect_type(result$alpha, "double")
  expect_s3_class(result$data, "data.frame")

  # Test value ranges
  expect_gte(result$statistic, 0)
  expect_gte(result$p_value, 0)
  expect_lte(result$p_value, 1)
  expect_gte(result$n_groups, 3)
  expect_gte(result$alpha, 0)
  expect_lte(result$alpha, 1)
})

test_that("Different methods work correctly", { # Verified

  methods_to_test <- c("holm", "hochberg", "hommel", "bonferroni",
                       "BH", "BY", "fdr", "none")

  for (method in methods_to_test) {

    expect_no_error((capture.output(result <- omnibus(
      y = "score",
      x = "group",
      data = normal_equal_var_data,
      method = method,
      na.action = "na.omit"))))
    }
})

test_that("Different na.action options work correctly", { # Verified

  na_actions <- c("na.omit", "na.exclude")

  for (na_action in na_actions) {
    expect_no_error(capture.output(
      result <- omnibus(
        y = "score",
        x = "group",
        data = data_with_na,
        method = "holm",
        na.action = na_action
      )))
  }

  # Test na.fail should error with NA data
  na_actions <- c("na.pass", "na.fail")

  for (na_action in na_actions) {
  expect_error(capture.output(
    result <- omnibus(
      y = "score",
      x = "group",
      data = data_with_na,
      method = "holm",
      na.action = "na.fail"
    )))
  }
})

test_that("Factor conversion works correctly", { # Verified

  # Test with character independent variable (should be converted to factor)
  char_data <- normal_equal_var_data
  char_data$group <- as.character(char_data$group)

  expect_no_error(capture.output(
    result <- omnibus(
      y = "score",
      x = "group",
      data = char_data,
      method = "holm",
      na.action = "na.omit"
    )))

  expect_s3_class(result$data$group, "factor")
})

test_that("Alpha parameter affects significance determination", { # Verified

  # Create data where we expect a specific p-value range
  capture.output(result_strict <- omnibus(
    y = "score",
    x = "group",
    data = normal_equal_var_data,
    alpha = 0.001,  # Very strict
    method = "holm",
    na.action = "na.omit"
  ))

  capture.output(result_lenient <- omnibus(
    y = "score",
    x = "group",
    data = normal_equal_var_data,
    alpha = 0.5,   # Very lenient
    method = "holm",
    na.action = "na.omit"
  ))

  expect_equal(result_strict$alpha, 0.001)
  expect_equal(result_lenient$alpha, 0.5)
  expect_equal(result_strict$significant, result_strict$p_value < 0.001)
  expect_equal(result_lenient$significant, result_lenient$p_value < 0.5)
})

test_that("Post-hoc tests are performed when significant", { # Verified

  # Create data likely to be significant
  significant_data <- data.frame(
    score = c(rnorm(20, 5, 1), rnorm(20, 10, 1), rnorm(20, 15, 1)),
    group = factor(rep(c("A", "B", "C"), each = 20))
  )

  capture.output(result <- omnibus(
    y = "score",
    x = "group",
    data = significant_data,
    method = "holm",
    na.action = "na.omit"
  ))

  if (result$significant) {
    expect_false(is.null(result$post_hoc))
  } else {
    expect_null(result$post_hoc)
  }
})

test_that("Console output is generated", {

  # Test that the function produces output (captured by expect_output)
  expect_output({
    result <- omnibus(
      y = "score",
      x = "group",
      data = normal_equal_var_data,
      method = "holm",
      na.action = "na.omit"
    )
  }, "Formula:")

  expect_output({
    result <- omnibus(
      y = "score",
      x = "group",
      data = normal_equal_var_data,
      method = "holm",
      na.action = "na.omit"
    )
  }, "Alpha")

  expect_output({
    result <- omnibus(
      y = "score",
      x = "group",
      data = normal_equal_var_data,
      method = "holm",
      na.action = "na.omit"
    )
  }, "Result:")
})

test_that("Edge cases are handled correctly", { # Verified

  # Test with minimum number of groups (3)
  min_groups_data <- data.frame(
    score = c(rnorm(10, 10, 2), rnorm(10, 12, 2), rnorm(10, 14, 2)),
    group = factor(rep(c("A", "B", "C"), c(10, 10, 10)))
  )

  capture.output({
    result <- omnibus(
      y = "score",
      x = "group",
      data = min_groups_data,
      method = "holm",
      na.action = "na.omit"
    )
  })

  expect_equal(result$n_groups, 3)

  # Test with many groups
  many_groups_data <- data.frame(
    score = rnorm(100, 10, 2),
    group = factor(rep(LETTERS[1:10], each = 10))
  )

  capture.output({
    result <- omnibus(
      y = "score",
      x = "group",
      data = many_groups_data,
      method = "holm",
      na.action = "na.omit"
    )
  })

  expect_equal(result$n_groups, 10)
})
