# Researcher session exclusion (SAP §3.4 / §4.4). Shared by Study 1 and Study 2.

source(file.path(PROJECT_ROOT, "R", "utils_logging.R"))

study_researcher_ids <- function(study) {
  study <- match.arg(study, c("study1", "study2"))
  if (identical(study, "study1")) {
    if (identical(DATA_SOURCE, "synthetic")) {
      ids <- SAP$study1_researcher_ids_synthetic
      if (length(ids) != 1L || is.na(ids) || !nzchar(ids)) {
        stop("Synthetic Study 1 researcher ID is missing from config.", call. = FALSE)
      }
      return(ids)
    }
    ids <- SAP$study1_researcher_ids_real
  } else {
    if (identical(DATA_SOURCE, "synthetic")) {
      ids <- SAP$study2_researcher_ids_synthetic
      if (length(ids) != 1L || is.na(ids) || !nzchar(ids)) {
        stop("Synthetic Study 2 researcher ID is missing from config.", call. = FALSE)
      }
      return(ids)
    }
    ids <- SAP$study2_researcher_ids_real
  }
  if (length(ids) != 1L || is.na(ids) || !nzchar(trimws(as.character(ids)))) {
    stop(
      "Real ", study, " researcher identifier is not set. Cannot exclude the researcher session.",
      call. = FALSE
    )
  }
  as.character(ids)
}

drop_study_researcher <- function(df, study, file_label, log_path = NULL) {
  ids <- study_researcher_ids(study)
  n0 <- nrow(df)
  hit <- df$participant_id %in% ids
  n_id <- length(unique(df$participant_id[hit]))
  if (n_id == 0L) {
    if (identical(study, "study1") && identical(DATA_SOURCE, "synthetic") &&
        isTRUE(SAP$study1_researcher_skip_if_unmatched_synthetic)) {
      if (!is.null(log_path)) {
        log_msg(
          log_path, file_label,
          " researcher exclusion skipped (synthetic has no token; pipeline N unchanged)."
        )
      }
      return(df)
    }
    stop(
      file_label, ": researcher exclusion matched 0 participant_id values. ",
      if (identical(DATA_SOURCE, "synthetic")) {
        "Synthetic expected one researcher session."
      } else {
        "Set the real researcher Public ID in config."
      },
      call. = FALSE
    )
  }
  if (n_id > 1L) {
    stop(
      file_label, ": researcher exclusion matched ", n_id,
      " participant_id values; expected exactly 1.",
      call. = FALSE
    )
  }
  out <- df[!hit, , drop = FALSE]
  if (!is.null(log_path)) {
    log_n_flow(log_path, paste0(file_label, "_researcher_exclude"), n0, nrow(out))
    log_msg(log_path, file_label, " researcher_n_ids_matched=", n_id)
  }
  out
}
