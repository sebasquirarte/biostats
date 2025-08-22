#' Omnibus Tests for Comparing Three or More Groups
#'
#' Performs omnibus tests to evaluate overall differences between three or more groups.
#' Automatically selects the appropriate statistical test based on data characteristics
#' and assumption testing. Supports both independent groups and repeated measures designs.
#' Tests include one-way ANOVA, repeated measures ANOVA, Kruskal-Wallis test, and
#' Friedman test. Performs comprehensive assumption checking (normality, homogeneity
#' of variance, sphericity) and post-hoc testing when significant results are detected.
#'
#' @param data Dataframe containing the variables to be analyzed.
#' @param y character string. Dependent variable (outcome).
#' @param x character string. Independent variable (group or within-subject variable).
#' @param paired_var character string or NULL. Source of repeated measurements. If 
#'   provided, a repeated measures design is assumed. Data should be in long format 
#'   with one row per observation. If NULL, independent groups design is assumed.
#' @param alpha numeric. Significance level for hypothesis tests. Default: 0.05.
#' @param p_method character string. Method for p-value adjustment in post-hoc multiple
#'   comparisons to control for Type I error inflation. Options: "holm" (Holm), 
#'   "hochberg" (Hochberg), "hommel" (Hommel), "bonferroni" (Bonferroni), "BH" 
#'   (Benjamini-Hochberg), "BY" (Benjamini-Yekutieli), "none" (no adjustment). Default: "holm".
#' @param na.action character string. Action to take if NAs are present ("na.omit" 
#'   or "na.exclude"). Default: "na.omit"
#'
#' @return A list containing:
#' \item{formula}{The modelled formula used for the test.}
#' \item{summary}{Summary object of the model or test.}
#' \item{statistic}{Test statistic value (F or Chi-squared).}
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
#' # Simulated clinical data with multiple tratment arms and visits
#' clinical_df <- clinical_data(n = 300, visits = 6, arms = c("A", "B", "C"))
#' 
#' # Compare numerical variable across treatments
#' result <- omnibus(data = clinical_df,
#'                   y = "biomarker", 
#'                   x = "treatment")
#' 
#' # Compare numerical variable changes across visits 
#' result <- omnibus(y = "biomarker", 
#'                   x = "visit", 
#'                   data = clinical_df, 
#'                   paired_var = "subject_id")
#'
#' @importFrom car leveneTest
#' @importFrom stats aov bartlett.test friedman.test kruskal.test lm mauchly.test shapiro.test as.formula na.action
#' @importFrom stats TukeyHSD pairwise.t.test pairwise.wilcox.test
#' @importFrom emmeans emmeans
#' @importFrom graphics pairs
#' @export

