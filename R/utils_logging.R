# Logging: console + file. Rules: aggregates only — no participant IDs, no raw rows.

start_log <- function(path, title) {
  dir_name <- dirname(path)
  if (!dir.exists(dir_name)) {
    dir.create(dir_name, recursive = TRUE, showWarnings = FALSE)
  }
  header <- c(
    title,
    paste("time:", as.character(Sys.time())),
    paste("R.version.string:", R.version.string),
    paste("DATA_SOURCE:", if (exists("DATA_SOURCE")) DATA_SOURCE else "UNSET"),
    paste("ENV_NAME:", if (exists("ENV_NAME")) ENV_NAME else "UNSET"),
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

log_msg <- function(path, ...) {
  line <- paste0(...)
  con <- file(path, open = "at")
  on.exit(close(con), add = TRUE)
  writeLines(line, con)
  message(line)
  invisible(line)
}

# N-flow: count before/after a named step (future exclusions). No IDs.
log_n_flow <- function(path, step, n_before, n_after, unit = "rows") {
  log_msg(path, "N_FLOW step=", step, " ", unit, "_before=", as.integer(n_before),
          " ", unit, "_after=", as.integer(n_after),
          " dropped=", as.integer(n_before) - as.integer(n_after))
}

todo_client_question <- function(question_number, why) {
  stop(
    "TODO(client-question #", question_number, "): ", why,
    " See docs/QUESTIONS_FOR_CLIENT.md. Do not guess.",
    call. = FALSE
  )
}
