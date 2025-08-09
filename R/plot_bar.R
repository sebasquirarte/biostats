#' Create Simple, Professional Bar Plots
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
#'
#' @return A ggplot2 object that can be further customized
#'
#' @examples
#' # Simulated clinical data
#' clinical_df <- clinical_data(visit = 4)
#'
#' # Grouped barplot of categorical variable by treatment
#' plot_bar(clinical_df, x = "response", group = "visit", facet = "treatment")
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
                     text_size = 12) {

  # Input validation
  if (!is.data.frame(data)) stop("data must be a data frame", call. = FALSE)

  vars_to_check <- c(x, y, group, facet)
  vars_to_check <- vars_to_check[!is.na(vars_to_check)]
  missing_vars <- vars_to_check[!vars_to_check %in% names(data)]
  if (length(missing_vars) > 0) {
    stop(paste("Variables not found in data:", paste(missing_vars, collapse = ", ")), call. = FALSE)
  }

  position <- match.arg(position)
  if (!is.null(stat)) {
    stat <- match.arg(stat, c("mean", "median"))
    if (is.null(y)) stop("y variable must be specified when using stat parameter", call. = FALSE)
  }

  # Convert variables to factors as needed
  # x and facet: convert if numeric with ≤10 unique values
  for (var in c(x, facet)) {
    if (!is.null(var) && is.numeric(data[[var]]) && length(unique(data[[var]])) <= 10) {
      data[[var]] <- factor(data[[var]])
    }
  }

  # group: always convert to factor for proper fill mapping
  if (!is.null(group) && !is.factor(data[[group]])) {
    data[[group]] <- factor(data[[group]])
  }

  # Apply statistical aggregation if requested
  if (!is.null(stat) && !is.null(y)) {
    group_vars <- c(x, group, facet)
    group_vars <- group_vars[!is.null(group_vars)]
    agg_formula <- stats::as.formula(paste(y, "~", paste(group_vars, collapse = " + ")))
    agg_fun <- if (stat == "mean") mean else median
    data <- stats::aggregate(agg_formula, data = data, FUN = function(x) agg_fun(x, na.rm = TRUE))

    if (is.null(ylab)) {
      ylab <- paste(stat, "of", y)
    }
  }

  # Set default TealGrn colors using R's built-in palette
  if (is.null(colors)) {
    n_colors <- if (is.null(group)) 1 else length(unique(data[[group]]))
    colors <- grDevices::hcl.colors(n_colors, palette = "TealGrn")
  }

  # Create base plot
  if (is.null(y)) {
    # Count-based plots
    p <- ggplot(data, aes(x = .data[[x]]))
    if (is.null(group)) {
      p <- p + geom_bar(fill = colors[1], color = "black", alpha = 0.8)
    } else {
      p <- p +
        geom_bar(aes(fill = .data[[group]]), position = position, color = "black", alpha = 0.8) +
        scale_fill_manual(values = colors)
    }
    if (is.null(ylab)) ylab <- if (position == "fill") "Percentage" else "Count"
  } else {
    # Value-based plots
    base_aes <- aes(x = .data[[x]], y = .data[[y]])
    if (!is.null(group)) {
      p <- ggplot(data, base_aes) +
        geom_col(aes(fill = .data[[group]]), position = position, color = "black", alpha = 0.8) +
        scale_fill_manual(values = colors)
    } else if (!is.null(facet)) {
      p <- ggplot(data, base_aes) +
        geom_col(aes(fill = .data[[x]]), color = "black", alpha = 0.8) +
        scale_fill_manual(values = colors)
    } else {
      p <- ggplot(data, base_aes) +
        geom_col(fill = colors[1], color = "black", alpha = 0.8)
    }
    if (is.null(ylab)) ylab <- y
  }

  # Handle percentage scale for fill position
  if (position == "fill") {
    p <- p + scale_y_continuous(labels = function(x) paste0(x * 100, "%"))
  }

  # Add faceting
  if (!is.null(facet)) {
    p <- p + facet_wrap(stats::as.formula(paste("~", facet)))
  }

  # Add labels and theme
  p <- p +
    labs(
      title = title,
      x = if (!is.null(xlab)) xlab else x,
      y = ylab,
      fill = if (!is.null(legend_title)) legend_title else group
    ) +
    theme_minimal(base_size = text_size) +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold"),
      panel.grid.minor = element_blank(),
      axis.ticks = element_line(color = "black"),
      legend.position = if (is.null(group)) "none" else "right",
      strip.text = element_text(face = "bold")
    )

  # Flip coordinates if requested
  if (flip) p <- p + coord_flip()

  return(p)
}
