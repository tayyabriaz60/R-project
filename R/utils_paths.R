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
