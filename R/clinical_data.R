#' Simulate Simple Clinical Trial Data
#'
#' Creates a simple simulated clinical trial dataset with participant demographics,
#' multiple visits, treatment groups with different effects, numerical and
#' categorical variables, as well as optional missing data and dropout rates.
#'
#' @param n Integer indicating the number (1-999) of participants. Default: 100.
#' @param visits Integer indicating the number of visits including baseline. Default: 3.
#' @param arms Character vector of treatment arm names. Default: c("Placebo", "Treatment").
#' @param dropout Numeric parameter indicating the proportion (0-1) of participants. who dropout. Default: 0.
#' @param missing Numeric parameter indicating the proportion (0-1) of missing values to be introduced 
#'   across numeric variables with fixed proportions (biomarker = 15%, weight = 25%, response = 60%). Default: 0.
#'   
#' @return Dataframe with columns: participant_id, visit, sex, treatment, age, 
#'   weight, biomarker, and response in long format.
#'   
#' @examples
#' # Basic dataset
#' clinical_df <- clinical_data()
#' 
#' # Multiple treatment arms with dropout rate and missing data
#' clinical_df <- clinical_data(arms = c('Placebo', 'A', 'B'), missing = 0.05, dropout = 0.10)
#' 
#' @importFrom stats rnorm runif
#' @export

clinical_data <- function(n = 100, 
                          visits = 3, 
                          arms = c("Placebo", "Treatment"), 
                          dropout = 0, 
                          missing = 0) {
  
  # Input validation
  if (!is.numeric(n) || length(n) != 1 || n != round(n) || n < 1 || n > 999) 
    stop("'n' must be a single integer between 1 and 999.", call. = FALSE)
  if (!is.numeric(visits) || length(visits) != 1 || visits != as.integer(visits) || visits < 1) 
    stop("'visits' must be a single positive integer.", call. = FALSE)
  if (!is.character(arms) || length(arms) < 1 || any(is.na(arms))) 
    stop("'arms' must be a character vector with at least one element.", call. = FALSE)
  if (!is.numeric(dropout) || length(dropout) != 1 || dropout < 0 || dropout > 1) 
    stop("'dropout' must be between 0 and 1.", call. = FALSE)
  if (dropout > 0 && !(visits > 1)) 
    stop("Must have more than 1 visit when using 'dropout'.", call. = FALSE)
  if (!is.numeric(missing) || length(missing) != 1 || missing < 0 || missing > 1) 
    stop("'missing' must be between 0 and 1.", call. = FALSE)
  
  # Setup treatment assignments
  treatment <- sample(arms, n, replace = TRUE)
  arm_positions <- match(treatment, arms)
  
  # Create clinical trial dataframe
  clinical_df <- data.frame(
    participant_id = rep(sprintf("%03d", seq_len(n)), each = visits),
    visit = factor(rep(seq_len(visits), times = n), levels = seq_len(visits)),
    sex = factor(rep(sample(c("Male", "Female"), n, replace = TRUE), each = visits),
                 levels = c("Male", "Female")),
    treatment = factor(rep(treatment, each = visits), levels = arms),
    age = rep(pmin(85, pmax(18, round(rnorm(n, 45, 15)))), each = visits),
    weight = pmin(120, pmax(45, round(rep(rnorm(n, 70, 15), each = visits) +
                                        rnorm(n * visits, 0, 2), 1))),
    biomarker = round(rnorm(n * visits, rep(50 + (arm_positions - 1) * (-3),
                                                   each = visits), 10), 2)
  )
  
  # Generate response variable
  rand_vals <- runif(nrow(clinical_df))
  complete_prob <- pmin(0.8, 0.2 + (rep(arm_positions, each = visits) - 1) * 0.15)
  clinical_df$response <- factor(
    ifelse(rand_vals <= complete_prob, "Complete",
           ifelse(rand_vals <= complete_prob + 0.3 * (1 - complete_prob), "Partial", "None")),
    levels = c("Complete", "Partial", "None")
  )
  
  # Apply dropout
  if (dropout > 0) {
    dropout_participants <- sample(unique(clinical_df$participant_id), round(n * dropout))
    for (part in dropout_participants) {
      dropout_visit <- sample(2:visits, 1)
      clinical_df[clinical_df$participant_id == part & 
                    as.numeric(clinical_df$visit) >= dropout_visit, 
                  c("weight", "biomarker", "response")] <- NA
    }
  }
  
  # Apply missing data
  if (missing > 0) {
    missing_vars <- c(biomarker = 0.15, weight = 0.25, response = 0.60)
    total_cells <- nrow(clinical_df) * length(missing_vars) * missing
    for (var in names(missing_vars)) {
      n_missing <- round(total_cells * missing_vars[var] / sum(missing_vars))
      if (n_missing > 0) {
        clinical_df[sample(nrow(clinical_df), min(n_missing, nrow(clinical_df))), var] <- NA
      }
    }
  }
  
  return(clinical_df)
}
