# Study 3 thesis figures. Presentation only; tests/tables unchanged.
# Wide-matrix column order matches Study 2: as.vector(t(outer(condition, level, paste, sep="_")))
# => for each level (K or Background), columns cycle Original then Optimized.

source(file.path(PROJECT_ROOT, "R", "utils_figures.R"))
source(file.path(PROJECT_ROOT, "R", "utils_figures_study2.R"))
source(file.path(PROJECT_ROOT, "R", "summarise_participants.R"))
source(file.path(PROJECT_ROOT, "R", "study3_summarise.R"))
source(file.path(PROJECT_ROOT, "R", "utils_logging.R"))

STUDY3_CONDITION_SHAPES <- c(Original = 16L, Optimized = 17L)

STUDY3_ACCURACY_FIGURE_CAPTION <- paste(
  "Panel A: participant-level mean accuracy in each Condition x Background cell",
  "(averaged across K and Difficulty); points are arithmetic means of the summary table",
  "cells, with Cousineau-Morey 95% CIs; points/shapes only.",
  "Panel B: Optimized minus Original accuracy differences for White, Black, and Overall."
)

STUDY3_ACCURACY_BY_K_CAPTION <- paste(
  "Descriptive only: mean participant-level accuracy by K within White (Panel A)",
  "and Black (Panel B) backgrounds. Cousineau-Morey 95% CIs.",
  "Means at each K average across Difficulty; unweighted mean across K matches",
  "the corresponding Condition x Background cell in the main accuracy figure."
)

STUDY3_PAIRWISE_FIGURE_CAPTION <- paste(
  "Panel A: overall Optimized-choice proportion (18 trials) vs 0.50 (H6).",
  "Panel B: participant-level White minus Black Optimized-choice proportion (H7)",
  "with zero reference line, mean, and 95% CI."
)

STUDY3_PAIRWISE_BY_BG_CAPTION <- paste(
  "Descriptive only: participant-level Optimized-choice proportions within",
  "White (Panel A) and Black (Panel B) backgrounds (9 trials each).",
  "0.50 reference line; vertical jitter only."
)

STUDY3_RT_FIGURE_CAPTION <- paste(
  "Descriptive mean response time (ms) by Condition and Background;",
  "plotted points are arithmetic means of participant summary cells;",
  "Cousineau-Morey 95% CIs (no lines across Background).",
  "Inferential RT analysis uses log-transformed participant means when trial-level",
  "skewness exceeds 1."
)

STUDY3_AE_FIGURE_CAPTION <- paste(
  "Descriptive mean absolute error by Condition and Background;",
  "plotted points are arithmetic means of participant summary cells;",
  "Cousineau-Morey 95% CIs (no lines across Background)."
)

study3_theme <- function() {
  study2_theme()
}

study3_wide_cols <- function(ord, levels) {
  as.vector(t(outer(ord, levels, paste, sep = "_")))
}

build_wide_from_cells <- function(cells, ord, levels, level_col, value_col) {
  if (!"participant_id" %in% names(cells)) {
    stop("build_wide_from_cells requires participant_id (same key as summaries).", call. = FALSE)
  }
  cells$key <- paste(
    as.character(cells$condition),
    if (level_col == "K") as.integer(cells[[level_col]]) else as.character(cells[[level_col]]),
    sep = "_"
  )
  cols <- study3_wide_cols(ord, levels)
  val_name <- value_col
  wide <- stats::reshape(
    cells[, c("participant_id", "participant_anon_id", "key", val_name)],
    idvar = "participant_id",
    timevar = "key",
    direction = "wide"
  )
  names(wide) <- sub(paste0("^", val_name, "\\."), "", names(wide))
  miss <- setdiff(cols, names(wide))
  if (length(miss) > 0L) {
    stop(
      "Missing wide columns: ", paste(miss, collapse = ", "),
      ". Check condition/level labels in the export.",
      call. = FALSE
    )
  }
  mat <- as.matrix(wide[, cols, drop = FALSE])
  rownames(mat) <- wide$participant_id
  list(mat = mat, cols = cols, ord = ord, levels = levels, participant_id = wide$participant_id)
}

