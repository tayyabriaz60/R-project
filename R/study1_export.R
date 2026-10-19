# Q13 / Q14 tables (.csv + .docx) and report figures (.png 300 dpi + .pdf).
# Q30 colours confirmed: Original #E69F00, Optimized #0072B2.

source(file.path(PROJECT_ROOT, "R", "utils_paths.R"))
source(file.path(PROJECT_ROOT, "R", "utils_io.R"))
source(file.path(PROJECT_ROOT, "R", "utils_logging.R"))
source(file.path(PROJECT_ROOT, "R", "utils_format.R"))
source(file.path(PROJECT_ROOT, "R", "utils_figures.R"))
source(file.path(PROJECT_ROOT, "R", "export_table_helpers.R"))

assert_no_gorilla_ids <- function(df, label) {
  bad <- intersect(names(df), c("participant_id", "participant_public_id", "participant_private_id"))
  if (length(bad) > 0L) {
    stop("Refusing to write ", label, " with Gorilla ID column(s).", call. = FALSE)
  }
  invisible(TRUE)
}

synthetic_note <- function() {
  if (identical(DATA_SOURCE, "synthetic")) {
    "SYNTHETIC DATA: pipeline test only. Not a finding."
  } else {
    ""
  }
}

study1_palette <- function(log_path = NULL) {
  pal <- require_param("figure_colours")
  if (!is.null(log_path)) {
    log_msg(log_path, "Q30 palette ", pal$name,
            " status=", pal$status,
            " Original=", pal$Original, " Optimized=", pal$Optimized)
  }
  pal
}

write_table_csv_docx <- function(df, name, title, notes, log_path) {
  assert_no_gorilla_ids(df, name)
  ensure_output_dirs()
  csv_path <- file.path(OUTPUT_TABLES, paste0(name, OUTPUT_SUFFIX, ".csv"))
  docx_path <- file.path(OUTPUT_TABLES, paste0(name, OUTPUT_SUFFIX, ".docx"))
  write_qc_csv(df, csv_path)
  ft <- flextable::flextable(df)
  ft <- format_thesis_table(ft)
  ft <- flextable::autofit(ft)
  doc <- officer::read_docx()
  doc <- officer::body_add_par(doc, title, style = "heading 1")
  for (nt in notes) {
    doc <- officer::body_add_par(doc, nt, style = "Normal")
  }
  if (nzchar(synthetic_note())) {
    doc <- officer::body_add_par(doc, synthetic_note(), style = "Normal")
  }
  doc <- flextable::body_add_flextable(doc, ft)
  print(doc, target = docx_path)
  log_msg(log_path, "wrote ", basename(csv_path), " and ", basename(docx_path))
  c(csv_path, docx_path)
}

save_report_figure <- function(plot, name, width_in, height_in, log_path) {
  ensure_output_dirs()
  png_path <- file.path(OUTPUT_FIGURES, paste0(name, OUTPUT_SUFFIX, ".png"))
  pdf_path <- file.path(OUTPUT_FIGURES, paste0(name, OUTPUT_SUFFIX, ".pdf"))
  is_gg <- inherits(plot, "ggplot")
  if (is_gg) {
    ggplot2::ggsave(png_path, plot, width = width_in, height = height_in, dpi = 300, units = "in")
    ggplot2::ggsave(pdf_path, plot, width = width_in, height = height_in, device = "pdf")
  } else {
    grDevices::png(png_path, width = width_in, height = height_in, units = "in", res = 300)
    grid::grid.draw(plot)
    grDevices::dev.off()
    grDevices::pdf(pdf_path, width = width_in, height = height_in)
    grid::grid.draw(plot)
    grDevices::dev.off()
  }
  sn <- synthetic_note()
  if (nzchar(sn)) {
    log_msg(log_path, "figure ", basename(png_path), ": ", sn)
  }
  log_msg(log_path, "wrote ", basename(png_path), " and ", basename(pdf_path))
  c(png_path, pdf_path)
}

# Thesis-ready report figures live in R/utils_figures.R (shared by Study 1 and 2).

format_thesis_table <- function(ft) {
  ft <- flextable::theme_booktabs(ft)
  ft <- flextable::bold(ft, part = "header")
  ft <- flextable::fontsize(ft, size = 10, part = "all")
  ft <- flextable::align(ft, align = "center", part = "all")
  ft
}

