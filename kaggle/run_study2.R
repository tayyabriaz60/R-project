# Paste after PROJECT_ROOT is set. Study 2 full pipeline (synthetic).

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

cat("\n===== STUDY 2 PREPARE log =====\n")
prep_file <- file.path(OUTPUT_LOGS, paste0("study2_log_prepare", OUTPUT_SUFFIX, ".txt"))
if (file.exists(prep_file)) {
  cat(readLines(prep_file), sep = "\n")
}

cat("\n===== STUDY 2 Q7 review =====\n")
q7_file <- file.path(OUTPUT_LOGS, paste0("study2_q7_fallback_review", OUTPUT_SUFFIX, ".txt"))
if (file.exists(q7_file)) {
  cat(readLines(q7_file), sep = "\n")
}

cat("\n===== STUDY 2 ANALYSIS log =====\n")
ana_file <- file.path(OUTPUT_LOGS, paste0("study2_log_analysis", OUTPUT_SUFFIX, ".txt"))
if (file.exists(ana_file)) {
  cat(readLines(ana_file), sep = "\n")
}

cat("\n===== STUDY 2 tables =====\n")
print(list.files(OUTPUT_TABLES, pattern = "study2_table_.*\\.(csv|docx)$", full.names = FALSE))

cat("\n===== STUDY 2 report figures =====\n")
print(list.files(OUTPUT_FIGURES, pattern = "study2_fig_.*\\.(png|pdf)$", full.names = FALSE))

cat("\n===== STUDY 2 diagnostic PNGs =====\n")
print(list.files(OUTPUT_FIGURES, pattern = "study2_diag_.*\\.png$", full.names = FALSE))

cat("\n===== gorilla-id check on Study 2 inferential CSVs =====\n")
csv_tabs <- list.files(OUTPUT_TABLES, pattern = "study2_table_.*\\.csv$", full.names = TRUE)
for (f in csv_tabs) {
  hdr <- readLines(f, n = 1L)
  cols <- strsplit(hdr, ",", fixed = TRUE)[[1]]
  bad <- any(cols %in% c("participant_id", "participant_public_id", "participant_private_id"))
  cat(basename(f), " header_has_gorilla_id_column=", bad, "\n", sep = "")
}

message("Study 2 cell finished. Numbers are synthetic pipeline output, not findings.")
