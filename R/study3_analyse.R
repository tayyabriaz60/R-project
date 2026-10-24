# Study 3 primary analysis. SAP §5.

source(file.path(PROJECT_ROOT, "R", "study3_models.R"))
source(file.path(PROJECT_ROOT, "R", "study3_export.R"))
source(file.path(PROJECT_ROOT, "R", "study3_q7.R"))
source(file.path(PROJECT_ROOT, "R", "utils_figures_study3.R"))
source(file.path(PROJECT_ROOT, "R", "utils_output_manifest.R"))
run_study3_analyse <- function(study3, study3_prep) {
  ensure_output_dirs()
  log_path <- output_log_path("study3_log_analysis")
  an_title <- if (identical(DATA_SOURCE, "synthetic")) {
    "STUDY 3 ANALYSIS (aggregates only; SYNTHETIC DATA: pipeline test only)"
  } else {
    "STUDY 3 ANALYSIS (aggregates only; real export; no participant IDs in this log)"
  }
  start_log(log_path, an_title)

  summaries <- study3_prep$summaries
  disc <- study3$discrimination
  pw <- study3$pairwise
  extra_diag <- save_study3_assumption_hists(summaries, log_path)
  q7_path <- write_study3_q7_report(extra_diag, log_path)
  log_effectsize_versions(log_path)

  norm <- study3_severe_nonnormality_flag(summaries, log_path)
  use_fallback <- if (!is.null(SAP$study3_accuracy_pairwise_use_fallback) &&
      !is.na(SAP$study3_accuracy_pairwise_use_fallback)) {
    isTRUE(SAP$study3_accuracy_pairwise_use_fallback)
  } else {
    any(norm$severe)
  }
  if (isTRUE(SAP$study3_inferential_path_locked) && use_fallback) {
    log_msg(log_path, "study3_inferential_path_locked=TRUE overrides fallback; using parametric path.")
    use_fallback <- FALSE
  }

  hold_inferential <- identical(DATA_SOURCE, "real") && isTRUE(SAP$study3_q_hold_inferential)
  if (hold_inferential) {
    log_msg(log_path, "study3_q_hold_inferential=TRUE: inferential tables skipped on real data.")
    write_study3_figures(disc, pw, summaries, log_path)
    write_study3_output_manifest(log_path)
    message("run_study3_analyse finished. Real-data inferential hold.")
    return(list(q7_path = q7_path, log_path = log_path, hold = TRUE))
  }

  acc_tests <- run_study3_accuracy_tests(summaries, log_path, use_fallback = use_fallback)
  pw_tests <- run_study3_pairwise_tests(summaries, log_path, use_fallback = use_fallback)
  rt_tests <- run_study3_rt_tests(summaries, log_path)
  ae_test <- run_study3_ae_test(summaries, log_path)

  write_study3_tables(summaries, disc, acc_tests, pw_tests, rt_tests, ae_test, log_path)
  write_study3_figures(disc, pw, summaries, log_path)
  write_study3_output_manifest(log_path)

  log_msg(log_path, "ANALYSIS COMPLETE.")
  message("run_study3_analyse finished.")
  list(
    accuracy = acc_tests,
    pairwise = pw_tests,
    rt = rt_tests,
    ae = ae_test,
    q7_path = q7_path,
    log_path = log_path
  )
}