# Same participant-level values as H4/H5 inference (summary table columns).
summary_to_wide_mat <- function(summary_df, ord, levels, value_prefix) {
  cols <- study3_wide_cols(ord, levels)
  n <- nrow(summary_df)
  mat <- matrix(NA_real_, nrow = n, ncol = length(cols))
  colnames(mat) <- cols
  rownames(mat) <- summary_df$participant_anon_id
  for (bg in levels) {
    for (cond in ord) {
      wide_nm <- paste(cond, bg, sep = "_")
      sum_nm <- paste(value_prefix, cond, bg, sep = "_")
      if (!sum_nm %in% names(summary_df)) {
        stop("Summary table missing column: ", sum_nm, call. = FALSE)
      }
      mat[, wide_nm] <- summary_df[[sum_nm]]
    }
  }
  mat
}

study3_cell_colname <- function(cond, level) {
  paste(cond, level, sep = "_")
}

# Wide columns: t(outer(condition, level)). Rows built level-major, condition-minor
# (matches summary column order and ggplot dodge at each x level).
study3_panel_from_wide_mat <- function(mat, ord, levels, level_name) {
  cols <- study3_wide_cols(ord, levels)
  if (!identical(colnames(mat), cols)) {
    stop(
      "Wide matrix columns must be ", paste(cols, collapse = ", "),
      call. = FALSE
    )
  }
  cm <- cousinau_morey_cell_stats(mat, SAP$ci_level)
  raw <- colMeans(mat, na.rm = TRUE)
  rows <- vector("list", length(levels) * length(ord))
  idx <- 1L
  for (lev in levels) {
    for (cond in ord) {
      cn <- study3_cell_colname(cond, lev)
      j <- match(cn, cols)
      half <- (cm$ci_high[j] - cm$ci_low[j]) / 2
      m <- raw[j]
      row <- data.frame(
        mean = m,
        ci_low = m - half,
        ci_high = m + half,
        condition = factor(cond, levels = ord),
        stringsAsFactors = FALSE
      )
      row[[level_name]] <- factor(lev, levels = levels)
      rows[[idx]] <- row
      idx <- idx + 1L
    }
  }
  do.call(rbind, rows)
}

cousinau_panel_aligned <- function(mat, ord, levels, level_name) {
  study3_panel_from_wide_mat(mat, ord, levels, level_name)
}

verify_study3_panel_vs_summary <- function(
    mat, summary_df, ord, levels, level_name, value_prefix, tol, log_path, label) {
  panel <- study3_panel_from_wide_mat(mat, ord, levels, level_name)
  for (lev in levels) {
    for (cond in ord) {
      cn <- study3_cell_colname(cond, lev)
      sum_nm <- paste(value_prefix, cond, lev, sep = "_")
      if (!sum_nm %in% names(summary_df)) {
        stop("Study 3 figure QA: missing ", sum_nm, call. = FALSE)
      }
      exp <- mean(summary_df[[sum_nm]], na.rm = TRUE)
      got <- mean(mat[, cn], na.rm = TRUE)
      d <- abs(exp - got)
      if (d > tol) {
        stop(
          "Study 3 figure QA (", label, "): wide cell ", cn,
          " does not match summary ", sum_nm, " (diff=", d, ").",
          call. = FALSE
        )
      }
      hit <- panel$condition == cond & panel[[level_name]] == lev
      if (sum(hit) != 1L) {
        stop("Study 3 figure QA: panel row not unique for ", cn, call. = FALSE)
      }
      d2 <- abs(panel$mean[hit] - exp)
      if (d2 > tol) {
        stop(
          "Study 3 figure QA (", label, "): panel mean for ", cn,
          " differs from summary (diff=", d2, "). Check label mapping.",
          call. = FALSE
        )
      }
    }
  }
  log_msg(log_path, "Study3 figure QA ", label, " panel means match summary columns.")
  invisible(TRUE)
}

