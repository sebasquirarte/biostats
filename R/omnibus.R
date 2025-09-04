#' Omnibus Tests for Comparing Three or More Groups
#'
#' Performs omnibus tests to evaluate overall differences between three or more groups. Automatically 
#' selects the appropriate statistical test based on data characteristics and assumption testing. 
#' Supports both independent groups and repeated measures designs. Tests include one-way ANOVA, repeated
#' measures ANOVA, Kruskal-Wallis test, and Friedman test. Performs comprehensive assumption checking
#' (normality, homogeneity of variance, sphericity) and post-hoc testing when significant results are detected.
#'
#' @param data Dataframe containing the variables to be analyzed. Data must be in long format 
#'   with one row per observation.
#' @param y Character string indicating the dependent variable (outcome).
#' @param x Character string indicating the independent variable (group or within-subject variable).
#' @param paired_by Character string indicating the source of repeated measurements. If 
#'   provided, a repeated measures design is assumed. If NULL, independent groups design is assumed. 
#'   Default: NULL.
#' @param alpha Numeric value indicating the significance level for hypothesis tests. Default: 0.05.
#' @param p_method Character string indicating the method for p-value adjustment in post-hoc multiple
#'   comparisons to control for Type I error inflation. Options: "holm" (Holm), "hochberg" (Hochberg), 
#'   "hommel" (Hommel), "bonferroni" (Bonferroni), "BH" (Benjamini-Hochberg), "BY" (Benjamini-Yekutieli),
#'   "none" (no adjustment). Default: "holm".
#' @param na.action Character string indicating the action to take if NAs are present ("na.omit" 
#'   or "na.exclude"). Default: "na.omit"
#'
#' @return
#' Prints results to console and invisibly returns a list including the formula, model,
#' statistic summary, name of the test performed, the value of the test statistic,
#' resulting p value and the results of the post_hoc test.
#' 
#' @references
#' Blanca, M., Alarcón, R., Arnau, J. et al. Effect of variance ratio on ANOVA robustness: Might 1.5 be the limit?. 
#' Behav Res. 2017 Jun 22; 50:937–962. https://doi.org/10.3758/s13428-017-0918-2
#' Field, A. P. Discovering Statistics Using R and RStudio. 1st ed. London: SAGE Publications; 2025.
#' 
#' @examples
#' # Simulated clinical data with multiple treatment arms and visits
#' clinical_df <- clinical_data(n = 300, visits = 6, arms = c("A", "B", "C"))
#' 
#' # Compare numerical variable across treatments
#' omnibus(data = clinical_df, y = "biomarker", x = "treatment")
#' 
#' # Filter simulated data to just one treatment
#' clinical_df_A <- clinical_df[clinical_df$treatment == "A", ]
#' # Compare numerical variable changes across visits 
#' omnibus(y = "biomarker", x = "visit", data = clinical_df_A, paired_by = "subject_id")
#'
#' @importFrom car leveneTest
#' @importFrom stats aov bartlett.test friedman.test kruskal.test lm mauchly.test shapiro.test as.formula na.action
#' @importFrom stats TukeyHSD pairwise.t.test pairwise.wilcox.test
#' @export

