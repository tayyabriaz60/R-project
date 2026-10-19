# Study 3 vision primary exclusions. Real: Ishihara 4/4 + questionnaire. Synthetic: Ishihara only -> N=46.

source(file.path(PROJECT_ROOT, "R", "utils_logging.R"))

study3_ishihara_scores <- function(vis) {
  scores <- tapply(vis$vision_item_correct, vis$participant_id, sum, na.rm = TRUE)
  structure(as.integer(scores), names = names(scores))
}

resolve_study3_questionnaire_path <- function() {
  if (identical(DATA_SOURCE, "synthetic")) {
    return(NA_character_)
  }
  role <- "study3_questionnaire"
  explicit <- REAL_STUDY3_FILES[[role]]
  if (!is.null(explicit) && length(explicit) == 1L && !is.na(explicit) && nzchar(explicit)) {
    p <- explicit
    if (!file.exists(p)) {
      p <- file.path(DATA_DIR, explicit)
    }
    if (file.exists(p)) {
      return(p)
    }
    stop("Configured Study 3 questionnaire path not found.", call. = FALSE)
  }
  ids <- REAL_STUDY3_QUESTIONNAIRE_TASK_IDS
  if (length(ids) == 0L) {
    stop("Study 3 questionnaire task ids not configured.", call. = FALSE)
  }
  all_csv <- list.files(DATA_DIR, pattern = "\\.csv$", recursive = TRUE, full.names = TRUE)
  hits <- character(0)
  for (tid in ids) {
    hits <- c(hits, all_csv[grepl(tid, basename(all_csv), fixed = TRUE)])
  }
  hits <- unique(hits)
  if (length(hits) == 0L) {
    stop("No Study 3 questionnaire CSV found under data/real/.", call. = FALSE)
  }
  if (length(hits) > 1L) {
    stop(
      "Several questionnaire CSVs match Study 3 ids. Set REAL_STUDY3_FILES$study3_questionnaire.",
      call. = FALSE
    )
  }
  hits[[1]]
}

read_study3_questionnaire_vision <- function(path) {
  raw <- utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
  id_col <- require_param("study3_id_column")
  gorilla_id <- if (id_col == "participant_public_id") {
    "Participant Public ID"
  } else if (id_col == "participant_private_id") {
    "Participant Private ID"
  } else {
    stop("Unsupported study3_id_column for questionnaire merge.", call. = FALSE)
  }
  if (!gorilla_id %in% names(raw)) {
    stop("Questionnaire CSV missing column: ", gorilla_id, call. = FALSE)
  }
  snippet <- require_param("study3_vision_question_snippet")
  resp_type <- raw[["Response Type"]]
  q_rows <- raw[
    grepl(snippet, raw$Question, fixed = TRUE) &
      resp_type == "response" &
      raw$Key == "value",
    ,
    drop = FALSE
  ]
  if (nrow(q_rows) == 0L) {
    stop("No Study 3 vision questionnaire response rows found.", call. = FALSE)
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

study3_questionnaire_fails_vision <- function(response) {
  excl <- require_param("study3_vision_questionnaire_exclude_pattern")
  if (is.na(response) || !nzchar(trimws(response))) {
    return(NA)
  }
  if (grepl(excl, response, fixed = TRUE)) {
    return(TRUE)
  }
  pass <- require_param("study3_vision_questionnaire_pass_pattern")
  if (grepl(pass, response, fixed = TRUE)) {
    return(FALSE)
  }
  NA
}

filter_study3_by_participants <- function(study3, keep_ids) {
  study3$discrimination <- study3$discrimination[
    study3$discrimination$participant_id %in% keep_ids, , drop = FALSE
  ]
  study3$pairwise <- study3$pairwise[study3$pairwise$participant_id %in% keep_ids, , drop = FALSE]
  study3$vision <- study3$vision[study3$vision$participant_id %in% keep_ids, , drop = FALSE]
  study3
}

apply_study3_vision_primary_exclusions <- function(study3, log_path) {
  if (!isTRUE(SAP$study3_primary_vision_exclusion)) {
    log_msg(log_path, "study3_primary_vision_exclusion=FALSE; no vision filter.")
    return(study3)
  }

  disc <- study3$discrimination
  vis <- study3$vision
  all_ids <- sort(unique(disc$participant_id))
  scores <- study3_ishihara_scores(vis)
  score_df <- data.frame(
    participant_id = names(scores),
    ishihara_score = as.integer(scores),
    stringsAsFactors = FALSE
  )
  score_df$ishihara_pass <- score_df$ishihara_score == 4L

  merged <- merge(
    data.frame(participant_id = all_ids, stringsAsFactors = FALSE),
    score_df,
    by = "participant_id",
    all.x = TRUE
  )

  if (identical(DATA_SOURCE, "real")) {
    q_path <- resolve_study3_questionnaire_path()
    log_msg(log_path, "questionnaire file (basename)=", basename(q_path))
    q_vis <- read_study3_questionnaire_vision(q_path)
    merged <- merge(merged, q_vis, by = "participant_id", all.x = TRUE)
    merged$questionnaire_fail <- vapply(
      merged$vision_question_response,
      study3_questionnaire_fails_vision,
      logical(1)
    )
    n_missing_ish <- sum(is.na(merged$ishihara_score))
    n_missing_q <- sum(is.na(merged$vision_question_response) |
      !nzchar(trimws(merged$vision_question_response)))
    n_ambig_q <- sum(is.na(merged$questionnaire_fail) &
      !is.na(merged$vision_question_response) &
      nzchar(trimws(merged$vision_question_response)))
    if (n_missing_ish > 0L || n_missing_q > 0L || n_ambig_q > 0L) {
      stop(
        "Study 3 vision primary: missing or ambiguous vision/questionnaire data. ",
        "missing_ishihara=", n_missing_ish,
        " missing_questionnaire=", n_missing_q,
        " ambiguous_questionnaire=", n_ambig_q,
        call. = FALSE
      )
    }
    merged$exclude <- !merged$ishihara_pass | (merged$questionnaire_fail %in% TRUE)
  } else {
    log_msg(log_path, "SYNTHETIC: Ishihara-only primary exclusion (no questionnaire).")
    n_missing_ish <- sum(is.na(merged$ishihara_score))
    if (n_missing_ish > 0L) {
      stop(
        "Study 3 synthetic vision QA: missing Ishihara scores for ",
        n_missing_ish, " participants.",
        call. = FALSE
      )
    }
    merged$exclude <- !merged$ishihara_pass
  }

  keep <- merged$participant_id[!merged$exclude]
  log_msg(log_path, "vision primary n_included=", length(keep),
          " n_excluded=", sum(merged$exclude))
  if (identical(DATA_SOURCE, "synthetic")) {
    exp <- as.integer(SAP$study3_primary_n_after_vision_synthetic)
    if (length(keep) != exp) {
      stop(
        "Study 3 synthetic primary N after Ishihara is ", length(keep),
        " but expected ", exp, ".",
        call. = FALSE
      )
    }
  } else {
    exp <- as.integer(SAP$study3_primary_n_real)
    if (length(keep) != exp) {
      stop(
        "Study 3 real primary N after vision is ", length(keep),
        " but expected ", exp, ".",
        call. = FALSE
      )
    }
  }
  filter_study3_by_participants(study3, keep)
}