verify_study3_k_panels_vs_disc <- function(disc, ord, k_levels, bg_order, tol, log_path) {
  cells_k <- stats::aggregate(
    accuracy ~ participant_id + condition + background + K,
    data = disc,
    FUN = function(x) mean(as.numeric(x), na.rm = TRUE)
  )
  for (bg in bg_order) {
    prep <- metric_mat_condition_k_by_background(disc, "accuracy", bg)
    panel <- study3_panel_from_wide_mat(prep$mat, ord, k_levels, "K")
    for (k in k_levels) {
      for (cond in ord) {
        cn <- study3_cell_colname(cond, k)
        exp <- mean(prep$mat[, cn], na.rm = TRUE)
        sub <- cells_k[cells_k$background == bg & cells_k$condition == cond & cells_k$K == k, , drop = FALSE]
        if (nrow(sub) == 0L) {
          stop("Study 3 figure QA: no K-level cells for ", cn, " ", bg, call. = FALSE)
        }
        by_pid <- stats::aggregate(accuracy ~ participant_id, data = sub, FUN = mean)
        d <- abs(mean(by_pid$accuracy) - exp)
        if (d > tol) {
          stop(
            "Study 3 figure QA (accuracy by K): ", bg, " ", cn,
            " wide matrix differs from discrimination (diff=", d, ").",
            call. = FALSE
          )
        }
        # K is a factor in the panel; do not use as.integer() (that is level index, not K).
        hit <- as.character(panel$condition) == cond &
          as.character(panel$K) == as.character(k)
        if (sum(hit) != 1L) {
          stop(
            "Study 3 figure QA: K panel row not unique for ", cn, " ", bg,
            " (matched ", sum(hit), " rows).",
            call. = FALSE
          )
        }
        d2 <- abs(panel$mean[hit] - exp)
        if (d2 > tol) {
          stop(
            "Study 3 figure QA (accuracy by K): panel mean for ", bg, " ", cn,
            " differs from data (diff=", d2, ").",
            call. = FALSE
          )
        }
      }
    }
  }
  log_msg(log_path, "Study3 figure QA accuracy-by-K panel means match participant cells.")
  invisible(TRUE)
}

metric_mat_condition_background <- function(disc, value_col) {
  form <- stats::as.formula(
    paste(value_col, "~ participant_anon_id + participant_id + condition + background")
  )
  cells <- stats::aggregate(form, data = disc, FUN = function(x) mean(as.numeric(x), na.rm = TRUE))
  ord <- require_param("condition_level_order")
  bg_order <- require_param("background_level_order")
  build_wide_from_cells(cells, ord, bg_order, "background", value_col)
}

metric_mat_condition_k_by_background <- function(disc, value_col, background_level) {
  sub <- disc[as.character(disc$background) == background_level, , drop = FALSE]
  if (nrow(sub) == 0L) {
    stop("No discrimination rows for background ", background_level, call. = FALSE)
  }
  form <- stats::as.formula(
    paste(value_col, "~ participant_anon_id + participant_id + condition + K")
  )
  cells <- stats::aggregate(form, data = sub, FUN = function(x) mean(as.numeric(x), na.rm = TRUE))
  ord <- require_param("condition_level_order")
  k_levels <- as.integer(SAP$k_levels_study3)
  prep <- build_wide_from_cells(cells, ord, k_levels, "K", value_col)
  c(prep, k_levels = list(k_levels), background = background_level)
}

