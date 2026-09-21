# Logging helpers. Rules §3: aggregate counts only — no participant IDs, no raw rows.

todo_client_question <- function(question_number, why) {
  stop(
    "TODO(client-question #", question_number, "): ", why,
    " See docs/QUESTIONS_FOR_CLIENT.md. No guessed fill-in.",
    call. = FALSE
  )
}

append_log <- function(path, lines) {
  # write() and cat() are base; keep one file handle pattern simple.
  con <- file(path, open = "at")
  on.exit(close(con), add = TRUE)
  writeLines(lines, con)
  invisible(path)
}

start_log <- function(path, title) {
  dir_name <- dirname(path)
  if (!dir.exists(dir_name)) {
    dir.create(dir_name, recursive = TRUE, showWarnings = FALSE)
  }
  stamp <- as.character(Sys.time())
  header <- c(
    title,
    paste("time:", stamp),
    paste("R.version.string:", R.version.string),
    paste("DATA_SOURCE:", if (exists("DATA_SOURCE")) DATA_SOURCE else "UNSET"),
    paste("IS_KAGGLE:", if (exists("IS_KAGGLE")) IS_KAGGLE else "UNSET"),
    if (exists("DATA_SOURCE") && identical(DATA_SOURCE, "synthetic")) {
      "LABEL: SYNTHETIC DATA: pipeline test only"
    } else {
      NULL
    },
    ""
  )
  writeLines(header, path)
  message(title)
  invisible(path)
}

log_count <- function(path, label, n) {
  line <- paste0(label, ": ", as.integer(n))
  append_log(path, line)
  message(line)
  invisible(n)
}
