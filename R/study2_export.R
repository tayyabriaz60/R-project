# Study 2 Q13/Q14 tables and figures. SAP §4. Q30 colours. Q32 npar not applied.

source(file.path(PROJECT_ROOT, "R", "study1_export.R"))

study2_notes <- function(n) {
  c(
    paste0("N = ", n, " (primary population after researcher exclusion; SAP §4.4)."),
    "SAP §4.1: accuracy is the mean of 3 Difficulty instances within each Condition x K cell.",
    "No standalone Difficulty hypothesis (Brief §6.2).",
    "SAP recommended path: H1/H2 2x4 RM-ANOVA; H3 one-sample t vs 0.50; RT/AE paired t.",
    "Q32: Study 1 Wilcoxon/Friedman lock is not applied.",
    "Holm only on H2 follow-ups if the Condition x K interaction is significant.",
    "SAP §4.4: K = 30 is retained with the same palette-capacity caveat as Study 1."
  )
}

write_study2_tables <- function(primary, vision_tab, ae_k, pw_rt, log_path) {
  n <- primary$n
  notes <- study2_notes(n)
  desc <- data.frame(
    condition = c("Original", "Optimized"),
    n = n,
    mean_accuracy = c(primary$acc_orig$mean, primary$acc_opt$mean),
    sd_accuracy = c(primary$acc_orig$sd, primary$acc_opt$sd),
    ci_low = c(primary$acc_orig$ci_low, primary$acc_opt$ci_low),
    ci_high = c(primary$acc_orig$ci_high, primary$acc_opt$ci_high),
    stringsAsFactors = FALSE
  )
  write_table_csv_docx(
    desc, "study2_table_accuracy_descriptives",
    "Study 2: Mean participant-level accuracy by Condition",
    notes, log_path
  )

  anova_df <- data.frame(
    hypothesis = c("H1_Condition", "H2_Condition_x_K"),
    effect = c(primary$h1$effect, primary$h2$effect),
    F = c(primary$h1$F, primary$h2$F),
    df_num = c(primary$h1$df_num, primary$h2$df_num),
    df_den = c(primary$h1$df_den, primary$h2$df_den),
    p = c(primary$h1$p, primary$h2$p),
    partial_eta_sq = c(primary$h1$pes, primary$h2$pes),
    pes_ci_low = c(primary$h1$pes_ci_low, primary$h2$pes_ci_low),
    pes_ci_high = c(primary$h1$pes_ci_high, primary$h2$pes_ci_high),
    mauchly_p = c(primary$h1$mauchly_p, primary$h2$mauchly_p),
    sphericity_correction = c(primary$h1$sphericity_correction, primary$h2$sphericity_correction),
    sphericity_reason = c(primary$h1$sphericity_reason, primary$h2$sphericity_reason),
    stringsAsFactors = FALSE
  )
  write_table_csv_docx(
    anova_df, "study2_table_h1_h2_anova",
    "Study 2: H1/H2 repeated-measures ANOVA (Condition x K)",
    notes, log_path
  )

  if (isTRUE(primary$follow$ran) && nrow(primary$follow$rows) > 0L) {
    write_table_csv_docx(
      primary$follow$rows, "study2_table_h2_followups",
      "Study 2: H2 follow-up paired t-tests at each K",
      c(notes, "Four Original vs Optimized comparisons. Holm within this family. Zero-variance K: descriptives only."),
      log_path
    )
  } else {
    write_table_csv_docx(
      data.frame(followups_run = FALSE, reason = primary$follow$reason, stringsAsFactors = FALSE),
      "study2_table_h2_followups",
      "Study 2: H2 follow-ups not run",
      c(notes, paste("Reason:", primary$follow$reason)),
      log_path
    )
  }

  h3 <- primary$h3
  write_table_csv_docx(
    data.frame(
      n = h3$n,
      mean_prop = h3$mean,
      sd = h3$sd,
      ci_low = h3$ci_low,
      ci_high = h3$ci_high,
      t = h3$t,
      df = h3$df,
      p = h3$p,
      d = h3$d,
      d_ci_low = h3$d_ci_low,
      d_ci_high = h3$d_ci_high,
      null = h3$mu,
      stringsAsFactors = FALSE
    ),
    "study2_table_h3",
    "Study 2: H3 one-sample t-test of Optimized-choice proportion vs 0.50",
    c(paste0("N = ", n, ". SAP §4.2; two-sided; 12 pairwise trials."),
      "Q32: Wilcoxon fallback not applied."),
    log_path
  )

  rt <- primary$rt
  write_table_csv_docx(
    data.frame(
      condition = c("Original", "Optimized"),
      n = n,
      mean_rt_ms = c(primary$rt_ms_orig$mean, primary$rt_ms_opt$mean),
      sd_rt_ms = c(primary$rt_ms_orig$sd, primary$rt_ms_opt$sd),
      analysis_scale = primary$rt_scale,
      mean_rt_analysis = c(primary$rt_an_orig$mean, primary$rt_an_opt$mean),
      sd_rt_analysis = c(primary$rt_an_orig$sd, primary$rt_an_opt$sd),
      stringsAsFactors = FALSE
    ),
    "study2_table_rt_descriptives",
    "Study 2: Discrimination response time descriptives (milliseconds)",
    c(paste0("N = ", n, ". SAP §4.3.1. Inferential test is on the ", primary$rt_scale, " scale (Q12)."),
      "Millisecond means are untransformed, for interpretation."),
    log_path
  )
  write_table_csv_docx(
    data.frame(
      mean_diff_analysis = rt$mean_diff,
      ci_low = rt$ci_low,
      ci_high = rt$ci_high,
      t = rt$t,
      df = rt$df,
      p = rt$p,
      d_z = rt$d_z,
      d_ci_low = rt$d_ci_low,
      d_ci_high = rt$d_ci_high,
      analysis_scale = primary$rt_scale,
      stringsAsFactors = FALSE
    ),
    "study2_table_rt",
    "Study 2: Paired t-test of mean RT (Optimized - Original) on the analysis scale",
    c(paste0("N = ", n, ". SAP §4.3.1. Analysis scale = ", primary$rt_scale, " (Q12).")),
    log_path
  )

  ae <- primary$ae
  write_table_csv_docx(
    data.frame(
      condition = c("Original", "Optimized"),
      n = n,
      mean_ae = c(primary$ae_orig$mean, primary$ae_opt$mean),
      sd_ae = c(primary$ae_orig$sd, primary$ae_opt$sd),
      stringsAsFactors = FALSE
    ),
    "study2_table_ae_descriptives",
    "Study 2: Absolute error descriptives by Condition (averaged across K)",
    c(paste0("N = ", n, ". SAP §4.3.2.")),
    log_path
  )
  write_table_csv_docx(
    data.frame(
      mean_diff = ae$mean_diff,
      ci_low = ae$ci_low,
      ci_high = ae$ci_high,
      t = ae$t,
      df = ae$df,
      p = ae$p,
      d_z = ae$d_z,
      d_ci_low = ae$d_ci_low,
      d_ci_high = ae$d_ci_high,
      stringsAsFactors = FALSE
    ),
    "study2_table_ae",
    "Study 2: Paired t-test of mean absolute error (Optimized - Original)",
    c(paste0("N = ", n, ". SAP §4.3.2.")),
    log_path
  )
  write_table_csv_docx(
    ae_k, "study2_table_ae_by_k_desc",
    "Study 2: Descriptive absolute error by Condition × K (no inferential test)",
    c(paste0("N = ", n, ". Brief §8.2: mean, SD, 95% CI only. No test by K.")),
    log_path
  )
  write_table_csv_docx(
    data.frame(
      condition = c("Original", "Optimized"),
      n = n,
      mean_signed_error = c(primary$se_orig$mean, primary$se_opt$mean),
      sd_signed_error = c(primary$se_orig$sd, primary$se_opt$sd),
      stringsAsFactors = FALSE
    ),
    "study2_table_signed_error",
    "Study 2: Signed error descriptives by Condition (no inferential test)",
    c(paste0("N = ", n, ". SAP §4.3.3. Negative = underestimation; positive = overestimation.")),
    log_path
  )
  write_table_csv_docx(
    pw_rt, "study2_table_pairwise_rt_desc",
    "Study 2: Pairwise-task response time (descriptive only)",
    c(paste0("N = ", n, ". SAP §4.3.1: pairwise RT remains descriptive.")),
    log_path
  )
  write_table_csv_docx(
    vision_tab, "study2_table_vision_sensitivity",
    "Study 2: Vision-screen sensitivity (N = 43; not the primary analysis)",
    c(
      "SAP §4.4. Primary N remains 50. This table repeats H1-H3 on score = 4 only.",
      "Same recommended tests as primary (ANOVA / one-sample t)."
    ),
    log_path
  )
}

