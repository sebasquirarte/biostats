#' Create Simple Professional Line Plots
#'
#' Generates publication-ready line plots with minimal code using ggplot2.
#'
#' @param data A data frame containing the variables to plot.
#' @param x Character string specifying the x-axis variable. 
#' @param y Character string specifying the y-axis variable.
#' @param group Character string specifying the grouping variable for multiple lines. Default: NULL.
#' @param facet Character string specifying the faceting variable. Default: NULL.
#' @param stat Character string for statistical aggregation: "mean" or "median".
#' @param error Character string for error bars: "se", "sd", "ci", or "none". Default: "se".
#' @param error_width Numeric value indicating the width of error bar caps. Default: 0.2.
#' @param colors Character vector of colors. If NULL, uses TealGrn palette. Default: NULL.
#' @param title Character string for plot title. Default: NULL.
#' @param xlab Character string for x-axis label. Default: NULL.
#' @param ylab Character string for y-axis label. Default: NULL.
#' @param legend_title Character string for legend title. Default: NULL.
#' @param points Logical parameter indicating whether to add points to lines. Default: TRUE.
#' @param line_size Numeric value indicating thickness of lines. Default: 1.
#' @param point_size Numeric value indicating size of points if shown. Default: 3.
#' @param y_limits Numeric vector of length 2 for y-axis limits. Default: NULL.
#' @param x_limits Numeric vector of length 2 for x-axis limits. Default: NULL.
#'
#' @return A ggplot2 object
#'
#' @examples
#' # Simulated clinical data
#' clinical_df <- clinical_data(arms = c("A","B","C"), visits = 10)
#' 
#' # Line plot with mean and standard error by treatment
#' plot_line(clinical_df, x = "visit", y = "biomarker",
#'           group = "treatment", stat = "mean", error = "se")
#' 
#' # Faceted line plots with median and 95% CI
#' plot_line(clinical_df, x = "visit", y = "biomarker", group = "treatment", 
#'           facet = "sex", stat = "median", error = "ci", points = FALSE)   
#'     
#' @import ggplot2                 
#' @importFrom stats aggregate as.formula sd qt quantile
#' @importFrom grDevices hcl.colors
#' @importFrom rlang .data
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
                      y_limits = NULL,
                      x_limits = NULL) {
  
  # Input validation
  if (!is.data.frame(data)) stop("'data' must be a data frame.", call. = FALSE)
  vars_to_check <- c(x, y, group, facet)[!is.na(c(x, y, group, facet))]
  missing_vars <- setdiff(vars_to_check, names(data))
  if (length(missing_vars) > 0) {
    stop(paste("Variables not found in data:", paste(missing_vars, collapse = ", "), "."), call. = FALSE)
  }
  error <- match.arg(error, c("none", "se", "sd", "ci"))
  if (!is.null(stat)) stat <- match.arg(stat, c("mean", "median"))
  if (!is.null(y_limits) && (!is.numeric(y_limits) || length(y_limits) != 2)) {
    stop("'y_limits' must be a numeric vector of length 2.", call. = FALSE)
  }
  if (!is.null(x_limits) && (!is.numeric(x_limits) || length(x_limits) != 2)) {
    stop("'x_limits' must be a numeric vector of length 2.", call. = FALSE)
  }
  
  # Data preparation
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
    agg_formula <- as.formula(paste(y, "~", paste(group_vars, collapse = " + ")))
    
    if (stat == "mean") {
      data <- aggregate(agg_formula, data = data,
                        FUN = function(v) c(val = mean(v, na.rm = TRUE),
                                            n = sum(!is.na(v)), sd = sd(v, na.rm = TRUE)))
      cols <- data[[y]]
      data[[y]] <- cols[, "val"]
      data$se <- cols[, "sd"] / sqrt(cols[, "n"])
      data$sd <- cols[, "sd"]
      data$ci_lower <- data[[y]] - qt(0.975, cols[, "n"] - 1) * data$se
      data$ci_upper <- data[[y]] + qt(0.975, cols[, "n"] - 1) * data$se
    } else {
      data <- aggregate(agg_formula, data = data,
                        FUN = function(v) quantile(v, c(0.5, 0.25, 0.75), na.rm = TRUE))
      cols <- data[[y]]
      data[[y]] <- cols[, 1]
      data$q25 <- cols[, 2]
      data$q75 <- cols[, 3]
    }
    if (is.null(ylab)) ylab <- paste(stat, "of", y)
  }
  
  # Color setup
  if (is.null(colors)) {
    if (is.null(group)) {
      colors <- "#79E1BE"
    } else {
      n_colors <- length(unique(data[[group]]))
      colors <- if (n_colors == 1) "#79E1BE" else hcl.colors(n_colors, palette = "TealGrn")
    }
  }
  single_color <- is.null(group) || length(unique(data[[group]])) == 1
  
  # Create base plot
  p <- ggplot(data, aes(x = .data[[x]], y = .data[[y]]))
  
  if (is.null(group)) {
    p <- p + geom_line(aes(group = 1), color = colors[1], linewidth = line_size, alpha = 0.8)
  } else if (single_color) {
    p <- p + geom_line(aes(group = .data[[group]]), color = colors[1], linewidth = line_size, alpha = 0.8)
  } else {
    p <- p + aes(color = .data[[group]], group = .data[[group]]) +
      geom_line(linewidth = line_size, alpha = 0.8) + scale_color_manual(values = colors)
  }
  
  # Add error bars
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
  
  # Faceting and axis limits
  if (!is.null(facet)) p <- p + facet_wrap(as.formula(paste("~", facet)))
  
  if (is.null(y_limits)) {
    p <- p + scale_y_continuous(expand = expansion(mult = c(0.05, 0.1)))
  } else {
    p <- p + scale_y_continuous(limits = y_limits, expand = expansion(mult = c(0.05, 0.1)))
  }
  
  if (!is.null(x_limits)) {
    if (is.numeric(data[[x]]) || !is.factor(data[[x]])) {
      p <- p + scale_x_continuous(limits = x_limits)
    } else {
      warning("'x_limits' ignored: x variable was converted to factor.", call. = FALSE)
    }
  }
  
  # Theme and labels
  p <- p +
    labs(title = title, x = if (!is.null(xlab)) xlab else x, y = if (!is.null(ylab)) ylab else y,
         color = if (!is.null(legend_title)) legend_title else group) +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5),
          panel.grid.minor = element_blank(),
          legend.position = if (single_color) "none" else "right")
  
  return(p)
}
