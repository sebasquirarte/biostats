#' Tests for comparing three or more groups (omnibus)
#'
#' Omnibus tests evaluate overall effects in the given data. One-way ANOVA,
#' Repeated measures ANOVA, Kruskal Wallis test and Friedman test are included
#' in this term.
#'
#' @param dependent_var Character string. Name of the column that contains the data of the dependent variable.
#' @param independent_var Character string. Name of the column that contains the data of the independent variable.
#' @param data Character string. Name of the dataframe where the independent, dependent and paired variables are found.
#' @param paired_var Character string. Name of the column that contains the data of the paired variable. If paired,
#'                   the dataframe must have each group organized in these two options: (A, B, C, A, B, C, A, B, C) or (A, A, A, B, B, B, C, C, C)
#' @param alpha Numeric. Type I error rate (significance level). Default is 0.05.
#' @param method Character string. Method wanted to conduct a multiplicity correction.
#' @param na.action What to do when NAs are found in data.
#'
#' @examples
#' # Examples go here
#' @export
#'
#' @importFrom car leveneTest
#' @importFrom stats aov bartlett.test friedman.test kruskal.test lm mauchly.test shapiro.test as.formula na.action
#' @importFrom stats TukeyHSD pairwise.t.test pairwise.wilcox.test

omnibus <- function(dependent_var = NULL,
                          independent_var = NULL,
                          data = NULL,
                          paired_var = NULL,
                          alpha = 0.05,
                          method = c("holm", "hochberg", "hommel",
                                     "bonferroni", "BH", "BY",
                                     "fdr", "none"),
                          na.action = c("na.omit", "na.exclude", "na.pass", "na.fail")) {
  # Input validation
  if (missing(dependent_var)) stop("The dependent variable must be specified")
  if (missing(independent_var)) stop("The independent variable must be specified")
  if (missing(data)) stop("The dataframe where each variable is found must be specified")
  if (!(dependent_var %in% names(data))) stop("The dependent variable was not found in the specified dataframe")
  if (!(independent_var %in% names(data))) stop("The dependent variable was not found in the specified dataframe")
  if (alpha <= 0 || alpha >= 1) stop("alpha must be between 0 and 1")
  num_levels <- length(unique(data[[independent_var]]))
  if (num_levels < 3) stop("The independent variable must have at least 3 groups")
  if (!is.factor(data[[independent_var]])) data[[independent_var]] <- as.factor(data[[independent_var]])
  if (missing(method)) stop("Method must be specified")
  if (!(length(method) == 1)) stop("Only one method can be selected at a time")
  if (!(method %in% c("holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", "none"))) stop("Please specify a supported p-value adjustment method")
  method <- match.arg(method)
  if (missing(na.action)) stop("What to do when encountering NAs must be specified")
  if (!(length(na.action) == 1)) stop("Only one method can be selected at a time")
  if (!(na.action %in% c("na.omit", "na.exclude", "na.pass", "na.fail"))) stop("Please specify a supported na.action")
  na.action <- match.arg(na.action)

  # Formula building
  formula <- as.formula(paste(dependent_var, "~", independent_var))

  # Shapiro-Wilk per group
  shapiroResults <- lapply(split(data[[dependent_var]], data[[independent_var]]), shapiro.test)

  norm_var <- list(
    significant = "was not observed in all groups",
    non_significant = "was observed in all groups"
  )

  key1 <- if (any(sapply(shapiroResults, function(x) x$p.value < alpha))) "significant" else "non_significant"

  # Homogeneity of variances tests
  bartlettResults <- bartlett.test(formula, data = data)
  leveneResults <- leveneTest(formula, data = data)

  if (key1 == "significant") {
    var_res <- leveneResults$`Pr(>F)`[1]
    var.test <- "Levene"
  } else {
    var_res <- bartlettResults$p.value
    var.test <- "Bartlett"
  }

  key2 <- if (var_res < alpha) "significant" else "non_significant"

  # Sphericity assumption test
  if (!is.null(paired_var)) {
    order_eval <- data[[independent_var]][1:num_levels]
    byrow_setting <- if (length(unique(order_eval)) == num_levels) TRUE else FALSE
    matrix <- matrix(data[[dependent_var]], ncol = num_levels, byrow = byrow_setting)
    mauchlyResults <- mauchly.test(lm(matrix ~ 1), X = ~ 1)

    key3 <- if (mauchlyResults$p.value < alpha) "significant" else "non_significant"
  }

  if (is.null(paired_var)) {
    if (key1 == "non_significant" && key2 == "non_significant") { # One-way ANOVA
      model <- aov(formula, data = data, na.action = na.action)
      summary <- summary(model)
      name <- "One-way ANOVA"
    } else { # Kruskal Wallis test
      model <- kruskal.test(formula, data = data, na.action = na.action)
      name <- "Kruskal-Wallis test"
    }
  } else {
    if (key1 == "non_significant" && key2 == "non_significant" && key3 == "non_significant") { # Repeated measures ANOVA
      formula <- as.formula(paste(dependent_var, "~", independent_var, "+ Error(", paired_var, ")"))
      model <- aov(formula, data = data, na.action = na.action)
      summary <- summary(model)
      name <- "Repeated measures ANOVA"
    } else {
      formula <- as.formula(paste(deparse(formula[[2]]), "~", deparse(formula[[3]]), "|", paired_var))
      model <- friedman.test(formula, data = data, na.action = na.action) # Friedman test
      name <- "Friedman test"
    }
  }

  # Extract key statistics
  if (grepl("ANOVA", name)) {
    if (name == "One-way ANOVA") {
      stat <- summary[[1]][1, "F value"]
      p_value <- summary[[1]][1, "Pr(>F)"]
      df_between <- summary[[1]][1, "Df"]
      df_within <- summary[[1]][2, "Df"]
    } else {
      stat <- summary[[2]][[1]][independent_var, "F value"]
      p_value <- summary[[2]][[1]][independent_var, "Pr(>F)"]
      df_between <- summary[[2]][[1]][independent_var, "Df"]
      df_within <- summary[[2]][[1]]["Residuals", "Df"]
    }
  } else if (grepl("Friedman", name)) {
    stat <- model$statistic
    p_value <- model$p.value
    df <- model$parameter
  } else {
    stat <- unname(model$statistic)
    p_value <- model$p.value
    df <- unname(model$parameter)
  }

  # Print results
  cat(sprintf("%s\n\n", name))
  if (!is.null(paired_var)) cat(sprintf("Sphericity %s (method: Mauchly)\n", norm_var[[key3]]))
  cat(sprintf("Normality %s (method: Shapiro Wilk)\n", norm_var[[key1]]))
  cat(sprintf("Homogeneity of variance %s (method: %s)\n\n", norm_var[[key2]], var.test))
  cat(sprintf("Formula: %s\n", deparse(formula)))
  cat(sprintf("Alpha (\u03b1): %.3f\n", alpha))
  if (grepl("ANOVA", name)) {
    cat(sprintf("F(%d, %d) = %.3f, p = %s\n", df_between, df_within, stat, .format_p(p_value)))
  } else {
    cat(sprintf("X(%d) = %.3f, p = %s\n", df, stat, .format_p(p_value)))
  }
  cat(sprintf("Result: %s\n\n", ifelse(p_value < alpha, "Significant", "Not significant")))

  # Perform post-hoc tests if significant
  if (p_value < alpha) {
    cat("Post-hoc Multiple Comparisons\n\n")
    post_hoc <- .post_hoc(
      name = name,
      dependent_var = dependent_var,
      independent_var = independent_var,
      paired_var = paired_var,
      method = method,
      alpha = alpha,
      model = model,
      data = data,
      key1 = key1,
      key2 = key2,
      key3 = key3
    )
  } else {
  cat("Post-hoc tests not performed (Results not significant)\n")
  post_hoc <- NULL
  }

  # Initialize results
  results <- list(
    formula = formula,
    summary = summary,
    statistic = stat,
    p_value = p_value,
    n_groups = length(unique(data[[independent_var]])),
    significant = p_value < alpha,
    alpha = alpha,
    model = model,
    data = data,
    post_hoc = post_hoc,
    name = name
  )

  cat("\n")
  invisible(results)
}

