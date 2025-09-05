#' Calculate and visualize sample size across a range of treatment effects
#'
#' Calculates required sample sizes for specified power levels (70%, 80%, 90%)
#' across a range of treatment effect values (\code{x1}), while keeping the control
#' group value (\code{x2}) fixed. Internally calls \code{sample_size()} and generates a
#' plot to visualize how total sample size changes with varying \code{x1}.
#'
#' @param x1_range Numeric vector of length 2 specifying the range of values to 
#'   evaluate for the treatment group mean or proportion (\code{x1}).
#' @param x2 Numeric value for the control group mean or proportion (reference value).
#' @param step Numeric value indicating the step size to increment across the 
#'   \code{x1_range}. Default: 0.1.
#' @param ... Additional arguments passed to \code{sample_size()}, such as 
#'   \code{sample}, \code{design}, \code{outcome}, \code{type}, \code{SD}, 
#'   \code{alpha}, etc.
#'
#' @return 
#' Prints range analysis summary to console and invisibly returns a list containing 
#' the dataframe of sample size calculations and the ggplot object. A plot is also 
#' generated to visualize the relationship between treatment effects and required 
#' sample sizes.
#'
#' @examples
#' # Two-sample parallel non-inferiority test for proportions with 10% dropout
#' sample_size_range(x1_range = c(0.65, 0.75), x2 = 0.65, step = 0.01,
#'                   sample = "two-sample", design = "parallel", outcome = "proportion",
#'                   type = "non-inferiority", delta = -0.1, dropout = 0.1)
#'                   
#' # One-sample equivalence test for means
#' sample_size_range(x1_range = c(-0.01, 0.01), x2 = 0, step = 0.005,
#'                   sample = "one-sample", outcome = "mean", type = "equivalence",
#'                   SD = 0.1, delta = 0.05, alpha = 0.05)
#'
#' @seealso \code{\link{sample_size}}
#'
#' @references
#' Chow, S.-C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). Sample Size Calculations 
#' in Clinical Research (3rd ed.). Chapman and Hall/CRC. https://doi.org/10.1201/9781315183084
#'
#' @import ggplot2
#' @importFrom utils capture.output
#'
#' @export

sample_size_range <- function(x1_range, 
                              x2, 
                              step = 0.1, 
                              ...) {
  
  # Input validation
  if (!is.numeric(x1_range) || length(x1_range) != 2) {
    stop("'x1_range' must be a numeric vector of length 2.", call. = FALSE)
  }
  if (x1_range[1] >= x1_range[2]) {
    stop("'x1_range[1]' must be less than 'x1_range[2]'.", call. = FALSE)
  }
  if (!is.numeric(x2) || length(x2) != 1) {
    stop("'x2' must be a single numeric value.", call. = FALSE)
  }
  if (!is.numeric(step) || length(step) != 1 || step <= 0) {
    stop("'step' must be a positive single numeric value.", call. = FALSE)
  }
  
  # Declare variables to avoid R CMD check NOTEs
  x1 <- total <- power <- ymin <- ymax <- NULL
  
  # Setup calculations
  power_levels <- c(70, 80, 90)
  results <- expand.grid(x1 = seq(x1_range[1], x1_range[2], by = step), 
                         power = power_levels)
  dropout_rate <- if ("dropout" %in% names(list(...))) list(...)$dropout else 0
  
  # Calculate sample sizes
  for (i in seq_len(nrow(results))) {
    ss_result <- tryCatch({
      suppressMessages(capture.output({
        ss <- sample_size(x1 = results$x1[i], x2 = x2, 
                          beta = 1 - results$power[i] / 100, ...)
      }))
      ss
    }, error = function(e) list(n1 = NA_real_, n2 = NA_real_, total = NA_real_))
    
    results$n1[i] <- ss_result$n1
    results$n2[i] <- ss_result$n2  
    results$total[i] <- ss_result$total
  }
  
  results$x2 <- x2
  results$diff <- results$x1 - x2
  
  # Print summary
  cat("\nSample Size Range Analysis\n\n")
  cat(sprintf("Treatment range (x1): %.3f to %.3f\n", x1_range[1], x1_range[2]))
  cat(sprintf("Control/Reference (x2): %.3f\n", x2))
  cat(sprintf("Step size: %.3f\n\n", step))
  
  for (pwr in power_levels) {
    valid_totals <- results$total[results$power == pwr & !is.na(results$total)]
    if (length(valid_totals) > 0) {
      cat(sprintf("%d%% Power: Total n = %d to %d\n", pwr, min(valid_totals), 
                  max(valid_totals)))
    } else {
      cat(sprintf("%d%% Power: Total n = NA (no valid calculations)\n", pwr))
    }
  }
  
  if (dropout_rate > 0) {
    cat(sprintf("\nSample size increased by %.1f%% to account for potential dropouts.\n", 
                dropout_rate * 100))
  }
  cat("\n")
  
  # Create plot
  colors <- c("70" = "#C5F4C1", "80" = "#79E1BE", "90" = "#33BFBC")
  
  p <- ggplot2::ggplot(results, ggplot2::aes(x = x1, y = total, color = factor(power))) +
    ggplot2::geom_line(linewidth = 1.2, na.rm = TRUE) +
    ggplot2::geom_point(size = 2, na.rm = TRUE) +
    ggplot2::scale_color_manual(values = colors, name = "Power (1 - beta)",
                                labels = c("70%", "80%", "90%"),
                                breaks = c("70", "80", "90")) +
    ggplot2::labs(x = "x1 (Treatment Effect)", y = "Total Sample Size") +
    ggplot2::theme_minimal() 
  # Add ribbons
  for (i in seq_len(length(power_levels) - 1)) {
    lower_data <- results[results$power == power_levels[i], ]
    upper_data <- results[results$power == power_levels[i + 1], ]
    valid_idx <- !is.na(lower_data$total) & !is.na(upper_data$total)
    
    if (any(valid_idx)) {
      p <- p + ggplot2::geom_ribbon(
        data = data.frame(x1 = lower_data$x1[valid_idx],
                          ymin = upper_data$total[valid_idx],
                          ymax = lower_data$total[valid_idx]),
        ggplot2::aes(x = x1, ymin = ymin, ymax = ymax),
        inherit.aes = FALSE, alpha = 0.2,
        fill = colors[as.character(power_levels[i])]
      )
    }
  }
  
  print(p)
  
  invisible(list(data = results[, c("power", "x1", "x2", "diff", "n1", "n2", "total")],
                 plot = p))
}
