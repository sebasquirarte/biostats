#' Create Simple Professional Histogram Plots
#'
#' Generates publication-ready histogram plots with minimal code using ggplot2.
#'
#' @param data A dataframe containing the variables to plot.
#' @param x Character string specifying the variable for the histogram.
#' @param group Character string specifying the grouping variable for multiple histograms. Default: NULL.
#' @param facet Character string specifying the faceting variable. Default: NULL.
#' @param bins Numeric value indicating the  number of bins for the histogram. Default: 30. 
#' @param binwidth Numeric value indicating the width of the bins (overrides bins if specified). Default: NULL.
#' @param alpha Numeric value indicating the transparency level for the bars. Default: 0.7.
#' @param colors Character vector of colors. If NULL, uses TealGrn palette. Default: NULL.
#' @param title Character string for plot title. Default: NULL.
#' @param xlab Character string for x-axis label. Default: NULL.
#' @param ylab Character string for y-axis label. Default: NULL.
#' @param legend_title Character string for legend title. Default: NULL.
#' @param y_limits Numeric vector of length 2 for y-axis limits. Default: NULL.
#' @param x_limits Numeric vector of length 2 for x-axis limits. Default: NULL.
#' @param stat Character string that adds line for "mean" or "median". Default: NULL.
#'
#' @return A ggplot2 object
#'
#' @examples
#' # Simulated clinical data
#' clinical_df <- clinical_data()
#' 
#' # Mirror histogram for 2 groups with mean lines
#' plot_hist(clinical_df, x = "biomarker", group = "treatment", stat = "mean")
#' 
#' # Faceted histogram
#' plot_hist(clinical_df, x = "biomarker", facet = "treatment")
#'
#' @importFrom stats aggregate as.formula median
#' @importFrom grDevices hcl.colors
#' @importFrom rlang .data
#' @import ggplot2
#' @export

