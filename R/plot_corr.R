#' Create Simple Professional Correlation Matrix Plots
#'
#' Generates publication-ready correlation matrix heatmaps with minimal code using ggplot2.
#'
#' @param data A dataframe containing the variables to analyze.
#' @param vars Character vector specifying which variables to include. Default: NULL.
#' @param method Character string specifying correlation method: "pearson" or "spearman". Default: "pearson".
#' @param type Character string specifying matrix type: "full", "upper", or "lower". Default: "full".
#' @param colors Character vector of 3 colors for negative, neutral, and positive correlations. Default: NULL.
#' @param title Character string for plot title. Default: NULL.
#' @param show_values Logical parameter indicating whether to display correlation values in cells. Default: TRUE.
#' @param value_size Numeric value indicating size of correlation value text. Default: 3.
#' @param show_sig Logical parameter indicating whether to mark significant correlations. Default: FALSE.
#' @param sig_level Numeric value indicating significance level for marking. Default: 0.05.
#' @param sig_only Logical parameter indicating whether to show only statistically significant values. Default: FALSE.
#' @param show_legend Logical parameter indicating whether to show legend. Default: TRUE.
#' @param p_method Character string indicating the method for p-value adjustment in post-hoc multiple comparisons to 
#'   control for Type I error inflation. Options: "holm" (Holm), "hochberg" (Hochberg), "hommel" (Hommel), 
#'   "bonferroni" (Bonferroni), "BH" (Benjamini-Hochberg), "BY" (Benjamini-Yekutieli), or "none" (no adjustment).
#'   Default: "holm".
#'
#' @return A ggplot2 object
#'
#' @examples
#' # Correlation matrix for base R dataset 'swiss'
#' plot_corr(data = swiss)
#' 
#' # Lower triangle with significance indicators and filtering
#' plot_corr(data = swiss, type = "lower", show_sig = TRUE, sig_only = TRUE)
#'
#' @import ggplot2
#' @importFrom stats cor cor.test complete.cases p.adjust
#' @importFrom rlang .data
#' @importFrom tools toTitleCase
#' @export