verify_study3_figure_cell_mapping <- function(disc, summary_df, log_path) {
  tol <- 1e-6
  ord <- require_param("condition_level_order")
  bg_order <- require_param("background_level_order")
  k_levels <- as.integer(SAP$k_levels_study3)

  mat_sum <- summary_to_wide_mat(summary_df, ord, bg_order, "acc")
  for (cn in colnames(mat_sum)) {
    sum_nm <- paste0("acc_", cn)
    d <- abs(mean(mat_sum[, cn], na.rm = TRUE) - mean(summary_df[[sum_nm]], na.rm = TRUE))
    if (d > tol) {
      stop("Study 3 figure QA: summary wide matrix mismatch on ", sum_nm, call. = FALSE)
    }
  }

  cells <- study3_accuracy_cells_long(disc)
  id_map <- stats::aggregate(
    participant_id ~ participant_anon_id,
    data = cells[, c("participant_anon_id", "participant_id")],
    FUN = function(x) x[[1L]]
  )
  max_cell_diff <- 0
  for (i in seq_len(nrow(summary_df))) {
    pid <- id_map$participant_id[match(summary_df$participant_anon_id[i], id_map$participant_anon_id)]
    if (is.na(pid)) {
      stop("Study 3 figure QA: participant_id not found for anon id.", call. = FALSE)
    }
    for (cond in ord) {
      for (bg in bg_order) {
        sum_nm <- paste0("acc_", cond, "_", bg)
        hit <- cells$participant_id == pid &
          cells$condition == cond & cells$background == bg
        if (!any(hit)) {
          stop("Study 3 figure QA: missing discrimination cell for participant.", call. = FALSE)
        }
        from_cell <- cells$accuracy[hit][1L]
        d <- abs(from_cell - summary_df[[sum_nm]][i])
        max_cell_diff <- max(max_cell_diff, d, na.rm = TRUE)
      }
    }
  }
  log_msg(log_path, "Study3 figure QA max|disc cell - summary| per participant=",
          sprintf("%.8f", max_cell_diff))
  if (max_cell_diff > tol) {
    stop(
      "Study 3 figure QA: discrimination cells disagree with participant summaries (max_diff=",
      max_cell_diff, ").",
      call. = FALSE
    )
  }

  prep_disc <- metric_mat_condition_background(disc, "accuracy")
  for (cn in colnames(mat_sum)) {
    d <- abs(mean(prep_disc$mat[, cn], na.rm = TRUE) - mean(mat_sum[, cn], na.rm = TRUE))
    if (d > tol) {
      stop(
        "Study 3 figure QA: wide matrix from disc (participant_id) differs from summary on ",
        cn, " (diff=", d, ").",
        call. = FALSE
      )
    }
  }

  for (bg in bg_order) {
    prep_k <- metric_mat_condition_k_by_background(disc, "accuracy", bg)
    for (i in seq_len(nrow(summary_df))) {
      pid <- id_map$participant_id[match(summary_df$participant_anon_id[i], id_map$participant_anon_id)]
      row_idx <- which(rownames(prep_k$mat) == pid)
      if (length(row_idx) != 1L) {
        stop("Study 3 figure QA: K wide matrix row not found for participant_id.", call. = FALSE)
      }
      for (cond in ord) {
        cols_k <- paste(cond, k_levels, sep = "_")
        row_mean_k <- mean(prep_k$mat[row_idx, cols_k, drop = FALSE], na.rm = TRUE)
        sum_nm <- paste0("acc_", cond, "_", bg)
        d <- abs(row_mean_k - summary_df[[sum_nm]][i])
        if (d > tol) {
          stop(
            "Study 3 figure QA: mean across K (", cond, ", ", bg,
            ") differs from Condition x Background summary for a participant (diff=", d, ").",
            call. = FALSE
          )
        }
      }
    }
  }

  verify_study3_panel_vs_summary(
    mat_sum, summary_df, ord, bg_order, "background", "acc", tol, log_path, "accuracy"
  )
  mat_rt <- summary_to_wide_mat(summary_df, ord, bg_order, "mean_rt_ms")
  verify_study3_panel_vs_summary(
    mat_rt, summary_df, ord, bg_order, "background", "mean_rt_ms", tol, log_path, "RT"
  )
  mat_ae <- summary_to_wide_mat(summary_df, ord, bg_order, "mean_ae")
  verify_study3_panel_vs_summary(
    mat_ae, summary_df, ord, bg_order, "background", "mean_ae", tol, log_path, "AE"
  )
  verify_study3_k_panels_vs_disc(disc, ord, k_levels, bg_order, tol, log_path)

  log_msg(log_path, "Study3 figure QA passed (panel labels match summary columns; K verified).")
  invisible(TRUE)
}

