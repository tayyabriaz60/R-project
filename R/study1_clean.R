# Study 1 population + Q31 duplicate cleaning. Q2. SAP §1, §3.4.
# Key (Q31): participant x Condition x K x configuration_instance (variation).
# Keep: earliest UTC Timestamp, Event Index as tie-breaker.

source(file.path(PROJECT_ROOT, "R", "utils_logging.R"))
source(file.path(PROJECT_ROOT, "R", "utils_validation.R"))

study1_duplicate_key <- function(disc) {
  paste(
    as.character(disc$participant_id),
    as.character(disc$condition),
    as.character(disc$K),
    as.character(disc$configuration_instance),
    sep = "|"
  )
}

# Alias used by older tests / logs.
study1_duplicate_key_guess <- study1_duplicate_key

# Returns counts only. Does not drop rows. Does not print IDs or keys.
audit_disc_duplicates <- function(disc) {
  if (!is.data.frame(disc) || nrow(disc) == 0L) {
    stop("audit_disc_duplicates: discrimination table is empty.", call. = FALSE)
  }
  key <- study1_duplicate_key(disc)
  tab <- table(key, useNA = "ifany")
  n_dup_keys <- as.integer(sum(tab > 1L))
  n_would_drop <- as.integer(sum(pmax(as.integer(tab) - 1L, 0L)))
  has_event <- "event_index" %in% names(disc) && any(!is.na(disc$event_index))
  has_utc <- "utc_timestamp" %in% names(disc) && any(!is.na(disc$utc_timestamp))
  list(
    key = if (exists("SAP")) SAP$duplicate_trial_key else "participant_id|condition|K|configuration_instance",
    keep = if (exists("SAP")) SAP$duplicate_keep_rule else "min_utc_timestamp_then_min_event_index",
    n_keys = length(tab),
    n_dup_keys = n_dup_keys,
    n_rows_would_drop = n_would_drop,
    event_index_available = has_event,
    utc_timestamp_available = has_utc,
    applied = FALSE
  )
}

audit_disc_duplicates_guess <- audit_disc_duplicates

count_full_clock_ties <- function(disc, key) {
  tab <- table(key, useNA = "ifany")
  dup_keys <- names(tab)[tab > 1L]
  if (length(dup_keys) == 0L) {
    return(0L)
  }
  idx <- key %in% dup_keys
  clock <- paste(
    key[idx],
    as.character(disc$utc_timestamp[idx]),
    as.character(disc$event_index[idx]),
    sep = "|"
  )
  as.integer(sum(duplicated(clock)))
}

# Keep one row per Q31 key: min UTC Timestamp, then min Event Index.
apply_study1_discrimination_dedup <- function(disc) {
  if (!is.data.frame(disc) || nrow(disc) == 0L) {
    stop("apply_study1_discrimination_dedup: discrimination table is empty.", call. = FALSE)
  }
  if (!isTRUE(SAP$duplicate_dedup_apply)) {
    stop("duplicate_dedup_apply is FALSE. Q31 cleaning is not applied.", call. = FALSE)
  }
  need <- c("participant_id", "condition", "K", "configuration_instance",
            "utc_timestamp", "event_index")
  miss <- setdiff(need, names(disc))
  if (length(miss) > 0L) {
    stop("Q31: discrimination is missing ", paste(miss, collapse = ", "), ".", call. = FALSE)
  }
  key <- study1_duplicate_key(disc)
  aud <- audit_disc_duplicates(disc)
  if (aud$n_dup_keys > 0L) {
    idx <- key %in% names(table(key))[table(key) > 1L]
    n_utc_na <- sum(is.na(disc$utc_timestamp[idx]))
    n_ev_na <- sum(is.na(disc$event_index[idx]))
    if (n_utc_na > 0L) {
      stop(
        "Q31 GATE: ", n_utc_na,
        " duplicate-key rows have missing UTC Timestamp. Cannot apply earliest-UTC keep.",
        call. = FALSE
      )
    }
    if (n_ev_na > 0L) {
      stop(
        "Q31 GATE: ", n_ev_na,
        " duplicate-key rows have missing Event Index. Cannot apply the tie-breaker.",
        call. = FALSE
      )
    }
    n_tie <- count_full_clock_ties(disc, key)
    if (n_tie > 0L) {
      stop(
        "Q31 GATE: ", n_tie,
        " extra rows share the same trial key, UTC Timestamp, and Event Index. ",
        "Cannot choose a row. Flag and stop.",
        call. = FALSE
      )
    }
  }
  o <- order(key, disc$utc_timestamp, disc$event_index, na.last = TRUE)
  disc2 <- disc[o, , drop = FALSE]
  keep <- !duplicated(key[o])
  out <- disc2[keep, , drop = FALSE]
  rownames(out) <- NULL
  out
}

apply_study1_primary_population <- function(study1, log_path) {
  disc <- study1$discrimination
  n_id <- n_unique_nonempty(disc$participant_id)
  log_msg(log_path, "Q2 population: all recruited participants in the loaded files; no outcome-based exclusion")
  log_msg(log_path, "Q2 self-test session: not present in these files (outside sample); no extra drop")
  log_msg(log_path, "Q1 vision subset: not applied as a primary exclusion")
  log_msg(log_path, "Q2 n_unique_participant_id=", n_id,
          " (synthetic expected ", as.integer(SAP$primary_n_study1), ")")
  if (identical(DATA_SOURCE, "synthetic") && n_id != as.integer(SAP$primary_n_study1)) {
    stop("Q2: synthetic primary N is not ", SAP$primary_n_study1, ".", call. = FALSE)
  }
  study1
}

apply_study1_q31_dedup <- function(study1, log_path) {
  disc <- study1$discrimination
  n_before <- nrow(disc)
  aud <- audit_disc_duplicates(disc)
  log_msg(log_path, "Q31 key=", require_param("duplicate_trial_key"),
          " keep=", require_param("duplicate_keep_rule"))
  log_msg(log_path, "Q31 before n_rows=", n_before,
          " n_keys=", aud$n_keys,
          " n_dup_keys=", aud$n_dup_keys,
          " n_rows_would_drop=", aud$n_rows_would_drop,
          " utc_timestamp_available=", aud$utc_timestamp_available,
          " event_index_available=", aud$event_index_available)
  disc2 <- apply_study1_discrimination_dedup(disc)
  n_after <- nrow(disc2)
  n_dropped <- n_before - n_after
  log_msg(log_path, "Q31 applied=TRUE n_rows_after=", n_after,
          " n_rows_dropped=", n_dropped)
  study1$discrimination <- disc2
  study1$duplicate_audit <- list(
    key = SAP$duplicate_trial_key,
    keep = SAP$duplicate_keep_rule,
    n_keys = aud$n_keys,
    n_dup_keys = aud$n_dup_keys,
    n_rows_would_drop = aud$n_rows_would_drop,
    n_rows_dropped = n_dropped,
    event_index_available = aud$event_index_available,
    utc_timestamp_available = aud$utc_timestamp_available,
    applied = TRUE
  )
  study1
}

# Kept name: now applies Q31 (no longer audit-only).
log_duplicate_audit <- function(disc, log_path) {
  study1 <- list(discrimination = disc)
  study1 <- apply_study1_q31_dedup(study1, log_path)
  study1$duplicate_audit
}
