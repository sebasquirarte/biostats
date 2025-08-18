#' Create Simple Professional Histogram Plots
#'
#' Generates publication-ready histogram plots with minimal code using ggplot2.
#'
#' @param data A data frame containing the variables to plot
#' @param x Character string specifying the variable for the histogram
#' @param group Optional character string specifying the grouping variable for multiple histograms
#' @param facet Optional character string specifying the faceting variable
#' @param bins Numeric; number of bins for the histogram (default: 30)
#' @param binwidth Numeric; width of the bins (overrides bins if specified)
#' @param alpha Numeric; transparency level for the bars (default: 0.7)
#' @param colors Character vector of colors for bars. If NULL, uses TealGrn color palette
#' @param title Optional character string for the plot title
#' @param xlab Optional character string for the x-axis label
#' @param ylab Optional character string for the y-axis label
#' @param legend_title Optional character string for the legend title
#' @param text_size Numeric value specifying the base text size (default: 12)
#' @param y_limits Numeric vector of length 2 specifying y-axis limits (e.g., c(0, 100))
#' @param x_limits Numeric vector of length 2 specifying x-axis limits (e.g., c(0, 50))
#' @param stat Optional character string; adds a dashed line for "mean" or "median" (default: NULL)
#'
#' @return A ggplot2 object that can be further customized
#'
#' @examples
#' # Sample clinical data
#' clinical_df <- clinical_data()
#'
#' # Simple histogram
#' plot_hist(clinical_df, x = "biomarker")
#'
#' # Mirror histogram for 2 groups with mean lines
#' plot_hist(clinical_df, x = "biomarker", group = "treatment", stat = "mean")
#'
#' # Faceted histogram
#' plot_hist(clinical_df, x = "biomarker", facet = "treatment")
#'
#' @import ggplot2
#' @importFrom rlang .data
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
                      text_size = 12,
                      y_limits = NULL,
                      x_limits = NULL,
                      stat = NULL) {
  
  # Avoid R CMD check NOTEs about global variables
  count <- NULL
  
  # Input validation
  if (!is.data.frame(data)) stop("data must be a data frame", call. = FALSE)
  
  vars_to_check <- c(x, group, facet)[!is.na(c(x, group, facet))]
  missing_vars <- setdiff(vars_to_check, names(data))
  if (length(missing_vars) > 0) {
    stop(paste("Variables not found in data:", paste(missing_vars, collapse = ", ")), call. = FALSE)
  }
  
  if (!is.numeric(data[[x]])) stop("x variable must be numeric for histogram", call. = FALSE)
  if (!is.null(stat)) stat <- match.arg(stat, c("mean", "median"))
  if (!is.null(group) && length(unique(data[[group]])) > 2) {
    stop("Mirror histograms only support 2 groups. Use a different approach for more groups.", call. = FALSE)
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
      # Single histogram, no faceting
      colors <- "#79E1BE"
    } else if (is.null(group) && !is.null(facet)) {
      # Faceted without grouping - need colors for each facet level
      colors <- grDevices::hcl.colors(length(unique(data[[facet]])), palette = "TealGrn")
    } else {
      # Grouped histograms - need colors for each group level
      colors <- grDevices::hcl.colors(length(unique(data[[group]])), palette = "TealGrn")
    }
  }
  
  # Histogram arguments
  hist_args <- list(bins = if (is.null(binwidth)) bins else NULL, binwidth = binwidth, color = "white", linewidth = 0.2)
  
  # Determine plot type and build base plot
  is_same_var <- !is.null(facet) && !is.null(group) && group == facet
  is_mirror <- !is.null(group) && length(unique(data[[group]])) == 2 && !is_same_var
  
  if (is.null(group)) {
    # Single histogram
    if (!is.null(facet)) {
      # Faceted without grouping - use facet variable for colors
      p <- ggplot(data, aes(x = .data[[x]], fill = .data[[facet]])) +
        do.call(geom_histogram, c(hist_args, list(alpha = alpha)))
    } else {
      # Simple single histogram
      p <- ggplot(data, aes(x = .data[[x]])) +
        do.call(geom_histogram, c(hist_args, list(fill = colors[1], alpha = alpha)))
    }
  } else if (is_same_var) {
    # Group and facet are same variable - regular histograms with different colors per facet
    p <- ggplot(data, aes(x = .data[[x]], fill = .data[[facet]])) +
      do.call(geom_histogram, c(hist_args, list(alpha = alpha)))
  } else if (is_mirror) {
    # Mirror histograms for 2 groups
    groups <- levels(factor(data[[group]]))
    group1_data <- data[data[[group]] == groups[1], ]
    group2_data <- data[data[[group]] == groups[2], ]
    
    p <- ggplot() +
      do.call(geom_histogram, c(list(data = group1_data, 
                                     mapping = aes(x = .data[[x]], y = after_stat(count), fill = .data[[group]]),
                                     alpha = 0.7), hist_args)) +
      do.call(geom_histogram, c(list(data = group2_data, 
                                     mapping = aes(x = .data[[x]], y = -after_stat(count), fill = .data[[group]]),
                                     alpha = 0.7), hist_args)) +
      geom_hline(yintercept = 0, color = "black", linewidth = 0.5, alpha = 0.7)
    
    # For non-faceted mirror plots, ensure symmetric y-axis around zero
    if (is.null(facet)) {
      # Force symmetric limits around zero regardless of histogram heights
      p_built <- ggplot_build(p)
      y_range <- p_built$layout$panel_params[[1]]$y.range
      y_max <- max(abs(y_range))
      p <- p + coord_cartesian(ylim = c(-y_max, y_max))
    }
  } else {
    # Regular overlapping histograms
    p <- ggplot(data, aes(x = .data[[x]], fill = .data[[group]])) +
      do.call(geom_histogram, c(hist_args, list(position = "identity", alpha = 0.5)))
  }
  
  # Add faceting and statistical lines
  if (!is.null(facet)) p <- p + facet_wrap(stats::as.formula(paste("~", facet)))
  
  if (!is.null(stat)) {
    stat_fun <- if (stat == "mean") mean else stats::median
    
    if (is.null(group) && is.null(facet)) {
      # Single histogram
      p <- p + geom_vline(xintercept = stat_fun(data[[x]], na.rm = TRUE), color = colors[1], linetype = "dashed", linewidth = 1, alpha = 0.8)
    } else if (is.null(group) && !is.null(facet)) {
      # Faceted without grouping - colors should match each facet
      stat_data <- stats::aggregate(data[[x]], by = list(data[[facet]]), FUN = stat_fun, na.rm = TRUE)
      names(stat_data) <- c(facet, "stat_val")
      
      facet_levels <- levels(factor(data[[facet]]))
      for (i in seq_along(facet_levels)) {
        facet_stat_data <- stat_data[stat_data[[facet]] == facet_levels[i], ]
        p <- p + geom_vline(data = facet_stat_data, aes(xintercept = .data[["stat_val"]]),
                            color = colors[i], linetype = "dashed", linewidth = 1, alpha = 0.8)
      }
    } else if (!is.null(facet)) {
      # Faceted with grouping
      if (is_same_var) {
        # Same variable case
        stat_data <- stats::aggregate(data[[x]], by = list(data[[facet]]), FUN = stat_fun, na.rm = TRUE)
        names(stat_data) <- c(facet, "stat_val")
        
        facet_levels <- levels(factor(data[[facet]]))
        for (i in seq_along(facet_levels)) {
          facet_stat_data <- stat_data[stat_data[[facet]] == facet_levels[i], ]
          p <- p + geom_vline(data = facet_stat_data, aes(xintercept = .data[["stat_val"]]),
                              color = colors[i], linetype = "dashed", linewidth = 1, alpha = 0.8)
        }
      } else {
        # Different group and facet variables
        stat_data <- stats::aggregate(data[[x]], by = list(data[[group]], data[[facet]]), FUN = stat_fun, na.rm = TRUE)
        names(stat_data) <- c(group, facet, "stat_val")
        
        groups <- levels(factor(data[[group]]))
        for (i in seq_along(groups)) {
          group_stat_data <- stat_data[stat_data[[group]] == groups[i], ]
          p <- p + geom_vline(data = group_stat_data, aes(xintercept = .data[["stat_val"]]),
                              color = colors[i], linetype = "dashed", linewidth = 1, alpha = 0.8)
        }
      }
    } else {
      # Mirror or overlapping histograms
      groups <- levels(factor(data[[group]]))
      for (i in seq_along(groups)) {
        stat_val <- stat_fun(data[data[[group]] == groups[i], ][[x]], na.rm = TRUE)
        p <- p + geom_vline(xintercept = stat_val, color = colors[i], linetype = "dashed", linewidth = 1, alpha = 0.8)
      }
    }
  }
  
  # Apply colors, legends, theme, and axis limits
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
    # Faceted without grouping - apply colors and hide legend
    p <- p + scale_fill_manual(values = colors, guide = "none")
  }
  
  p <- p +
    labs(title = title, x = xlab %||% x, y = ylab %||% "Count", fill = legend_title %||% group) +
    theme_minimal(base_size = text_size) +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"),
          panel.grid.minor = element_blank(),
          panel.grid.major.x = element_blank(),
          axis.ticks = element_line(color = "black"),
          strip.text = element_text(face = "bold"),
          legend.position = if (show_legend) "right" else "none")
  
  # Apply axis limits
  if (!is.null(y_limits)) {
    p <- p + scale_y_continuous(limits = y_limits, expand = expansion(mult = c(0, 0.1)))
  } else if (!is_mirror || !is.null(facet)) {
    p <- p + scale_y_continuous(expand = expansion(mult = c(0, 0.1)))
  }
  
  if (!is.null(x_limits)) {
    p <- p + scale_x_continuous(limits = x_limits, expand = expansion(mult = c(0.02, 0.02)))
  } else {
    p <- p + scale_x_continuous(expand = expansion(mult = c(0.02, 0.02)))
  }
  
  return(p)
}