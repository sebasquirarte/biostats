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
#' @param na_rate Numeric. Proportion of values missing at random (0-1). Default is 0.
#' @param seed Integer or NULL. Random seed for reproducibility. Default is NULL.
#'
#' @return A data.frame with columns: subject_id, visit, sex, treatment, age,
#'   weight, biomarker, and response. Data is in long format.
#'
#' @examples
#' # Basic dataset
#' clinical_df <- clinical_data()
#'
#' # Multiple treatment arms with missing data
#' clinical_df <- clinical_data(arms = c("Placebo", "Low", "High"), na_rate = 0.05)
#'
#' @export
clinical_data <- function(n = 100,
                          visits = 3,
                          arms = c("Placebo", "Treatment"),
                          dropout_rate = 0,
                          na_rate = 0,
                          seed = NULL) {

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
  if (!is.numeric(na_rate) || length(na_rate) != 1 || na_rate < 0 || na_rate > 1) {
    stop("na_rate must be between 0 and 1.", call. = FALSE)
  }
  if (!is.null(seed)) {
    if (!is.numeric(seed) || length(seed) != 1) {
      stop("seed must be a single number or NULL.", call. = FALSE)
    }
    set.seed(seed)
  }

  # Generate subject data
  treatment <- sample(arms, n, replace = TRUE)
  arm_positions <- match(treatment, arms)

  # Create trial data
  trial_data <- data.frame(
    subject_id = rep(sprintf("%03d", seq_len(n)), each = visits),
    visit = rep(seq_len(visits), times = n),
    sex = rep(sample(c("Male", "Female"), n, replace = TRUE), each = visits),
    treatment = rep(treatment, each = visits),
    age = rep(pmin(85, pmax(18, round(stats::rnorm(n, 45, 15)))), each = visits),
    weight = rep(pmin(120, pmax(45, round(stats::rnorm(n, 70, 15), 1))), each = visits),
    biomarker = round(stats::rnorm(n * visits,
                                   rep(50 + (arm_positions - 1) * (-3), each = visits), 10), 2),
    stringsAsFactors = FALSE
  )

  # Generate response (with simple treatment effect)
  complete_prob <- pmin(0.8, 0.2 + (rep(arm_positions, each = visits) - 1) * 0.15)
  trial_data$response <- ifelse(
    stats::runif(nrow(trial_data)) < complete_prob, "Complete",
    ifelse(stats::runif(nrow(trial_data)) < 0.3, "Partial", "None")
  )

  # Apply dropout
  if (dropout_rate > 0 && visits > 1) {
    unique_subjects <- unique(trial_data$subject_id)
    dropout_subjects <- sample(unique_subjects, round(length(unique_subjects) * dropout_rate))

    for (subj in dropout_subjects) {
      dropout_visit <- sample(2:visits, 1)
      subject_rows <- trial_data$subject_id == subj & trial_data$visit >= dropout_visit
      trial_data[subject_rows, c("biomarker", "response")] <- NA
    }
  }

  # Apply missing data
  if (na_rate > 0) {
    for (var in c("biomarker", "response")) {
      available_indices <- which(!is.na(trial_data[[var]]))
      n_to_miss <- round(length(available_indices) * na_rate)
      if (n_to_miss > 0) {
        trial_data[sample(available_indices, n_to_miss), var] <- NA
      }
    }
  }

  # Convert to factors
  trial_data$sex <- factor(trial_data$sex, levels = c("Male", "Female"))
  trial_data$treatment <- factor(trial_data$treatment, levels = arms)
  trial_data$response <- factor(trial_data$response, levels = c("Complete", "Partial", "None"))

  return(trial_data)
}