plot_study3_nominal_condition_background <- function(panel_df, y_lab, pal, ylim = NULL) {
  pd <- ggplot2::position_dodge(width = 0.4)
  p <- ggplot2::ggplot(panel_df, ggplot2::aes(
    x = background, y = mean, colour = condition, shape = condition
  )) +
    ggplot2::geom_point(position = pd, size = 2.8) +
    ggplot2::geom_errorbar(
      ggplot2::aes(ymin = ci_low, ymax = ci_high),
      width = 0.12,
      position = pd,
      linewidth = 0.5
    ) +
    ggplot2::scale_colour_manual(values = condition_colour_values(pal)) +
    ggplot2::scale_shape_manual(values = STUDY3_CONDITION_SHAPES) +
    ggplot2::labs(x = "Background", y = y_lab, colour = "Condition", shape = "Condition") +
    study3_theme() +
    study2_legend_top()
  if (!is.null(ylim)) {
    p <- p + ggplot2::coord_cartesian(ylim = ylim)
  }
  p
}

plot_study3_condition_by_k_aligned <- function(panel_df, y_lab, pal, ylim = NULL, ref_hline = NULL) {
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
    ggplot2::scale_shape_manual(values = STUDY3_CONDITION_SHAPES) +
    ggplot2::labs(x = "Number of classes (K)", y = y_lab, colour = "Condition", shape = "Condition") +
    study3_theme() +
    study2_legend_top()
  if (!is.null(ref_hline)) {
    p <- p + ggplot2::geom_hline(yintercept = ref_hline, colour = "grey75", linewidth = 0.35)
  }
  if (!is.null(ylim)) {
    p <- p + ggplot2::coord_cartesian(ylim = ylim)
  }
  p
}

diff_ci_one_sample <- function(x, ci_level = 0.95) {
  x <- as.numeric(x)
  x <- x[is.finite(x)]
  n <- length(x)
  m <- mean(x)
  if (n < 2L) {
    return(list(n = n, mean = m, ci_low = NA_real_, ci_high = NA_real_))
  }
  se <- stats::sd(x) / sqrt(n)
  tcrit <- stats::qt(1 - (1 - ci_level) / 2, df = n - 1L)
  list(n = n, mean = m, ci_low = m - tcrit * se, ci_high = m + tcrit * se)
}

