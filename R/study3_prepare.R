# Study 3 prepare. Vision primary, dedup, gates, summaries.

source(file.path(PROJECT_ROOT, "R", "study3_clean.R"))
source(file.path(PROJECT_ROOT, "R", "study3_gates.R"))
source(file.path(PROJECT_ROOT, "R", "study3_summarise.R"))
source(file.path(PROJECT_ROOT, "R", "study3_vision_primary.R"))
run_study3_prepare <- function(study3) {
  ensure_output_dirs()
  log_path <- output_log_path("study3_log_prepare")
  prep_title <- if (identical(DATA_SOURCE, "synthetic")) {
    "STUDY 3 PREPARE (aggregates only; SYNTHETIC DATA: pipeline test only)"
  } else {
    "STUDY 3 PREPARE (aggregates only; real export; no participant IDs in this log)"
  }
  start_log(log_path, prep_title)
  log_msg(log_path, "SAP §5.4: researcher excluded at load; vision primary in prepare.")

  study3 <- apply_study3_vision_primary_exclusions(study3, log_path)
  n_id <- n_unique_nonempty(study3$discrimination$participant_id)
  log_msg(log_path, "primary n_unique_participant_id=", n_id)

  study3 <- apply_study3_q31_dedup(study3, log_path)
  disc <- study3$discrimination
  pw <- study3$pairwise
  gate_study3_pairwise_mapping_q3(pw, log_path)
  gate_study3_incomplete_cells_q4(disc, pw, log_path)

  summaries <- summarise_study3_participants(disc, pw, log_path)
  sum_path <- file.path(OUTPUT_TABLES, paste0("study3_participant_summaries", OUTPUT_SUFFIX, ".csv"))
  if ("participant_id" %in% names(summaries)) {
    stop("Refusing to write summaries with participant_id.", call. = FALSE)
  }
  write_qc_csv(summaries, sum_path)
  log_msg(log_path, "wrote ", basename(sum_path))

  list(
    study3 = study3,
    summaries = summaries,
    log_path = log_path
  )
}
