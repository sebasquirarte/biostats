#' Calculate and visualize sample size across a range of treatment effects
#'
#' Calculates required sample sizes for specified power levels (70%, 80%, 90%)
#' across a range of treatment effect values (`x1`), while keeping the control
#' group value (`x2`) fixed. Internally calls `sample_size()` and generates a
#' plot to visualize how total sample size changes with varying `x1`.
#'
#' @param x1_range Numeric vector of length 2. Range of values to evaluate for
#'   the treatment group mean or proportion (`x1`).
#' @param x2 Numeric. Fixed reference value for the control group.
#' @param step Numeric. Step size to increment across the `x1_range`. Default is 0.1.
#' @param ... Additional arguments passed to `sample_size()`, such as `sample`,
#'   `design`, `outcome`, `type`, `SD`, `alpha`, etc.
#'
#' @return Invisibly returns a data frame with the following columns:
#'   \describe{
#'     \item{power}{Power level in percent (70, 80, 90).}
#'     \item{x1}{Value of the treatment effect evaluated.}
#'     \item{x2}{Fixed value for the control group.}
#'     \item{n1}{Sample size for group 1 (treatment).}
#'     \item{n2}{Sample size for group 2 (control).}
#'     \item{total}{Total sample size (n1 + n2 or total per design).}
#'   }
#'   A plot is also printed to visualize how total sample size changes across `x1`.
#'
#' @examples
#' # One-sample equivalence test for means
#' result <- sample_size_range(x1_range = c(-0.01, 0.01),
#'                             x2 = 0,
#'                             step = 0.005,
#'                             sample = "one-sample",
#'                             outcome = "mean",
#'                             type = "equivalence",
#'                             SD = 0.1,
#'                             delta = 0.05,
#'                             alpha = 0.05)
#' # Two-sample parallel non-inferiority test for proportions w/ 10% dropout rate
#' result <- sample_size_range(x1_range = c(0.65, 0.75),
#'                             x2 = 0.65,
#'                             step = 0.01,
#'                             sample = "two-sample",
#'                             design = "parallel",
#'                             outcome = "proportion",
#'                             type = "non-inferiority",
#'                             delta = -0.1,
#'                             alpha = 0.05,
#'                             dropout_rate = 0.1)
#' # Two-sample crossover non-inferiority test for means
#' result <- sample_size_range(x1_range = c(-0.15, -0.10),
#'                             x2 = 0,
#'                             step = 0.01,
#'                             sample = "two-sample",
#'                             design = "crossover",
#'                             outcome = "mean",
#'                             type = "non-inferiority",
#'                             SD = 0.20,
#'                             delta = -0.20,
#'                             alpha = 0.05)
#'
#' @seealso \code{\link{sample_size}}
#'
#' @references
#' Chow, S., Shao, J., & Wang, H. (2008). \emph{Sample Size Calculations in
#' Clinical Research} (2nd ed.). Chapman & Hall/CRC.
#'
#' @importFrom ggplot2 ggplot aes geom_line geom_ribbon
#'   scale_color_manual labs theme_minimal geom_point
#' @importFrom utils capture.output
#'
#' @export
sample_size_range <- function(x1_range = c(0.5, 1.5),
                              x2 = 0,
                              step = 0.1,
                              ...) {

  # Declare ggplot2 variables to avoid R CMD check NOTEs
  x1 <- total <- power <- ymin <- ymax <- NULL

  if (x1_range[1] >= x1_range[2]) stop("x1_range[1] must be less than x1_range[2].")
  power_levels <- c(70, 80, 90)
  x1_seq <- seq(x1_range[1], x1_range[2], by = step)
  results <- expand.grid(x1 = x1_seq, power = power_levels)

  # Pre-allocate vectors for n1 and n2
  n1_vec <- numeric(nrow(results))
  n2_vec <- numeric(nrow(results))
  total_vec <- numeric(nrow(results))

  # Calculate sample sizes for each combination
  for (i in seq_len(nrow(results))) {
    res <- tryCatch({
      suppressMessages(capture.output(
        ss <- sample_size(x1 = results$x1[i], x2 = x2, beta = 1 - results$power[i]/100, ...)
      ))
      if (!is.finite(ss$total)) {
        list(n1 = NA, n2 = NA, total = NA)
      } else {
        list(n1 = ss$n1, n2 = ss$n2, total = ss$total)
      }
    }, error = function(e) {
      list(n1 = NA, n2 = NA, total = NA)
    })
    n1_vec[i] <- res$n1
    n2_vec[i] <- res$n2
    total_vec[i] <- res$total
  }

  results$n1 <- n1_vec
  results$n2 <- n2_vec
  results$total <- total_vec
  results$x2 <- x2
  results$`x1 - x2` <- results$x1 - results$x2

  # Print summary ignoring NAs
  cat("\nSample Size Range\n\n")
  cat(sprintf("x1: %.2f to %.2f\n", x1_range[1], x1_range[2]))
  cat(sprintf("x2: %.2f\n\n", x2))

  for (pwr in power_levels) {
    pwr_data <- results[results$power == pwr, ]
    cat(sprintf("%d%% Power: total n = %s to %s\n",
                pwr,
                ifelse(all(is.na(pwr_data$total)), "NA", min(pwr_data$total, na.rm = TRUE)),
                ifelse(all(is.na(pwr_data$total)), "NA", max(pwr_data$total, na.rm = TRUE))))
  }
  cat("\n")

  colors <- c("70" = "#c7ebe2", "80" = "#7fcdbb", "90" = "#41a296")

  p <- ggplot(results, aes(x = x1, y = total, color = factor(power))) +
    geom_line(size = 1.2) +
    geom_point(size = 2, na.rm = TRUE) +
    scale_color_manual(
      values = colors,
      name = "Power (1 - beta)",
      labels = c("90%", "80%", "70%"),
      breaks = c("90", "80", "70")) +
    labs(x = "x1 (Treatment)", y = "Sample Size") +
    theme_minimal()

  for (i in 1:2) {
    lower <- results[results$power == power_levels[i], ]
    upper <- results[results$power == power_levels[i + 1], ]
    valid_idx <- !(is.na(lower$total) | is.na(upper$total))
    p <- p + geom_ribbon(
      data = data.frame(x1 = lower$x1[valid_idx], ymin = upper$total[valid_idx], ymax = lower$total[valid_idx]),
      aes(x = x1, ymin = ymin, ymax = ymax),
      inherit.aes = FALSE, alpha = 0.2,
      fill = colors[as.character(power_levels[i])]
    )
  }

  print(p)
  invisible(results[, c("power", "x1", "x2", "x1 - x2", "n1", "n2", "total")])
}
