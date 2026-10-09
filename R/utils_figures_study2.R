# Study 2 thesis figures. Presentation only; SAP tests and tables unchanged.

source(file.path(PROJECT_ROOT, "R", "utils_figures.R"))
source(file.path(PROJECT_ROOT, "R", "summarise_participants.R"))

STUDY2_CONDITION_SHAPES <- c(Original = 16L, Optimized = 17L)

STUDY2_ACCURACY_FIGURE_CAPTION <- paste(
  "Panel B shows Optimized minus Original accuracy by K with 95% CIs.",
  "Per-K and All K values are descriptive only;",
  "they are not inferential H2 follow-ups when the interaction is not significant."
)

STUDY2_AE_FIGURE_CAPTION <- paste(
  "Descriptive means and 95% CIs by K (Cousineau-Morey).",
  "No inferential tests or significance annotations."
)

study2_theme <- function() {
  thesis_theme() +
    ggplot2::theme(
      plot.tag = ggplot2::element_text(face = "bold", size = 12),
      axis.title = ggplot2::element_text(size = 11),
      axis.text = ggplot2::element_text(size = 10),
      legend.text = ggplot2::element_text(size = 10),
      legend.title = ggplot2::element_text(size = 11)
    )
}

study2_legend_top <- function() {
  ggplot2::theme(legend.position = "top", legend.justification = "left")
}

cousinau_morey_cell_stats <- function(mat, ci_level = 0.95) {
  mat <- as.matrix(mat)
  n <- nrow(mat)
  if (n < 2L) {
    stop("Need at least 2 participants for Cousineau-Morey CIs.", call. = FALSE)
  }
  grand <- mean(mat, na.rm = TRUE)
  subj_mean <- rowMeans(mat, na.rm = TRUE)
  norm <- mat - subj_mean + grand
  m <- colMeans(norm, na.rm = TRUE)
  se <- apply(norm, 2L, stats::sd, na.rm = TRUE) / sqrt(n)
  tcrit <- stats::qt(1 - (1 - ci_level) / 2, df = n - 1L)
  morey <- sqrt(n / (n - 1L))
  half <- tcrit * se * morey
  list(mean = m, ci_low = m - half, ci_high = m + half, n = n)
}

metric_mat_condition_k <- function(disc, value_col) {
  form <- stats::as.formula(
    paste(value_col, "~ participant_anon_id + participant_id + condition + K")
  )
  cells <- stats::aggregate(form, data = disc, FUN = function(x) mean(as.numeric(x), na.rm = TRUE))
  cells$key <- paste(cells$condition, cells$K, sep = "_")
  ord <- require_param("condition_level_order")
  k_levels <- as.integer(SAP$k_levels_study2)
  cols <- as.vector(t(outer(ord, k_levels, paste, sep = "_")))
  val_name <- value_col
  wide <- stats::reshape(
    cells[, c("participant_anon_id", "key", val_name)],
    idvar = "participant_anon_id",
    timevar = "key",
    direction = "wide"
  )
  names(wide) <- sub(paste0("^", val_name, "\\."), "", names(wide))
  miss <- setdiff(cols, names(wide))
  if (length(miss) > 0L) {
    stop("Missing Condition x K cells for ", value_col, ": ", paste(miss, collapse = ", "), call. = FALSE)
  }
  mat <- as.matrix(wide[, cols, drop = FALSE])
  rownames(mat) <- wide$participant_anon_id
  list(mat = mat, k_levels = k_levels, ord = ord)
}

cousinau_morey_panel <- function(mat, k_levels, ord) {
  cm <- cousinau_morey_cell_stats(mat, SAP$ci_level)
  data.frame(
    K = rep(factor(k_levels, levels = k_levels), times = length(ord)),
    condition = rep(factor(ord, levels = ord), each = length(k_levels)),
    mean = cm$mean,
    ci_low = cm$ci_low,
    ci_high = cm$ci_high,
    stringsAsFactors = FALSE
  )
}

