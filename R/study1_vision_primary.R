# Study 1 primary vision exclusions (aligned with Study 2, Oct 2026).
# Ishihara 4/4 AND questionnaire normal/corrected-to-normal vision.

source(file.path(PROJECT_ROOT, "R", "utils_logging.R"))

study1_ishihara_scores <- function(vis) {
  if (!"vision_item_correct" %in% names(vis)) {
    stop("vision_item_correct missing from Study 1 vision data.", call. = FALSE)
  }
  scores <- tapply(vis$vision_item_correct, vis$participant_id, sum, na.rm = TRUE)
  structure(as.integer(scores), names = names(scores))
}

resolve_study1_questionnaire_path <- function() {
  if (identical(DATA_SOURCE, "synthetic")) {
    return(NA_character_)
  }
  role <- "study1_questionnaire"
  explicit <- REAL_STUDY1_FILES[[role]]
  if (!is.null(explicit) && length(explicit) == 1L && !is.na(explicit) && nzchar(explicit)) {
    p <- explicit
    if (!file.exists(p)) {
      p <- file.path(DATA_DIR, explicit)
    }
    if (file.exists(p)) {
      return(p)
    }
    stop("Configured Study 1 questionnaire path not found.", call. = FALSE)
  }
  task_id <- REAL_STUDY1_TASK_IDS[[role]]
  if (is.null(task_id) || is.na(task_id) || !nzchar(task_id)) {
    stop(
      "Study 1 questionnaire task id is not configured (study1_questionnaire). ",
      "Set REAL_STUDY1_TASK_IDS$study1_questionnaire or REAL_STUDY1_FILES$study1_questionnaire.",
      call. = FALSE
    )
  }
  all_csv <- list.files(DATA_DIR, pattern = "\\.csv$", recursive = TRUE, full.names = TRUE)
  hits <- all_csv[grepl(task_id, basename(all_csv), fixed = TRUE)]
  if (length(hits) == 0L) {
    stop(
      "No questionnaire CSV under data/real/ matching '", task_id, "'. ",
      "Place the background questionnaire export there.",
      call. = FALSE
    )
  }
  if (length(hits) > 1L) {
    stop(
      "Several questionnaire CSVs match '", task_id, "'. ",
      "Set REAL_STUDY1_FILES$study1_questionnaire to the exact filename.",
      call. = FALSE
    )
  }
  hits[[1]]
}

read_study1_questionnaire_vision <- function(path) {
  raw <- utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
  id_col <- require_param("study1_id_column")
  gorilla_id <- if (id_col == "participant_public_id") {
    "Participant Public ID"
  } else if (id_col == "participant_private_id") {
    "Participant Private ID"
  } else {
    stop("Unsupported study1_id_column for questionnaire merge.", call. = FALSE)
  }
  if (!gorilla_id %in% names(raw)) {
    stop("Questionnaire CSV missing column: ", gorilla_id, call. = FALSE)
  }
  snippet <- require_param("study1_vision_question_snippet")
  resp_type <- raw[["Response Type"]]
  q_rows <- raw[
    grepl(snippet, raw$Question, fixed = TRUE) &
      resp_type == "response" &
      raw$Key == "value",
    ,
    drop = FALSE
  ]
  if (nrow(q_rows) == 0L) {
    stop("No vision questionnaire response rows found (Key=value).", call. = FALSE)
  }
  agg <- stats::aggregate(
    Response ~ get(gorilla_id),
    data = q_rows,
    FUN = function(x) {
      x <- unique(trimws(as.character(x)))
      x <- x[nzchar(x)]
      if (length(x) == 0L) {
        return(NA_character_)
      }
      if (length(x) > 1L) {
        return(paste(x, collapse = " | "))
      }
      x[[1]]
    }
  )
  names(agg) <- c("participant_id", "vision_question_response")
  agg
}

study1_questionnaire_fails_vision <- function(response) {
  excl <- require_param("study1_vision_questionnaire_exclude_pattern")
  if (is.na(response) || !nzchar(trimws(response))) {
    return(NA)
  }
  if (grepl(excl, response, fixed = TRUE)) {
    return(TRUE)
  }
  pass <- require_param("study1_vision_questionnaire_pass_pattern")
  if (grepl(pass, response, fixed = TRUE)) {
    return(FALSE)
  }
  NA
}

