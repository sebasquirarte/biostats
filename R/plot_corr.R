#' Create Simple Professional Correlation Matrix Plots
#'
#' Generates publication-ready correlation matrix heatmaps with minimal code using ggplot2.
#'
#' @param data A data frame containing the variables to analyze
#' @param vars Optional character vector specifying which variables to include.
#'   If NULL (default), all numeric variables will be used
#' @param method Character string specifying correlation method; one of "pearson" (default),
#'   "spearman", or "kendall"
#' @param type Character string specifying matrix type; one of "full" (default),
#'   "upper", or "lower"
#' @param diag Logical; whether to show diagonal (always 1.0) (default: TRUE)
#' @param colors Character vector of 3 colors for negative, neutral, and positive correlations.
#'   If NULL, uses a TealGrn-based palette consistent with other plotting functions
#' @param title Optional character string for the plot title
#' @param text_size Numeric value specifying the base text size (default: 12)
#' @param show_values Logical; whether to display correlation values in cells (default: TRUE)
#' @param value_size Numeric; size of correlation value text (default: 3)
#' @param show_significance Logical; whether to mark significant correlations (default: FALSE)
#' @param sig_level Numeric; significance level for marking (default: 0.05)
#'
#' @return A ggplot2 object that can be further customized
#'
#' @examples
#' # Create clinical data with additional correlated variables
#' clinical_df <- clinical_data(n = 100, visits = 8, na_rate = 0.03, dropout_rate = 0.05)
#' clinical_df$height <- 150 + 0.3 * clinical_df$age + rnorm(nrow(clinical_df), 0, 8)
#' clinical_df$systolic_bp <- 100 + 0.8 * clinical_df$age + rnorm(nrow(clinical_df), 0, 10)
#' 
#' # Correlation matrix with statistical significance
#' plot_corr(clinical_df, type = "upper", show_significance = TRUE)
#'
#' @import ggplot2
#' @export
plot_corr <- function(data,
                      vars = NULL,
                      method = c("pearson", "spearman", "kendall"),
                      type = c("full", "upper", "lower"),
                      diag = TRUE,
                      colors = NULL,
                      title = NULL,
                      text_size = 12,
                      show_values = TRUE,
                      value_size = 3,
                      show_significance = FALSE,
                      sig_level = 0.05) {
  
  # Input validation
  if (!is.data.frame(data)) stop("data must be a data frame", call. = FALSE)
  method <- match.arg(method)
  type <- match.arg(type)
  
  # Select numeric variables
  if (is.null(vars)) {
    vars <- names(data)[sapply(data, is.numeric)]
    if (length(vars) == 0) stop("No numeric variables found in data", call. = FALSE)
  } else {
    missing_vars <- setdiff(vars, names(data))
    if (length(missing_vars) > 0) stop(paste("Variables not found:", paste(missing_vars, collapse = ", ")), call. = FALSE)
    if (!all(sapply(data[vars], is.numeric))) stop("All specified variables must be numeric", call. = FALSE)
  }
  
  # Clean data and compute correlation matrix
  cor_data <- data[vars][complete.cases(data[vars]), ]
  if (nrow(cor_data) == 0) stop("No complete cases found", call. = FALSE)
  
  cor_mat <- stats::cor(cor_data, method = method)
  
  # Compute p-values if needed
  p_mat <- NULL
  if (show_significance) {
    n_vars <- ncol(cor_data)
    p_mat <- matrix(1, n_vars, n_vars)
    for (i in 1:(n_vars-1)) {
      for (j in (i+1):n_vars) {
        test_result <- tryCatch(stats::cor.test(cor_data[,i], cor_data[,j], method = method),
                                error = function(e) NULL)
        if (!is.null(test_result)) p_mat[i,j] <- p_mat[j,i] <- test_result$p.value
      }
    }
  }
  
  # Convert to long format
  cor_df <- expand.grid(Var1 = factor(rownames(cor_mat), levels = rownames(cor_mat)),
                        Var2 = factor(colnames(cor_mat), levels = rev(colnames(cor_mat))))
  cor_df$value <- as.vector(cor_mat)
  
  # Apply matrix type filtering
  n_vars <- nrow(cor_mat)
  if (type == "upper") {
    keep_indices <- which(upper.tri(matrix(1, n_vars, n_vars), diag = diag))
  } else if (type == "lower") {
    keep_indices <- which(lower.tri(matrix(1, n_vars, n_vars), diag = diag))
  } else {
    keep_indices <- if (diag) 1:nrow(cor_df) else which(cor_df$Var1 != cor_df$Var2)
  }
  cor_df <- cor_df[keep_indices, ]
  
  # Add significance markers
  if (show_significance && !is.null(p_mat)) {
    cor_df$significant <- as.vector(p_mat)[keep_indices] < sig_level
  }
  
  # Set colors
  if (is.null(colors)) colors <- c("#489CAC", "#FFFFFF", "#79E1BE")
  if (length(colors) != 3) stop("colors must be a vector of 3 colors (negative, neutral, positive)", call. = FALSE)
  
  # Create plot
  p <- ggplot(cor_df, aes(x = .data[["Var1"]], y = .data[["Var2"]], fill = .data[["value"]])) +
    geom_tile(color = "black", linewidth = 0.5) +
    scale_fill_gradient2(low = colors[1], mid = colors[2], high = colors[3],
                         midpoint = 0, limit = c(-1, 1),
                         name = paste(tools::toTitleCase(method), "\nCorrelation")) +
    theme_minimal(base_size = text_size) +
    theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1, color = "black"),
          axis.text.y = element_text(color = "black"),
          axis.title = element_blank(),
          panel.grid = element_blank(),
          panel.background = element_blank(),
          plot.title = element_text(hjust = 0.5, face = "bold"),
          legend.title = element_text(size = text_size * 0.9),
          legend.text = element_text(size = text_size * 0.8)) +
    coord_fixed()
  
  # Add values and significance
  if (show_values) {
    value_labels <- sprintf("%.2f", cor_df$value)
    if (show_significance && "significant" %in% names(cor_df)) {
      value_labels[cor_df$significant & !is.na(cor_df$significant)] <- 
        paste0(value_labels[cor_df$significant & !is.na(cor_df$significant)], "*")
    }
    p <- p + geom_text(aes(label = value_labels), 
                       color = "black", size = value_size * 1.2)
  }
  
  if (!is.null(title)) p <- p + labs(title = title)
  return(p)
}
