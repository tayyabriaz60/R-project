# Q7: diagnostics then STOP before any fallback. Do not auto-switch.
# Primary parametric tests may run after this report is written (SAP recommended path).
# Wilcoxon / Friedman / fallback ES are never called from here.

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

# Extra SAP diagnostics (not Q13 report figures).
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
    "STUDY 1 — Q7 fallback review (send this file + the diagnostic plots to Fatimah)",
    paste("time:", as.character(Sys.time())),
    paste("R.version.string:", R.version.string),
    label,
    "",
    "Q7 (your instruction): no new numerical cutoff. Generate the SAP-specified",
    "diagnostics, then STOP before switching to a fallback test. Do not auto-switch.",
    "",
    "What this run did NOT do:",
    "- Did not apply Wilcoxon signed-rank or Friedman tests.",
    "- Did not invent a skewness / Shapiro cutoff for ANOVA or t-tests.",
    "- Did not treat any histogram as a programmed switch.",
    "",
    "What this run will do after this report is written:",
    "- SAP §3.1 recommended path: 2 × 4 RM-ANOVA (H1 = Condition; H2 = Condition × K).",
    "- If H2 is significant: paired t at K = 5, 10, 20, 30, Holm on the estimable tests.",
    "- SAP §3.2: one-sample t of Optimized-choice proportion vs 0.50 (H3).",
    "- SAP §3.3.1–§3.3.2: paired t for RT (log scale; Q12) and AE; signed error stays descriptive.",
    "",
    "Please review these diagnostic plots before any fallback decision:",
    paste0("- ", basename(diag_files)),
    "",
    "Primary N = 50. Vision-screen sensitivity (N = 48) is a separate analysis,",
    "not a change of the primary population (SAP §3.4; Q1).",
    "",
    "If you want Wilcoxon / Friedman instead of the parametric tests, say so.",
    "Until you do, the reported Study 1 tests stay parametric.",
    "",
    "Q30 (figure colours) and Q31 (duplicate-trial key) are still open.",
    "They do not change this fallback question."
  )
  writeLines(lines, path)
  log_msg(log_path, "Q7 report written: ", basename(path), " fallback_applied=FALSE")
  message(
    "Q7: fallback NOT applied. Primary parametric path will be used. ",
    "Send ", basename(path), " and the diagnostic PNGs to Fatimah before any Wilcoxon/Friedman decision."
  )
  path
}
