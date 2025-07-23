# Helper functions that create summary statistics

# Create summary statistics for any variable type
.create_summary <- function(x, all_stats = FALSE, force_median = FALSE) {
  if (length(x) == 0) return("No data")

  if (is.numeric(x)) {
    stats <- list(
      mean = mean(x, na.rm = TRUE),
      median = median(x, na.rm = TRUE),
      sd = sd(x, na.rm = TRUE),
      iqr = IQR(x, na.rm = TRUE)
    )

    p_norm <- .check_normality(x)
    use_mean <- !force_median && !is.na(p_norm) && p_norm > 0.05

    if (all_stats) {
      q <- quantile(x, c(0.25, 0.75), na.rm = TRUE)
      r <- range(x, na.rm = TRUE)
      return(sprintf("Mean (SD): %.2f (%.1f); Median (IQR): %.2f (%.1f,%.1f); Range: %.2f,%.2f",
                     stats$mean, stats$sd, stats$median, q[1], q[2], r[1], r[2]))
    }

    if (use_mean) {
      sprintf("Mean (SD): %.2f (%.2f)", stats$mean, stats$sd)
    } else {
      sprintf("Median (IQR): %.2f (%.2f)", stats$median, stats$iqr)
    }
  } else {
    # Categorical summary
    tab <- table(x)
    if (length(tab) == 0) return("No data")

    paste(names(tab), ": ", tab, " (", sprintf("%.1f", 100 * tab / sum(tab)), "%)",
          sep = "", collapse = "; ")
  }
}
