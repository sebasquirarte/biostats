#' Create Simple Professional Histogram Plots
#'
#' Generates publication-ready histogram plots with minimal code using ggplot2.
#'
#' @param data A dataframe containing the variables to plot.
#' @param x Character string specifying the variable for the histogram.
#' @param group Character string specifying the grouping variable for multiple histograms. Default: NULL.
#' @param facet Character string specifying the faceting variable. Default: NULL.
#' @param bins Numeric value indicating the number of bins for the histogram. Default: 30. 
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
#' # Basic histogram
#' plot_hist(clinical_df, x = "biomarker")
#' 
#' # Grouped histogram
#' plot_hist(clinical_df, x = "biomarker", group = "treatment")
#' 
#' # Faceted histogram
#' plot_hist(clinical_df, x = "biomarker", facet = "treatment")
#'
#' @import ggplot2
#' @importFrom stats aggregate as.formula median
#' @importFrom grDevices hcl.colors
#' @importFrom rlang .data
#' @export

plot_hist <- function(data, x, group = NULL, facet = NULL, bins = 30, binwidth = NULL,
                      alpha = 0.7, colors = NULL, title = NULL, xlab = NULL, ylab = NULL,
                      legend_title = NULL, y_limits = NULL, x_limits = NULL, stat = NULL) {
  
  # Input validation
  if (!is.data.frame(data)) stop("'data' must be a data frame.", call. = FALSE)
  vars_to_check <- c(x, group, facet)[!sapply(c(x, group, facet), is.null)]
  missing_vars <- setdiff(vars_to_check, names(data))
  if (length(missing_vars) > 0) {
    stop(paste("Variables not found in data:", paste(missing_vars, collapse = ", ")), call. = FALSE)
  }
  if (!is.numeric(data[[x]])) stop("'x' variable must be numeric for histogram.", call. = FALSE)
  if (!is.null(stat)) stat <- match.arg(stat, c("mean", "median"))
  if (!is.null(binwidth) && (!is.numeric(binwidth) || binwidth <= 0)) {
    stop("'binwidth' must be a positive numeric value.", call. = FALSE)
  }
  
  # Data preparation and cleaning
  data <- data[!is.na(data[[x]]), ]
  if (!is.null(group)) {
    data <- data[!is.na(data[[group]]), ]
    data[[group]] <- factor(data[[group]])
    if (length(unique(data[[group]])) > 2) {
      stop("Mirror histograms only support 2 groups.", call. = FALSE)
    }
  }
  if (!is.null(facet)) {
    data <- data[!is.na(data[[facet]]), ]
    data[[facet]] <- factor(data[[facet]])
  }
  
  # Color setup
  if (is.null(colors)) {
    n_colors <- if (!is.null(group)) length(unique(data[[group]])) else if (!is.null(facet)) length(unique(data[[facet]])) else 1
    colors <- if (n_colors == 1) "#79E1BE" else hcl.colors(n_colors, palette = "TealGrn")
  }
  
  # Create histogram layers based on scenario
  is_mirror <- !is.null(group) && length(unique(data[[group]])) == 2 && is.null(facet)
  
  if (is_mirror) {
    # Mirror histogram
    groups <- levels(data[[group]])
    group1_data <- data[data[[group]] == groups[1], ]
    group2_data <- data[data[[group]] == groups[2], ]
    
    if (is.null(binwidth)) {
      p <- ggplot() +
        geom_histogram(data = group1_data, aes(x = .data[[x]], y = after_stat(.data[["count"]]), fill = .data[[group]]),
                       bins = bins, alpha = alpha, color = "white", linewidth = 0.2) +
        geom_histogram(data = group2_data, aes(x = .data[[x]], y = -after_stat(.data[["count"]]), fill = .data[[group]]),
                       bins = bins, alpha = alpha, color = "white", linewidth = 0.2) +
        geom_hline(yintercept = 0, color = "black", linewidth = 0.5)
    } else {
      p <- ggplot() +
        geom_histogram(data = group1_data, aes(x = .data[[x]], y = after_stat(.data[["count"]]), fill = .data[[group]]),
                       binwidth = binwidth, alpha = alpha, color = "white", linewidth = 0.2) +
        geom_histogram(data = group2_data, aes(x = .data[[x]], y = -after_stat(.data[["count"]]), fill = .data[[group]]),
                       binwidth = binwidth, alpha = alpha, color = "white", linewidth = 0.2) +
        geom_hline(yintercept = 0, color = "black", linewidth = 0.5)
    }
  } else {
    # Standard histogram
    p <- ggplot(data, aes(x = .data[[x]]))
    
    if (!is.null(group)) {
      p <- p + aes(fill = .data[[group]])
      if (is.null(binwidth)) {
        p <- p + geom_histogram(bins = bins, alpha = 0.6, position = "identity", color = "white", linewidth = 0.2)
      } else {
        p <- p + geom_histogram(binwidth = binwidth, alpha = 0.6, position = "identity", color = "white", linewidth = 0.2)
      }
    } else if (!is.null(facet)) {
      p <- p + aes(fill = .data[[facet]])
      if (is.null(binwidth)) {
        p <- p + geom_histogram(bins = bins, alpha = alpha, color = "white", linewidth = 0.2)
      } else {
        p <- p + geom_histogram(binwidth = binwidth, alpha = alpha, color = "white", linewidth = 0.2)
      }
    } else {
      if (is.null(binwidth)) {
        p <- p + geom_histogram(bins = bins, fill = colors[1], alpha = alpha, color = "white", linewidth = 0.2)
      } else {
        p <- p + geom_histogram(binwidth = binwidth, fill = colors[1], alpha = alpha, color = "white", linewidth = 0.2)
      }
    }
  }
  
  # Add faceting
  if (!is.null(facet)) p <- p + facet_wrap(as.formula(paste("~", facet)))
  
  # Add statistical lines
  if (!is.null(stat)) {
    stat_fun <- if (stat == "mean") mean else median
    if (is.null(group)) {
      stat_val <- stat_fun(data[[x]], na.rm = TRUE)
      p <- p + geom_vline(xintercept = stat_val, color = colors[1], linetype = "dashed", linewidth = 1, alpha = 0.8)
    } else {
      groups <- levels(data[[group]])
      for (i in seq_along(groups)) {
        stat_val <- stat_fun(data[data[[group]] == groups[i], ][[x]], na.rm = TRUE)
        p <- p + geom_vline(xintercept = stat_val, color = colors[i], linetype = "dashed", linewidth = 1, alpha = 0.8)
      }
    }
  }
  
  # Apply colors and styling
  if (!is.null(group) || !is.null(facet)) {
    if (is_mirror) {
      p <- p + scale_fill_manual(name = legend_title %||% group, values = colors[1:2], 
                                 labels = levels(data[[group]]))
    } else {
      p <- p + scale_fill_manual(values = colors, name = legend_title %||% group %||% facet)
    }
  }
  
  # Apply limits and theme
  if (!is.null(y_limits)) p <- p + scale_y_continuous(limits = y_limits, expand = expansion(mult = c(0, 0.1)))
  else p <- p + scale_y_continuous(expand = expansion(mult = c(0, 0.1)))
  if (!is.null(x_limits)) p <- p + scale_x_continuous(limits = x_limits, expand = expansion(mult = c(0.05, 0.05)))
  else p <- p + scale_x_continuous(expand = expansion(mult = c(0.05, 0.05)))
  
  p <- p + labs(title = title, x = xlab %||% x, y = ylab %||% "Count", fill = legend_title %||% group %||% facet) +
    theme_minimal() +
    theme(plot.title = element_text(size = 20, hjust = 0.5, margin = margin(b = 20)), 
          panel.grid.minor = element_blank(), 
          panel.grid.major.x = element_blank(),
          legend.position = if (is.null(group) && is.null(facet)) "none" else "right",
          axis.title.x = element_text(size = 14, margin = margin(t = 10)),
          axis.title.y = element_text(size = 14, margin = margin(r = 10)),
          axis.text = element_text(size = 12))
  
  return(p)
}