plot_study3_accuracy_h4h5_panels <- function(disc, summary_df, pal) {
  ord <- require_param("condition_level_order")
  bg_order <- require_param("background_level_order")
  mat <- summary_to_wide_mat(summary_df, ord, bg_order, "acc")
  panel_a_df <- study3_panel_from_wide_mat(mat, ord, bg_order, "background")
  p_a <- plot_study3_nominal_condition_background(
    panel_a_df, "Mean participant-level accuracy", pal, ylim = c(0, 1)
  ) + ggplot2::labs(tag = "A")

  diff_white <- summary_df$acc_Optimized_White - summary_df$acc_Original_White
  diff_black <- summary_df$acc_Optimized_Black - summary_df$acc_Original_Black
  diff_overall <- summary_df$acc_diff_h4
  st_w <- diff_ci_one_sample(diff_white, SAP$ci_level)
  st_b <- diff_ci_one_sample(diff_black, SAP$ci_level)
  st_o <- diff_ci_one_sample(diff_overall, SAP$ci_level)
  panel_b <- data.frame(
    label = factor(c("White", "Black", "Overall"), levels = c("White", "Black", "Overall")),
    mean = c(st_w$mean, st_b$mean, st_o$mean),
    ci_low = c(st_w$ci_low, st_b$ci_low, st_o$ci_low),
    ci_high = c(st_w$ci_high, st_b$ci_high, st_o$ci_high),
    is_overall = c(FALSE, FALSE, TRUE),
    stringsAsFactors = FALSE
  )
  p_b <- ggplot2::ggplot(panel_b, ggplot2::aes(x = label, y = mean)) +
    ggplot2::geom_hline(yintercept = 0, colour = "grey40", linewidth = 0.4) +
    ggplot2::geom_errorbar(ggplot2::aes(ymin = ci_low, ymax = ci_high), width = 0.12, colour = pal$Optimized) +
    ggplot2::geom_point(ggplot2::aes(shape = is_overall), size = 2.8, colour = pal$Optimized) +
    ggplot2::scale_shape_manual(values = c(`FALSE` = 16L, `TRUE` = 18L), guide = "none") +
    ggplot2::labs(x = NULL, y = "Optimized - Original (accuracy)", tag = "B") +
    study3_theme() +
    ggplot2::theme(legend.position = "none")

  gridExtra::grid.arrange(p_a, p_b, ncol = 2, widths = c(1.15, 1))
}

plot_study3_accuracy_by_k_descriptive <- function(disc, pal) {
  bg_order <- require_param("background_level_order")
  panels <- lapply(bg_order, function(bg) {
    prep <- metric_mat_condition_k_by_background(disc, "accuracy", bg)
    study3_panel_from_wide_mat(prep$mat, prep$ord, prep$levels, "K")
  })
  p_white <- plot_study3_condition_by_k_aligned(
    panels[[1L]], "Mean participant-level accuracy", pal, ylim = c(0, 1), ref_hline = 1
  ) + ggplot2::labs(tag = "A") +
    ggplot2::annotate("text", x = 2, y = 1.02, label = "White background", size = 3.5, hjust = 0.5)
  p_black <- plot_study3_condition_by_k_aligned(
    panels[[2L]], "Mean participant-level accuracy", pal, ylim = c(0, 1), ref_hline = 1
  ) + ggplot2::labs(tag = "B") +
    ggplot2::annotate("text", x = 2, y = 1.02, label = "Black background", size = 3.5, hjust = 0.5)
  gridExtra::grid.arrange(p_white, p_black, ncol = 2)
}

study3_h6_mean_ci <- function(summary_df) {
  st <- mean_sd_ci(summary_df$pairwise_prop_optimized)
  list(mean = st$mean, ci_low = st$ci_low, ci_high = st$ci_high)
}

study3_pairwise_y_jitter <- function(ids) {
  set.seed(SEED)
  base <- as.numeric(factor(ids, levels = unique(ids)))
  stats::runif(length(base), -0.14, 0.14) + base
}

