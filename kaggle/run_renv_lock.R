# Optional Kaggle cell: write renv.lock as a version record only.

cat("R version: ", R.version.string, "\n", sep = "")

if (!exists("PROJECT_ROOT") || !file.exists(file.path(PROJECT_ROOT, "config", "config.R"))) {
  stop("Set PROJECT_ROOT first.", call. = FALSE)
}

if (!exists("required_packages")) {
  source(file.path(PROJECT_ROOT, "config", "config.R"))
  source(file.path(PROJECT_ROOT, "scripts", "00_setup.R"))
}

source(file.path(PROJECT_ROOT, "scripts", "write_renv_lock.R"))
lock_path <- file.path(PROJECT_ROOT, "renv.lock")
if (file.exists(lock_path)) {
  cat("\n===== renv.lock (first 40 lines) =====\n")
  lines <- readLines(lock_path)
  cat(utils::head(lines, 40L), sep = "\n")
  cat("\nlockfile_lines=", length(lines), "\n", sep = "")
}
