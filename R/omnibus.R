#' Omnibus Tests for Comparing Three or More Groups
#'
#' Performs omnibus tests to evaluate overall differences between three or more groups.
#' Automatically selects the appropriate statistical test based on data characteristics
#' and assumption testing. Supports both independent groups and repeated measures designs.
#' Tests include one-way ANOVA, repeated measures ANOVA, Kruskal-Wallis test, and
#' Friedman test. Includes comprehensive assumption checking (normality, homogeneity
#' of variance, sphericity) and automatic post-hoc testing when significant results
#' are detected.
#'
#' @param y Character string. Dependent variable (outcome).
#' @param x Character string. Independent variable (groups). Must have at least three unique groups.
#' @param data Dataframe containing the variables.
#' @param paired_var Character string or NULL. Paired (within-subject) variable.
#'                   If provided, a repeated measures design is assumed. Data should be in long format with
#'                   one row per observation. If NULL, independent groups design is assumed.
#' @param alpha Numeric. Significance level for hypothesis tests. Default is 0.05.
#' @param method Character string. p-value adjustment method for multiple comparisons in post-hoc tests.
#'               One of "holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", or "none".
#' @param na.action Character string. Action to take if NAs are present. One of "na.omit", "na.exclude", "na.pass", or "na.fail".
#'
#' @return A list containing:
#' \item{formula}{The modelled formula used for the test.}
#' \item{summary}{Summary object of the model or test.}
#' \item{statistic}{Test statistic value (F or chi-squared).}
#' \item{p_value}{p-value observed in the omnibus test.}
#' \item{n_groups}{Number of groups in the independent variable.}
#' \item{significant}{Logical indicating whether the test was significant at the alpha level.}
#' \item{alpha}{Significance level used.}
#' \item{model}{The fitted model or test object.}
#' \item{data}{Input data frame.}
#' \item{post_hoc}{List of post-hoc test results if omnibus test was significant, otherwise NULL.}
#' \item{name}{Name of the test performed (e.g., "One-way ANOVA", "Kruskal-Wallis test", etc.).}
#'
#' @examples
#' # Examples go here
#'
#' @export
#'
#' @importFrom car leveneTest
#' @importFrom stats aov bartlett.test friedman.test kruskal.test lm mauchly.test shapiro.test as.formula na.action
#' @importFrom stats TukeyHSD pairwise.t.test pairwise.wilcox.test
#' @importFrom emmeans emmeans
#' @importFrom graphics pairs
omnibus <- function(y = NULL,
                    x = NULL,
                    data = NULL,
                    paired_var = NULL,
                    alpha = 0.05,
                    method = c("holm", "hochberg", "hommel", "bonferroni",
                               "BH", "BY", "fdr", "none"),
                    na.action = c("na.omit", "na.exclude", "na.pass", "na.fail")) {
  # Input validation
  if (missing(y)) stop("Dependent variable (y) must be specified.")
  if (missing(x)) stop("Independent variable (x) must be specified.")
  if (missing(data)) stop("Dataframe must be specified.")
  if (!(y %in% names(data))) stop("The dependent variable (y) was not found in the dataframe.")
  if (!(x %in% names(data))) stop("The independent variable (x) was not found in the dataframe")
  if (alpha <= 0 || alpha >= 1) stop("alpha must be between 0 and 1.")
  num_levels <- length(unique(data[[x]]))
  if (num_levels < 3) stop("The independent variable (x) must have at least 3 groups.")
  if (!is.factor(data[[x]])) data[[x]] <- as.factor(data[[x]])
  if (missing(method)) stop("Method must be specified.")
  if (!(length(method) == 1)) stop("Only one method can be selected at a time.")
  if (!(method %in% c("holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", "none"))) stop("Invalid p-value adjustment method.")
  method <- match.arg(method)
  if (missing(na.action)) stop("na.action must be specified.")
  if (!(length(na.action) == 1)) stop("Only one na.action can be selected at a time.")
  if (!(na.action %in% c("na.omit", "na.exclude", "na.pass", "na.fail"))) stop("Invalid na.action.")
  na.action <- match.arg(na.action)

  formula <- as.formula(paste(y, "~", x))

  # Normality assesment using Shapito-Wilk
  shapiroResults <- lapply(split(data[[y]], data[[x]]), shapiro.test)
  norm_var <- list(significant = "was not observed in all groups",
                   non_significant = "was observed in all groups")

  normality_key <- if (any(sapply(shapiroResults, function(x) x$p.value < alpha))) "significant" else "non_significant"

  # Homogeneity of variances assesment
  bartlett_results <- bartlett.test(formula, data = data)
  leveneResults <- leveneTest(formula, data = data)

  if (normality_key == "significant") {
    var_res <- leveneResults$`Pr(>F)`[1]
    var.test <- "Levene"
  } else {
    var_res <- bartlett_results$p.value
    var.test <- "Bartlett"
  }

  variance_key <- if (var_res < alpha) "significant" else "non_significant"

  # Sphericity assesment
  if (!is.null(paired_var)) {
    order_eval <- data[[x]][1:num_levels]
    byrow_setting <- if (length(unique(order_eval)) == num_levels) TRUE else FALSE
    matrix <- matrix(data[[y]], ncol = num_levels, byrow = byrow_setting)
    mauchlyResults <- mauchly.test(lm(matrix ~ 1), X = ~ 1)

    sphericity_key <- if (mauchlyResults$p.value < alpha) "significant" else "non_significant"
  }

  if (is.null(paired_var)) {
    if (normality_key == "non_significant" && variance_key == "non_significant") {
      model <- aov(formula, data = data, na.action = na.action) # One-way ANOVA
      summary <- summary(model)
      name <- "One-way ANOVA"
    } else {
      model <- kruskal.test(formula, data = data, na.action = na.action) # Kruskal-Wallis
      name <- "Kruskal-Wallis" #### ¿Porqué no hau summary(model)?
    }
  } else {
    if (normality_key == "non_significant" && variance_key == "non_significant" && sphericity_key == "non_significant") { # Repeated measures ANOVA
      formula <- as.formula(paste(y, "~", x, "+ Error(", paired_var, ")"))
      model <- aov(formula, data = data, na.action = na.action)
      summary <- summary(model)
      name <- "Repeated measures ANOVA"
    } else {
      formula <- as.formula(paste(deparse(formula[[2]]), "~", deparse(formula[[3]]), "|", paired_var))
      model <- friedman.test(formula, data = data, na.action = na.action) # Friedman test
      name <- "Friedman" #### ¿Porqué no hau summary(model)?
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
      stat <- summary[[2]][[1]][x, "F value"]
      p_value <- summary[[2]][[1]][x, "Pr(>F)"]
      df_between <- summary[[2]][[1]][x, "Df"]
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
  cat(sprintf("\nOmnibus Test: %s\n\n", name))
  if (!is.null(paired_var)) cat(sprintf("Sphericity %s (method: Mauchly).\n", norm_var[[sphericity_key]]))
  cat(sprintf("Normality %s (method: Shapiro Wilk).\n", norm_var[[normality_key]]))
  cat(sprintf("Homogeneity of variance %s (method: %s).\n\n", norm_var[[variance_key]], var.test))
  cat(sprintf("Formula: %s\n", deparse(formula)))
  cat(sprintf("alpha (\u03b1): %.2f\n", alpha))
  if (grepl("ANOVA", name)) {
    cat(sprintf("F (%d,%d) = %.3f, p = %s\n", df_between, df_within, stat, .format_p(p_value)))
  } else {
    cat(sprintf("X(%d) = %.3f, p = %s\n", df, stat, .format_p(p_value)))
  }
  cat(sprintf("Result: %s\n\n", ifelse(p_value < alpha, "Significant", "Not significant")))

  # Perform post-hoc tests if significant
  if (p_value < alpha) {
    cat("Post-hoc Multiple Comparisons\n\n")
    post_hoc <- .post_hoc(
      name = name,
      y = y,
      x = x,
      paired_var = paired_var,
      method = method,
      alpha = alpha,
      model = model,
      data = data,
      normality_key = normality_key,
      variance_key = variance_key,
      sphericity_key = sphericity_key
    )
  } else {
    cat("Post-hoc tests not performed (results not significant).\n")
    post_hoc <- NULL
  }
  cat("\n")

  invisible(list(formula = formula,
                 summary = summary,
                 statistic = stat,
                 p_value = p_value,
                 n_groups = length(unique(data[[x]])),
                 significant = p_value < alpha,
                 alpha = alpha,
                 model = model,
                 data = data,
                 post_hoc = post_hoc,
                 name = name))
}