filter_study1_by_participants <- function(study1, keep_ids) {
  study1$discrimination <- study1$discrimination[
    study1$discrimination$participant_id %in% keep_ids,
    ,
    drop = FALSE
  ]
  study1$pairwise <- study1$pairwise[study1$pairwise$participant_id %in% keep_ids, , drop = FALSE]
  study1$vision <- study1$vision[study1$vision$participant_id %in% keep_ids, , drop = FALSE]
  study1
}

apply_study1_vision_primary_exclusions <- function(study1, log_path) {
  if (!isTRUE(SAP$study1_primary_vision_exclusion)) {
    log_msg(log_path, "study1_primary_vision_exclusion=FALSE; no vision-based primary filter.")
    return(study1)
  }

  if (identical(DATA_SOURCE, "synthetic")) {
    log_msg(
      log_path,
      "SYNTHETIC: questionnaire vision item not applied; Ishihara primary exclusion skipped for pipeline N=50."
    )
    log_msg(log_path, "Real data: Ishihara 4/4 + questionnaire pass required for primary inclusion.")
    return(study1)
  }

  disc <- study1$discrimination
  vis <- study1$vision
  all_ids <- sort(unique(disc$participant_id))
  scores <- study1_ishihara_scores(vis)
  score_df <- data.frame(
    participant_id = names(scores),
    ishihara_score = as.integer(scores),
    stringsAsFactors = FALSE
  )
  score_df$ishihara_pass <- score_df$ishihara_score == 4L

  q_path <- resolve_study1_questionnaire_path()
  log_msg(log_path, "questionnaire file resolved (basename only): ", basename(q_path))
  q_vis <- read_study1_questionnaire_vision(q_path)
  merged <- merge(
    data.frame(participant_id = all_ids, stringsAsFactors = FALSE),
    score_df,
    by = "participant_id",
    all.x = TRUE
  )
  merged <- merge(merged, q_vis, by = "participant_id", all.x = TRUE)
  merged$questionnaire_fail <- vapply(
    merged$vision_question_response,
    study1_questionnaire_fails_vision,
    logical(1)
  )

  n_missing_ishihara <- sum(is.na(merged$ishihara_score))
  n_missing_q <- sum(is.na(merged$vision_question_response) | !nzchar(trimws(merged$vision_question_response)))
  n_ambig_q <- sum(is.na(merged$questionnaire_fail) & !is.na(merged$vision_question_response) &
    nzchar(trimws(merged$vision_question_response)))
  n_conflict_q <- sum(grepl(" | ", merged$vision_question_response, fixed = TRUE))

  log_msg(log_path, "vision primary screen n_participants=", length(all_ids))
  log_msg(log_path, "vision primary n_missing_ishihara=", n_missing_ishihara)
  log_msg(log_path, "vision primary n_missing_questionnaire=", n_missing_q)
  log_msg(log_path, "vision primary n_ambiguous_questionnaire=", n_ambig_q)
  log_msg(log_path, "vision primary n_conflicting_questionnaire=", n_conflict_q)

  if (n_missing_ishihara > 0L || n_missing_q > 0L || n_ambig_q > 0L || n_conflict_q > 0L) {
    stop(
      "Study 1 vision primary exclusion: missing or ambiguous vision data. ",
      "missing_ishihara=", n_missing_ishihara,
      " missing_questionnaire=", n_missing_q,
      " ambiguous_questionnaire=", n_ambig_q,
      " conflicting_questionnaire=", n_conflict_q,
      ". Report to client before continuing.",
      call. = FALSE
    )
  }

  merged$exclude <- !merged$ishihara_pass | (merged$questionnaire_fail %in% TRUE)
  n_excl_ish <- sum(!merged$ishihara_pass, na.rm = TRUE)
  n_excl_q <- sum(merged$questionnaire_fail %in% TRUE, na.rm = TRUE)
  n_excl_both <- sum(!merged$ishihara_pass & (merged$questionnaire_fail %in% TRUE), na.rm = TRUE)
  keep <- merged$participant_id[!merged$exclude]
  log_msg(log_path, "vision primary exclude n_ishihara_below4=", n_excl_ish)
  log_msg(log_path, "vision primary exclude n_questionnaire_uncorrected=", n_excl_q)
  log_msg(log_path, "vision primary exclude n_both_criteria=", n_excl_both)
  log_msg(log_path, "vision primary n_included=", length(keep))
  log_msg(log_path, "vision_subset_applied_as_primary_exclusion=TRUE")

  filter_study1_by_participants(study1, keep)
}
