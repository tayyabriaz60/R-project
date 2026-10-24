# Study 3 tables export (thesis/journal-ready descriptives + inferential statistics).

source(file.path(PROJECT_ROOT, "R", "study1_export.R"))
source(file.path(PROJECT_ROOT, "R", "export_table_helpers.R"))
source(file.path(PROJECT_ROOT, "R", "study3_summarise.R"))

study3_note_n <- function(n) {
  paste0("N = ", n, " (primary after vision exclusions).")
}

study3_anova_effect_row <- function(h, effect_label) {
  data.frame(
    Effect = effect_label,
    F = fmt_num(h$F, 3),
    df = fmt_df(h$df_num, h$df_den),
    p = fmt_p(h$p),
    `Partial eta-squared` = fmt_num(h$pes, 3),
    `Partial eta-squared 95% CI` = fmt_ci(h$pes_ci_low, h$pes_ci_high, 3),
    `Mauchly p` = fmt_p(h$mauchly_p),
    `Sphericity correction` = h$sphericity_correction,
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
}

study3_cbg_descriptive_table <- function(summary_df, value_prefix) {
  cond_order <- require_param("condition_level_order")
  bg_order <- require_param("background_level_order")
  rows <- list()
  idx <- 1L
  for (cond in cond_order) {
    for (bg in bg_order) {
      col <- paste0(value_prefix, cond, "_", bg)
      st <- mean_sd_ci(summary_df[[col]])
      rows[[idx]] <- data.frame(
        Condition = cond,
        Background = bg,
        N = st$n,
        Mean = fmt_num(st$mean, 3),
        SD = fmt_num(st$sd, 3),
        `95% CI` = fmt_ci(st$ci_low, st$ci_high, 3),
        check.names = FALSE,
        stringsAsFactors = FALSE
      )
      idx <- idx + 1L
    }
  }
  do.call(rbind, rows)
}

study3_acc_by_k_descriptive_table <- function(disc) {
  cond_order <- require_param("condition_level_order")
  bg_order <- require_param("background_level_order")
  k_levels <- as.integer(SAP$k_levels_study3)
  cells <- stats::aggregate(
    accuracy ~ participant_id + condition + background + K,
    data = disc,
    FUN = function(x) mean(as.numeric(x), na.rm = TRUE)
  )
  rows <- list()
  idx <- 1L
  for (bg in bg_order) {
    for (k in k_levels) {
      for (cond in cond_order) {
        sub <- cells[
          as.character(cells$background) == bg &
            as.integer(cells$K) == as.integer(k) &
            as.character(cells$condition) == cond,
          "accuracy"
        ]
        st <- mean_sd_ci(sub)
        rows[[idx]] <- data.frame(
          Background = bg,
          K = k,
          Condition = cond,
          N = st$n,
          Mean = fmt_num(st$mean, 3),
          SD = fmt_num(st$sd, 3),
          `95% CI` = fmt_ci(st$ci_low, st$ci_high, 3),
          check.names = FALSE,
          stringsAsFactors = FALSE
        )
        idx <- idx + 1L
      }
    }
  }
  do.call(rbind, rows)
}

study3_cond_overall_table <- function(summary_df, orig_col, opt_col, n) {
  cond_mean_table(
    n,
    mean_sd_ci(summary_df[[orig_col]])$mean,
    mean_sd_ci(summary_df[[orig_col]])$sd,
    mean_sd_ci(summary_df[[orig_col]])$ci_low,
    mean_sd_ci(summary_df[[orig_col]])$ci_high,
    mean_sd_ci(summary_df[[opt_col]])$mean,
    mean_sd_ci(summary_df[[opt_col]])$sd,
    mean_sd_ci(summary_df[[opt_col]])$ci_low,
    mean_sd_ci(summary_df[[opt_col]])$ci_high
  )
}

write_study3_tables <- function(summary_df, disc, acc_tests, pw_tests, rt_tests, ae_test, log_path) {
  n <- acc_tests$n
  note_n <- study3_note_n(n)
  syn <- synthetic_note()
  notes_base <- c(note_n, syn)
  notes_base <- notes_base[nzchar(notes_base)]

  write_table_csv_docx(
    study3_cbg_descriptive_table(summary_df, "acc_"),
    "study3_table_accuracy_descriptives",
    "Study 3: Mean participant-level accuracy by Condition and Background",
    c(
      notes_base,
      "Each cell averages across K and Difficulty instances (participant summary columns)."
    ),
    log_path
  )

  if (acc_tests$mode == "anova") {
    anova_df <- rbind(
      study3_anova_effect_row(acc_tests$h4, "H4 Condition"),
      study3_anova_effect_row(acc_tests$h_background, "Background"),
      study3_anova_effect_row(acc_tests$h5, "H5 Condition x Background")
    )
    write_table_csv_docx(
      anova_df,
      "study3_table_h4_h5",
      "Study 3: H4/H5 accuracy repeated-measures ANOVA (Condition x Background)",
      c(
        notes_base,
        "Type III RM-ANOVA on participant-level accuracy cells.",
        "Partial eta-squared 95% CIs from effectsize (two-sided, SAP ci_level).",
        "Greenhouse-Geisser when Mauchly p < .05."
      ),
      log_path
    )
  } else {
    h4 <- acc_tests$h4
    h5 <- acc_tests$h5
    write_table_csv_docx(
      data.frame(
        hypothesis = c("H4_Optimized_minus_Original_overall", "H5_White_minus_Black_diff"),
        test = "paired_wilcoxon",
        n_pairs = c(h4$n_pairs, h5$n_pairs),
        n_zero = c(h4$n_zero, h5$n_zero),
        n_nonzero = c(h4$n_nonzero, h5$n_nonzero),
        V = c(h4$V, h5$V),
        p = c(h4$p, h5$p),
        rank_biserial = c(h4$r_rb, h5$r_rb),
        r_ci_low = c(h4$r_ci_low, h5$r_ci_low),
        r_ci_high = c(h4$r_ci_high, h5$r_ci_high),
        stringsAsFactors = FALSE
      ),
      "study3_table_h4_h5",
      "Study 3: H4/H5 accuracy Wilcoxon signed-rank tests (fallback path)",
      notes_base,
      log_path
    )
  }

  if (isTRUE(acc_tests$follow$ran) && nrow(acc_tests$follow$rows) > 0L) {
    fr <- acc_tests$follow$rows
    follow_df <- data.frame(
      Background = fr$background,
      Estimable = fr$estimable,
      `Mean difference (Opt - Orig)` = fmt_num(fr$mean_diff, 3),
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
      follow_df,
      "study3_table_h5_followups",
      "Study 3: H5 follow-up paired t-tests by Background (interaction significant)",
      c(notes_base, "Holm adjustment within White and Black comparisons."),
      log_path
    )
  } else {
    write_table_csv_docx(
      data.frame(
        followups_run = FALSE,
        reason = acc_tests$follow$reason,
        stringsAsFactors = FALSE
      ),
      "study3_table_h5_followups",
      "Study 3: H5 follow-ups not run",
      c(notes_base, paste("Reason:", acc_tests$follow$reason)),
      log_path
    )
  }

  if (pw_tests$mode == "t") {
    h6 <- pw_tests$h6
    h7 <- pw_tests$h7
    h6w <- mean_sd_ci(summary_df$pairwise_prop_optimized_White)
    h6b <- mean_sd_ci(summary_df$pairwise_prop_optimized_Black)
    write_table_csv_docx(
      data.frame(
        hypothesis = "H6_overall_optimized_proportion",
        N = h6$n,
        Mean = fmt_num(h6$mean, 3),
        SD = fmt_num(h6$sd, 3),
        `95% CI` = fmt_ci(h6$ci_low, h6$ci_high, 3),
        Null = fmt_num(h6$mu, 2),
        t = fmt_num(h6$t, 3),
        df = fmt_num(h6$df, 2),
        p = fmt_p(h6$p),
        `Cohen's d` = fmt_num(h6$d, 3),
        `d 95% CI` = fmt_ci(h6$d_ci_low, h6$d_ci_high, 3),
        check.names = FALSE,
        stringsAsFactors = FALSE
      ),
      "study3_table_h6",
      "Study 3: H6 one-sample t-test of Optimized-choice proportion vs 0.50",
      c(notes_base, paste0("Alternative: ", require_param("h3_alternative"), "; 18 pairwise trials per participant.")),
      log_path
    )
    write_table_csv_docx(
      rbind(
        data.frame(
          Background = "White",
          N = h6w$n,
          Mean = fmt_num(h6w$mean, 3),
          SD = fmt_num(h6w$sd, 3),
          `95% CI` = fmt_ci(h6w$ci_low, h6w$ci_high, 3),
          check.names = FALSE,
          stringsAsFactors = FALSE
        ),
        data.frame(
          Background = "Black",
          N = h6b$n,
          Mean = fmt_num(h6b$mean, 3),
          SD = fmt_num(h6b$sd, 3),
          `95% CI` = fmt_ci(h6b$ci_low, h6b$ci_high, 3),
          check.names = FALSE,
          stringsAsFactors = FALSE
        )
      ),
      "study3_table_h7_descriptives",
      "Study 3: H7 descriptive Optimized-choice proportions by Background",
      c(notes_base, "Nine pairwise trials per background."),
      log_path
    )
    write_table_csv_docx(
      cbind(
        data.frame(
          Comparison = "White - Black (Optimized proportion)",
          check.names = FALSE,
          stringsAsFactors = FALSE
        ),
        paired_test_table(
          h7$mean_diff, h7$ci_low, h7$ci_high, h7$t, h7$df, h7$p,
          h7$d_z, h7$d_ci_low, h7$d_ci_high
        )
      ),
      "study3_table_h6_h7",
      "Study 3: H7 paired t-test (White vs Black Optimized proportion)",
      notes_base,
      log_path
    )
  } else {
    h6 <- pw_tests$h6
    h7 <- pw_tests$h7
    write_table_csv_docx(
      data.frame(
        hypothesis = c("H6_overall", "H7_white_vs_black"),
        test = "wilcoxon",
        V = c(h6$V, h7$V),
        p = c(h6$p, h7$p),
        n_nonzero = c(h6$n_nonzero, h7$n_nonzero),
        rank_biserial = c(h6$r_rb, h7$r_rb),
        r_ci_low = c(h6$r_ci_low, h7$r_ci_low),
        r_ci_high = c(h6$r_ci_high, h7$r_ci_high),
        stringsAsFactors = FALSE
      ),
      "study3_table_h6_h7",
      "Study 3: H6/H7 Wilcoxon tests (fallback path)",
      notes_base,
      log_path
    )
  }

  rt_scale <- rt_tests$scale[[1L]]
  write_table_csv_docx(
    study3_cbg_descriptive_table(summary_df, "mean_rt_ms_"),
    "study3_table_rt_descriptives",
    "Study 3: Mean discrimination response time (ms) by Condition and Background",
    c(
      notes_base,
      paste0(
        "Inferential RT model uses ",
        rt_scale,
        " participant means (see study3_table_rt_anova)."
      )
    ),
    log_path
  )

  rt_anova_df <- rbind(
    study3_anova_effect_row(rt_tests$condition, "Condition"),
    study3_anova_effect_row(rt_tests$background, "Background"),
    study3_anova_effect_row(rt_tests$interaction, "Condition x Background")
  )
  write_table_csv_docx(
    rt_anova_df,
    "study3_table_rt_anova",
    "Study 3: RT repeated-measures ANOVA (Condition x Background)",
    c(
      notes_base,
      paste0("Dependent variable: ", rt_scale, " RT (participant-level cell means)."),
      "Partial eta-squared 95% CIs from effectsize (two-sided, SAP ci_level)."
    ),
    log_path
  )

  if (isTRUE(rt_tests$follow$ran) && nrow(rt_tests$follow$rows) > 0L) {
    fr <- rt_tests$follow$rows
    write_table_csv_docx(
      data.frame(
        Background = fr$background,
        Estimable = fr$estimable,
        `Mean difference (Opt - Orig)` = fmt_num(fr$mean_diff, 3),
        t = fmt_num(fr$t, 3),
        df = fmt_num(fr$df, 2),
        p = fmt_p(fr$p_raw),
        `p (Holm)` = fmt_p(fr$p_holm),
        check.names = FALSE,
        stringsAsFactors = FALSE
      ),
      "study3_table_rt_followups",
      "Study 3: RT follow-up paired t-tests by Background (interaction significant)",
      c(notes_base, paste0("Analysis scale: ", rt_scale, ".")),
      log_path
    )
  } else {
    write_table_csv_docx(
      data.frame(followups_run = FALSE, reason = rt_tests$follow$reason, stringsAsFactors = FALSE),
      "study3_table_rt_followups",
      "Study 3: RT follow-ups not run",
      c(notes_base, paste("Reason:", rt_tests$follow$reason)),
      log_path
    )
  }

  write_table_csv_docx(
    study3_cbg_descriptive_table(summary_df, "mean_ae_"),
    "study3_table_ae_descriptives",
    "Study 3: Mean absolute error by Condition and Background",
    c(notes_base, "Participant-level cell means."),
    log_path
  )
  write_table_csv_docx(
    study3_cond_overall_table(summary_df, "mean_ae_Original", "mean_ae_Optimized", n),
    "study3_table_ae_overall_descriptives",
    "Study 3: Mean absolute error by Condition (averaged across Background)",
    notes_base,
    log_path
  )
  if (isTRUE(ae_test$estimable)) {
    write_table_csv_docx(
      paired_test_table(
        ae_test$mean_diff, ae_test$ci_low, ae_test$ci_high,
        ae_test$t, ae_test$df, ae_test$p,
        ae_test$d_z, ae_test$d_ci_low, ae_test$d_ci_high
      ),
      "study3_table_ae",
      "Study 3: Absolute error paired t-test (Optimized - Original)",
      c(notes_base, "Paired on participant means averaged across Background."),
      log_path
    )
  } else {
    write_table_csv_docx(
      data.frame(
        estimable = FALSE,
        n = ae_test$n,
        note = "zero_variance_diff",
        stringsAsFactors = FALSE
      ),
      "study3_table_ae",
      "Study 3: Absolute error paired t-test not estimable",
      notes_base,
      log_path
    )
  }

  write_table_csv_docx(
    study3_cbg_descriptive_table(summary_df, "mean_se_"),
    "study3_table_signed_error_descriptives",
    "Study 3: Mean signed error by Condition and Background",
    c(notes_base, "Descriptive only."),
    log_path
  )

  write_table_csv_docx(
    study3_acc_by_k_descriptive_table(disc),
    "study3_table_accuracy_by_k_descriptives",
    "Study 3: Mean accuracy by K, Condition, and Background",
    c(
      notes_base,
      "Each cell averages across Difficulty instances at participant level, then group descriptives."
    ),
    log_path
  )

  invisible(TRUE)
}
