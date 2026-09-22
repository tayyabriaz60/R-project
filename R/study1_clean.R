# Study 1 population + duplicate AUDIT. Q2. SAP §1, §3.4.
# Dedup is NOT applied until Q31 confirms the configured-trial key.

source(file.path(PROJECT_ROOT, "R", "utils_logging.R"))
source(file.path(PROJECT_ROOT, "R", "utils_validation.R"))

# Best-guess key while Q31 is NA. To swap after she answers:
#   1. set SAP$duplicate_trial_key to her key
#   2. rewrite this helper to match that key
#   3. only then set SAP$duplicate_dedup_apply <- TRUE
study1_duplicate_key_guess <- function(disc) {
  paste(
    as.character(disc$participant_id),
    as.character(disc$condition),
    as.character(disc$K),
    as.character(disc$configuration_instance),
    sep = "|"
  )
}

# Returns counts only. Does not drop rows. Does not print IDs or keys.
audit_disc_duplicates_guess <- function(disc) {
  if (!is.data.frame(disc) || nrow(disc) == 0L) {
    stop("audit_disc_duplicates_guess: discrimination table is empty.", call. = FALSE)
  }
  key <- study1_duplicate_key_guess(disc)
  tab <- table(key, useNA = "ifany")
  n_dup_keys <- as.integer(sum(tab > 1L))
  n_would_drop <- as.integer(sum(pmax(as.integer(tab) - 1L, 0L)))
  has_event <- "event_index" %in% names(disc) && any(!is.na(disc$event_index))
  list(
    key_guess = if (exists("SAP")) SAP$duplicate_audit_key_guess else "participant_id|condition|K|configuration_instance",
    keep_guess = if (exists("SAP")) SAP$duplicate_audit_keep_guess else "min_event_index",
    n_keys = length(tab),
    n_dup_keys = n_dup_keys,
    n_rows_would_drop = n_would_drop,
    event_index_available = has_event,
    applied = FALSE
  )
}

apply_study1_primary_population <- function(study1, log_path) {
  disc <- study1$discrimination
  pw <- study1$pairwise
  vis <- study1$vision
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

log_duplicate_audit <- function(disc, log_path) {
  log_msg(log_path, "Q31 PENDING: duplicate key is NA. Audit uses guess only; rows NOT dropped")
  log_msg(log_path, "Q31 guess key=", SAP$duplicate_audit_key_guess,
          " keep=", SAP$duplicate_audit_keep_guess)
  aud <- audit_disc_duplicates_guess(disc)
  log_msg(log_path, "Q31 audit n_keys=", aud$n_keys,
          " n_dup_keys=", aud$n_dup_keys,
          " n_rows_would_drop=", aud$n_rows_would_drop,
          " event_index_available=", aud$event_index_available,
          " applied=", aud$applied)
  if (isTRUE(SAP$duplicate_dedup_apply)) {
    stop("duplicate_dedup_apply is TRUE but Q31 is still pending. Do not apply.", call. = FALSE)
  }
  q31_pending <- length(SAP$duplicate_trial_key) == 1L && is.na(SAP$duplicate_trial_key)
  if (q31_pending && aud$n_dup_keys > 0L) {
    stop(
      "Q31 GATE: ", aud$n_dup_keys,
      " duplicate discrimination keys were found under the audit-only guess (",
      SAP$duplicate_audit_key_guess, "). n_rows_would_drop=",
      aud$n_rows_would_drop,
      ". Rows were NOT dropped. Confirm the configured-trial key and ",
      "'earliest' rule (Q31) before continuing. Do not analyse undeduplicated rows.",
      call. = FALSE
    )
  }
  aud
}
