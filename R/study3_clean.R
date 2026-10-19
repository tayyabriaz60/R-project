# Study 3 Q31-style dedup. Key: participant x condition x background x K x difficulty_index.

source(file.path(PROJECT_ROOT, "R", "utils_logging.R"))
source(file.path(PROJECT_ROOT, "R", "utils_validation.R"))

study3_duplicate_key <- function(disc) {
  paste(
    as.character(disc$participant_id),
    as.character(disc$condition),
    as.character(disc$background),
    as.character(disc$K),
    as.character(disc$difficulty_index),
    sep = "|"
  )
}

audit_study3_disc_duplicates <- function(disc) {
  key <- study3_duplicate_key(disc)
  tab <- table(key, useNA = "ifany")
  list(
    key = SAP$study3_duplicate_trial_key,
    n_keys = length(tab),
    n_dup_keys = as.integer(sum(tab > 1L)),
    n_rows_would_drop = as.integer(sum(pmax(as.integer(tab) - 1L, 0L)))
  )
}

apply_study3_discrimination_dedup <- function(disc) {
  if (!isTRUE(SAP$duplicate_dedup_apply)) {
    stop("duplicate_dedup_apply is FALSE.", call. = FALSE)
  }
  need <- c(
    "participant_id", "condition", "background", "K", "difficulty_index",
    "utc_timestamp", "event_index"
  )
  miss <- setdiff(need, names(disc))
  if (length(miss) > 0L) {
    stop("Study 3 dedup: missing ", paste(miss, collapse = ", "), ".", call. = FALSE)
  }
  key <- study3_duplicate_key(disc)
  o <- order(key, disc$utc_timestamp, disc$event_index, na.last = TRUE)
  disc2 <- disc[o, , drop = FALSE]
  keep <- !duplicated(key[o])
  disc2[keep, , drop = FALSE]
}

apply_study3_q31_dedup <- function(study3, log_path) {
  disc <- study3$discrimination
  n_before <- nrow(disc)
  aud <- audit_study3_disc_duplicates(disc)
  log_msg(log_path, "Study3 dedup key=", SAP$study3_duplicate_trial_key)
  log_msg(log_path, "before n_rows=", n_before, " n_dup_keys=", aud$n_dup_keys,
          " n_rows_would_drop=", aud$n_rows_would_drop)
  disc2 <- apply_study3_discrimination_dedup(disc)
  n_dropped <- n_before - nrow(disc2)
  log_msg(log_path, "dedup applied n_rows_after=", nrow(disc2), " n_dropped=", n_dropped)
  study3$discrimination <- disc2
  study3$duplicate_audit <- c(aud, list(n_rows_dropped = n_dropped, applied = TRUE))
  study3
}
