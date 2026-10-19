# Study 3 assumption / fallback review note.

source(file.path(PROJECT_ROOT, "R", "study1_q7.R"))

save_study3_assumption_hists <- function(summary_df, log_path) {
  p1 <- save_vector_hist(
    summary_df$acc_diff_h4,
    "study3_diag_h4_opt_minus_orig",
    "H4 Optimized-Original accuracy (diagnostic)",
    "difference",
    log_path
  )
  p2 <- save_vector_hist(
    summary_df$acc_diff_h5_white_minus_black,
    "study3_diag_h5_white_minus_black_diff",
    "H5 White-Black Opt-Orig diff (diagnostic)",
    "difference",
    log_path
  )
  p3 <- save_vector_hist(
    summary_df$pairwise_prop_optimized,
    "study3_diag_h6_prop",
    "H6 pairwise Optimized proportion (diagnostic)",
    "proportion",
    log_path
  )
  c(p1, p2, p3)
}

write_study3_q7_report <- function(diag_files, log_path) {
  ensure_output_dirs()
  path <- output_log_path("study3_q7_fallback_review")
  label <- if (identical(DATA_SOURCE, "synthetic")) {
    "SYNTHETIC DATA: pipeline test only."
  } else {
    "Real-data run."
  }
  locked <- isTRUE(SAP$study3_inferential_path_locked)
  hold <- isTRUE(SAP$study3_q_hold_inferential)
  lines <- c(
    "STUDY 3 — accuracy / pairwise assumption review",
    paste("time:", as.character(Sys.time())),
    label,
    "",
    "Primary sample: researcher excluded at load; Ishihara 4/4 (+ questionnaire on real).",
    "Synthetic expected N=46 after Ishihara-only exclusion.",
    "Real expected N=46 after Ishihara + questionnaire.",
    "",
    if (locked) {
      c(
        "LOCKED PATH (Oct 2026 real diagnostics, N=46):",
        "  H4/H5: 2x2 RM-ANOVA (Condition x Background accuracy cells).",
        "  H6/H7: one-sample t vs 0.50; paired t White vs Black proportions.",
        "  RT: 2x2 RM-ANOVA on log RT when trial skew > 1.",
        "  AE: paired t Optimized - Original.",
        "  Wilcoxon fallbacks NOT selected (|skew| well below severe flag |skew|>2).",
        "  See docs/STUDY3_Q7_RECOMMENDATION.md.",
        ""
      )
    } else {
      c(
        "Parametric path: 2x2 RM ANOVA on Condition x Background accuracy cells (H4/H5).",
        "Fallback: H4 Wilcoxon on overall Opt-Orig accuracy; H5 Wilcoxon on White-Black Opt-Orig diff.",
        "H6/H7: one-sample and paired t on pairwise proportions; Wilcoxon fallbacks if |skew|>2.",
        ""
      )
    },
    paste0("study3_q_hold_inferential=", hold),
    paste0("study3_inferential_path_locked=", locked),
    "",
    "Diagnostic plots:",
    paste0("- ", basename(diag_files))
  )
  writeLines(lines, path)
  log_msg(log_path, "Study3 Q7 note written: ", basename(path))
  path
}
