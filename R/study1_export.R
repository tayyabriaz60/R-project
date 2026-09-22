# Q13 / Q14 tables (.csv + .docx) and report figures (.png 300 dpi + .pdf).
# Q30 colours confirmed: Original #E69F00, Optimized #0072B2.

source(file.path(PROJECT_ROOT, "R", "utils_paths.R"))
source(file.path(PROJECT_ROOT, "R", "utils_io.R"))
source(file.path(PROJECT_ROOT, "R", "utils_logging.R"))
source(file.path(PROJECT_ROOT, "R", "utils_format.R"))

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
  ggplot2::ggsave(png_path, plot, width = width_in, height = height_in, dpi = 300, units = "in")
  ggplot2::ggsave(pdf_path, plot, width = width_in, height = height_in, device = "pdf")
  log_msg(log_path, "wrote ", basename(png_path), " and ", basename(pdf_path))
  c(png_path, pdf_path)
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
  notes_acc <- c(
    paste0("N = ", n, " (primary population; SAP §3.4)."),
    "SAP §3.1: accuracy is the mean of 3 configuration instances within each Condition × K cell.",
    "Q7 locked path (real-data diagnostics, 22 Sep 2026): H1 paired Wilcoxon; H2 Friedman on Opt-Orig diffs by K.",
    "H3 one-sample Wilcoxon vs 0.50. RT and AE stay paired t-tests. Vision subset uses the same tests.",
    "Q10: exact-zero paired differences omitted; n_nonzero reported. Holm only on H2 Friedman follow-ups (if run).",
    "SAP §3.4: K = 30 is retained; palette-capacity limits are a reporting caveat, not an exclusion."
  )
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
    desc, "study1_table_accuracy_descriptives",
    "Study 1: Mean participant-level accuracy by Condition",
    notes_acc, log_path
  )

  h1 <- primary$h1
  h1_df <- data.frame(
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
  )
  write_table_csv_docx(
    h1_df, "study1_table_h1_wilcoxon",
    "Study 1: H1 paired Wilcoxon signed-rank test (Optimized vs Original accuracy)",
    notes_acc, log_path
  )

  h2 <- primary$h2
  h2_df <- data.frame(
    hypothesis = "H2_Condition_x_K",
    test = "friedman_opt_minus_orig_by_K",
    n = h2$n,
    n_k = h2$n_k,
    chi_squared = h2$statistic,
    df = h2$df,
    p = h2$p,
    kendalls_w = h2$kendalls_w,
    w_ci_low = h2$w_ci_low,
    w_ci_high = h2$w_ci_high,
    stringsAsFactors = FALSE
  )
  write_table_csv_docx(
    h2_df, "study1_table_h2_friedman",
    "Study 1: H2 Friedman test of Optimized-Original accuracy differences across K",
    notes_acc, log_path
  )

  if (isTRUE(primary$follow$ran) && nrow(primary$follow$rows) > 0L) {
    write_table_csv_docx(
      primary$follow$rows, "study1_table_h2_followups",
      "Study 1: H2 Friedman follow-up pairwise Wilcoxon tests on K-difference scores",
      c(notes_acc, "Six pairwise Wilcoxon tests on Opt-Orig diffs between K levels. Holm within this family."),
      log_path
    )
  } else {
    note_df <- data.frame(
      followups_run = FALSE,
      reason = primary$follow$reason,
      stringsAsFactors = FALSE
    )
    write_table_csv_docx(
      note_df, "study1_table_h2_followups",
      "Study 1: H2 Friedman follow-ups not run",
      c(notes_acc, paste("Reason:", primary$follow$reason)),
      log_path
    )
  }

  h3 <- primary$h3
  h3_df <- data.frame(
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
  )
  write_table_csv_docx(
    h3_df, "study1_table_h3",
    "Study 1: H3 one-sample Wilcoxon test of Optimized-choice proportion vs 0.50",
    c(
      paste0("N = ", n, ". SAP §3.2 fallback; two-sided; 12 pairwise trials per participant."),
      "Interpretation: whether proportions tend to sit above or below 0.50 (not a test of the mean).",
      "Mean and t-style CI are descriptive only. Q10: exact ties at 0.50 omitted."
    ),
    log_path
  )

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

  write_table_csv_docx(
    vision_tab, "study1_table_vision_sensitivity",
    "Study 1: Vision-screen sensitivity (N = 48; not the primary analysis)",
    c(
      "SAP §3.4; Q1. Primary N remains 50. This table repeats H1–H3 on score = 4 only.",
      "Not merged with primary results. Same locked tests as primary (Wilcoxon / Friedman / Wilcoxon)."
    ),
    log_path
  )
}

write_study1_figures <- function(acc_cells, h3, rt_ms, ae_k, log_path) {
  pal <- study1_palette(log_path)
  cap <- paste0(
    "Palette: Original ", pal$Original, ", Optimized ", pal$Optimized,
    " (Q30). ", synthetic_note()
  )
  acc_cells$K <- factor(acc_cells$K, levels = as.integer(SAP$k_levels_study1))
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
      title = "Study 1: Accuracy by Condition × K (95% CI)",
      y = "Mean participant-level accuracy",
      x = "K",
      colour = "Condition",
      caption = cap
    ) +
    ggplot2::theme_bw()
  save_report_figure(p_acc, "study1_fig_accuracy_condition_k", 7, 4.5, log_path)

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
      title = "Study 1: Optimized-choice proportion (95% CI) vs 0.50",
      y = "Mean proportion",
      x = NULL,
      caption = cap
    ) +
    ggplot2::theme_bw()
  save_report_figure(p_pw, "study1_fig_pairwise_prop", 5, 4.5, log_path)

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
      title = "Study 1: Descriptive discrimination RT by Condition (ms)",
      y = "Mean RT (ms)",
      x = "Condition",
      caption = cap
    ) +
    ggplot2::theme_bw()
  save_report_figure(p_rt, "study1_fig_rt_by_condition", 5, 4.5, log_path)

  ae_k$K <- factor(ae_k$K, levels = as.integer(SAP$k_levels_study1))
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
      title = "Study 1: Descriptive absolute error by Condition × K (95% CI)",
      y = "Mean absolute error",
      x = "K",
      colour = "Condition",
      caption = cap
    ) +
    ggplot2::theme_bw()
  save_report_figure(p_ae, "study1_fig_ae_condition_k", 7, 4.5, log_path)
}
