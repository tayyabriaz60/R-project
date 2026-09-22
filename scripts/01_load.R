# SUPERSEDED by R/study1_load.R (Chunk B). Kept for review only. Do not source this.
# Reads raw Gorilla-style CSVs. Does not derive analysis variables.
# Blocked (not done here): Object Name row filters (Q5), participant_id choice (Q6),
# exclusions (Q2, Q18), pairwise mapping (Brief §4).

if (!exists("OUTPUT_LOGS") || !exists("DATA_SOURCE") || !exists("SYNTHETIC_FILES")) {
  stop("Source config/config.R before scripts/01_load.R", call. = FALSE)
}

source(file.path(PROJECT_ROOT, "R", "utils_io.R"))
source(file.path(PROJECT_ROOT, "R", "utils_load.R"))

load_log <- file.path(OUTPUT_LOGS, paste0("study_all_log_load", OUTPUT_SUFFIX, ".txt"))
start_log(load_log, "LOAD SUMMARY (counts only; SYNTHETIC DATA: pipeline test only if synthetic)")

# SUPERSEDED. Real + synthetic Study 1 load is R/study1_load.R via run_all.R.
if (!identical(DATA_SOURCE, "synthetic")) {
  stop(
    "scripts/01_load.R is superseded. Use run_all.R (R/study1_load.R) for real exports.",
    call. = FALSE
  )
}

if (!dir.exists(DATA_DIR)) {
  stop("Data directory does not exist for DATA_SOURCE=", DATA_SOURCE, call. = FALSE)
}

study1_g1 <- load_one_csv(
  SYNTHETIC_FILES$study1_disc_g1, STUDY1_DISC_REQUIRED, "study1_disc_g1", load_log
)
study1_g2 <- load_one_csv(
  SYNTHETIC_FILES$study1_disc_g2, STUDY1_DISC_REQUIRED, "study1_disc_g2", load_log
)
study1_disc <- rbind(study1_g1, study1_g2)
log_count(load_log, "study1_disc rows_combined", nrow(study1_disc))
check_synthetic_n(nrow(study1_disc), SYNTHETIC_EXPECTED_AFTER_BLANK$study1_disc, "study1_disc", load_log)

study1_pairwise <- load_one_csv(
  SYNTHETIC_FILES$study1_pairwise, STUDY1_PAIRWISE_REQUIRED, "study1_pairwise", load_log
)
check_synthetic_n(nrow(study1_pairwise), SYNTHETIC_EXPECTED_AFTER_BLANK$study1_pairwise, "study1_pairwise", load_log)

study1_vision <- load_one_csv(
  SYNTHETIC_FILES$study1_vision, STUDY1_VISION_REQUIRED, "study1_vision", load_log
)
check_synthetic_n(nrow(study1_vision), SYNTHETIC_EXPECTED_AFTER_BLANK$study1_vision, "study1_vision", load_log)

study2_tasks <- load_one_csv(
  SYNTHETIC_FILES$study2_tasks, STUDY2_REQUIRED, "study2_tasks", load_log
)
check_synthetic_n(nrow(study2_tasks), SYNTHETIC_EXPECTED_AFTER_BLANK$study2_tasks, "study2_tasks", load_log)

study3_tasks <- load_one_csv(
  SYNTHETIC_FILES$study3_tasks, STUDY3_REQUIRED, "study3_tasks", load_log
)
check_synthetic_n(nrow(study3_tasks), SYNTHETIC_EXPECTED_AFTER_BLANK$study3_tasks, "study3_tasks", load_log)

# Do not write participant-level tables to disk (Rules §3). Later chunks re-read CSVs.
append_log(load_log, "LOAD COMPLETE (no hypothesis tests were run; no participant-level files written)")
message("LOAD COMPLETE (no hypothesis tests were run)")
