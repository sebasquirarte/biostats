# Test data setup
set.seed(123)

# Normal data
normal_equal_var_data <- data.frame(
  score = c(rnorm(20,10,2), rnorm(20,12,2), rnorm(20,14,2)),
  group = factor(rep(c("A","B","C"), each = 20))
)

# Non normal data
non_normal_data <- data.frame(
  score = c(rexp(20,1), rexp(20,0.8), rexp(20,0.6)),
  group = factor(rep(c("A","B","C"), each = 20))
)

# Paired data
paired_data <- data.frame(
  score = c(rnorm(15,10,2), rnorm(15,12,2), rnorm(15,14,2)),
  group = factor(rep(c("Time1","Time2","Time3"), each = 15)),
  subject = factor(rep(1:15,3))
)

# Paired data with NAs introduced
data_with_na <- normal_equal_var_data
data_with_na$score[c(1,21,41)] <- NA
two_groups_data <- data.frame(
  score = c(rnorm(20,10,2), rnorm(20,12,2)),
  group = factor(rep(c("A","B"), each = 20))
)

test_that("Input validation works correctly", { # Verified
  # Missing parameters
  expect_error(omnibus(x = "group", data = normal_equal_var_data),
               "Dependent variable ('y') must be specified.", fixed = TRUE)
  expect_error(omnibus(y = "score", data = normal_equal_var_data),
               "Independent variable ('x') must be specified.", fixed = TRUE)
  expect_error(omnibus(y = "score", x = "group"), "'data' must be specified.", fixed = TRUE)
  
  # Non-existent variables
  expect_error(omnibus(y = "nonexistent", x = "group", data = normal_equal_var_data),
               "The dependent variable ('y') was not found in the dataframe.", fixed = TRUE)
  expect_error(omnibus(y = "score", x = "nonexistent", data = normal_equal_var_data),
               "The independent variable ('x') was not found in the dataframe.", fixed = TRUE)
  
  # Alpha validation
  for(a in c(0,1,-0.1,1.1)) {
    expect_error(omnibus(y = "score", x = "group", data = normal_equal_var_data, alpha = a),
                 "'alpha' must be between 0 and 1.", fixed = TRUE)
  }
  
  # Insufficient groups
  expect_error(omnibus(y = "score", x = "group", data = two_groups_data),
               "must have at least 3 levels", fixed = TRUE)
  
  # p_method & na.action validation
  expect_error(omnibus(y = "score", x = "group", data = normal_equal_var_data, p_method = "invalid_method"),
               "Invalid p-value adjustment", fixed = TRUE)
  expect_error(omnibus(y = "score", x = "group", data = normal_equal_var_data, na.action = c("na.omit","na.exclude")),
               "Only one 'na.action' can be selected", fixed = TRUE)
  expect_error(omnibus(y = "score", x = "group", data = normal_equal_var_data, na.action = "invalid_action"),
               "Invalid 'na.action'", fixed = TRUE)
})

test_that("Return object structure is correct", { # Verified
  
  result <- omnibus(y = "score", x = "group", data = normal_equal_var_data)
  
  expect_type(result, "list")
  
  # Elements expected in the output
  expected_elements <- c("formula","stat_summary","statistic","p_value","post_hoc","name")
  expect_true(all(expected_elements %in% names(result)))
  expect_type(result$formula, "character")
  expect_type(result$stat_summary, "list")
  expect_type(result$name, "character")
  expect_type(result$statistic, "double")
  expect_type(result$p_value, "double")
  expect_type(result$post_hoc, "list")
  expect_gte(result$statistic, 0)
  expect_gte(result$p_value, 0)
  expect_lte(result$p_value, 1)
})

test_that("Different p_methods work correctly", {
  
  for(p_method in c("holm","hochberg","hommel","bonferroni","BH","BY","none")) {
    expect_no_error(result <- omnibus(y = "score", x = "group", data = normal_equal_var_data, p_method = p_method))
  }
  
})

test_that("Post-hoc tests are performed when significant", {
  # Create greatly different data
  sig_data <- data.frame(
    score = c(rnorm(20, 5, 1),rnorm(20, 10, 1),rnorm(20, 15, 1)),
    group = factor(rep(c("A","B","C"), each = 20))
  )
  
  result <- omnibus(y = "score", x = "group", data = sig_data)
  
  # Are post-hoc tests performed ?
  if(result$p_value < 0.05) expect_false(is.null(result$post_hoc)) else expect_null(result$post_hoc)
})

test_that("Console output is generated", {
  # Expected characters to be printed ->
  expect_output(print(omnibus(y = "score", x = "group", data = normal_equal_var_data)), "Formula:")
  expect_output(print(omnibus(y = "score", x = "group", data = normal_equal_var_data)), "alpha:")
  expect_output(print(omnibus(y = "score", x = "group", data = normal_equal_var_data)), "Result:")
})

test_that("Edge cases are handled correctly", {
  min_groups_data <- data.frame(score = c(rnorm(10,10,2),rnorm(10,12,2),rnorm(10,14,2)),
                                group = factor(rep(c("A","B","C"), each = 10)))
  expect_no_error(result <- omnibus(y = "score", x = "group", data = min_groups_data))
  
  many_groups_data <- data.frame(score = rnorm(100,10,2), group = factor(rep(LETTERS[1:10], each = 10)))
  expect_no_error(result <- omnibus(y = "score", x = "group", data = many_groups_data))
})

test_that("Different na.action options work correctly", {
  for(na_action in c("na.omit","na.exclude")) {
    expect_no_error(result <- omnibus(y = "score", x = "group", data = data_with_na, na.action = na_action))
  }
  
  # na.fail is not supported + will cause function to fail
  expect_error(result <- omnibus(y = "score", x = "group", data = data_with_na, na.action = "na.fail"))
})

test_that("util-omnibus is working", {
  df <- data.frame(score = 1:3, group = factor(c("A","B","C")))
  
  # Testing the tryCatch() in .assumptions()
  expect_warning(.assumptions(formula = score ~ group, y = "nonexistent_column",
                              x = "group", data = df, paired_by = NULL, alpha = 0.05, num_levels = 3),
                 regexp="Assumption evaluation failed")
})

test_that("Sphericity evaluation works", {
  # .assumptions
  res <- .assumptions(formula = score ~ group, y = "score", x = "group", data = paired_data, paired_by = "subject", alpha = 0.05,
                      num_levels = length(levels(paired_data$group)))
  
  # When paired sphericity can not be NULL
  expect_true(!is.null(res$sphericity_results))
  
  # Evaluate the existing elements
  sph <- res$sphericity_results
  expect_named(sph, c("test","statistic","p_value","df","key"))
  expect_type(sph$test,"character")
  expect_type(sph$statistic,"double")
  expect_type(sph$p_value,"double")
  expect_type(sph$key,"character")
  expect_true(sph$key %in% c("significant","non_significant"))
})

test_that("Post-hoc result structure is valid", {
  post_hoc <- .post_hoc(name = "Repeated measures ANOVA", y = "score", x = "group", paired_by = "subject", p_method = "BH", alpha = 0.05, model = NULL, data = paired_data)
  
  # Are these two elements found in names(post_hoc) ?
  expect_true(all(c("post_hoc","p_method") %in% names(post_hoc)))
  
  # Evaluates output and structure
  p_matrix <- post_hoc$post_hoc$p.value
  expect_true(is.matrix(p_matrix))
  expect_type(p_matrix,"double")
  expect_true(all(rownames(p_matrix) %in% levels(paired_data$group)))
  expect_true(all(colnames(p_matrix) %in% levels(paired_data$group)))
})
