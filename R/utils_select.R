# Row selection and reporting-ID helpers. Dictionary §10; Q5, Q6.
# Does not apply participant exclusions (Q2) or vision-subset population change (Q1).

filter_object_name <- function(raw, expected, file_label, log_path = NULL) {
  if (!"Object Name" %in% names(raw)) {
    stop(file_label, ": Object Name column is missing.", call. = FALSE)
  }
  n0 <- nrow(raw)
  obj <- as.character(raw[["Object Name"]])
  keep <- !is.na(obj) & obj == expected
  out <- raw[keep, , drop = FALSE]
  if (!is.null(log_path)) {
    log_n_flow(log_path, paste0(file_label, "_object_name_", gsub(" ", "_", expected)), n0, nrow(out))
  }
  if (nrow(out) == 0L) {
    stop(
      file_label, ": Object Name filter '", expected, "' dropped all ", n0,
      " rows (Q5: keep the filter). Check the export or the expected token.",
      call. = FALSE
    )
  }
  out
}

filter_task_name <- function(raw, expected, file_label, log_path = NULL) {
  if (!"Task Name" %in% names(raw)) {
    stop(file_label, ": Task Name column is missing.", call. = FALSE)
  }
  n0 <- nrow(raw)
  task <- as.character(raw[["Task Name"]])
  keep <- !is.na(task) & task == expected
  out <- raw[keep, , drop = FALSE]
  if (!is.null(log_path)) {
    log_n_flow(log_path, paste0(file_label, "_task_name"), n0, nrow(out))
  }
  if (nrow(out) == 0L) {
    stop(
      file_label, ": Task Name filter '", expected, "' dropped all ", n0,
      " rows. Check the export or the expected task token.",
      call. = FALSE
    )
  }
  out
}

# Q6: reporting IDs only. Never print the source IDs.
make_anonymous_id_map <- function(ids, prefix = "S1_P") {
  ids <- as.character(ids)
  key <- sort(unique(ids[!is.na(ids) & nzchar(trimws(ids))]))
  if (length(key) == 0L) {
    stop("make_anonymous_id_map: no non-empty IDs.", call. = FALSE)
  }
  anon <- sprintf("%s%03d", prefix, seq_along(key))
  names(anon) <- key
  anon
}

apply_analysis_id <- function(df, id_col, file_label) {
  if (!id_col %in% names(df)) {
    stop(file_label, ": configured id column '", id_col, "' is not in the mapped table.",
         call. = FALSE)
  }
  df$participant_id <- as.character(df[[id_col]])
  empty <- is.na(df$participant_id) | !nzchar(trimws(df$participant_id))
  if (any(empty)) {
    stop(file_label, ": participant_id missing on ", sum(empty), " rows after ID mapping.",
         call. = FALSE)
  }
  n_blind <- sum(df$participant_id == "BLINDED", na.rm = TRUE)
  if (n_blind > 0L) {
    stop(
      file_label, ": participant_id is BLINDED on ", n_blind,
      " rows. Public ID is not usable on this file.",
      call. = FALSE
    )
  }
  df
}

apply_study1_analysis_id <- function(df, file_label) {
  apply_analysis_id(df, require_param("study1_id_column"), file_label)
}

apply_study2_analysis_id <- function(df, file_label) {
  apply_analysis_id(df, require_param("study2_id_column"), file_label)
}
