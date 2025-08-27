#' Create Simple Professional Box Plots
#'
#' Generates publication-ready boxplots with optional jittered points and mean overlay.
#'
#' @param data A dataframe containing the variables to plot.
#' @param x Character string specifying the x-axis variable.
#' @param y Character string specifying the y-axis variable.
#' @param group Character string specifying grouping variable for fill/color. Default: NULL.
#' @param facet Character string specifying faceting variable. Default: NULL.
#' @param colors Character vector of colors. If NULL, uses TealGrn palette. Default: NULL.
#' @param title Character string for plot title. Default: NULL.
#' @param xlab Character string for x-axis label. Default: NULL.
#' @param ylab Character string for y-axis label. Default: NULL.
#' @param legend_title Character string for legend title. Default: NULL.
#' @param points Logical parameter indicating if jittered points. Default: FALSE.
#' @param point_size Numeric value indicating the size of points. Default: 2.
#' @param y_limits Numeric vector of length 2 for y-axis limits. Default: NULL.
#' @param show_mean Logical parameter indicating if mean should be shown. Default: TRUE.
#'
#' @return A ggplot2 object
#'
#' @examples
#' #Simulated clinical data
#' clinical_df <- clinical_data(visits = 10)
#' 
#' # Boxplot of biomarker by sex and treatment
#' plot_box(clinical_df, x = "sex", y = "biomarker", group = "treatment")
#' 
#' # Barplot of bimarker by study visit and treatment
#' plot_box(clinical_df, x = "visit", y = "biomarker", group = "treatment")
#'
#' @import ggplot2
#' @importFrom stats as.formula
#' @importFrom grDevices hcl.colors
#' @importFrom rlang .data
#' @export

plot_box <- function(data,
                     x,
                     y,
                     group = NULL,
                     facet = NULL,
                     colors = NULL,
                     title = NULL,
                     xlab = NULL,
                     ylab = NULL,
                     legend_title = NULL,
                     points = FALSE,
                     point_size = 2,
                     y_limits = NULL,
                     show_mean = TRUE) {
  
  # Input validation
  if (!is.data.frame(data)) stop("'data' must be a data frame.", call. = FALSE)
  vars_to_check <- c(x, y, group, facet)[!sapply(c(x, y, group, facet), is.null)]
  missing_vars <- setdiff(vars_to_check, names(data))
  if (length(missing_vars) > 0) {
    stop(paste("Variables not found in data:", paste(missing_vars, collapse = ", "), "."), call. = FALSE)
  }
  if (!is.null(y_limits) && (!is.numeric(y_limits) || length(y_limits) != 2)) {
    stop("'y_limits' must be a numeric vector of length 2.", call. = FALSE)
  }
  
  # Data preparation
  for (var in c(group, facet)[!sapply(c(group, facet), is.null)]) {
    data <- data[!is.na(data[[var]]), ]
    if (!is.factor(data[[var]])) data[[var]] <- factor(data[[var]])
  }
  if (is.numeric(data[[x]]) && length(unique(data[[x]])) <= 10) {
    data[[x]] <- factor(data[[x]])
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
  
  # Add jitter points (behind boxplot)
  if (points) {
    if (single_color) {
      p <- p + geom_jitter(width = 0.2, size = point_size, alpha = 0.3, color = colors[1])
    } else {
      p <- p + geom_jitter(aes(color = .data[[group]]), width = 0.2, size = point_size, alpha = 0.6) +
        scale_color_manual(values = colors)
    }
  }
  
  # Add boxplot
  if (single_color) {
    p <- p + geom_boxplot(fill = colors[1], color = "black", alpha = 0.8)
  } else {
    p <- p + geom_boxplot(aes(fill = .data[[group]]), alpha = 0.8) +
      scale_fill_manual(values = colors)
  }
  
  # Add mean points (conditional)
  if (show_mean) {
    if (single_color) {
      p <- p + stat_summary(fun = mean, geom = "point", shape = 21, size = 3, fill = "white", color = "black", stroke = 0.5)
    } else {
      p <- p + stat_summary(aes(group = .data[[group]]), fun = mean, geom = "point", 
                            shape = 21, size = 2.5, fill = "white", color = "black", stroke = 0.5, position = position_dodge(width = 0.75))
    }
  }
  
  # Faceting and axis limits
  if (!is.null(facet)) p <- p + facet_wrap(as.formula(paste("~", facet)))
  if (!is.null(y_limits)) {
    p <- p + scale_y_continuous(limits = y_limits, expand = expansion(mult = c(0.05, 0.1)))
  } else {
    p <- p + scale_y_continuous(expand = expansion(mult = c(0.05, 0.1)))
  }
  
  # Theme and labels
  p <- p +
    labs(title = title, x = if (!is.null(xlab)) xlab else x, y = if (!is.null(ylab)) ylab else y,
         fill = if (!is.null(legend_title)) legend_title else group,
         color = if (!is.null(legend_title)) legend_title else group) +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5),
          legend.position = if (single_color) "none" else "right",
          strip.text = element_text())
  
  return(p)
}
