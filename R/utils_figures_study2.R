# Study 2 thesis figures (client Oct 2026). Presentation only; SAP tests unchanged.

source(file.path(PROJECT_ROOT, "R", "utils_figures.R"))
source(file.path(PROJECT_ROOT, "R", "summarise_participants.R"))

STUDY2_FIGURE_NOTE <- paste(
  "Panel B per-K differences and CIs are descriptive only;",
  "they are not inferential H2 follow-ups (interaction not significant; follow-ups not run)."
)

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

accuracy_mat_condition_k <- function(disc) {
  cells <- accuracy_cells_long(disc)
  cells$key <- paste(cells$condition, cells$K, sep = "_")
  ord <- require_param("condition_level_order")
  k_levels <- as.integer(SAP$k_levels_study2)
  cols <- as.vector(t(outer(ord, k_levels, paste, sep = "_")))
  wide <- stats::reshape(
    cells[, c("participant_anon_id", "key", "accuracy")],
    idvar = "participant_anon_id",
    timevar = "key",
    direction = "wide"
  )
  names(wide) <- sub("^accuracy\\.", "", names(wide))
  miss <- setdiff(cols, names(wide))
  if (length(miss) > 0L) {
    stop("Missing Condition x K cells for figure: ", paste(miss, collapse = ", "), call. = FALSE)
  }
  mat <- as.matrix(wide[, cols, drop = FALSE])
  rownames(mat) <- wide$participant_anon_id
  list(mat = mat, k_levels = k_levels, ord = ord)
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
  prep <- accuracy_mat_condition_k(disc)
  mat <- prep$mat
  k_levels <- prep$k_levels
  ord <- prep$ord
  cm <- cousinau_morey_cell_stats(mat, SAP$ci_level)

  panel_a <- data.frame(
    K = rep(factor(k_levels, levels = k_levels), times = length(ord)),
    condition = rep(factor(ord, levels = ord), each = length(k_levels)),
    mean = cm$mean,
    ci_low = cm$ci_low,
    ci_high = cm$ci_high,
    stringsAsFactors = FALSE
  )
  shapes <- c(Original = 16L, Optimized = 17L)
  pd <- ggplot2::position_dodge(width = 0.35)
  p_a <- ggplot2::ggplot(panel_a, ggplot2::aes(x = K, y = mean, colour = condition, shape = condition, group = condition)) +
    ggplot2::geom_hline(yintercept = 1, colour = "grey75", linewidth = 0.35) +
    ggplot2::geom_line(position = pd, linewidth = 0.6) +
    ggplot2::geom_point(position = pd, size = 2.8) +
    ggplot2::geom_errorbar(
      ggplot2::aes(ymin = ci_low, ymax = ci_high),
      width = 0.12,
      position = pd
    ) +
    ggplot2::scale_colour_manual(values = condition_colour_values(pal)) +
    ggplot2::scale_shape_manual(values = shapes) +
    ggplot2::coord_cartesian(ylim = c(0, 1)) +
    ggplot2::labs(
      x = "Number of classes (K)",
      y = "Mean participant-level accuracy",
      colour = "Condition",
      shape = "Condition",
      tag = "A"
    ) +
    thesis_theme() +
    ggplot2::theme(plot.tag = ggplot2::element_text(face = "bold"))

  per_k <- lapply(k_levels, function(k) {
    o <- mat[, paste("Original", k, sep = "_"), drop = TRUE]
    p <- mat[, paste("Optimized", k, sep = "_"), drop = TRUE]
    st <- paired_diff_descriptive(o, p, SAP$ci_level)
    data.frame(label = as.character(k), x = as.numeric(k), st, stringsAsFactors = FALSE)
  })
  orig_all <- rowMeans(mat[, paste("Original", k_levels, sep = "_"), drop = FALSE], na.rm = TRUE)
  opt_all <- rowMeans(mat[, paste("Optimized", k_levels, sep = "_"), drop = FALSE], na.rm = TRUE)
  st_all <- paired_diff_descriptive(orig_all, opt_all, SAP$ci_level)
  sep_x <- max(k_levels) + 1.5
  all_k_x <- max(k_levels) + 3
  panel_b <- do.call(rbind, c(per_k, list(data.frame(
    label = "All K", x = all_k_x, st_all, stringsAsFactors = FALSE
  ))))
  p_b <- ggplot2::ggplot(panel_b, ggplot2::aes(x = x, y = mean)) +
    ggplot2::geom_hline(yintercept = 0, colour = "grey40", linewidth = 0.4) +
    ggplot2::geom_vline(x = sep_x, linetype = "dotted", colour = "grey60") +
    ggplot2::geom_point(size = 2.8, colour = pal$Optimized) +
    ggplot2::geom_errorbar(ggplot2::aes(ymin = ci_low, ymax = ci_high), width = 0.12, colour = pal$Optimized) +
    ggplot2::scale_x_continuous(
      breaks = c(k_levels, all_k_x),
      labels = c(as.character(k_levels), "All K")
    ) +
    ggplot2::labs(x = "Number of classes (K)", y = "Optimized - Original (accuracy)", tag = "B") +
    thesis_theme() +
    ggplot2::theme(plot.tag = ggplot2::element_text(face = "bold"), legend.position = "none")

  gridExtra::grid.arrange(
    p_a, p_b, ncol = 2,
    bottom = grid::textGrob(STUDY2_FIGURE_NOTE, x = 0, hjust = 0, gp = grid::gpar(cex = 0.85))
  )
}

plot_study2_h3_stacked_dots <- function(pw, h3, pal) {
  props <- pairwise_proportion(pw)
  props$prop <- props$chose_optimized
  props$prop_snapped <- round(props$prop * 12L) / 12L
  mean_df <- data.frame(prop = h3$mean, ci_low = h3$ci_low, ci_high = h3$ci_high, y = 0.22)
  ggplot2::ggplot(props, ggplot2::aes(x = prop_snapped, y = 0)) +
    ggplot2::geom_hline(yintercept = as.numeric(SAP$h3_null), linetype = "dashed", colour = pal$reference) +
    ggplot2::geom_jitter(width = 0.012, height = 0.14, size = 1.9, alpha = 0.8, colour = pal$Optimized) +
    ggplot2::geom_point(data = mean_df, ggplot2::aes(x = prop, y = y), inherit.aes = FALSE, size = 3.5, colour = pal$Optimized) +
    ggplot2::geom_errorbar(
      data = mean_df,
      ggplot2::aes(x = prop, xmin = ci_low, xmax = ci_high, y = y),
      inherit.aes = FALSE,
      width = 0.06,
      linewidth = 0.5,
      colour = pal$Optimized
    ) +
    ggplot2::scale_x_continuous(breaks = seq(0, 1, by = 1 / 12), labels = function(x) format(x, digits = 3)) +
    ggplot2::coord_cartesian(xlim = c(-0.02, 1.02), ylim = c(-0.35, 0.35)) +
    ggplot2::labs(
      x = "Proportion of Optimized choices (12 trials)",
      y = NULL
    ) +
    thesis_theme() +
    ggplot2::theme(
      axis.text.y = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank()
    )
}