plot_corr <- function(data,
                      vars = NULL,
                      method = c("pearson", "spearman"),
                      type = c("full", "upper", "lower"),
                      colors = NULL,
                      title = NULL,
                      show_values = TRUE,
                      value_size = 3,
                      show_sig = FALSE,
                      sig_level = 0.05,
                      sig_only = FALSE,
                      show_legend = TRUE,
                      p_method = "holm") {
  
  # Input validation
  if (!is.data.frame(data)) stop("'data' must be a data frame.", call. = FALSE)
  method <- match.arg(method)
  type <- match.arg(type)
  if (!is.numeric(sig_level) || sig_level <= 0 || sig_level >= 1) {
    stop("'sig_level' must be numeric between 0 and 1.", call. = FALSE)
  }
  if (!p_method %in% c("holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "none")) {
    stop("'p_method' must be one of: 'holm', 'hochberg', 'hommel', 'bonferroni', 'BH', 'BY', 'none'.", call. = FALSE)
  }
  # Select and validate numeric variables
  if (is.null(vars)) {
    vars <- names(data)[sapply(data, is.numeric)]
    if (length(vars) == 0) stop("No numeric variables found in data.", call. = FALSE)
  } else {
    missing_vars <- setdiff(vars, names(data))
    if (length(missing_vars) > 0) stop(paste("Variables not found:", paste(missing_vars, collapse = ", "), "."), call. = FALSE)
    if (!all(sapply(data[vars], is.numeric))) stop("All specified variables must be numeric.", call. = FALSE)
  }
  
  # Data preparation and constant variable check
  cor_data <- data[vars][complete.cases(data[vars]), ]
  if (nrow(cor_data) == 0) stop("No complete cases found.", call. = FALSE)
  constant_vars <- sapply(cor_data, function(x) var(x) == 0)
  if (any(constant_vars)) message("Constant variables detected: ", paste(names(cor_data)[constant_vars], collapse = ", "), ".")
  
  # Helper function for significance stars
  get_sig_stars <- function(p_val, sig_level) {
    if (is.na(p_val) || p_val >= sig_level) return("")
    if (p_val < 0.001) return("***")
    if (p_val < 0.01) return("**") 
    return("*")
  }
  
  # Compute correlation matrix
  cor_mat <- suppressWarnings(cor(cor_data, method = method))
  n_vars <- ncol(cor_data)
  
  # Compute p-values if needed
  p_mat <- NULL
  if (show_sig || sig_only) {
    p_mat <- matrix(1, n_vars, n_vars)
    p_values_vector <- numeric(0)
    
    # Collect all p-values first
    for (i in 1:(n_vars - 1)) {
      for (j in (i + 1):n_vars) {
        p_val <- suppressWarnings({
          tryCatch({
            if (var(cor_data[, i]) == 0 || var(cor_data[, j]) == 0) {
              1
            } else {
              cor.test(cor_data[, i], cor_data[, j], method = method)$p.value
            }
          }, error = function(e) 1)
        })
        
        p_values_vector <- c(p_values_vector, p_val)
      }
    }
    
    # Apply correction to all p-values simultaneously
    if (p_method != "none" && length(p_values_vector) > 0) {
      adjusted_p <- p.adjust(p_values_vector, method = p_method)
    } else {
      adjusted_p <- p_values_vector
    }
    
    # Populate the matrix with adjusted p-values
    k <- 1
    for (i in 1:(n_vars - 1)) {
      for (j in (i + 1):n_vars) {
        p_mat[i, j] <- p_mat[j, i] <- adjusted_p[k]
        k <- k + 1
      }
    }
  }
  
  # Convert to long format
  cor_df <- expand.grid(
    Var1 = factor(rownames(cor_mat), levels = rownames(cor_mat)),
    Var2 = factor(colnames(cor_mat), levels = rev(colnames(cor_mat)))
  )
  cor_df$value <- as.vector(cor_mat)
  
  # Apply matrix type filtering
  keep_indices <- if (type == "upper") {
    which(lower.tri(matrix(1, n_vars, n_vars), diag = TRUE))
  } else if (type == "lower") {
    which(upper.tri(matrix(1, n_vars, n_vars), diag = TRUE))
  } else {
    seq_len(nrow(cor_df))
  }
  cor_df <- cor_df[keep_indices, ]
  
  # Add significance information
  if (show_sig || sig_only) {
    p_values <- as.vector(p_mat)[keep_indices]
    cor_df$significant <- p_values < sig_level
    cor_df$p_value <- p_values
  }
  
  # Handle value display for significance filtering
  cor_df$value_display <- if (sig_only && "significant" %in% names(cor_df)) {
    is_diagonal <- cor_df$Var1 == cor_df$Var2
    ifelse(is_diagonal | cor_df$significant, cor_df$value, 0)
  } else {
    cor_df$value
  }
  
  # Set colors and create plot
  if (is.null(colors)) colors <- c("#489CAC", "#FFFFFF", "#79E1BE")
  if (length(colors) != 3) stop("'colors' must be a vector of 3 colors.", call. = FALSE)
  
  p <- ggplot(cor_df, aes(x = .data[["Var1"]], y = .data[["Var2"]], fill = .data[["value_display"]])) +
    geom_tile(color = "black", linewidth = 0.5) +
    scale_fill_gradient2(low = colors[1], mid = colors[2], high = colors[3], midpoint = 0, 
                         limit = c(-1, 1), name = paste(toTitleCase(method), "\nCorrelation"),
                         guide = if (show_legend) "colorbar" else "none") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1, color = "black"),
          axis.text.y = element_text(color = "black"), axis.title = element_blank(),
          panel.grid = element_blank(), panel.background = element_blank(),
          plot.title = element_text(hjust = 0.5, face = "bold")) +
    coord_fixed()
  
  # Add correlation values with significance markers
  if (show_values) {
    is_diagonal <- cor_df$Var1 == cor_df$Var2
    value_labels <- if (sig_only && "significant" %in% names(cor_df)) {
      ifelse(!is_diagonal & !cor_df$significant, "", sprintf("%.2f", cor_df$value))
    } else {
      sprintf("%.2f", cor_df$value_display)
    }
    
    if (show_sig && "significant" %in% names(cor_df)) {
      sig_stars <- sapply(cor_df$p_value, get_sig_stars, sig_level = sig_level)
      non_empty_mask <- value_labels != ""
      value_labels[non_empty_mask] <- paste0(value_labels[non_empty_mask], sig_stars[non_empty_mask])
    }
    p <- p + geom_text(aes(label = value_labels), color = "black", size = value_size)
  }
  
  if (!is.null(title)) p <- p + labs(title = title)
  return(p)
}
