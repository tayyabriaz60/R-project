# Study 2 Q13/Q14 tables and figures. SAP §4. Q30 colours. Q32 npar not applied.
# Table/figure layout is thesis-ready (client 29 Sep 2026). Tests unchanged.

source(file.path(PROJECT_ROOT, "R", "study1_export.R"))

cond_mean_table <- function(n, mean_a, sd_a, lo_a, hi_a, mean_b, sd_b, lo_b, hi_b) {
  data.frame(
    Condition = c("Original", "Optimized"),
    N = n,
    Mean = c(fmt_num(mean_a, 3), fmt_num(mean_b, 3)),
    SD = c(fmt_num(sd_a, 3), fmt_num(sd_b, 3)),
    `95% CI` = c(fmt_ci(lo_a, hi_a, 3), fmt_ci(lo_b, hi_b, 3)),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
}

paired_test_table <- function(diff, lo, hi, t, df, p, d, d_lo, d_hi) {
  data.frame(
    Comparison = "Optimized - Original",
    `Mean difference` = fmt_num(diff, 3),
    `95% CI` = fmt_ci(lo, hi, 3),
    t = fmt_num(t, 3),
    df = fmt_num(df, 2),
    p = fmt_p(p),
    `Cohen's dz` = fmt_num(d, 3),
    `dz 95% CI` = fmt_ci(d_lo, d_hi, 3),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
}

write_study2_tables <- function(primary, vision_tab, ae_k, pw_rt, log_path) {
  n <- primary$n
  note_n <- paste0("N = ", n, " (primary sample after researcher exclusion).")
  write_table_csv_docx(
    cond_mean_table(
      n,
      primary$acc_orig$mean, primary$acc_orig$sd, primary$acc_orig$ci_low, primary$acc_orig$ci_high,
      primary$acc_opt$mean, primary$acc_opt$sd, primary$acc_opt$ci_low, primary$acc_opt$ci_high
    ),
    "study2_table_accuracy_descriptives",
    "Study 2: Mean participant-level accuracy by Condition",
    c(note_n, "Accuracy is averaged across the three Difficulty instances within each Condition x K cell, then across K."),
    log_path
  )

  write_table_csv_docx(
    data.frame(
      Hypothesis = c("H1 Condition", "H2 Condition x K"),
      F = c(fmt_num(primary$h1$F, 3), fmt_num(primary$h2$F, 3)),
      df = c(fmt_df(primary$h1$df_num, primary$h1$df_den), fmt_df(primary$h2$df_num, primary$h2$df_den)),
      p = c(fmt_p(primary$h1$p), fmt_p(primary$h2$p)),
      `Partial eta-squared` = c(fmt_num(primary$h1$pes, 3), fmt_num(primary$h2$pes, 3)),
      `95% CI` = c(
        fmt_ci(primary$h1$pes_ci_low, primary$h1$pes_ci_high, 3),
        fmt_ci(primary$h2$pes_ci_low, primary$h2$pes_ci_high, 3)
      ),
      `Mauchly p` = c(fmt_p(primary$h1$mauchly_p), fmt_p(primary$h2$mauchly_p)),
      Sphericity = c(primary$h1$sphericity_correction, primary$h2$sphericity_correction),
      check.names = FALSE,
      stringsAsFactors = FALSE
    ),
    "study2_table_h1_h2_anova",
    "Study 2: H1/H2 repeated-measures ANOVA (Condition x K)",
    c(note_n, "Greenhouse-Geisser applied when Mauchly p < .05. Holm follow-ups only if H2 is significant."),
    log_path
  )

  if (isTRUE(primary$follow$ran) && nrow(primary$follow$rows) > 0L) {
    fr <- primary$follow$rows
    follow_df <- data.frame(
      K = fr$K,
      Estimable = fr$estimable,
      `Mean difference` = fmt_num(fr$mean_diff, 3),
      `95% CI` = fmt_ci(fr$ci_low, fr$ci_high, 3),
      t = fmt_num(fr$t, 3),
      df = fmt_num(fr$df, 2),
      p = fmt_p(fr$p_raw),
      `p (Holm)` = fmt_p(fr$p_holm),
      `Cohen's dz` = fmt_num(fr$d_z, 3),
      check.names = FALSE,
      stringsAsFactors = FALSE
    )
    write_table_csv_docx(
      follow_df, "study2_table_h2_followups",
      "Study 2: H2 follow-up paired t-tests at each K",
      c(note_n, "Holm adjustment within this family of four comparisons."),
      log_path
    )
  } else {
    write_table_csv_docx(
      data.frame(
        Follow_ups = "Not run",
        Reason = primary$follow$reason,
        stringsAsFactors = FALSE
      ),
      "study2_table_h2_followups",
      "Study 2: H2 follow-ups not run",
      c(note_n, paste("Follow-ups are run only if the Condition x K interaction is significant. Reason:", primary$follow$reason)),
      log_path
    )
  }

  h3 <- primary$h3
  write_table_csv_docx(
    data.frame(
      N = h3$n,
      Mean = fmt_num(h3$mean, 3),
      SD = fmt_num(h3$sd, 3),
      `95% CI` = fmt_ci(h3$ci_low, h3$ci_high, 3),
      t = fmt_num(h3$t, 3),
      df = fmt_num(h3$df, 2),
      p = fmt_p(h3$p),
      `Cohen's d` = fmt_num(h3$d, 3),
      `d 95% CI` = fmt_ci(h3$d_ci_low, h3$d_ci_high, 3),
      Null = fmt_num(h3$mu, 2),
      check.names = FALSE,
      stringsAsFactors = FALSE
    ),
    "study2_table_h3",
    "Study 2: H3 one-sample t-test of Optimized-choice proportion vs 0.50",
    c(paste0("N = ", n, ". Two-sided test; 12 pairwise trials per participant.")),
    log_path
  )

  rt <- primary$rt
  write_table_csv_docx(
    cbind(
      cond_mean_table(
        n,
        primary$rt_ms_orig$mean, primary$rt_ms_orig$sd, primary$rt_ms_orig$ci_low, primary$rt_ms_orig$ci_high,
        primary$rt_ms_opt$mean, primary$rt_ms_opt$sd, primary$rt_ms_opt$ci_low, primary$rt_ms_opt$ci_high
      ),
      data.frame(`Analysis scale` = primary$rt_scale, check.names = FALSE, stringsAsFactors = FALSE)
    ),
    "study2_table_rt_descriptives",
    "Study 2: Discrimination response time (milliseconds)",
    c(note_n, paste0("Millisecond means are untransformed. Inferential test uses the ", primary$rt_scale, " scale.")),
    log_path
  )
  write_table_csv_docx(
    cbind(
      paired_test_table(
        rt$mean_diff, rt$ci_low, rt$ci_high, rt$t, rt$df, rt$p,
        rt$d_z, rt$d_ci_low, rt$d_ci_high
      ),
      data.frame(`Analysis scale` = primary$rt_scale, check.names = FALSE, stringsAsFactors = FALSE)
    ),
    "study2_table_rt",
    "Study 2: Paired t-test of mean RT (Optimized - Original)",
    c(note_n, paste0("Analysis scale = ", primary$rt_scale, ".")),
    log_path
  )

  ae <- primary$ae
  write_table_csv_docx(
    cond_mean_table(
      n,
      primary$ae_orig$mean, primary$ae_orig$sd, primary$ae_orig$ci_low, primary$ae_orig$ci_high,
      primary$ae_opt$mean, primary$ae_opt$sd, primary$ae_opt$ci_low, primary$ae_opt$ci_high
    ),
    "study2_table_ae_descriptives",
    "Study 2: Absolute error by Condition",
    c(note_n, "Averaged across K."),
    log_path
  )
  write_table_csv_docx(
    paired_test_table(
      ae$mean_diff, ae$ci_low, ae$ci_high, ae$t, ae$df, ae$p,
      ae$d_z, ae$d_ci_low, ae$d_ci_high
    ),
    "study2_table_ae",
    "Study 2: Paired t-test of mean absolute error (Optimized - Original)",
    c(note_n),
    log_path
  )

  ae_disp <- data.frame(
    Condition = as.character(ae_k$condition),
    K = ae_k$K,
    N = ae_k$n,
    Mean = fmt_num(ae_k$mean, 3),
    SD = fmt_num(ae_k$sd, 3),
    `95% CI` = fmt_ci(ae_k$ci_low, ae_k$ci_high, 3),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  write_table_csv_docx(
    ae_disp, "study2_table_ae_by_k_desc",
    "Study 2: Absolute error by Condition x K (descriptive only)",
    c(note_n, "No inferential test by K."),
    log_path
  )
  write_table_csv_docx(
    cond_mean_table(
      n,
      primary$se_orig$mean, primary$se_orig$sd, primary$se_orig$ci_low, primary$se_orig$ci_high,
      primary$se_opt$mean, primary$se_opt$sd, primary$se_opt$ci_low, primary$se_opt$ci_high
    ),
    "study2_table_signed_error",
    "Study 2: Signed error by Condition (descriptive only)",
    c(note_n, "Negative = underestimation; positive = overestimation. No hypothesis test was prespecified."),
    log_path
  )
  write_table_csv_docx(
    data.frame(
      N = pw_rt$n,
      `Mean RT (ms)` = fmt_num(pw_rt$mean_rt_ms, 1),
      SD = fmt_num(pw_rt$sd_rt_ms, 1),
      `95% CI` = fmt_ci(pw_rt$ci_low, pw_rt$ci_high, 1),
      check.names = FALSE,
      stringsAsFactors = FALSE
    ),
    "study2_table_pairwise_rt_desc",
    "Study 2: Pairwise-task response time (descriptive only)",
    c(note_n, "No inferential test for pairwise RT."),
    log_path
  )

  vis <- vision_tab
  write_table_csv_docx(
    data.frame(
      Analysis = vis$analysis,
      N = vis$n,
      Statistic = fmt_num(vis$statistic, 3),
      p = fmt_p(vis$p),
      `Effect size` = fmt_num(vis$effect_size, 3),
      `ES name` = vis$es_name,
      `Agrees with primary` = ifelse(vis$sig_agrees_with_primary, "Yes", "No"),
      check.names = FALSE,
      stringsAsFactors = FALSE
    ),
    "study2_table_vision_sensitivity",
    "Study 2: Vision-screen sensitivity (not the primary analysis)",
    c("Score = 4 subset, N = 43. Primary N remains 50. Same tests as the primary analysis."),
    log_path
  )
}

write_study2_figures <- function(acc_cells, h3, rt_ms, ae_k, log_path) {
  pal <- study1_palette(log_path)
  k_levels <- as.integer(SAP$k_levels_study2)
  save_report_figure(
    plot_condition_by_k(acc_cells, "Mean participant-level accuracy", pal, k_levels),
    "study2_fig_accuracy_condition_k", 7, 4.5, log_path
  )
  save_report_figure(plot_pairwise_prop(h3, pal), "study2_fig_pairwise_prop", 5, 4.5, log_path)
  save_report_figure(plot_rt_by_condition(rt_ms, pal), "study2_fig_rt_by_condition", 5.5, 4.5, log_path)
  save_report_figure(
    plot_condition_by_k(ae_k, "Mean absolute error", pal, k_levels),
    "study2_fig_ae_condition_k", 7, 4.5, log_path
  )
}
