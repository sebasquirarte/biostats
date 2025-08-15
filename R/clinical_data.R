#' Simulate Clinical Trial Data
#'
#' Creates a simulated clinical trial dataset with subject demographics,
#' multiple visits, treatment groups with different effects, numerical and
#' categorical variables, as well as optional missing data and dropout rates.
#'
#' @param n Integer. Number of subjects (1-999). Default is 100.
#' @param visits Integer. Number of visits including baseline. Default is 3.
#' @param arms Character vector. Treatment arm names. Default is c("Placebo", "Treatment").
#' @param dropout_rate Numeric. Proportion of subjects who dropout (0-1). Default is 0.
#' @param na_rate Numeric. Overall proportion (0-1) of missing values to be
#'   introduced across the variables `weight`, `biomarker`, and `response`.
#'   Distributed using fixed proportions (biomarker = 15%, weight = 25%, response = 60%).
#'   Default is 0 (no missing data).
#'
#' @return A data.frame with columns: subject_id, visit, sex, treatment, age,
#'   weight, biomarker, and response. Data is in long format.
#' @examples
#' # Basic dataset
#' clinical_df <- clinical_data()
#' # Multiple treatment arms with dropout rate and missing data
#' clinical_df <- clinical_data(arms = c('Placebo', 'A', 'B'), na_rate = 0.05, dropout_rate = 0.10)
#' @export
#' @importFrom stats rnorm runif

clinical_data <- function(n = 100, visits = 3, arms = c("Placebo", "Treatment"),
                          dropout_rate = 0, na_rate = 0) {

  # Input validation
  if (!is.numeric(n) || length(n) != 1 || n != round(n) || n < 1 || n > 999) {
    stop("n must be an integer between 1 and 999.", call. = FALSE)
  }
  if (!is.numeric(visits) || length(visits) != 1 || visits != as.integer(visits) || visits < 1) {
    stop("visits must be a positive integer.", call. = FALSE)
  }
  if (!is.character(arms) || length(arms) < 1 || any(is.na(arms))) {
    stop("arms must be a character vector with at least one element.", call. = FALSE)
  }
  if (!is.numeric(dropout_rate) || length(dropout_rate) != 1 || dropout_rate < 0 || dropout_rate > 1) {
    stop("dropout_rate must be between 0 and 1.", call. = FALSE)
  }
  if (dropout_rate > 0 && !(visits > 1)) {
    stop("Must have more than 1 visit when implementing dropout_rate.", call. = FALSE)
  }
  if (!is.numeric(na_rate) || length(na_rate) != 1 || na_rate < 0 || na_rate > 1) {
    stop("na_rate must be between 0 and 1.", call. = FALSE)
  }

  # Treatment assignment and arm positions
  treatment <- sample(arms, n, replace = TRUE)
  arm_positions <- match(treatment, arms)

  # Create clinical trial data with factors created inline
  trial_data <- data.frame(
    subject_id = rep(sprintf("%03d", seq_len(n)), each = visits),
    visit = rep(seq_len(visits), times = n),
    sex = factor(rep(sample(c("Male", "Female"), n, replace = TRUE), each = visits),
                 levels = c("Male", "Female")),
    treatment = factor(rep(treatment, each = visits), levels = arms),
    age = rep(pmin(85, pmax(18, round(stats::rnorm(n, 45, 15)))), each = visits),
    weight = pmin(120, pmax(45, round(rep(stats::rnorm(n, 70, 15), each = visits) +
                                        rnorm(n * visits, 0, 2), 1))),
    biomarker = round(stats::rnorm(n * visits, rep(50 + (arm_positions - 1) * (-3),
                                                   each = visits), 10), 2),
    stringsAsFactors = FALSE
  )

  # Generate response using case_when style logic
  complete_prob <- pmin(0.8, 0.2 + (rep(arm_positions, each = visits) - 1) * 0.15)
  rand_vals <- stats::runif(nrow(trial_data))
  trial_data$response <- factor(
    ifelse(rand_vals < complete_prob, "Complete",
           ifelse(rand_vals < complete_prob + 0.3 * (1 - complete_prob), "Partial", "None")),
    levels = c("Complete", "Partial", "None")
  )

  # Apply dropout
  if (dropout_rate > 0 && visits > 1) {
    dropout_subjects <- sample(unique(trial_data$subject_id),
                               round(n * dropout_rate))
    for (subj in dropout_subjects) {
      dropout_visit <- sample(2:visits, 1)
      subject_rows <- trial_data$subject_id == subj & trial_data$visit >= dropout_visit
      trial_data[subject_rows, c("weight", "biomarker", "response")] <- NA
    }
  }

  # Apply missing data
  if (na_rate > 0) {
    valid_cols <- c("weight", "biomarker", "response")
    total_missing_cells <- round(nrow(trial_data) * length(valid_cols) * na_rate)

    # Realistic clinical missing data proportions
    proportions <- c(biomarker = 0.15, weight = 0.25, response = 0.60)
    missing_counts <- round(total_missing_cells * proportions)
    missing_counts["response"] <- missing_counts["response"] +
      (total_missing_cells - sum(missing_counts))  # Adjust for rounding

    # Apply missing data
    for (var in valid_cols) {
      if (missing_counts[var] > 0) {
        available_indices <- which(!is.na(trial_data[[var]]))
        if (length(available_indices) >= missing_counts[var]) {
          miss_indices <- sample(available_indices, missing_counts[var])
          trial_data[miss_indices, var] <- NA
        }
      }
    }
  }

  return(trial_data)
}