plot_study3_pairwise_horizontal <- function(prop, mean_ci, pal, tag_label, panel_title = NULL) {
  yj <- study3_pairwise_y_jitter(seq_along(prop))
  pts <- data.frame(prop = prop, y = yj, stringsAsFactors = FALSE)
  mean_df <- data.frame(
    prop = mean_ci$mean,
    ci_low = mean_ci$ci_low,
    ci_high = mean_ci$ci_high,
    y = mean(yj),
    stringsAsFactors = FALSE
  )
  y_top <- max(yj) + 0.35
  ggplot2::ggplot(pts, ggplot2::aes(x = prop, y = y)) +
    ggplot2::geom_vline(xintercept = as.numeric(SAP$h3_null), linetype = "dashed", colour = pal$reference) +
    ggplot2::geom_point(size = 1.9, alpha = 0.75, colour = pal$Optimized) +
    ggplot2::geom_point(data = mean_df, ggplot2::aes(x = prop, y = y), inherit.aes = FALSE, size = 3.5, colour = pal$Optimized) +
    ggplot2::geom_errorbar(
      data = mean_df,
      ggplot2::aes(x = prop, xmin = ci_low, xmax = ci_high, y = y),
      inherit.aes = FALSE,
      width = 0.06,
      linewidth = 0.5,
      colour = pal$Optimized
    ) +
    ggplot2::annotate("text", x = 0.08, y = y_top, label = "Original", size = 3.5) +
    ggplot2::annotate("text", x = 0.92, y = y_top, label = "Optimized", size = 3.5) +
    ggplot2::scale_x_continuous(breaks = seq(0, 1, by = 0.25), labels = function(x) sprintf("%.2f", x)) +
    ggplot2::coord_cartesian(xlim = c(-0.02, 1.02)) +
    ggplot2::labs(
      x = "Proportion of Optimized choices",
      y = NULL,
      tag = tag_label,
      title = panel_title
    ) +
    study3_theme() +
    ggplot2::theme(axis.text.y = ggplot2::element_blank(), axis.ticks.y = ggplot2::element_blank())
}

plot_study3_pairwise_diff_panel <- function(summary_df, pal) {
  d <- summary_df$pairwise_prop_optimized_White - summary_df$pairwise_prop_optimized_Black
  yj <- study3_pairwise_y_jitter(summary_df$participant_anon_id)
  pts <- data.frame(diff = d, y = yj, stringsAsFactors = FALSE)
  st <- diff_ci_one_sample(d, SAP$ci_level)
  mean_df <- data.frame(
    diff = st$mean,
    ci_low = st$ci_low,
    ci_high = st$ci_high,
    y = mean(yj),
    stringsAsFactors = FALSE
  )
  ggplot2::ggplot(pts, ggplot2::aes(x = diff, y = y)) +
    ggplot2::geom_vline(xintercept = 0, colour = "grey40", linewidth = 0.4) +
    ggplot2::geom_point(size = 1.9, alpha = 0.75, colour = pal$Optimized) +
    ggplot2::geom_point(data = mean_df, ggplot2::aes(x = diff, y = y), inherit.aes = FALSE, size = 3.5, colour = pal$Optimized) +
    ggplot2::geom_errorbar(
      data = mean_df,
      ggplot2::aes(x = diff, xmin = ci_low, xmax = ci_high, y = y),
      inherit.aes = FALSE,
      width = 0.06,
      linewidth = 0.5,
      colour = pal$Optimized
    ) +
    ggplot2::scale_x_continuous(labels = function(x) sprintf("%.2f", x)) +
    ggplot2::labs(
      x = "White - Black (Optimized proportion)",
      y = NULL,
      tag = "B",
      title = "White - Black difference"
    ) +
    study3_theme() +
    ggplot2::theme(axis.text.y = ggplot2::element_blank(), axis.ticks.y = ggplot2::element_blank())
}

plot_study3_pairwise_panels <- function(summary_df, pal) {
  h6 <- study3_h6_mean_ci(summary_df)
  p_a <- plot_study3_pairwise_horizontal(summary_df$pairwise_prop_optimized, h6, pal, "A")
  p_b <- plot_study3_pairwise_diff_panel(summary_df, pal)
  gridExtra::grid.arrange(p_a, p_b, ncol = 2, widths = c(1, 1))
}

plot_study3_pairwise_by_background_descriptive <- function(summary_df, pal) {
  h6w <- mean_sd_ci(summary_df$pairwise_prop_optimized_White)
  h6b <- mean_sd_ci(summary_df$pairwise_prop_optimized_Black)
  p_a <- plot_study3_pairwise_horizontal(
    summary_df$pairwise_prop_optimized_White,
    list(mean = h6w$mean, ci_low = h6w$ci_low, ci_high = h6w$ci_high),
    pal,
    "A",
    panel_title = "White background"
  )
  p_b <- plot_study3_pairwise_horizontal(
    summary_df$pairwise_prop_optimized_Black,
    list(mean = h6b$mean, ci_low = h6b$ci_low, ci_high = h6b$ci_high),
    pal,
    "B",
    panel_title = "Black background"
  )
  gridExtra::grid.arrange(p_a, p_b, ncol = 2)
}

