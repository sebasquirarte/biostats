#' Summary Table with Optional Group Comparisons
#'
#' Generates a summary table for biostatistics and clinical data analysis with
#' automatic normality, effet size, and statistical test calculations. Handles both
#' numeric and categorical variables, performing appropriate descriptive statistics
#' and inferential tests for single-group summaries or two-group comparisons.
#'
#' @param data Dataframe containing the variables to be summarized.
#' @param group_var character. name of the grouping variable for two-group comparisons. Default is NULL.
#' @param all_stats logical. If TRUE, provides detailed statistical summary. Default is FALSE.
#' @param effect_size logical. If TRUE, includes effect size estimates. Default is FALSE.
#' @param exclude character vector. Variable names to exclude from the summary. Default is NULL.
#'
#' @return A gt table object with formatted summary statistics.
#'
#' @importFrom stats IQR chisq.test fisher.test median quantile sd shapiro.test t.test var wilcox.test
#' @importFrom gt gt opt_row_striping
#'
#' @examples
#' # General summary without considering treatment groups
#' clinical_df <- clinical_data()
#' 
#' clinical_summary <- summary_table(clinical_df,
#'                                   exclude = c('subject_id', 'visit'))
#' 
#' # Grouped summary for each treatment group
#' clinical_summary <- summary_table(clinical_df,
#'                                   group_var = 'treatment',
#'                                   exclude = c('subject_id', 'visit'))
#' 
#' # Grouped summary with all stats and effect size
#' clinical_summary_gt <- summary_table(clinical_df,
#'                                      group_var = 'treatment',
#'                                      all_stats = TRUE,
#'                                      effect_size = TRUE,
#'                                      exclude = c('subject_id', 'visit'))
#'
#' @export
summary_table <- function(data,
                          group_var = NULL,
                          all_stats = FALSE,
                          effect_size = FALSE,
                          exclude = NULL) {
  
  # Check for gt package
  if (!requireNamespace("gt", quietly = TRUE)) {
    stop("Package 'gt' is required. Please install it with install.packages('gt').")
  }
  
  # Input validation
  if (!is.data.frame(data)) stop("Data must be a dataframe.")
  if (nrow(data) == 0) stop("Data cannot be empty.")
  if (!is.null(exclude) && !is.character(exclude)) {
    stop("exclude must be a character vector.")
  }
  
  use_groups <- !is.null(group_var)
  if (use_groups) {
    if (!group_var %in% names(data)) {
      stop("The grouping variable '", group_var, "' is not found in the data.")
    }
    if (length(unique(data[[group_var]])) != 2) {
      stop("When using group_var, it must have exactly two groups.")
    }
  }
  
  # Get variables to analyze
  vars <- setdiff(names(data), c(group_var, exclude))
  if (length(vars) == 0) {
    warning("No variables remain after applying exclusions.")
    return(gt::gt(data.frame()))
  }
  
  # Process all variables
  results_list <- lapply(vars, .process_variable,
                         data = data, group_var = group_var,
                         all_stats = all_stats, effect_size = effect_size)
  
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
  return(gt::gt(result_df) |> 
           gt::opt_align_table_header(align = "center") |>
           gt::cols_align(align = "center"))
}
