# SUPERSEDED by utils_io.R + study1_load.R. Do not source this file.
# Chunk 1: read, drop blank housekeeping rows, check required columns exist.
# Does NOT apply Object Name filters (Q5), exclusions (Q2 / Q18), or ID recode (Q6).

read_gorilla_csv <- function(path) {
  if (!file.exists(path)) {
    stop("CSV not found: ", basename(path), " (full path not printed).", call. = FALSE)
  }
  # stringsAsFactors = FALSE: required on R < 4.0; harmless later.
  # check.names = FALSE: keep "Spreadsheet: condition" exactly (Dictionary names).
  df <- utils::read.csv(
    file = path,
    header = TRUE,
    stringsAsFactors = FALSE,
    check.names = FALSE,
    na.strings = c("", "NA"),
    comment.char = ""
  )
  df
}

drop_blank_rows <- function(df) {
  # Fully empty housekeeping rows (Study 2 and Study 3 synthetic files).
  if (ncol(df) == 0L || nrow(df) == 0L) {
    return(df)
  }
  keep <- rowSums(!is.na(df)) > 0L
  df[keep, , drop = FALSE]
}

require_columns <- function(df, columns, file_label) {
  missing <- setdiff(columns, names(df))
  if (length(missing) > 0L) {
    stop(
      "Missing required columns in ", file_label, ": ",
      paste(missing, collapse = ", "),
      call. = FALSE
    )
  }
  invisible(TRUE)
}

n_unique_nonempty <- function(x) {
  x <- x[!is.na(x)]
  if (is.character(x)) {
    x <- x[nzchar(trimws(x))]
  }
  length(unique(x))
}

n_missing <- function(x) {
  sum(is.na(x))
}

# Dictionary §3 / §4 / §7 raw columns needed to *load* Study 1 tables.
STUDY1_DISC_REQUIRED <- c(
  "Participant Public ID",
  "Participant Private ID",
  "Task Name",
  "Response Type",
  "Object Name",
  "Response",
  "Reaction Time",
  "Correct",
  "Spreadsheet: condition",
  "Spreadsheet: colormap",
  "Spreadsheet: num_classes",
  "Spreadsheet: variation",
  "Spreadsheet: image",
  "Spreadsheet: correct_answer"
)

STUDY1_PAIRWISE_REQUIRED <- c(
  "Participant Public ID",
  "Participant Private ID",
  "Task Name",
  "Response Type",
  "Object Name",
  "Response",
  "Reaction Time",
  "Spreadsheet: trial_number",
  "Spreadsheet: image_left",
  "Spreadsheet: image_right",
  "Spreadsheet: left_option",
  "Spreadsheet: right_option"
)

STUDY1_VISION_REQUIRED <- c(
  "Participant Public ID",
  "Participant Private ID",
  "Task Name",
  "Response Type",
  "Object Name",
  "Response",
  "Correct",
  "Spreadsheet: tag",
  "Spreadsheet: correct_answer"
)

STUDY2_REQUIRED <- c(
  "Participant Public ID",
  "Participant Private ID",
  "Task Name",
  "Response Type",
  "Object Name",
  "Response",
  "Reaction Time"
)

STUDY3_REQUIRED <- STUDY2_REQUIRED

load_one_csv <- function(path, required, file_label, log_path) {
  raw_n <- NA_integer_
  df <- read_gorilla_csv(path)
  raw_n <- nrow(df)
  log_count(log_path, paste0(file_label, " rows_read"), raw_n)
  df <- drop_blank_rows(df)
  log_count(log_path, paste0(file_label, " rows_after_blank_drop"), nrow(df))
  require_columns(df, required, file_label)
  if ("Object Name" %in% names(df)) {
    log_count(log_path, paste0(file_label, " object_name_missing"), n_missing(df[["Object Name"]]))
  }
  if ("Participant Public ID" %in% names(df)) {
    log_count(log_path, paste0(file_label, " n_unique_public_id"), n_unique_nonempty(df[["Participant Public ID"]]))
  }
  if ("Participant Private ID" %in% names(df)) {
    log_count(log_path, paste0(file_label, " n_unique_private_id"), n_unique_nonempty(df[["Participant Private ID"]]))
  }
  if ("Task Name" %in% names(df)) {
    task_tab <- table(df[["Task Name"]], useNA = "ifany")
    # Task names only — not IDs.
    append_log(log_path, paste0(file_label, " task_name_counts:"))
    append_log(log_path, paste0("  ", names(task_tab), "=", as.integer(task_tab)))
    message(file_label, " Task Name levels: ", paste(names(task_tab), collapse = ", "))
  }
  if ("Response Type" %in% names(df)) {
    rt_tab <- table(df[["Response Type"]], useNA = "ifany")
    append_log(log_path, paste0(file_label, " response_type_counts:"))
    append_log(log_path, paste0("  ", names(rt_tab), "=", as.integer(rt_tab)))
  }
  df
}

# Synthetic expected row counts AFTER blank-row drop (README / Dictionary §9).
# Used only as a pipeline structure check, not as a result.
SYNTHETIC_EXPECTED_AFTER_BLANK <- list(
  study1_disc = 1200L,
  study1_pairwise = 600L,
  study1_vision = 200L,
  study2_tasks = 2040L,
  study3_tasks = 2900L
)

check_synthetic_n <- function(observed, expected, label, log_path) {
  log_count(log_path, paste0(label, " expected_after_blank"), expected)
  log_count(log_path, paste0(label, " observed_after_blank"), observed)
  if (!identical(as.integer(observed), as.integer(expected))) {
    stop(
      "Synthetic structure mismatch for ", label,
      ": expected ", expected, " rows after blank drop, observed ", observed,
      ". Check PROJECT_ROOT and that the CSV was not altered.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}
