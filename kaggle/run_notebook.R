# Paste after PROJECT_ROOT is set. Load + prepare (not H1-H3).

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

cat("\n===== PREPARE log =====\n")
prep_file <- file.path("/kaggle/working/output/logs", "study1_log_prepare_SYNTHETIC.txt")
if (!file.exists(prep_file)) {
  prep_file <- file.path(OUTPUT_LOGS, paste0("study1_log_prepare", OUTPUT_SUFFIX, ".txt"))
}
cat(readLines(prep_file), sep = "\n")

cat("\n===== summary file (header + n only) =====\n")
sum_file <- file.path(OUTPUT_TABLES, paste0("study1_participant_summaries", OUTPUT_SUFFIX, ".csv"))
print(sum_file)
print(file.exists(sum_file))
if (file.exists(sum_file)) {
  hdr <- readLines(sum_file, n = 1L)
  cat(hdr, "\n", sep = "")
  n_lines <- length(readLines(sum_file)) - 1L
  cat("n_data_rows=", n_lines, "\n", sep = "")
  cols <- strsplit(hdr, ",", fixed = TRUE)[[1]]
  has_public <- any(cols %in% c("participant_id", "participant_public_id", "participant_private_id"))
  cat("header_has_gorilla_id_column=", has_public, "\n", sep = "")
}

cat("\n===== diagnostic PNGs =====\n")
print(list.files(OUTPUT_FIGURES, pattern = "study1_diag_.*\\.png$", full.names = FALSE))
