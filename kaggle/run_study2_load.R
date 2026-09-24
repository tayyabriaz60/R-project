# Paste after PROJECT_ROOT is set. Study 2 load + QC only.

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

source(file.path(PROJECT_ROOT, "run_study2.R"))

cat("\n===== STUDY 2 QC log =====\n")
qc_file <- file.path("/kaggle/working/output/logs", "study2_log_data_qc_SYNTHETIC.txt")
if (!file.exists(qc_file)) {
  qc_file <- file.path(OUTPUT_LOGS, paste0("study2_log_data_qc", OUTPUT_SUFFIX, ".txt"))
}
if (file.exists(qc_file)) {
  cat(readLines(qc_file), sep = "\n")
}

cat("\n===== STUDY 2 QC csv items =====\n")
qc_csv <- file.path(OUTPUT_LOGS, paste0("study2_log_data_qc", OUTPUT_SUFFIX, ".csv"))
print(qc_csv)
print(file.exists(qc_csv))
if (file.exists(qc_csv)) {
  cat(readLines(qc_csv), sep = "\n")
  cat("\n")
}

message("Study 2 load cell finished. No hypothesis tests were run.")
