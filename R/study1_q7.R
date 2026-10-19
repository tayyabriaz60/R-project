# Q7: diagnostics first; test path open until client review (Oct 2026).

source(file.path(PROJECT_ROOT, "R", "utils_logging.R"))
source(file.path(PROJECT_ROOT, "R", "utils_paths.R"))

save_vector_hist <- function(x, name, main, xlab, log_path) {
  ensure_output_dirs()
  path <- file.path(OUTPUT_FIGURES, paste0(name, OUTPUT_SUFFIX, ".png"))
  grDevices::png(filename = path, width = 5, height = 4, units = "in", res = 150)
  graphics::hist(as.numeric(x), main = main, xlab = xlab, col = "grey80", border = "grey30")
  grDevices::dev.off()
  log_msg(log_path, "wrote diagnostic ", basename(path))
  path
}

save_assumption_hists <- function(summary_df, log_path, file_prefix = "study1") {
  p_h1 <- save_vector_hist(
    summary_df$acc_Optimized - summary_df$acc_Original,
    paste0(file_prefix, "_diag_h1_opt_minus_orig"),
    "H1 Optimized-Original accuracy (diagnostic)",
    "difference",
    log_path
  )
  k_levels <- as.integer(SAP$k_levels_study1)
  h2_pool <- unlist(lapply(k_levels, function(k) {
    summary_df[[paste0("acc_diff_K", k)]]
  }))
  p_h2 <- save_vector_hist(
    h2_pool,
    paste0(file_prefix, "_diag_h2_opt_minus_orig_by_k"),
    "H2 Opt-Orig accuracy diffs by K (diagnostic)",
    "difference",
    log_path
  )
  p_h3 <- save_vector_hist(
    summary_df$pairwise_prop_optimized,
    paste0(file_prefix, "_diag_h3_prop"),
    "H3 Optimized-choice proportion (diagnostic)",
    "proportion",
    log_path
  )
  rt_diff <- summary_df$mean_rt_analysis_Optimized - summary_df$mean_rt_analysis_Original
  p_rt <- save_vector_hist(
    rt_diff,
    paste0(file_prefix, "_diag_rt_diff"),
    "RT Optimized-Original on analysis scale (diagnostic)",
    "difference",
    log_path
  )
  ae_diff <- summary_df$mean_ae_Optimized - summary_df$mean_ae_Original
  p_ae <- save_vector_hist(
    ae_diff,
    paste0(file_prefix, "_diag_ae_diff"),
    "AE Optimized-Original (diagnostic)",
    "difference",
    log_path
  )
  c(p_h1, p_h2, p_h3, p_rt, p_ae)
}

save_study1_assumption_hists <- function(summary_df, log_path) {
  save_assumption_hists(summary_df, log_path, "study1")
}

write_q7_client_report <- function(diag_files, log_path) {
  ensure_output_dirs()
  path <- output_log_path("study1_q7_fallback_review")
  label <- if (identical(DATA_SOURCE, "synthetic")) {
    "SYNTHETIC DATA: pipeline test only. These plots are for pipeline testing, not findings."
  } else {
    "Real-data run."
  }
  rd <- as.integer(SAP$study1_rank_diff_round_digits)
  locked <- isTRUE(SAP$q7_path_locked)
  if (locked) {
    lines <- c(
      "STUDY 1 — Q7 locked mixed analysis path (Oct 2026)",
      paste("time:", as.character(Sys.time())),
      paste("R.version.string:", R.version.string),
      label,
      "",
      "Primary sample: N = 48 after researcher exclusion and Ishihara 4/4 + questionnaire pass.",
      "",
      "Recommendation basis (SAP §3.1 fallback; same principles as Study 2 Q32):",
      "- H1/H2 decision used participant-level Optimized-Original difference scores",
      "  (study1_diag_h1_opt_minus_orig, study1_diag_h2_opt_minus_orig_by_k), not raw accuracy",
      "  cell histograms alone. Cell plots show ceiling/bimodality at some K (especially K=30);",
      "  difference-score plots show discrete spikes and mass near zero — rank-based tests fit SAP fallback.",
      "- H3: one-sample t vs 0.50 (Study 2 mixed path); proportion diagnostic is skewed but t on",
      "  the mean proportion with Cohen's d is the agreed parametric H3 for this mixed path.",
      "- RT/AE: paired t on the Q12 analysis scale (RT diff diagnostic on analysis scale is unimodal).",
      "",
      "Locked tests:",
      "- H1: paired Wilcoxon signed-rank on Optimized minus Original accuracy.",
      "- H2: Friedman on Optimized minus Original difference scores across K;",
      "  if Friedman p < alpha, Holm-adjusted pairwise Wilcoxon follow-ups on K-difference contrasts.",
      "- H3: two-sided one-sample t-test of Optimized-choice proportion vs 0.50.",
      "- RT / AE: paired t-tests.",
      "",
      paste0(
        "Rank-based inputs: difference scores rounded to ", rd,
        " decimals before Wilcoxon/Friedman. Q10 zero handling unchanged."
      ),
      "",
      "Diagnostic plots reviewed for this lock:",
      paste0("- ", basename(diag_files)),
      "",
      "Q30 colours and Q31 duplicate key remain as confirmed earlier."
    )
    log_suffix <- " path_locked=TRUE q7_mixed_study2_aligned"
    msg <- "Q7: Study 1 mixed path locked (Wilcoxon/Friedman + t)."
  } else {
    lines <- c(
      "STUDY 1 — Q7 path (open pending diagnostic review)",
      paste("time:", as.character(Sys.time())),
      paste("R.version.string:", R.version.string),
      label,
      "",
      "Awaiting diagnostic review before locking H1-H3 tests.",
      "",
      "Diagnostic plots from this run:",
      paste0("- ", basename(diag_files)),
      ""
    )
    log_suffix <- " path_locked=FALSE"
    msg <- "Q7: Study 1 test path open pending diagnostic review."
  }
  writeLines(lines, path)
  log_msg(log_path, "Q7 report written: ", basename(path), log_suffix)
  message(msg)
  path
}
