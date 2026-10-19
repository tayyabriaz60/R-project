# Study 3 row selection. Dictionary §10 Study 3; Q20 pairwise Response Left/Right.

source(file.path(PROJECT_ROOT, "R", "utils_logging.R"))

filter_study3_trials <- function(raw, role, task_names, log_path = NULL) {
  if (!"Response Type" %in% names(raw)) {
    stop(role, ": Response Type column is missing.", call. = FALSE)
  }
  if (!"Task Name" %in% names(raw)) {
    stop(role, ": Task Name column is missing.", call. = FALSE)
  }
  n0 <- nrow(raw)
  rt <- as.character(raw[["Response Type"]])
  task <- as.character(raw[["Task Name"]])
  keep <- !is.na(rt) & rt == "response" &
    !is.na(task) & task %in% task_names
  out <- raw[keep, , drop = FALSE]
  if (!is.null(log_path)) {
    log_n_flow(log_path, paste0(role, "_response_type_and_task"), n0, nrow(out))
  }
  if (nrow(out) == 0L) {
    stop(
      role, ": response-type + task filter dropped all ", n0,
      " rows. Tasks expected: ", paste(task_names, collapse = ", "),
      call. = FALSE
    )
  }

  if (identical(role, "study3_disc")) {
    expected <- require_param("study3_object_name_disc")
    if ("Object Name" %in% names(out)) {
      obj <- as.character(out[["Object Name"]])
      has_resp <- any(!is.na(obj) & obj == expected)
      if (has_resp) {
        n1 <- nrow(out)
        out <- out[!is.na(obj) & obj == expected, , drop = FALSE]
        if (!is.null(log_path)) {
          log_n_flow(log_path, paste0(role, "_object_name_", expected), n1, nrow(out))
        }
      } else if (!is.null(log_path)) {
        log_msg(
          log_path, role,
          " object_name_filter_skipped: no rows with Object Name '", expected,
          "' (Q20 synthetic: use response rows only)."
        )
      }
    }
  }

  if (identical(role, "study3_pairwise")) {
    if (!isTRUE(SAP$study3_pairwise_filter_response_left_right)) {
      return(out)
    }
    resp <- as.character(out[["Response"]])
    n1 <- nrow(out)
    keep_pw <- !is.na(resp) & resp %in% c("Left", "Right")
    out <- out[keep_pw, , drop = FALSE]
    if (!is.null(log_path)) {
      log_n_flow(log_path, paste0(role, "_response_left_right"), n1, nrow(out))
    }
    if (nrow(out) == 0L) {
      stop(
        role, ": Response Left/Right filter dropped all pairwise rows (Q20).",
        call. = FALSE
      )
    }
  }

  if (identical(role, "study3_vision")) {
    expected <- require_param("object_name_vision")
    if ("Object Name" %in% names(out)) {
      obj <- as.character(out[["Object Name"]])
      n1 <- nrow(out)
      out <- out[!is.na(obj) & obj == expected, , drop = FALSE]
      if (!is.null(log_path)) {
        log_n_flow(log_path, paste0(role, "_object_name_", gsub(" ", "_", expected)), n1, nrow(out))
      }
      if (nrow(out) == 0L) {
        stop(role, ": vision Object Name filter dropped all rows.", call. = FALSE)
      }
    }
  }

  out
}