plot_study2_condition_by_k <- function(panel_df, y_lab, pal, ylim = NULL, ref_hline = NULL) {
  pd <- ggplot2::position_dodge(width = 0.35)
  p <- ggplot2::ggplot(panel_df, ggplot2::aes(
    x = K, y = mean, colour = condition, shape = condition, group = condition
  )) +
    ggplot2::geom_line(position = pd, linewidth = 0.6) +
    ggplot2::geom_point(position = pd, size = 2.8) +
    ggplot2::geom_errorbar(
      ggplot2::aes(ymin = ci_low, ymax = ci_high),
      width = 0.12,
      position = pd
    ) +
    ggplot2::scale_colour_manual(values = condition_colour_values(pal)) +
    ggplot2::scale_shape_manual(values = STUDY2_CONDITION_SHAPES) +
    ggplot2::labs(
      x = "Number of classes (K)",
      y = y_lab,
      colour = "Condition",
      shape = "Condition"
    ) +
    study2_theme() +
    study2_legend_top()
  if (!is.null(ref_hline)) {
    p <- p + ggplot2::geom_hline(yintercept = ref_hline, colour = "grey75", linewidth = 0.35)
  }
  if (!is.null(ylim)) {
    p <- p + ggplot2::coord_cartesian(ylim = ylim)
  }
  p
}

paired_diff_descriptive <- function(orig, opt, ci_level = 0.95) {
  d <- as.numeric(opt) - as.numeric(orig)
  d <- d[is.finite(d)]
  n <- length(d)
  m <- mean(d)
  if (n < 2L) {
    return(list(n = n, mean = m, ci_low = NA_real_, ci_high = NA_real_))
  }
  se <- stats::sd(d) / sqrt(n)
  tcrit <- stats::qt(1 - (1 - ci_level) / 2, df = n - 1L)
  list(n = n, mean = m, ci_low = m - tcrit * se, ci_high = m + tcrit * se)
}

plot_study2_accuracy_panels <- function(disc, pal) {
  prep <- metric_mat_condition_k(disc, "accuracy")
  mat <- prep$mat
  k_levels <- prep$k_levels
  panel_a <- cousinau_morey_panel(mat, k_levels, prep$ord)
  p_a <- plot_study2_condition_by_k(
    panel_a, "Mean participant-level accuracy", pal, ylim = c(0, 1), ref_hline = 1
  ) + ggplot2::labs(tag = "A")

  per_k <- lapply(k_levels, function(k) {
    o <- mat[, paste("Original", k, sep = "_"), drop = TRUE]
    p <- mat[, paste("Optimized", k, sep = "_"), drop = TRUE]
    st <- paired_diff_descriptive(o, p, SAP$ci_level)
    data.frame(is_all_k = FALSE, x = as.numeric(k), st, stringsAsFactors = FALSE)
  })
  orig_all <- rowMeans(mat[, paste("Original", k_levels, sep = "_"), drop = FALSE], na.rm = TRUE)
  opt_all <- rowMeans(mat[, paste("Optimized", k_levels, sep = "_"), drop = FALSE], na.rm = TRUE)
  st_all <- paired_diff_descriptive(orig_all, opt_all, SAP$ci_level)
  sep_x <- max(k_levels) + 1.5
  all_k_x <- max(k_levels) + 3
  panel_b <- do.call(rbind, c(per_k, list(data.frame(
    is_all_k = TRUE, x = all_k_x, st_all, stringsAsFactors = FALSE
  ))))
  p_b <- ggplot2::ggplot(panel_b, ggplot2::aes(x = x, y = mean)) +
    ggplot2::geom_hline(yintercept = 0, colour = "grey40", linewidth = 0.4) +
    ggplot2::geom_vline(xintercept = sep_x, linetype = "dotted", colour = "grey60") +
    ggplot2::geom_errorbar(ggplot2::aes(ymin = ci_low, ymax = ci_high), width = 0.12, colour = pal$Optimized) +
    ggplot2::geom_point(ggplot2::aes(shape = is_all_k), size = 2.8, colour = pal$Optimized) +
    ggplot2::scale_shape_manual(values = c(`FALSE` = 16L, `TRUE` = 18L), guide = "none") +
    ggplot2::scale_x_continuous(
      breaks = c(k_levels, all_k_x),
      labels = c(as.character(k_levels), "All K")
    ) +
    ggplot2::labs(x = "Number of classes (K)", y = "Optimized - Original (accuracy)", tag = "B") +
    study2_theme() +
    ggplot2::theme(legend.position = "none")

  gridExtra::grid.arrange(p_a, p_b, ncol = 2)
}

