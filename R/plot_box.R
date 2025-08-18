#' Create Simple Professional Box Plots with Mean
#'
#' Generates publication-ready boxplots with optional jittered points and mean overlay.
#'
#' @param data A data frame containing the variables to plot
#' @param x Character string specifying the x-axis variable (categorical or numeric with few unique values)
#' @param y Character string specifying the y-axis variable (numeric)
#' @param group Optional character string specifying grouping variable for fill/color
#' @param facet Optional character string specifying faceting variable
#' @param colors Character vector of colors. If NULL, uses TealGrn palette
#' @param title Optional plot title
#' @param xlab Optional x-axis label
#' @param ylab Optional y-axis label
#' @param legend_title Optional legend title
#' @param points Logical; add jittered points (default: FALSE)
#' @param point_size Numeric; size of points
#' @param text_size Numeric; base text size
#' @param y_limits Numeric vector of length 2 for y-axis limits
#'
#' @examples
#' # Simulated clinical data
#' clinical_df <- clinical_data(visit = 10)
#'
#' # Barplot of age by sex and treatment
#' plot_box(clinical_df, x = "sex", y = "age", group = "treatment")
#'
#' # Barplot of bimarker by study visit and treatment
#' plot_box(clinical_df, x = "visit", y = "biomarker", group = "treatment")
#'
#' @return A ggplot2 object
#' @import ggplot2
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
                     text_size = 12,
                     y_limits = NULL) {
  
  # Input validation
  if (!is.data.frame(data)) stop("data must be a data frame", call. = FALSE)
  vars_to_check <- c(x, y, group, facet)[!sapply(c(x, y, group, facet), is.null)]
  missing_vars <- setdiff(vars_to_check, names(data))
  if (length(missing_vars) > 0) stop(paste("Variables not found in data:", paste(missing_vars, collapse = ", ")), call. = FALSE)
  
  # Clean data and convert to factors
  for (var in c(group, facet)[!sapply(c(group, facet), is.null)]) {
    data <- data[!is.na(data[[var]]), ]
    if (!is.factor(data[[var]])) data[[var]] <- factor(data[[var]])
  }
  
  # Convert numeric x with <=10 unique values to factor
  if (is.numeric(data[[x]]) && length(unique(data[[x]])) <= 10) data[[x]] <- factor(data[[x]])
  
  # Set colors
  if (is.null(colors)) {
    if (is.null(group)) {
      colors <- "#79E1BE"
    } else {
      n_colors <- length(unique(data[[group]]))
      colors <- if (n_colors == 1) "#79E1BE" else grDevices::hcl.colors(n_colors, palette = "TealGrn")
    }
  }
  
  single_color <- is.null(group) || length(unique(data[[group]])) == 1
  
  # Base plot
  p <- ggplot(data, aes(x = .data[[x]], y = .data[[y]]))
  
  # Add jitter (behind boxplot)
  if (points) {
    if (single_color) {
      p <- p + geom_jitter(width = 0.2, size = point_size, alpha = 0.3, color = colors[1])
    } else {
      p <- p + geom_jitter(aes(color = .data[[group]]), width = 0.8, size = point_size, alpha = 0.6) +
        scale_color_manual(values = colors)
    }
  }
  
  # Add boxplot on top
  if (single_color) {
    p <- p + geom_boxplot(fill = colors[1], color = "black", alpha = 0.8)
  } else {
    p <- p + geom_boxplot(aes(fill = .data[[group]]), alpha = 0.8) +
      scale_fill_manual(values = colors)
  }
  
  # Add mean points
  if (single_color) {
    p <- p + stat_summary(fun = mean, geom = "point", shape = 18, size = 3, color = "white")
  } else {
    p <- p + stat_summary(aes(fill = .data[[group]]), fun = mean, geom = "point", shape = 18, size = 3, color = "white", position = position_dodge(width = 0.75))
  }
  
  # Faceting
  if (!is.null(facet)) p <- p + facet_wrap(stats::as.formula(paste("~", facet)))
  
  # Labels and theme
  p <- p +
    labs(title = title,
         x = if (!is.null(xlab)) xlab else x,
         y = if (!is.null(ylab)) ylab else y,
         fill = if (!is.null(legend_title)) legend_title else group,
         color = if (!is.null(legend_title)) legend_title else group) +
    theme_minimal(base_size = text_size) +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"),
          panel.grid.minor = element_blank(),
          axis.ticks = element_line(color = "black"),
          legend.position = if (single_color) "none" else "right",
          strip.text = element_text(face = "bold"))
  
  # Y-axis limits
  if (!is.null(y_limits)) {
    p <- p + scale_y_continuous(limits = y_limits, expand = expansion(mult = c(0.05, 0.1)))
  }
  
  return(p)
}