omnibus <- function(data = NULL,
                    y = NULL,
                    x = NULL,
                    paired_var = NULL,
                    alpha = 0.05,
                    p_method = "holm",
                    na.action = "na.omit") {
  
  # Input validation
  if (missing(y)) stop("Dependent variable ('y') must be specified.", call. = FALSE)
  if (missing(x)) stop("Independent variable ('x') must be specified.", call. = FALSE)
  if (missing(data)) stop("'data' must be specified.", call. = FALSE)
  if (!(y %in% names(data))) stop("The dependent variable ('y') was not found in the dataframe.", call. = FALSE)
  if (!(x %in% names(data))) stop("The independent variable ('x') was not found in the dataframe.", call. = FALSE)
  if (!is.factor(data[[x]])) data[[x]] <- as.factor(data[[x]])
  if (!is.numeric(data[[y]])) data[[y]] <- as.numeric(data[[y]])
  if (alpha <= 0 || alpha >= 1) stop("'alpha' must be between 0 and 1.", call. = FALSE)
  num_levels <- length(levels(data[[x]]))
  if (num_levels < 3) stop("The independent variable ('x') must have at least 3 levels.", call. = FALSE)
  if (!(p_method %in% c("holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "none"))) {
    stop("Invalid p-value adjustment method.", call. = FALSE)
  }
  if (!(length(na.action) == 1)) stop("Only one 'na.action' can be selected at a time.", call. = FALSE)
  if (!(na.action %in% c("na.omit", "na.exclude"))) stop("Invalid 'na.action'.", call. = FALSE)
  
  formula <- as.formula(paste(y, "~", x))
  
  # Assumption evaluation
  results_assumptions <- .assumptions(formula = formula, 
                                      y = y, 
                                      x = x, 
                                      data = data,
                                      paired_var = paired_var, 
                                      alpha = alpha,
                                      num_levels = num_levels)
  
  normality_key <- results_assumptions$normality_key
  variance_key <- results_assumptions$variance_key
  sphericity_key <- results_assumptions$sphericity_key
  var.test <- results_assumptions$var.test
  
  if (is.null(paired_var)) {
    if (normality_key == "non_significant" && variance_key == "non_significant") {
      model <- aov(formula, data = data, na.action = na.action) # One-way ANOVA
      summary <- summary(model)
      name <- "One-way ANOVA"
    } else {
      model <- kruskal.test(formula, data = data, na.action = na.action) # Kruskal-Wallis
      name <- "Kruskal-Wallis"
    }
  } else {
    if (normality_key == "non_significant" && variance_key == "non_significant" && sphericity_key == "non_significant") { 
      formula <- as.formula(paste(y, "~", x, "+ Error(", paired_var, "/", x, ")")) # Repeated measures ANOVA
      model <- aov(formula, data = data, na.action = na.action)
      summary <- summary(model)
      name <- "Repeated measures ANOVA"
    } else {
      formula <- as.formula(paste(deparse(formula[[2]]), "~", deparse(formula[[3]]), "|", paired_var))
      model <- friedman.test(formula, data = data, na.action = na.action) # Friedman test
      name <- "Friedman"
    }
  }
  
  # Extract key statistics
  if (name == "One-way ANOVA") {
    stat <- summary[[1]][1, "F value"]
    p_value <- summary[[1]][1, "Pr(>F)"]
    df_between <- summary[[1]][1, "Df"]
    df_within <- summary[[1]][2, "Df"]
  }
  
  if (name == "Repeated measures ANOVA") {
    stat <- summary[[2]][[1]][x, "F value"]
    p_value <- summary[[2]][[1]][x, "Pr(>F)"]
    df_between <- summary[[2]][[1]][x, "Df"]
    df_within <- summary[[2]][[1]]["Residuals", "Df"]
  }
  
  if (name %in% c("Friedman", "Kruskal-Wallis")) {
    stat <- unname(model$statistic)
    p_value <- model$p.value
    df <- unname(model$parameter)
  }
  
  # Print results
  cat(sprintf("\nOmnibus Test: %s\n\n", name))
  .print_assumptions(results_assumptions, alpha)
  cat("Test Results:\n\n")
  cat(sprintf("  Formula: %s\n", deparse(formula)))
  cat(sprintf("  alpha: %.2f\n", alpha))
  if (grepl("ANOVA", name)) {
    cat(sprintf("  F(%d,%d) = %.3f, p = %s\n", df_between, df_within, stat, .format_p(p_value)))
  } else {
    cat(sprintf("  Chi-squared(%d) = %.3f, p = %s\n", df, stat, .format_p(p_value)))
  }
  cat(sprintf("  Result: %s\n\n", ifelse(p_value < alpha, "significant", "not significant")))
  
  
  # Perform post-hoc tests if significant
  if (p_value < alpha) {
    cat("Post-hoc Multiple Comparisons\n\n")
    post_hoc <- .post_hoc(
      name = name,
      y = y,
      x = x,
      paired_var = paired_var,
      p_method = p_method,
      alpha = alpha,
      model = model,
      data = data
    )
  } else {
    cat("Post-hoc tests not performed (results not significant).\n\n")
    post_hoc <- NULL
  }
  
  obs_levels <- table(data[[x]])
  if (all(obs_levels == obs_levels[1]) == FALSE) cat("\nSample sizes across groups are unequal - unbalanced design.\n\n")
  
  invisible(list(formula = formula,
                 summary = summary,
                 statistic = stat,
                 p_value = p_value,
                 n_groups = num_levels,
                 significant = p_value < alpha,
                 alpha = alpha,
                 model = model,
                 data = data,
                 post_hoc = post_hoc,
                 name = name))
}