plot_hist <- function(data,
                      x,
                      group = NULL,
                      facet = NULL,
                      bins = 30,
                      binwidth = NULL,
                      alpha = 0.7,
                      colors = NULL,
                      title = NULL,
                      xlab = NULL,
                      ylab = NULL,
                      legend_title = NULL,
                      y_limits = NULL,
                      x_limits = NULL,
                      stat = NULL) {
  
  # Input validation
  if (!is.data.frame(data)) stop("'data' must be a data frame.", call. = FALSE)
  vars_to_check <- c(x, group, facet)[!is.na(c(x, group, facet))]
  missing_vars <- setdiff(vars_to_check, names(data))
  if (length(missing_vars) > 0) {
    stop(paste("Variables not found in data:", paste(missing_vars, collapse = ", "), "."), call. = FALSE)
  }
  if (!is.numeric(data[[x]])) stop("'x' variable must be numeric for histogram.", call. = FALSE)
  if (!is.null(stat)) stat <- match.arg(stat, c("mean", "median"))
  if (!is.null(group) && length(unique(data[[group]])) > 2) {
    stop("Mirror histograms only support 2 groups.", call. = FALSE)
  }
  
  # Data preparation
  for (var in c(group, facet)[!sapply(c(group, facet), is.null)]) {
    data <- data[!is.na(data[[var]]), ]
    if (!is.factor(data[[var]])) data[[var]] <- factor(data[[var]])
  }
  data <- data[!is.na(data[[x]]), ]
  
  # Color setup
  if (is.null(colors)) {
    if (is.null(group) && is.null(facet)) {
      colors <- "#79E1BE"
    } else if (is.null(group) && !is.null(facet)) {
      colors <- hcl.colors(length(unique(data[[facet]])), palette = "TealGrn")
    } else {
      colors <- hcl.colors(length(unique(data[[group]])), palette = "TealGrn")
    }
  }
  
  # Histogram setup
  hist_args <- list(bins = if (is.null(binwidth)) bins else NULL, binwidth = binwidth,
                    color = "white", linewidth = 0.2)
  is_same_var <- !is.null(facet) && !is.null(group) && group == facet
  is_mirror <- !is.null(group) && length(unique(data[[group]])) == 2 && !is_same_var
  
  # Create base plot
  if (is.null(group)) {
    if (!is.null(facet)) {
      p <- ggplot(data, aes(x = .data[[x]], fill = .data[[facet]])) +
        do.call(geom_histogram, c(hist_args, list(alpha = alpha)))
    } else {
      p <- ggplot(data, aes(x = .data[[x]])) +
        do.call(geom_histogram, c(hist_args, list(fill = colors[1], alpha = alpha)))
    }
  } else if (is_same_var) {
    p <- ggplot(data, aes(x = .data[[x]], fill = .data[[facet]])) +
      do.call(geom_histogram, c(hist_args, list(alpha = alpha)))
  } else if (is_mirror) {
    groups <- levels(factor(data[[group]]))
    group1_data <- data[data[[group]] == groups[1], ]
    group2_data <- data[data[[group]] == groups[2], ]
    
    p <- ggplot() +
      do.call(geom_histogram, c(list(data = group1_data, 
                                     mapping = aes(x = .data[[x]], y = after_stat(.data[["count"]]), fill = .data[[group]]),
                                     alpha = 0.7), hist_args)) +
      do.call(geom_histogram, c(list(data = group2_data, 
                                     mapping = aes(x = .data[[x]], y = -after_stat(.data[["count"]]), fill = .data[[group]]),
                                     alpha = 0.7), hist_args)) +
      geom_hline(yintercept = 0, color = "black", linewidth = 0.5, alpha = 0.7)
    
    if (is.null(facet)) {
      p_built <- ggplot_build(p)
      y_range <- p_built$layout$panel_params[[1]]$y.range
      y_max <- max(abs(y_range))
      p <- p + coord_cartesian(ylim = c(-y_max, y_max))
    }
  } else {
    p <- ggplot(data, aes(x = .data[[x]], fill = .data[[group]])) +
      do.call(geom_histogram, c(hist_args, list(position = "identity", alpha = 0.5)))
  }
  
  # Add faceting and statistical lines
  if (!is.null(facet)) p <- p + facet_wrap(as.formula(paste("~", facet)))
  
  if (!is.null(stat)) {
    stat_fun <- if (stat == "mean") mean else median
    if (is.null(group) && is.null(facet)) {
      p <- p + geom_vline(xintercept = stat_fun(data[[x]], na.rm = TRUE), 
                          color = colors[1], linetype = "dashed", linewidth = 1, alpha = 0.8)
    } else if (!is.null(group)) {
      groups <- levels(factor(data[[group]]))
      for (i in seq_along(groups)) {
        stat_val <- stat_fun(data[data[[group]] == groups[i], ][[x]], na.rm = TRUE)
        p <- p + geom_vline(xintercept = stat_val, color = colors[i], 
                            linetype = "dashed", linewidth = 1, alpha = 0.8)
      }
    }
  }
  
  # Apply colors and theme
  show_legend <- !is.null(group) && !is_same_var
  if (!is.null(group)) {
    if (is_mirror && is.null(facet)) {
      p <- p + scale_fill_manual(name = legend_title %||% group, values = colors[1:2], 
                                 labels = levels(factor(data[[group]])),
                                 guide = guide_legend(override.aes = list(alpha = 0.7)))
    } else {
      p <- p + scale_fill_manual(values = colors, guide = if (show_legend) "legend" else "none")
    }
  } else if (!is.null(facet)) {
    p <- p + scale_fill_manual(values = colors, guide = "none")
  }
  
  # Axis limits and theme
  if (!is.null(y_limits)) {
    p <- p + scale_y_continuous(limits = y_limits, expand = expansion(mult = c(0, 0.1)))
  } else if (!is_mirror || !is.null(facet)) {
    p <- p + scale_y_continuous(expand = expansion(mult = c(0, 0.1)))
  }
  if (!is.null(x_limits)) {
    p <- p + scale_x_continuous(limits = x_limits, expand = expansion(mult = c(0.02, 0.02)))
  }
  
  p <- p +
    labs(title = title, x = xlab %||% x, y = ylab %||% "Count", fill = legend_title %||% group) +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5),
          panel.grid.minor = element_blank(), panel.grid.major.x = element_blank(),
          legend.position = if (show_legend) "right" else "none")
  
  return(p)
}
