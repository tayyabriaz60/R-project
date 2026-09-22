# Paste after PROJECT_ROOT is set. Load + prepare + locked Q7 path.

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

cat("\n===== Q7 fallback review (send this to Fatimah) =====\n")
q7_file <- file.path("/kaggle/working/output/logs", "study1_q7_fallback_review_SYNTHETIC.txt")
if (!file.exists(q7_file)) {
  q7_file <- file.path(OUTPUT_LOGS, paste0("study1_q7_fallback_review", OUTPUT_SUFFIX, ".txt"))
}
if (file.exists(q7_file)) {
  cat(readLines(q7_file), sep = "\n")
}

cat("\n===== ANALYSIS log =====\n")
ana_file <- file.path("/kaggle/working/output/logs", "study1_log_analysis_SYNTHETIC.txt")
if (!file.exists(ana_file)) {
  ana_file <- file.path(OUTPUT_LOGS, paste0("study1_log_analysis", OUTPUT_SUFFIX, ".txt"))
}
if (file.exists(ana_file)) {
  cat(readLines(ana_file), sep = "\n")
}

cat("\n===== tables =====\n")
print(list.files(OUTPUT_TABLES, pattern = "study1_table_.*\\.(csv|docx)$", full.names = FALSE))

cat("\n===== report figures =====\n")
print(list.files(OUTPUT_FIGURES, pattern = "study1_fig_.*\\.(png|pdf)$", full.names = FALSE))

cat("\n===== gorilla-id check on inferential CSVs =====\n")
csv_tabs <- list.files(OUTPUT_TABLES, pattern = "study1_table_.*\\.csv$", full.names = TRUE)
for (f in csv_tabs) {
  hdr <- readLines(f, n = 1L)
  cols <- strsplit(hdr, ",", fixed = TRUE)[[1]]
  bad <- any(cols %in% c("participant_id", "participant_public_id", "participant_private_id"))
  cat(basename(f), " header_has_gorilla_id_column=", bad, "\n", sep = "")
}