# Cell means + t CI for a Condition × K table (descriptive figure / AE×K).
cell_mean_ci <- function(df, value_col, by = c("condition", "K")) {
  split_key <- interaction(df[by], drop = TRUE)
  pieces <- lapply(split(df, split_key), function(part) {
    st <- mean_sd_ci(part[[value_col]])
    out <- part[1, by, drop = FALSE]
    out$n <- st$n
    out$mean <- st$mean
    out$sd <- st$sd
    out$ci_low <- st$ci_low
    out$ci_high <- st$ci_high
    out
  })
  out <- do.call(rbind, pieces)
  rownames(out) <- NULL
  out
}

write_study1_tables <- function(primary, vision_tab, ae_k, pw_rt, log_path) {
  n <- primary$n
  note_n <- paste0("N = ", n, " (primary sample after researcher exclusion and vision rules).")
  notes_acc <- c(
    note_n,
    "Accuracy is averaged across three Difficulty levels within each Condition x K cell, then across K for H1.",
    "Q7 path open: final H1-H3 tests will be locked after diagnostic review (difference-score plots + SAP fallback).",
    paste0(
      "Rank-based tests (if selected) round Optimized-Original difference scores to ",
      as.integer(SAP$study1_rank_diff_round_digits),
      " decimals before ranking."
    ),
    "Q10: exact-zero paired differences omitted when Wilcoxon tests are used."
  )
  write_table_csv_docx(
    cond_mean_table(
      n,
      primary$acc_orig$mean, primary$acc_orig$sd, primary$acc_orig$ci_low, primary$acc_orig$ci_high,
      primary$acc_opt$mean, primary$acc_opt$sd, primary$acc_opt$ci_low, primary$acc_opt$ci_high
    ),
    "study1_table_accuracy_descriptives",
    "Study 1: Mean participant-level accuracy by Condition",
    notes_acc,
    log_path
  )

  if (identical(require_param("study1_h1_test"), "paired_wilcoxon")) {
    h1 <- primary$h1
    write_table_csv_docx(
      data.frame(
        hypothesis = "H1_Condition",
        test = "paired_wilcoxon",
        n_pairs = h1$n_pairs,
        n_zero = h1$n_zero,
        n_nonzero = h1$n_nonzero,
        V = h1$V,
        p = h1$p,
        rank_biserial = h1$r_rb,
        r_ci_low = h1$r_ci_low,
        r_ci_high = h1$r_ci_high,
        stringsAsFactors = FALSE
      ),
      "study1_table_h1_wilcoxon",
      "Study 1: H1 paired Wilcoxon signed-rank test (Optimized vs Original accuracy)",
      notes_acc,
      log_path
    )
    h2 <- primary$h2
    write_table_csv_docx(
      data.frame(
        hypothesis = "H2_Condition_x_K",
        test = "friedman_opt_minus_orig_by_k",
        n = h2$n,
        n_k = h2$n_k,
        chi_squared = h2$statistic,
        df = h2$df,
        p = h2$p,
        kendalls_w = h2$kendalls_w,
        w_ci_low = h2$w_ci_low,
        w_ci_high = h2$w_ci_high,
        stringsAsFactors = FALSE
      ),
      "study1_table_h2_friedman",
      "Study 1: H2 Friedman test of Optimized-Original accuracy differences across K",
      notes_acc,
      log_path
    )
    if (isTRUE(primary$follow$ran) && nrow(primary$follow$rows) > 0L) {
      write_table_csv_docx(
        primary$follow$rows, "study1_table_h2_followups",
        "Study 1: H2 Friedman follow-up pairwise Wilcoxon tests on K-difference scores",
        c(notes_acc, "Six pairwise Wilcoxon tests on Opt-Orig diffs between K levels. Holm within this family."),
        log_path
      )
    } else {
      write_table_csv_docx(
        data.frame(followups_run = FALSE, reason = primary$follow$reason, stringsAsFactors = FALSE),
        "study1_table_h2_followups",
        "Study 1: H2 Friedman follow-ups not run",
        c(notes_acc, paste("Reason:", primary$follow$reason)),
        log_path
      )
    }
  } else {
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
      "study1_table_h1_h2_anova",
      "Study 1: H1/H2 repeated-measures ANOVA (Condition x K)",
      c(note_n, "Greenhouse-Geisser when Mauchly p < .05. Holm follow-ups only if H2 interaction is significant."),
      log_path
    )
    if (isTRUE(primary$follow$ran) && nrow(primary$follow$rows) > 0L) {
      fr <- primary$follow$rows
      write_table_csv_docx(
        data.frame(
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
        ),
        "study1_table_h2_followups",
        "Study 1: H2 follow-up paired t-tests at each K",
        c(note_n, "Holm adjustment within this family of four comparisons."),
        log_path
      )
    } else {
      write_table_csv_docx(
        data.frame(Follow_ups = "Not run", Reason = primary$follow$reason, stringsAsFactors = FALSE),
        "study1_table_h2_followups",
        "Study 1: H2 follow-ups not run",
        c(note_n, paste("Reason:", primary$follow$reason)),
        log_path
      )
    }
  }

  h3 <- primary$h3
  if (identical(require_param("study1_h3_test"), "onesample_t")) {
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
      "study1_table_h3",
      "Study 1: H3 one-sample t-test of Optimized-choice proportion vs 0.50",
      c(paste0("N = ", n, ". Two-sided test; 12 pairwise trials per participant.")),
      log_path
    )
  } else {
    write_table_csv_docx(
      data.frame(
        n = h3$n,
        mean_prop = h3$mean,
        sd = h3$sd,
        mean_ci_low = h3$ci_low,
        mean_ci_high = h3$ci_high,
        n_zero = h3$n_zero,
        n_nonzero = h3$n_nonzero,
        V = h3$V,
        p = h3$p,
        rank_biserial = h3$r_rb,
        r_ci_low = h3$r_ci_low,
        r_ci_high = h3$r_ci_high,
        null = h3$mu,
        stringsAsFactors = FALSE
      ),
      "study1_table_h3",
      "Study 1: H3 one-sample Wilcoxon test of Optimized-choice proportion vs 0.50",
      c(
        paste0("N = ", n, ". SAP §3.2 fallback; two-sided; 12 pairwise trials per participant."),
        "Q10: exact ties at 0.50 omitted."
      ),
      log_path
    )
  }

  rt <- primary$rt
  rt_df <- data.frame(
    condition = c("Original", "Optimized"),
    n = n,
    mean_rt_ms = c(primary$rt_ms_orig$mean, primary$rt_ms_opt$mean),
    sd_rt_ms = c(primary$rt_ms_orig$sd, primary$rt_ms_opt$sd),
    analysis_scale = primary$rt_scale,
    mean_rt_analysis = c(primary$rt_an_orig$mean, primary$rt_an_opt$mean),
    sd_rt_analysis = c(primary$rt_an_orig$sd, primary$rt_an_opt$sd),
    stringsAsFactors = FALSE
  )
  rt_inf <- data.frame(
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
  )
  write_table_csv_docx(
    rt_df, "study1_table_rt_descriptives",
    "Study 1: Discrimination response time descriptives (milliseconds)",
    c(
      paste0("N = ", n, ". SAP §3.3.1. Inferential test is on the ", primary$rt_scale, " scale (Q12)."),
      "Millisecond means are untransformed, for interpretation."
    ),
    log_path
  )
  write_table_csv_docx(
    rt_inf, "study1_table_rt",
    "Study 1: Paired t-test of mean RT (Optimized − Original) on the analysis scale",
    c(
      paste0("N = ", n, ". SAP §3.3.1. Analysis scale = ", primary$rt_scale, " (Q12)."),
      "Q7: RT stays the paired t-test on the analysis scale."
    ),
    log_path
  )

  ae <- primary$ae
  ae_df <- data.frame(
    condition = c("Original", "Optimized"),
    n = n,
    mean_ae = c(primary$ae_orig$mean, primary$ae_opt$mean),
    sd_ae = c(primary$ae_orig$sd, primary$ae_opt$sd),
    stringsAsFactors = FALSE
  )
  ae_inf <- data.frame(
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
  )
  write_table_csv_docx(
    ae_df, "study1_table_ae_descriptives",
    "Study 1: Absolute error descriptives by Condition (averaged across K)",
    c(paste0("N = ", n, ". SAP §3.3.2.")),
    log_path
  )
  write_table_csv_docx(
    ae_inf, "study1_table_ae",
    "Study 1: Paired t-test of mean absolute error (Optimized − Original)",
    c(paste0("N = ", n, ". SAP §3.3.2. Q7: AE stays the paired t-test.")),
    log_path
  )

  write_table_csv_docx(
    ae_k, "study1_table_ae_by_k_desc",
    "Study 1: Descriptive absolute error by Condition × K (no inferential test)",
    c(paste0("N = ", n, ". Q14 / Brief §8.2: mean, SD, 95% CI only. No test by K.")),
    log_path
  )

  se_df <- data.frame(
    condition = c("Original", "Optimized"),
    n = n,
    mean_signed_error = c(primary$se_orig$mean, primary$se_opt$mean),
    sd_signed_error = c(primary$se_orig$sd, primary$se_opt$sd),
    stringsAsFactors = FALSE
  )
  write_table_csv_docx(
    se_df, "study1_table_signed_error",
    "Study 1: Signed error descriptives by Condition (no inferential test)",
    c(
      paste0("N = ", n, ". SAP §3.3.3. Negative = underestimation; positive = overestimation."),
      "No hypothesis test was prespecified."
    ),
    log_path
  )

  write_table_csv_docx(
    pw_rt, "study1_table_pairwise_rt_desc",
    "Study 1: Pairwise-task response time (descriptive only)",
    c(paste0("N = ", n, ". SAP §3.3.1: pairwise RT remains descriptive.")),
    log_path
  )

  if (nrow(vision_tab) > 0L) {
    write_table_csv_docx(
      data.frame(
        Analysis = vision_tab$analysis,
        N = vision_tab$n,
        Statistic = fmt_num(vision_tab$statistic, 3),
        p = fmt_p(vision_tab$p),
        `Effect size` = fmt_num(vision_tab$effect_size, 3),
        `ES name` = vision_tab$es_name,
        `Agrees with primary` = ifelse(vision_tab$sig_agrees_with_primary, "Yes", "No"),
        check.names = FALSE,
        stringsAsFactors = FALSE
      ),
      "study1_table_vision_sensitivity",
      "Study 1: Vision-screen sensitivity (legacy; not primary when vision rule applies)",
      c("Score = 4 subset only. Skipped when primary Ishihara 4/4 rule applies."),
      log_path
    )
  } else {
    log_msg(log_path, "study1_table_vision_sensitivity skipped (primary vision rule).")
  }
}

