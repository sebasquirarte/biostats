#' Create Simple Professional Bar Plots
#'
#' Generates publication-ready bar plots with minimal code using ggplot2.
#'
#' @param data A data frame containing the variables to plot
#' @param x Character string specifying the x-axis variable
#' @param y Optional character string specifying the y-axis variable. If provided,
#'   values from this column will be used for bar heights. If NULL (default),
#'   counts will be calculated automatically
#' @param group Optional character string specifying the grouping variable for fill color
#' @param facet Optional character string specifying the faceting variable
#' @param position Character string specifying the bar position; one of "dodge" (default),
#'   "stack", or "fill" (for percentage stacking)
#' @param stat Optional character string for statistical aggregation; one of "mean" or "median"
#' @param colors Character vector of colors for bars or groups. If NULL, uses
#'   TealGrn color palette
#' @param title Optional character string for the plot title
#' @param xlab Optional character string for the x-axis label
#' @param ylab Optional character string for the y-axis label
#' @param legend_title Optional character string for the legend title
#' @param flip Logical; whether to flip the coordinates (horizontal bars)
#' @param text_size Numeric value specifying the base text size (default: 12)
#' @param values Logical; whether to display value labels above bars (default: FALSE)
#'
#' @return A ggplot2 object that can be further customized
#'
#' @examples
#' # Simulated clinical data
#' clinical_df <- clinical_data()
#'
# Proportion of response by treatment
#'plot_bar(clinical_df, x = "treatment", group = "response",
#'         position = "fill", values = TRUE)
#'
#' # Grouped barplot of categorical variable by treatment with value labels
#' plot_bar(clinical_df, x = "response", group = "visit", facet = "treatment", values = TRUE)
#'
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
                     text_size = 12,
                     values = FALSE) {

  # Input validation
  if (!is.data.frame(data)) stop("data must be a data frame", call. = FALSE)

  vars_to_check <- c(x, y, group, facet)[!sapply(c(x, y, group, facet), is.null)]
  missing_vars <- setdiff(vars_to_check, names(data))
  if (length(missing_vars) > 0) {
    stop(paste("Variables not found in data:", paste(missing_vars, collapse = ", ")), call. = FALSE)
  }

  position <- match.arg(position)
  if (!is.null(stat)) {
    stat <- match.arg(stat, c("mean", "median"))
    if (is.null(y)) stop("y variable must be specified when using stat parameter", call. = FALSE)
  }

  # Clean data and convert to factors
  for (var in c(group, facet)[!sapply(c(group, facet), is.null)]) {
    data <- data[!is.na(data[[var]]), ]
    if (!is.factor(data[[var]])) data[[var]] <- factor(data[[var]])
  }

  # Convert x to factor if numeric with ≤10 unique values
  if (is.numeric(data[[x]]) && length(unique(data[[x]])) <= 10) {
    data[[x]] <- factor(data[[x]])
  }

  # Statistical aggregation
  if (!is.null(stat) && !is.null(y)) {
    group_vars <- c(x, group, facet)[!sapply(c(x, group, facet), is.null)]
    agg_formula <- stats::as.formula(paste(y, "~", paste(group_vars, collapse = " + ")))
    agg_fun <- if (stat == "mean") mean else stats::median
    data <- stats::aggregate(agg_formula, data = data, FUN = function(v) agg_fun(v, na.rm = TRUE))

    if (is.null(ylab)) ylab <- paste(stat, "of", y)
  }

  # Set colors - use #79E1BE for single group scenarios
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

  # Create base plot
  p <- ggplot(data, aes(x = .data[[x]]))

  if (is.null(y)) {
    # Count-based plots
    if (single_color) {
      p <- p + geom_bar(fill = colors[1], color = "black", alpha = 0.8)
      if (values) {
        p <- p + geom_text(stat = "count", aes(label = after_stat(.data[["count"]])),
                           vjust = -0.5, size = text_size / 3)
      }
    } else {
      p <- p +
        geom_bar(aes(fill = .data[[group]]), position = position, color = "black", alpha = 0.8) +
        scale_fill_manual(values = colors)
      if (values) {
        text_aes <- switch(position,
                           fill = aes(label = after_stat(paste0(round(100 * .data[["prop"]], 1), "%")), group = .data[[group]]),
                           stack = aes(label = after_stat(.data[["count"]]), group = .data[[group]]),
                           dodge = aes(label = after_stat(.data[["count"]]), group = .data[[group]])
        )
        text_pos <- switch(position,
                           fill = position_fill(vjust = 0.5),
                           stack = position_stack(vjust = 0.5),
                           dodge = position_dodge(width = 0.9)
        )
        text_vjust <- if (position == "dodge") -0.5 else 0.5
        p <- p + geom_text(text_aes, stat = "count", position = text_pos,
                           vjust = text_vjust, size = text_size / 3)
      }
    }
    if (is.null(ylab)) ylab <- if (position == "fill") "Percentage" else "Count"
  } else {
    # Value-based plots
    p <- ggplot(data, aes(x = .data[[x]], y = .data[[y]]))

    if (!is.null(group)) {
      p <- p +
        geom_col(aes(fill = .data[[group]]), position = position, color = "black", alpha = 0.8) +
        scale_fill_manual(values = colors)
      if (values) {
        if (position == "fill") {
          p <- p + geom_text(aes(label = paste0(round(100 * .data[[y]]/sum(.data[[y]]), 1), "%"),
                                 group = .data[[group]]),
                             position = position_fill(vjust = 0.5), size = text_size / 3)
        } else if (position == "stack") {
          p <- p + geom_text(aes(label = round(.data[[y]], 1), group = .data[[group]]),
                             position = position_stack(vjust = 0.5), size = text_size / 3)
        } else {
          p <- p + geom_text(aes(label = round(.data[[y]], 1), group = .data[[group]]),
                             position = position_dodge(width = 0.9), vjust = -0.5, size = text_size / 3)
        }
      }
    } else {
      # Single bar or faceted
      fill_aes <- if (!is.null(facet)) aes(fill = .data[[x]]) else NULL
      p <- p + geom_col(fill_aes, fill = if (is.null(facet)) colors[1] else NULL,
                        color = "black", alpha = 0.8)
      if (!is.null(facet)) p <- p + scale_fill_manual(values = colors)
      if (values) {
        p <- p + geom_text(aes(label = round(.data[[y]], 1)), vjust = -0.5, size = text_size / 3)
      }
    }
    if (is.null(ylab)) ylab <- y
  }

  # Y-axis scale
  if (position == "fill") {
    p <- p + scale_y_continuous(labels = function(x) paste0(x * 100, "%"),
                                expand = expansion(mult = c(0, 0.1)))
  } else {
    p <- p + scale_y_continuous(expand = expansion(mult = c(0, 0.1)))
  }

  # Add faceting
  if (!is.null(facet)) {
    p <- p + facet_wrap(stats::as.formula(paste("~", facet)))
  }

  # Apply theme and labels
  p <- p +
    labs(title = title,
         x = if (!is.null(xlab)) xlab else x,
         y = ylab,
         fill = if (!is.null(legend_title)) legend_title else group) +
    theme_minimal(base_size = text_size) +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"),
          panel.grid.minor = element_blank(),
          axis.ticks = element_line(color = "black"),
          legend.position = if (single_color) "none" else "right",
          strip.text = element_text(face = "bold"))

  # Flip coordinates if requested
  if (flip) p <- p + coord_flip()

  return(p)
}
