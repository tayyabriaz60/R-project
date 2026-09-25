# Study 2 prepare. SAP §4: same gates/summaries as Study 1 unless stated.
# Researcher already dropped at load (SAP §4.4). Difficulty is averaged in
# summarise (Condition × K cells). No standalone Difficulty model.

source(file.path(PROJECT_ROOT, "R", "study1_clean.R"))
source(file.path(PROJECT_ROOT, "R", "study1_gates.R"))
source(file.path(PROJECT_ROOT, "R", "study1_summarise.R"))
source(file.path(PROJECT_ROOT, "R", "study1_diagnostics.R"))

apply_study2_primary_population <- function(study2, log_path) {
  disc <- study2$discrimination
  n_id <- n_unique_nonempty(disc$participant_id)
  log_msg(log_path, "SAP §4.4 population: researcher excluded at load; no outcome-based exclusion")
  log_msg(log_path, "Q1 vision subset: not applied as a primary exclusion")
  log_msg(log_path, "primary n_unique_participant_id=", n_id,
          " (synthetic expected ", as.integer(SAP$primary_n_study2), ")")
  if (identical(DATA_SOURCE, "synthetic") && n_id != as.integer(SAP$primary_n_study2)) {
    stop("Study 2: synthetic primary N is not ", SAP$primary_n_study2, ".", call. = FALSE)
  }
  study2
}

write_study2_summaries <- function(summary_df) {
  ensure_output_dirs()
  path <- file.path(OUTPUT_TABLES, paste0("study2_participant_summaries", OUTPUT_SUFFIX, ".csv"))
  if ("participant_id" %in% names(summary_df) || "participant_public_id" %in% names(summary_df)) {
    stop("Refusing to write a summary table that still has a Gorilla ID column.", call. = FALSE)
  }
  write_qc_csv(summary_df, path)
  path
}

run_study2_prepare <- function(study2) {
  ensure_output_dirs()
  log_path <- output_log_path("study2_log_prepare")
  prep_title <- if (identical(DATA_SOURCE, "synthetic")) {
    "STUDY 2 PREPARE (aggregates only; SYNTHETIC DATA: pipeline test only)"
  } else {
    "STUDY 2 PREPARE (aggregates only; real export; no participant IDs in this log)"
  }
  start_log(log_path, prep_title)
  log_msg(log_path, "Prepare step only. H1-H3 / ES / Q13 figures run in analyse, not here.")
  log_msg(log_path, "SAP §4.1: accuracy averaged across 3 Difficulty instances within Condition x K.")
  log_msg(log_path, "No standalone Difficulty model (Brief §6.2).")

  study2 <- apply_study2_primary_population(study2, log_path)
  study2 <- apply_study1_q31_dedup(study2, log_path)
  disc <- study2$discrimination
  pw <- study2$pairwise
  vis <- study2$vision
  aud <- study2$duplicate_audit
  gate_pairwise_mapping_q3(pw, log_path)
  gate_incomplete_cells_q4(disc, pw, log_path)

  summaries <- summarise_study1_participants(disc, pw, log_path)
  sum_path <- write_study2_summaries(summaries)
  log_msg(log_path, "wrote ", basename(sum_path))

  diag_paths <- save_q8_histograms(
    summaries,
    log_path,
    "study2",
    "Q8 diagnostics saved. SAP recommended ANOVA/t run in analyse. Npar not applied (Q32)."
  )

  list(
    study2 = study2,
    duplicate_audit = aud,
    summaries = summaries,
    diagnostic_files = diag_paths,
    log_path = log_path
  )
}
