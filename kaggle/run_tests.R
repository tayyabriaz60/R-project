# Paste after PROJECT_ROOT is set (see docs/KAGGLE_RUN.md).
# Chunk C: toy-data helper tests only.

cat("R version: ", R.version.string, "\n", sep = "")

if (!exists("PROJECT_ROOT") || !is.character(PROJECT_ROOT) || !nzchar(PROJECT_ROOT)) {
  env <- Sys.getenv("PROJECT_ROOT", unset = "")
  if (nzchar(env)) {
    PROJECT_ROOT <- env
  }
}

if (!exists("PROJECT_ROOT") || !file.exists(file.path(PROJECT_ROOT, "config", "config.R"))) {
  stop(
    "Set PROJECT_ROOT to the folder that contains config/config.R.",
    call. = FALSE
  )
}

source(file.path(PROJECT_ROOT, "tests", "run_tests.R"))

cat("\n===== Chunk C test log =====\n")
log_file <- file.path("/kaggle/working/output/logs", "study1_log_chunk_c_tests_SYNTHETIC.txt")
if (!file.exists(log_file)) {
  log_file <- file.path(OUTPUT_LOGS, paste0("study1_log_chunk_c_tests", OUTPUT_SUFFIX, ".txt"))
}
if (file.exists(log_file)) {
  cat(readLines(log_file), sep = "\n")
}
