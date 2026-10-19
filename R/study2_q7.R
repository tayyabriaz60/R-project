# Study 2 Q7 / Q32 path note. Locked mixed path Oct 2026.

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
  rd <- as.integer(SAP$study2_rank_diff_round_digits)
  lines <- c(
    "STUDY 2 — Q32 locked mixed analysis path",
    paste("time:", as.character(Sys.time())),
    paste("R.version.string:", R.version.string),
    label,
    "",
    "Client confirmation (Oct 2026): Study 2 does not inherit the Study 1 all-npar lock.",
    "Locked tests for the primary sample:",
    "- H1: paired Wilcoxon signed-rank on participant-level Optimized minus Original accuracy.",
    "- H2: Friedman on Optimized minus Original accuracy difference scores across K;",
    "  if Friedman p < alpha, Holm-adjusted pairwise Wilcoxon follow-ups on K-difference contrasts.",
    "- H3: two-sided one-sample t-test of Optimized-choice proportion vs 0.50.",
    "- RT: paired t-test on the Q12 analysis scale (log or ms as flagged in the prepare log).",
    "- AE: paired t-test.",
    "",
    "Fallback rationale (for thesis text): base the H1/H2 choice mainly on the participant-level",
    "difference-score diagnostic histograms (h1_opt_minus_orig, h2_opt_minus_orig_by_k) and the",
    "SAP §3.1/§4.1 fallback rules — not on raw accuracy cell histograms alone.",
    "",
    paste0(
      "Rank-based inputs: Optimized-Original difference scores are rounded to ",
      rd,
      " decimal places before Wilcoxon/Friedman so float representations of values such as 1/3 ",
      "do not split ranks. Q10 exact-zero pairs are still omitted before ranking."
    ),
    "",
    "Primary sample: researcher excluded at load; Ishihara 4/4 plus questionnaire pass (real data).",
    "Expected real primary N = 42 after vision exclusions (verify in prepare/analysis logs).",
    "",
    "Diagnostic plots from this run:",
    paste0("- ", basename(diag_files)),
    "",
    "Q30 colours and Q31 duplicate key remain as confirmed for Study 1."
  )
  writeLines(lines, path)
  log_msg(log_path, "Q7/Q32 report written: ", basename(path), " path_locked=TRUE q32_mixed")
  message("Q7: Study 2 Q32 mixed path locked (Wilcoxon/Friedman + t).")
  path
}
