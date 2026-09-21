# Paste after PROJECT_ROOT is set (see docs/KAGGLE_RUN.md).
# Chunk B: config + setup + Study 1 load/QC.

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

source(file.path(PROJECT_ROOT, "run_all.R"))

cat("\n===== QC log =====\n")
qc_file <- file.path("/kaggle/working/output/logs", "study1_log_data_qc_SYNTHETIC.txt")
if (!file.exists(qc_file)) {
  qc_file <- file.path(OUTPUT_LOGS, paste0("study1_log_data_qc", OUTPUT_SUFFIX, ".txt"))
}
cat(readLines(qc_file), sep = "\n")
