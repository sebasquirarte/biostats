#' Create Simple Professional Line Plots
#'
#' Generates publication-ready line plots with minimal code using ggplot2.
#'
#' @param data A data frame containing the variables to plot
#' @param x Character string specifying the x-axis variable (typically time or ordered)
#' @param y Character string specifying the y-axis variable (measurement or outcome)
#' @param group Optional character string specifying the grouping variable for multiple lines
#' @param facet Optional character string specifying the faceting variable
#' @param stat Optional character string for statistical aggregation; one of "mean" or "median"
#' @param error Optional character string for error bars; one of "se" (standard error, default),
#'   "sd" (standard deviation), "ci" (95% confidence interval), or "none"
#' @param error_width Numeric; width of the error bar caps (default: 0.2)
#' @param colors Character vector of colors for lines. If NULL, uses TealGrn color palette
#' @param title Optional character string for the plot title
#' @param xlab Optional character string for the x-axis label
#' @param ylab Optional character string for the y-axis label
#' @param legend_title Optional character string for the legend title
#' @param points Logical; whether to add points to the lines (default: TRUE)
#' @param line_size Numeric; thickness of the lines (default: 1)
#' @param point_size Numeric; size of the points if shown (default: 3)
#' @param text_size Numeric value specifying the base text size (default: 12)
#' @param y_limits Numeric vector of length 2 specifying y-axis limits (e.g., c(0, 100))
#' @param x_limits Numeric vector of length 2 specifying x-axis limits (e.g., c(1, 10))
#'
#' @return A ggplot2 object that can be further customized
#'
#' @examples
#' # Simulated clinical data
#' clinical_df <- clinical_data(visit = 4)
#'
#' # Line plot with mean and standard error by treatment
#' plot_line(clinical_df, x = "visit", y = "biomarker",
#'           group = "treatment", stat = "mean", error = "se")
#'
#' # Line plot with custom axis limits
#' plot_line(clinical_df, x = "visit", y = "biomarker",
#'           group = "treatment", y_limits = c(0, 50), x_limits = c(1, 4))
#'
#' @import ggplot2
#' @export
plot_line <- function(data,
                      x,
                      y,
                      group = NULL,
                      facet = NULL,
                      stat = NULL,
                      error = "se",
                      error_width = 0.2,
                      colors = NULL,
                      title = NULL,
                      xlab = NULL,
                      ylab = NULL,
                      legend_title = NULL,
                      points = TRUE,
                      line_size = 1,
                      point_size = 3,
                      text_size = 12,
                      y_limits = NULL,
                      x_limits = NULL) {

  # Input validation
  if (!is.data.frame(data)) stop("data must be a data frame", call. = FALSE)

  vars_to_check <- c(x, y, group, facet)[!is.na(c(x, y, group, facet))]
  missing_vars <- setdiff(vars_to_check, names(data))
  if (length(missing_vars) > 0) {
    stop(paste("Variables not found in data:", paste(missing_vars, collapse = ", ")), call. = FALSE)
  }

  error <- match.arg(error, c("none", "se", "sd", "ci"))
  if (!is.null(stat)) stat <- match.arg(stat, c("mean", "median"))

  # Validate axis limits
  if (!is.null(y_limits) && (!is.numeric(y_limits) || length(y_limits) != 2)) {
    stop("y_limits must be a numeric vector of length 2", call. = FALSE)
  }
  if (!is.null(x_limits) && (!is.numeric(x_limits) || length(x_limits) != 2)) {
    stop("x_limits must be a numeric vector of length 2", call. = FALSE)
  }

  # Clean data and convert to factors
  for (var in c(group, facet)[!sapply(c(group, facet), is.null)]) {
    data <- data[!is.na(data[[var]]), ]
    if (!is.factor(data[[var]])) data[[var]] <- factor(data[[var]])
  }

  if (is.numeric(data[[x]]) && length(unique(data[[x]])) <= 10) {
    data[[x]] <- factor(data[[x]])
  }

  # Statistical aggregation
  if (!is.null(stat)) {
    group_vars <- c(x, group, facet)[!sapply(c(x, group, facet), is.null)]
    agg_formula <- stats::as.formula(paste(y, "~", paste(group_vars, collapse = " + ")))

    if (stat == "mean") {
      data <- stats::aggregate(agg_formula, data = data,
                               FUN = function(v) c(val = mean(v, na.rm = TRUE),
                                                   n = sum(!is.na(v)),
                                                   sd = stats::sd(v, na.rm = TRUE)))
      cols <- data[[y]]
      data[[y]] <- cols[, "val"]
      data$se <- cols[, "sd"] / sqrt(cols[, "n"])
      data$sd <- cols[, "sd"]
      data$ci_lower <- data[[y]] - stats::qt(0.975, cols[, "n"] - 1) * data$se
      data$ci_upper <- data[[y]] + stats::qt(0.975, cols[, "n"] - 1) * data$se
    } else {
      data <- stats::aggregate(agg_formula, data = data,
                               FUN = function(v) stats::quantile(v, c(0.5, 0.25, 0.75), na.rm = TRUE))
      cols <- data[[y]]
      data[[y]] <- cols[, 1]
      data$q25 <- cols[, 2]
      data$q75 <- cols[, 3]
    }
    if (is.null(ylab)) ylab <- paste(stat, "of", y)
  }

  # Set colors
  if (is.null(colors)) {
    if (is.null(group)) {
      colors <- "#79E1BE"
    } else {
      n_colors <- length(unique(data[[group]]))
      colors <- if (n_colors == 1) "#79E1BE" else grDevices::hcl.colors(n_colors, palette = "TealGrn")
    }
  }

  # Determine if single color scenario
  single_color <- is.null(group) || length(unique(data[[group]])) == 1

  # Build plot with appropriate aesthetics
  p <- ggplot(data, aes(x = .data[[x]], y = .data[[y]]))

  if (is.null(group)) {
    p <- p + geom_line(aes(group = 1), color = colors[1], linewidth = line_size, alpha = 0.8)
  } else if (single_color) {
    p <- p + geom_line(aes(group = .data[[group]]), color = colors[1], linewidth = line_size, alpha = 0.8)
  } else {
    p <- p +
      aes(color = .data[[group]], group = .data[[group]]) +
      geom_line(linewidth = line_size, alpha = 0.8) +
      scale_color_manual(values = colors)
  }

  # Add error bars if requested
  if (!is.null(stat) && error != "none") {
    if (stat == "mean") {
      err_aes <- switch(error,
                        se = aes(ymin = .data[[y]] - .data[["se"]], ymax = .data[[y]] + .data[["se"]]),
                        sd = aes(ymin = .data[[y]] - .data[["sd"]], ymax = .data[[y]] + .data[["sd"]]),
                        ci = aes(ymin = .data[["ci_lower"]], ymax = .data[["ci_upper"]]))
    } else {
      err_aes <- aes(ymin = .data[["q25"]], ymax = .data[["q75"]])
    }

    if (single_color) {
      p <- p + geom_errorbar(err_aes, width = error_width, alpha = 0.6, color = colors[1])
    } else {
      p <- p + geom_errorbar(err_aes, width = error_width, alpha = 0.6)
    }
  }

  # Add points
  if (points) {
    if (single_color) {
      p <- p + geom_point(size = point_size, alpha = 0.9, color = colors[1])
    } else {
      p <- p + geom_point(size = point_size, alpha = 0.9)
    }
  }

  # Add faceting
  if (!is.null(facet)) {
    p <- p + facet_wrap(stats::as.formula(paste("~", facet)))
  }

  # Apply theme and labels
  p <- p +
    labs(title = title,
         x = if (!is.null(xlab)) xlab else x,
         y = if (!is.null(ylab)) ylab else y,
         color = if (!is.null(legend_title)) legend_title else group) +
    theme_minimal(base_size = text_size) +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"),
          panel.grid.minor = element_blank(),
          axis.ticks = element_line(color = "black"),
          legend.position = if (is.null(group)) "none" else "right",
          strip.text = element_text(face = "bold"))

  # Apply axis limits and scales
  if (is.null(y_limits)) {
    p <- p + scale_y_continuous(expand = expansion(mult = c(0.05, 0.1)))
  } else {
    p <- p + scale_y_continuous(limits = y_limits, expand = expansion(mult = c(0.05, 0.1)))
  }

  if (!is.null(x_limits)) {
    # Apply x_limits only if x is numeric (not converted to factor)
    if (is.numeric(data[[x]]) || !is.factor(data[[x]])) {
      p <- p + scale_x_continuous(limits = x_limits)
    } else {
      warning("x_limits ignored: x variable was converted to factor. Use numeric x values for x_limits.", call. = FALSE)
    }
  }

  return(p)
}