write_study2_figures <- function(acc_cells, h3, rt_ms, ae_k, log_path) {
  pal <- study1_palette(log_path)
  cap <- paste0(
    "Palette: Original ", pal$Original, ", Optimized ", pal$Optimized,
    " (Q30). ", synthetic_note()
  )
  acc_cells$K <- factor(acc_cells$K, levels = as.integer(SAP$k_levels_study2))
  acc_cells$condition <- factor(acc_cells$condition, levels = require_param("condition_level_order"))
  p_acc <- ggplot2::ggplot(acc_cells, ggplot2::aes(x = K, y = mean, colour = condition, group = condition)) +
    ggplot2::geom_point(position = ggplot2::position_dodge(width = 0.3), size = 2.5) +
    ggplot2::geom_errorbar(
      ggplot2::aes(ymin = ci_low, ymax = ci_high),
      width = 0.15,
      position = ggplot2::position_dodge(width = 0.3)
    ) +
    ggplot2::scale_colour_manual(values = c(Original = pal$Original, Optimized = pal$Optimized)) +
    ggplot2::labs(
      title = "Study 2: Accuracy by Condition x K (95% CI)",
      y = "Mean participant-level accuracy",
      x = "K",
      colour = "Condition",
      caption = cap
    ) +
    ggplot2::theme_bw()
  save_report_figure(p_acc, "study2_fig_accuracy_condition_k", 7, 4.5, log_path)

  h3_df <- data.frame(
    x = "Optimized-choice proportion",
    mean = h3$mean,
    ci_low = h3$ci_low,
    ci_high = h3$ci_high,
    stringsAsFactors = FALSE
  )
  p_pw <- ggplot2::ggplot(h3_df, ggplot2::aes(x = x, y = mean)) +
    ggplot2::geom_hline(yintercept = as.numeric(SAP$h3_null), colour = pal$reference, linetype = "dashed") +
    ggplot2::geom_point(size = 3, colour = pal$Optimized) +
    ggplot2::geom_errorbar(ggplot2::aes(ymin = ci_low, ymax = ci_high), width = 0.1, colour = pal$Optimized) +
    ggplot2::coord_cartesian(ylim = c(0, 1)) +
    ggplot2::labs(
      title = "Study 2: Optimized-choice proportion (95% CI) vs 0.50",
      y = "Mean proportion",
      x = NULL,
      caption = cap
    ) +
    ggplot2::theme_bw()
  save_report_figure(p_pw, "study2_fig_pairwise_prop", 5, 4.5, log_path)

  rt_df <- data.frame(
    condition = factor(c("Original", "Optimized"), levels = require_param("condition_level_order")),
    mean = c(rt_ms$orig$mean, rt_ms$opt$mean),
    ci_low = c(rt_ms$orig$ci_low, rt_ms$opt$ci_low),
    ci_high = c(rt_ms$orig$ci_high, rt_ms$opt$ci_high),
    stringsAsFactors = FALSE
  )
  p_rt <- ggplot2::ggplot(rt_df, ggplot2::aes(x = condition, y = mean, fill = condition)) +
    ggplot2::geom_col(width = 0.6, colour = "grey20") +
    ggplot2::geom_errorbar(ggplot2::aes(ymin = ci_low, ymax = ci_high), width = 0.15) +
    ggplot2::scale_fill_manual(values = c(Original = pal$Original, Optimized = pal$Optimized), guide = "none") +
    ggplot2::labs(
      title = "Study 2: Descriptive discrimination RT by Condition (ms)",
      y = "Mean RT (ms)",
      x = "Condition",
      caption = cap
    ) +
    ggplot2::theme_bw()
  save_report_figure(p_rt, "study2_fig_rt_by_condition", 5, 4.5, log_path)

  ae_k$K <- factor(ae_k$K, levels = as.integer(SAP$k_levels_study2))
  ae_k$condition <- factor(ae_k$condition, levels = require_param("condition_level_order"))
  p_ae <- ggplot2::ggplot(ae_k, ggplot2::aes(x = K, y = mean, colour = condition, group = condition)) +
    ggplot2::geom_point(position = ggplot2::position_dodge(width = 0.3), size = 2.5) +
    ggplot2::geom_errorbar(
      ggplot2::aes(ymin = ci_low, ymax = ci_high),
      width = 0.15,
      position = ggplot2::position_dodge(width = 0.3)
    ) +
    ggplot2::scale_colour_manual(values = c(Original = pal$Original, Optimized = pal$Optimized)) +
    ggplot2::labs(
      title = "Study 2: Descriptive absolute error by Condition x K (95% CI)",
      y = "Mean absolute error",
      x = "K",
      colour = "Condition",
      caption = cap
    ) +
    ggplot2::theme_bw()
  save_report_figure(p_ae, "study2_fig_ae_condition_k", 7, 4.5, log_path)
}