omnibus <- function(data,
                    y,
                    x,
                    paired_by = NULL,
                    alpha = 0.05,
                    p_method = "holm",
                    na.action = "na.omit") {
  
  # Input validation
  if (missing(y)) stop("Dependent variable ('y') must be specified.", call. = FALSE)
  if (missing(x)) stop("Independent variable ('x') must be specified.", call. = FALSE)
  if (missing(data)) stop("'data' must be specified.", call. = FALSE)
  if (!(y %in% names(data))) stop("The dependent variable ('y') was not found in the dataframe.", call. = FALSE)
  if (!(x %in% names(data))) stop("The independent variable ('x') was not found in the dataframe.", call. = FALSE)
  if (!is.null(paired_by) && !(paired_by %in% names(data))) stop("'paired_by' variable not found in data", call. = FALSE)
  data[[y]] <- as.numeric(data[[y]])
  data[[x]] <- as.factor(data[[x]])
  if (!is.null(paired_by)) data[[paired_by]] <- as.factor(data[[paired_by]])
  if (!is.null(paired_by) && !all(table(data[[paired_by]], data[[x]]) == 1)) stop("When analyzing repeated measures, 'data' must have exactly one measurement per subject per level of 'x'.")
  
  data <- .data_organization(data = data, y = y, x = x, paired_by = paired_by)
  
  if (alpha <= 0 || alpha >= 1) stop("'alpha' must be between 0 and 1.", call. = FALSE)
  num_levels <- length(levels(data[[x]]))
  if (num_levels < 3) stop("The independent variable ('x') must have at least 3 levels.", call. = FALSE)
  if (any(table(data[[x]]) < 3)) stop("Each level in the independent variable ('x') must have at least 3 observations.", call. = FALSE)
  if (!(p_method %in% c("holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "none"))) stop("Invalid p-value adjustment method.", call. = FALSE)
  if (!(length(na.action) == 1)) stop("Only one 'na.action' can be selected at a time.", call. = FALSE)
  if (!(na.action %in% c("na.omit", "na.exclude"))) stop("Invalid 'na.action'.", call. = FALSE)
  
  formula <- as.formula(paste(y, "~", x))
  
  # Assumption evaluation
  results_assumptions <- .assumptions(formula = formula, 
                                      y = y, 
                                      x = x, 
                                      data = data,
                                      paired_by = paired_by, 
                                      alpha = alpha,
                                      num_levels = num_levels)
  
  normality_key <- results_assumptions$normality_key
  variance_key <- results_assumptions$variance_key
  sphericity_key <- results_assumptions$sphericity_key
  var.test <- results_assumptions$var.test
  
  stat_summary <- NULL
  if (is.null(paired_by)) {
    if (normality_key == "non_significant" && variance_key == "non_significant") {
      name <- "One-way ANOVA"
      model <- aov(formula, data = data, na.action = na.action) # One-way ANOVA
      stat_summary <- summary(model)
    } else {
      name <- "Kruskal-Wallis"
      model <- kruskal.test(formula, data = data, na.action = na.action) # Kruskal-Wallis
    }
  } else {
    if (normality_key == "non_significant" && variance_key == "non_significant" && sphericity_key == "non_significant") { 
      name <- "Repeated measures ANOVA"
      formula <- as.formula(paste(y, "~", x, "+ Error(", paired_by, "/", x, ")")) # Repeated measures ANOVA
      model <- aov(formula, data = data, na.action = na.action)
      stat_summary <- summary(model)
    } else {
      formula <- as.formula(paste(deparse(formula[[2]]), "~", deparse(formula[[3]]), "|", paired_by))
      name <- "Friedman"
      model <- friedman.test(formula, data = data, na.action = na.action)
    }
  }
  
  # Extract key statistics
  if (name == "One-way ANOVA") {
    stat <- stat_summary[[1]][1, "F value"]
    p_value <- stat_summary[[1]][1, "Pr(>F)"]
    df_between <- stat_summary[[1]][1, "Df"]
    df_within <- stat_summary[[1]][2, "Df"]
  }
  
  if (name == "Repeated measures ANOVA") {
    stat <- stat_summary[[2]][[1]][x, "F value"]
    p_value <- stat_summary[[2]][[1]][x, "Pr(>F)"]
    df_between <- stat_summary[[2]][[1]][x, "Df"]
    df_within <- stat_summary[[2]][[1]]["Residuals", "Df"]
  }
  
  if (name %in% c("Friedman", "Kruskal-Wallis")) {
    stat <- unname(model$statistic)
    p_value <- model$p.value
    df <- unname(model$parameter)
  }
  
  # Print results
  message(sprintf("\nOmnibus Test: %s\n", name))
  .print_assumptions(results_assumptions, alpha)
  message("Test Results:\n")
  message(sprintf("  Formula: %s", deparse(formula)))
  message(sprintf("  alpha: %.2f", alpha))
  if (grepl("ANOVA", name)) {
    message(sprintf("  F(%d,%d) = %.3f, p = %s", df_between, df_within, stat, .format_p(p_value)))
  } else {
    message(sprintf("  Chi-squared(%d) = %.3f, p = %s", df, stat, .format_p(p_value)))
  }
  message(sprintf("  Result: %s\n", ifelse(p_value < alpha, "significant", "not significant")))
  
  # Perform post-hoc tests if significant
  if (p_value < alpha) {
    message("Post-hoc Multiple Comparisons\n")
    post_hoc <- .post_hoc(
      name = name,
      y = y,
      x = x,
      paired_by = paired_by,
      p_method = p_method,
      alpha = alpha,
      model = model,
      data = data
    )
  } else {
    message("Post-hoc tests not performed (results not significant).")
    post_hoc <- NULL
  }
  
  total.SD <- by(data[[y]], data[[x]], function(v) sd(v, na.rm = TRUE))
  total.mean <- by(data[[y]], data[[x]], function(v) mean(v, na.rm = TRUE))
  coef_ssvar <- sum(total.SD) / sum(total.mean)
  
  if (coef_ssvar > 0 && coef_ssvar <= 0.16) {
    unbalance <- "well balanced (low variability)"
  } else if (coef_ssvar > 0.16 && coef_ssvar <= 0.33) {
    unbalance <- "moderately unbalanced"
  } else {
    unbalance <- "highly unbalanced"
  }
  
  message(sprintf("\nThe study groups show a %s distribution of sample sizes (\u0394n = %.3f).\n", unbalance, coef_ssvar))
  
  invisible(list(formula = formula,
                 model = model,
                 stat_summary = stat_summary,
                 name = name,
                 statistic = stat,
                 p_value = p_value,
                 post_hoc = post_hoc))
}