plot_study2_ae_by_k <- function(disc, pal) {
  prep <- metric_mat_condition_k(disc, "absolute_error")
  panel <- cousinau_morey_panel(prep$mat, prep$k_levels, prep$ord)
  plot_study2_condition_by_k(panel, "Mean absolute error", pal)
}

plot_study2_rt_by_condition <- function(rt_ms, pal) {
  ord <- require_param("condition_level_order")
  rt_df <- data.frame(
    condition = factor(ord, levels = ord),
    mean = c(rt_ms$orig$mean, rt_ms$opt$mean),
    ci_low = c(rt_ms$orig$ci_low, rt_ms$opt$ci_low),
    ci_high = c(rt_ms$orig$ci_high, rt_ms$opt$ci_high),
    stringsAsFactors = FALSE
  )
  ggplot2::ggplot(rt_df, ggplot2::aes(x = condition, y = mean, colour = condition, shape = condition)) +
    ggplot2::geom_point(size = 2.8) +
    ggplot2::geom_errorbar(ggplot2::aes(ymin = ci_low, ymax = ci_high), width = 0.12, linewidth = 0.5) +
    ggplot2::scale_colour_manual(values = condition_colour_values(pal)) +
    ggplot2::scale_shape_manual(values = STUDY2_CONDITION_SHAPES) +
    ggplot2::labs(
      x = "Condition",
      y = "Mean response time (ms)",
      colour = "Condition",
      shape = "Condition"
    ) +
    study2_theme() +
    study2_legend_top()
}

h3_mean_ci_for_figure <- function(summary_df) {
  x <- summary_df$pairwise_prop_optimized
  st <- mean_sd_ci(x)
  list(mean = st$mean, ci_low = st$ci_low, ci_high = st$ci_high)
}

plot_study2_h3_stacked_dots <- function(pw, h3, pal) {
  props <- pairwise_proportion(pw)
  props$prop <- props$chose_optimized
  mean_df <- data.frame(prop = h3$mean, ci_low = h3$ci_low, ci_high = h3$ci_high, y = 0)
  ggplot2::ggplot(props, ggplot2::aes(x = prop, y = 0)) +
    ggplot2::geom_vline(xintercept = as.numeric(SAP$h3_null), linetype = "dashed", colour = pal$reference) +
    ggplot2::geom_jitter(width = 0.012, height = 0.14, size = 1.9, alpha = 0.75, colour = pal$Optimized) +
    ggplot2::geom_point(data = mean_df, ggplot2::aes(x = prop, y = y), inherit.aes = FALSE, size = 3.5, colour = pal$Optimized) +
    ggplot2::geom_errorbar(
      data = mean_df,
      ggplot2::aes(x = prop, xmin = ci_low, xmax = ci_high, y = y),
      inherit.aes = FALSE,
      width = 0.06,
      linewidth = 0.5,
      colour = pal$Optimized
    ) +
    ggplot2::annotate("text", x = 0.08, y = 0.28, label = "Original", size = 3.5) +
    ggplot2::annotate("text", x = 0.92, y = 0.28, label = "Optimized", size = 3.5) +
    ggplot2::scale_x_continuous(
      breaks = seq(0, 1, by = 0.25),
      labels = function(x) sprintf("%.2f", x)
    ) +
    ggplot2::coord_cartesian(xlim = c(-0.02, 1.02), ylim = c(-0.35, 0.35)) +
    ggplot2::labs(
      x = "Proportion of Optimized choices",
      y = NULL
    ) +
    study2_theme() +
    ggplot2::theme(
      axis.text.y = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank()
    )
}
