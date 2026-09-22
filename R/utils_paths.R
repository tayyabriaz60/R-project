# Path helpers. All paths from PROJECT_ROOT / OUTPUT_DIR (config).

require_project_root <- function() {
  if (!exists("PROJECT_ROOT") || !dir.exists(PROJECT_ROOT)) {
    stop("PROJECT_ROOT is not set or does not exist. Source config/config.R first.", call. = FALSE)
  }
  PROJECT_ROOT
}

project_path <- function(...) {
  file.path(require_project_root(), ...)
}

ensure_output_dirs <- function() {
  if (!exists("OUTPUT_DIR")) {
    stop("OUTPUT_DIR is missing. Source config/config.R first.", call. = FALSE)
  }
  dirs <- c(OUTPUT_DIR, OUTPUT_TABLES, OUTPUT_FIGURES, OUTPUT_MODELS, OUTPUT_LOGS)
  for (d in dirs) {
    if (!dir.exists(d)) {
      dir.create(d, recursive = TRUE, showWarnings = FALSE)
    }
  }
  invisible(OUTPUT_DIR)
}

output_log_path <- function(name) {
  ensure_output_dirs()
  suffix <- if (exists("OUTPUT_SUFFIX")) OUTPUT_SUFFIX else ""
  file.path(OUTPUT_LOGS, paste0(name, suffix, ".txt"))
}

study1_file_roles <- function() {
  c("study1_disc_g1", "study1_disc_g2", "study1_pairwise", "study1_vision")
}

# Synthetic: fixed names. Real: REAL_STUDY1_FILES if set, else filename contains the task id.
resolve_study1_file <- function(role) {
  if (!role %in% study1_file_roles()) {
    stop("Unknown Study 1 file role: ", role, call. = FALSE)
  }
  if (identical(DATA_SOURCE, "synthetic")) {
    p <- SYNTHETIC_FILES[[role]]
    if (is.null(p) || !file.exists(p)) {
      stop("Synthetic file not found for ", role, ".", call. = FALSE)
    }
    return(p)
  }
  explicit <- REAL_STUDY1_FILES[[role]]
  if (!is.null(explicit) && length(explicit) == 1L && !is.na(explicit) && nzchar(explicit)) {
    p <- explicit
    if (!file.exists(p)) {
      p <- file.path(DATA_DIR, explicit)
    }
    if (!file.exists(p)) {
      stop(
        "Configured real path for ", role, " was not found. ",
        "Put the Gorilla CSV under data/real/ or set REAL_STUDY1_FILES$", role,
        ". Expected task id: ", REAL_STUDY1_TASK_IDS[[role]], ".",
        call. = FALSE
      )
    }
    return(p)
  }
  task_id <- REAL_STUDY1_TASK_IDS[[role]]
  if (is.null(task_id) || !nzchar(task_id)) {
    stop("REAL_STUDY1_TASK_IDS$", role, " is empty.", call. = FALSE)
  }
  if (!dir.exists(DATA_DIR)) {
    stop(
      "data/real/ does not exist. Create it and place the unedited Gorilla CSVs there.",
      call. = FALSE
    )
  }
  all_csv <- list.files(DATA_DIR, pattern = "\\.csv$", recursive = TRUE, full.names = TRUE)
  hits <- all_csv[grepl(task_id, basename(all_csv), fixed = TRUE)]
  if (length(hits) == 0L) {
    stop(
      "No CSV under data/real/ contains '", task_id, "' in the filename (", role, "). ",
      "Place the unedited Gorilla export there. Do not rename columns or filter rows.",
      call. = FALSE
    )
  }
  if (length(hits) > 1L) {
    stop(
      "Several CSVs under data/real/ match '", task_id, "' (", role, ", n=",
      length(hits), "). Set REAL_STUDY1_FILES$", role, " to the exact filename.",
      call. = FALSE
    )
  }
  hits[[1]]
}