plot_study3_rt_ms <- function(summary_df, pal) {
  ord <- require_param("condition_level_order")
  bg_order <- require_param("background_level_order")
  mat <- summary_to_wide_mat(summary_df, ord, bg_order, "mean_rt_ms")
  panel <- study3_panel_from_wide_mat(mat, ord, bg_order, "background")
  plot_study3_nominal_condition_background(panel, "Mean response time (ms)", pal)
}

plot_study3_ae <- function(summary_df, pal) {
  ord <- require_param("condition_level_order")
  bg_order <- require_param("background_level_order")
  mat <- summary_to_wide_mat(summary_df, ord, bg_order, "mean_ae")
  panel <- study3_panel_from_wide_mat(mat, ord, bg_order, "background")
  plot_study3_nominal_condition_background(panel, "Mean absolute error", pal, ylim = c(0, NA))
}

write_study3_figure_captions <- function(log_path) {
  ensure_output_dirs()
  path <- file.path(OUTPUT_LOGS, paste0("study3_figure_captions", OUTPUT_SUFFIX, ".txt"))
  lines <- c(
    "Study 3 report figure captions (thesis; not embedded in PNG/PDF).",
    "",
    paste0("study3_fig_accuracy_condition_background: ", STUDY3_ACCURACY_FIGURE_CAPTION),
    paste0("study3_fig_accuracy_by_k_descriptive: ", STUDY3_ACCURACY_BY_K_CAPTION),
    paste0("study3_fig_pairwise_prop: ", STUDY3_PAIRWISE_FIGURE_CAPTION),
    paste0("study3_fig_pairwise_by_background_descriptive: ", STUDY3_PAIRWISE_BY_BG_CAPTION),
    paste0("study3_fig_rt_condition_background: ", STUDY3_RT_FIGURE_CAPTION),
    paste0("study3_fig_ae_condition_background: ", STUDY3_AE_FIGURE_CAPTION),
    "",
    "Diagnostic histograms (study3_diag_*) are assumption checks only, not thesis figures."
  )
  writeLines(lines, path, useBytes = TRUE)
  log_msg(log_path, "wrote ", basename(path))
  path
}

write_study3_figures <- function(disc, pw, summary_df, log_path) {
  ensure_output_dirs()
  verify_study3_figure_cell_mapping(disc, summary_df, log_path)
  pal <- study1_palette(log_path)
  log_msg(log_path, "Study 3 thesis figures (final revision): QA passed; writing outputs.")

  save_report_figure(
    plot_study3_accuracy_h4h5_panels(disc, summary_df, pal),
    "study3_fig_accuracy_condition_background",
    10, 4.5, log_path
  )
  save_report_figure(
    plot_study3_accuracy_by_k_descriptive(disc, pal),
    "study3_fig_accuracy_by_k_descriptive",
    10, 4.5, log_path
  )
  save_report_figure(
    plot_study3_pairwise_panels(summary_df, pal),
    "study3_fig_pairwise_prop",
    10, 3.8, log_path
  )
  save_report_figure(
    plot_study3_pairwise_by_background_descriptive(summary_df, pal),
    "study3_fig_pairwise_by_background_descriptive",
    10, 3.8, log_path
  )
  save_report_figure(
    plot_study3_rt_ms(summary_df, pal),
    "study3_fig_rt_condition_background",
    6.5, 4.5, log_path
  )
  save_report_figure(
    plot_study3_ae(summary_df, pal),
    "study3_fig_ae_condition_background",
    6.5, 4.5, log_path
  )
  write_study3_figure_captions(log_path)
  invisible(TRUE)
}
