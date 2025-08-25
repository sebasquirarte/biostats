#' Summary Table with Optional Group Comparisons
#'
#' Generates a summary table for biostatistics and clinical data analysis with
#' automatic normality, effect size, and statistical test calculations. Handles both
#' numeric and categorical variables, performing appropriate descriptive statistics
#' and inferential tests for single-group summaries or two-group comparisons.
#'
#' @param data Dataframe containing the variables to be summarized.
#' @param group_by character. Name of the grouping variable for two-group comparisons. Default: NULL.
#' @param normality_test character. Normality test to use: 'S-W' for Shapiro-Wilk or 'K-S' for Kolmogorov-Smirnov. Default: 'S-W'.
#' @param all_stats logical. If TRUE, provides detailed statistical summary. Default: FALSE.
#' @param effect_size logical. If TRUE, includes effect size estimates. Default: FALSE.
#' @param exclude character vector. Variable names to exclude from the summary. Default: NULL.
#'
#' @return A gt table object with formatted summary statistics.
#'
#' @examples
#' # Simulated clinical data
#' clinical_df <- clinical_data()
#' 
#' # Overall summary without considering treatment groups
#' summary_table(clinical_df,
#'               exclude = c('subject_id', 'visit'))
#' 
#' # Grouped summary by treatment group
#' summary_table(clinical_df,
#'               group_by = 'treatment',
#'               exclude = c('subject_id', 'visit'))
#' 
#' # Grouped summary by treatment group with all stats and effect size
#' summary_table(clinical_df,
#'               group_by = 'treatment',
#'               all_stats = TRUE,
#'               effect_size = TRUE,
#'               exclude = c('subject_id', 'visit'))
#'               
#' @importFrom stats IQR chisq.test fisher.test median quantile sd shapiro.test ks.test t.test var wilcox.test na.omit setNames addmargins
#' @importFrom gt gt opt_align_table_header cols_align cols_width px
#' @export

summary_table <- function(data,
                          group_by = NULL,
                          normality_test = 'S-W',
                          all_stats = FALSE,
                          effect_size = FALSE,
                          exclude = NULL) {
  
  # Check for gt package
  if (!requireNamespace("gt", quietly = TRUE)) {
    stop("Package 'gt' is required. Please install it with install.packages('gt').", call.=FALSE)
  }
  # Input validation
  if (!is.data.frame(data)) stop("'data' must be a dataframe.", call.=FALSE)
  if (nrow(data) == 0) stop("'data' cannot be empty.", call.=FALSE)
  if (!is.null(exclude) && !is.character(exclude)) stop("'exclude' must be a character vector.", call.=FALSE)
  if (!normality_test %in% c('S-W', 'K-S')) {
    stop("'normality_test' must be either 'S-W' (Shapiro-Wilk) or 'K-S' (Kolmogorov-Smirnov).", call.=FALSE)
  }
  use_groups <- !is.null(group_by)
  if (use_groups) {
    if (!group_by %in% names(data)) {
      stop("The grouping variable '", group_by, "' is not found in the data.", call.=FALSE)
    }
    if (length(unique(data[[group_by]])) != 2) {
      stop("When using 'group_by', data must have exactly two groups.", call.=FALSE)
    }
  }
  
  # Get variables to analyze
  vars <- setdiff(names(data), c(group_by, exclude))
  if (length(vars) == 0) stop("No variables remain after applying exclusions.", call.=FALSE)
  
  # Process all variables
  results_list <- lapply(vars, .process_variable,
                         data = data, group_var = group_by,
                         all_stats = all_stats, effect_size = effect_size,
                         normality_test = normality_test)
  
  # Combine results
  result_df <- do.call(rbind, results_list)
  rownames(result_df) <- NULL
  
  # Clean up empty columns
  if ("NAs" %in% names(result_df)) {
    na_pattern <- if (use_groups) "A: 0, B: 0" else "0"
    if (all(result_df$NAs == na_pattern)) result_df$NAs <- NULL
  }
  
  # Remove effect size columns if not requested
  if (!effect_size || !use_groups) {
    result_df$effect_size <- NULL
    result_df$effect_param <- NULL
  }
  
  # Create and return basic gt table
  return(gt::gt(result_df) |> gt::opt_align_table_header(align = "center") |>
           gt::cols_align(align = "center") |> gt::cols_width(normality ~ px(80)))
}
