#' Create Simple Professional Bar Plots
#'
#' Generates publication-ready bar plots with minimal code using ggplot2.
#'
#' @param data A data frame containing the variables to plot
#' @param x Character string specifying the x-axis variable.
#' @param y Character string specifying the y-axis variable. If NULL, counts calculated automatically. Default: NULL.
#' @param group Character string specifying the grouping variable for fill color. Default: NULL.
#' @param facet Character string specifying the faceting variable. Default: NULL.
#' @param position Character string specifying bar position: "dodge", "stack", or "fill".
#' @param stat Character string for statistical aggregation: "mean" or "median".
#' @param colors Character vector of colors. If NULL, uses TealGrn palette. Default: NULL.
#' @param title Character string for plot title. Default: NULL.
#' @param xlab Character string for x-axis label. Default: NULL.
#' @param ylab Character string for y-axis label. Default: NULL.
#' @param legend_title Character string for legend title. Default: NULL.
#' @param flip Logical parameter indicating whether to flip coordinates. Default: FALSE.
#' @param values Logical parameter indicating whether to display value labels above bars. Default: FALSE.
#'
#' @return A ggplot2 object
#'
#' @examples
#' clinical_df <- clinical_data()
#' plot_bar(clinical_df, x = "treatment", group = "response", position = "fill")
#'
#' @importFrom stats aggregate as.formula
#' @importFrom grDevices hcl.colors
#' @importFrom rlang .data
#' @import ggplot2
#' @export

plot_bar <- function(data,
                     x,
                     y = NULL,
                     group = NULL,
                     facet = NULL,
                     position = c("dodge", "stack", "fill"),
                     stat = NULL,
                     colors = NULL,
                     title = NULL,
                     xlab = NULL,
                     ylab = NULL,
                     legend_title = NULL,
                     flip = FALSE,
                     values = FALSE) {
  
  # Input validation
  if (!is.data.frame(data)) stop("'data' must be a data frame.", call. = FALSE)
  vars_to_check <- c(x, y, group, facet)[!sapply(c(x, y, group, facet), is.null)]
  missing_vars <- setdiff(vars_to_check, names(data))
  if (length(missing_vars) > 0) {
    stop(paste("Variables not found in data:", paste(missing_vars, collapse = ", "), "."), call. = FALSE)
  }
  position <- match.arg(position)
  if (!is.null(stat)) {
    stat <- match.arg(stat, c("mean", "median"))
    if (is.null(y)) stop("'y' variable must be specified when using 'stat' parameter.", call. = FALSE)
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
  if (!is.null(stat) && !is.null(y)) {
    group_vars <- c(x, group, facet)[!sapply(c(x, group, facet), is.null)]
    agg_formula <- as.formula(paste(y, "~", paste(group_vars, collapse = " + ")))
    agg_fun <- if (stat == "mean") mean else stats::median
    data <- aggregate(agg_formula, data = data, FUN = function(v) agg_fun(v, na.rm = TRUE))
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
  p <- ggplot(data, aes(x = .data[[x]]))
  
  if (is.null(y)) {
    # Count-based plots
    if (single_color) {
      p <- p + geom_bar(fill = colors[1], color = NA, alpha = 0.8)
      if (values) {
        p <- p + geom_text(stat = "count", aes(label = after_stat(.data[["count"]])),
                           vjust = -0.5, size = 4)
      }
    } else {
      p <- p + geom_bar(aes(fill = .data[[group]]), position = position, color = NA, alpha = 0.8) +
        scale_fill_manual(values = colors)
      if (values) {
        text_aes <- switch(position,
                           fill = aes(label = after_stat(paste0(round(100 * .data[["prop"]], 1), "%")), group = .data[[group]]),
                           aes(label = after_stat(.data[["count"]]), group = .data[[group]]))
        text_pos <- switch(position,
                           fill = position_fill(vjust = 0.5),
                           stack = position_stack(vjust = 0.5),
                           position_dodge(width = 0.9))
        text_vjust <- if (position == "dodge") -0.5 else 0.5
        p <- p + geom_text(text_aes, stat = "count", position = text_pos,
                           vjust = text_vjust, size = 4)
      }
    }
    if (is.null(ylab)) ylab <- if (position == "fill") "Percentage" else "Count"
  } else {
    # Value-based plots
    p <- ggplot(data, aes(x = .data[[x]], y = .data[[y]]))
    if (!is.null(group)) {
      p <- p + geom_col(aes(fill = .data[[group]]), position = position, color = NA, alpha = 0.8) +
        scale_fill_manual(values = colors)
      if (values) {
        if (position == "fill") {
          p <- p + geom_text(aes(label = paste0(round(100 * .data[[y]]/sum(.data[[y]]), 1), "%"),
                                 group = .data[[group]]), position = position_fill(vjust = 0.5), size = 4)
        } else if (position == "stack") {
          p <- p + geom_text(aes(label = round(.data[[y]], 1), group = .data[[group]]),
                             position = position_stack(vjust = 0.5), size = 4)
        } else {
          p <- p + geom_text(aes(label = round(.data[[y]], 1), group = .data[[group]]),
                             position = position_dodge(width = 0.9), vjust = -0.5, size = 4)
        }
      }
    } else {
      fill_aes <- if (!is.null(facet)) aes(fill = .data[[x]]) else NULL
      p <- p + geom_col(fill_aes, fill = if (is.null(facet)) colors[1] else NULL, color = NA, alpha = 0.8)
      if (!is.null(facet)) p <- p + scale_fill_manual(values = colors)
      if (values) p <- p + geom_text(aes(label = round(.data[[y]], 1)), vjust = -0.5, size = 4)
    }
    if (is.null(ylab)) ylab <- y
  }
  
  # Y-axis scale and faceting
  if (position == "fill") {
    p <- p + scale_y_continuous(labels = function(x) paste0(x * 100, "%"), expand = expansion(mult = c(0, 0)))
  } else {
    p <- p + scale_y_continuous(expand = expansion(mult = c(0, 0.1)))
  }
  if (!is.null(facet)) p <- p + facet_wrap(as.formula(paste("~", facet)), 
                                           strip.position = "top",
                                           labeller = label_value)
  
  # Theme and labels
  p <- p +
    labs(title = title, x = if (!is.null(xlab)) xlab else x, y = ylab,
         fill = if (!is.null(legend_title)) legend_title else group) +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5),
          panel.grid.minor = element_blank(),
          legend.position = if (single_color) "none" else "right")
  
  if (flip) p <- p + coord_flip()
  return(p)
}