write_study1_figure_captions <- function(log_path) {
  if (!exists("STUDY1_ACCURACY_FIGURE_CAPTION", inherits = TRUE)) {
    source(file.path(PROJECT_ROOT, "R", "utils_figures_study1.R"), local = FALSE)
  }
  ensure_output_dirs()
  path <- file.path(OUTPUT_LOGS, paste0("study1_figure_captions", OUTPUT_SUFFIX, ".txt"))
  lines <- c(
    paste0("study1_fig_accuracy_condition_k: ", STUDY1_ACCURACY_FIGURE_CAPTION),
    paste0("study1_fig_ae_condition_k: ", STUDY1_AE_FIGURE_CAPTION),
    "study1_fig_pairwise_prop: Participant-level Optimized choice proportions; mean with 95% CI.",
    "study1_fig_rt_by_condition: Mean response time (ms) by condition with 95% CIs."
  )
  writeLines(lines, path)
  log_msg(log_path, "wrote ", basename(path))
  path
}

write_study1_figures <- function(disc, pw, h3, rt_ms, log_path) {
  source(file.path(PROJECT_ROOT, "R", "utils_figures_study1.R"), local = FALSE)
  pal <- study1_palette(log_path)
  save_report_figure(
    plot_study1_accuracy_panels(disc, pal),
    "study1_fig_accuracy_condition_k", 10, 4.5, log_path
  )
  save_report_figure(
    plot_study1_ae_by_k(disc, pal),
    "study1_fig_ae_condition_k", 7, 4.5, log_path
  )
  save_report_figure(
    plot_study1_h3_stacked_dots(pw, h3, pal),
    "study1_fig_pairwise_prop", 7, 3.5, log_path
  )
  save_report_figure(
    plot_study1_rt_by_condition(rt_ms, pal),
    "study1_fig_rt_by_condition", 5.5, 4.5, log_path
  )
  write_study1_figure_captions(log_path)
}
