# Q7: write diagnostics, then run the locked path (no auto-cutoff).
# Locked 22 Sep 2026: H1 Wilcoxon, H2 Friedman, H3 Wilcoxon; RT/AE paired t.

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

save_study1_assumption_hists <- function(summary_df, log_path) {
  p_h3 <- save_vector_hist(
    summary_df$pairwise_prop_optimized,
    "study1_diag_h3_prop",
    "H3 Optimized-choice proportion (diagnostic)",
    "proportion",
    log_path
  )
  rt_diff <- summary_df$mean_rt_analysis_Optimized - summary_df$mean_rt_analysis_Original
  p_rt <- save_vector_hist(
    rt_diff,
    "study1_diag_rt_diff",
    "RT Optimized-Original on analysis scale (diagnostic)",
    "difference",
    log_path
  )
  ae_diff <- summary_df$mean_ae_Optimized - summary_df$mean_ae_Original
  p_ae <- save_vector_hist(
    ae_diff,
    "study1_diag_ae_diff",
    "AE Optimized-Original (diagnostic)",
    "difference",
    log_path
  )
  c(p_h3, p_rt, p_ae)
}

write_q7_client_report <- function(diag_files, log_path) {
  ensure_output_dirs()
  path <- output_log_path("study1_q7_fallback_review")
  label <- if (identical(DATA_SOURCE, "synthetic")) {
    "SYNTHETIC DATA: pipeline test only. These plots are for pipeline testing, not findings."
  } else {
    "Real-data run."
  }
  lines <- c(
    "STUDY 1 — Q7 path (locked 22 Sep 2026)",
    paste("time:", as.character(Sys.time())),
    paste("R.version.string:", R.version.string),
    label,
    "",
    "No new numerical cutoff was invented. The path below was locked after",
    "Fatimah reviewed the real-data diagnostic plots and Tayyab agreed.",
    "",
    "Locked tests:",
    "- H1: paired Wilcoxon signed-rank, overall Original vs Optimized accuracy.",
    "- H2: Friedman test on Optimized-Original accuracy differences at K = 5, 10, 20, 30.",
    "  Pairwise Wilcoxon on those difference scores, Holm x 6, only if Friedman is significant.",
    "- H3: one-sample Wilcoxon of Optimized-choice proportion vs 0.50.",
    "- RT: paired t-test on the Q12 analysis scale (log if trial-level skewness > 1).",
    "- AE: paired t-test.",
    "- Vision-screen subset (N = 48): the same tests. Primary N stays 50.",
    "",
    "Q10: exact-zero paired differences are omitted; n_nonzero is reported.",
    "",
    "Diagnostic plots from this run:",
    paste0("- ", basename(diag_files)),
    "",
    "Q30 colours and Q31 duplicate key remain as confirmed earlier."
  )
  writeLines(lines, path)
  log_msg(log_path, "Q7 report written: ", basename(path), " path_locked=TRUE")
  message("Q7: locked path will be used (H1/H2/H3 npar; RT/AE t).")
  path
}
