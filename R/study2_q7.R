# Study 2 Q7 review note. SAP §4.1 recommended path. Q32 npar not applied.

source(file.path(PROJECT_ROOT, "R", "utils_logging.R"))
source(file.path(PROJECT_ROOT, "R", "utils_paths.R"))
source(file.path(PROJECT_ROOT, "R", "study1_q7.R"))

write_study2_q7_report <- function(diag_files, log_path) {
  ensure_output_dirs()
  path <- output_log_path("study2_q7_fallback_review")
  label <- if (identical(DATA_SOURCE, "synthetic")) {
    "SYNTHETIC DATA: pipeline test only. These plots are for pipeline testing, not findings."
  } else {
    "Real-data run."
  }
  lines <- c(
    "STUDY 2 — Q7 path (SAP recommended; npar not locked)",
    paste("time:", as.character(Sys.time())),
    paste("R.version.string:", R.version.string),
    label,
    "",
    "SAP §4.1: same recommended analyses as Study 1. This run uses that recommended path:",
    "- H1/H2: 2 x 4 repeated-measures ANOVA (Condition x K).",
    "- H3: two-sided one-sample t-test vs 0.50.",
    "- RT: paired t-test on the Q12 analysis scale.",
    "- AE: paired t-test.",
    "- Vision-screen subset (N = 43): the same tests. Primary N stays 50.",
    "",
    "No new numerical cutoff was invented. The Study 1 Wilcoxon/Friedman lock is",
    "NOT applied here (Q32). Send the diagnostic plots if you want a Study 2 lock.",
    "",
    "Diagnostic plots from this run:",
    paste0("- ", basename(diag_files)),
    "",
    "Q30 colours and Q31 duplicate key remain as confirmed for Study 1."
  )
  writeLines(lines, path)
  log_msg(log_path, "Q7 report written: ", basename(path), " path_locked=FALSE q32_npar_not_applied")
  message("Q7: SAP recommended ANOVA/t used. Study 1 npar lock not inherited (Q32).")
  path
}
