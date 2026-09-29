# Thesis figure style. Presentation only; does not change tests or estimates.
# Client example (29 Sep 2026): no in-figure title, clear axis labels,
# legend on the right titled Condition, Q30 colours, theme_bw, major grid only.

source(file.path(PROJECT_ROOT, "R", "utils_format.R"))

thesis_theme <- function() {
  ggplot2::theme_bw(base_size = 12) +
    ggplot2::theme(
      plot.title = ggplot2::element_blank(),
      plot.subtitle = ggplot2::element_blank(),
      plot.caption = ggplot2::element_blank(),
      legend.position = "right",
      legend.title = ggplot2::element_text(),
      legend.background = ggplot2::element_blank(),
      legend.key = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      axis.title.x = ggplot2::element_text(margin = ggplot2::margin(t = 8)),
      axis.title.y = ggplot2::element_text(margin = ggplot2::margin(r = 8))
    )
}

condition_colour_values <- function(pal) {
  c(Original = pal$Original, Optimized = pal$Optimized)
}

# Condition x K means with 95% CI. Matches the Study 1 example figure.
plot_condition_by_k <- function(df, y_lab, pal, k_levels) {
  pd <- ggplot2::position_dodge(width = 0.35)
  df$K <- factor(df$K, levels = as.integer(k_levels))
  df$condition <- factor(df$condition, levels = require_param("condition_level_order"))
  ggplot2::ggplot(df, ggplot2::aes(x = K, y = mean, colour = condition, group = condition)) +
    ggplot2::geom_line(position = pd, linewidth = 0.6) +
    ggplot2::geom_point(position = pd, size = 2.8) +
    ggplot2::geom_errorbar(
      ggplot2::aes(ymin = ci_low, ymax = ci_high),
      width = 0.12,
      position = pd
    ) +
    ggplot2::scale_colour_manual(values = condition_colour_values(pal)) +
    ggplot2::labs(
      x = "Number of classes (K)",
      y = y_lab,
      colour = "Condition"
    ) +
    thesis_theme()
}

plot_pairwise_prop <- function(h3, pal) {
  h3_df <- data.frame(
    x = "Optimized",
    mean = h3$mean,
    ci_low = h3$ci_low,
    ci_high = h3$ci_high,
    stringsAsFactors = FALSE
  )
  ggplot2::ggplot(h3_df, ggplot2::aes(x = x, y = mean)) +
    ggplot2::geom_hline(
      yintercept = as.numeric(SAP$h3_null),
      colour = pal$reference,
      linetype = "dashed"
    ) +
    ggplot2::geom_point(size = 3, colour = pal$Optimized) +
    ggplot2::geom_errorbar(
      ggplot2::aes(ymin = ci_low, ymax = ci_high),
      width = 0.1,
      colour = pal$Optimized
    ) +
    ggplot2::coord_cartesian(ylim = c(0, 1)) +
    ggplot2::labs(
      x = NULL,
      y = "Mean Optimized-choice proportion"
    ) +
    thesis_theme() +
    ggplot2::theme(legend.position = "none")
}

plot_rt_by_condition <- function(rt_ms, pal) {
  rt_df <- data.frame(
    condition = factor(
      c("Original", "Optimized"),
      levels = require_param("condition_level_order")
    ),
    mean = c(rt_ms$orig$mean, rt_ms$opt$mean),
    ci_low = c(rt_ms$orig$ci_low, rt_ms$opt$ci_low),
    ci_high = c(rt_ms$orig$ci_high, rt_ms$opt$ci_high),
    stringsAsFactors = FALSE
  )
  ggplot2::ggplot(rt_df, ggplot2::aes(x = condition, y = mean, colour = condition)) +
    ggplot2::geom_point(size = 2.8) +
    ggplot2::geom_errorbar(ggplot2::aes(ymin = ci_low, ymax = ci_high), width = 0.12) +
    ggplot2::scale_colour_manual(values = condition_colour_values(pal)) +
    ggplot2::labs(
      x = "Condition",
      y = "Mean response time (ms)",
      colour = "Condition"
    ) +
    thesis_theme()
}
