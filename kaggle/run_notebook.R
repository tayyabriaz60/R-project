# kaggle/run_notebook.R  -- Chunk A only
# Paste after PROJECT_ROOT is set (see docs/KAGGLE_RUN.md).

cat("R version: ", R.version.string, "\n", sep = "")

if (!exists("PROJECT_ROOT") || !is.character(PROJECT_ROOT) || !nzchar(PROJECT_ROOT)) {
  env <- Sys.getenv("PROJECT_ROOT", unset = "")
  if (nzchar(env)) {
    PROJECT_ROOT <- env
  }
}

if (!exists("PROJECT_ROOT") || !file.exists(file.path(PROJECT_ROOT, "config", "config.R"))) {
  stop(
    "Set PROJECT_ROOT to the folder that contains config/config.R before sourcing this file.",
    call. = FALSE
  )
}

source(file.path(PROJECT_ROOT, "config", "config.R"))
source(file.path(PROJECT_ROOT, "scripts", "00_setup.R"))
write_session_info()

# Show specified vs pending parameters (names and whether NA). No data rows.
pending <- names(SAP)[vapply(SAP, function(x) length(x) == 1L && is.na(x), logical(1))]
filled <- setdiff(names(SAP), pending)
cat("SAP filled parameters: ", paste(filled, collapse = ", "), "\n", sep = "")
cat("SAP pending (NA) parameters: ", paste(pending, collapse = ", "), "\n", sep = "")

cat("require_param('alpha') = ", require_param("alpha"), "\n", sep = "")

# Intended loud failure for a pending parameter (Chunk A check).
# We call it inside tryCatch ONLY to show the message; analysis code must not catch this.
pending_msg <- tryCatch(
  require_param("vision_subset_rule"),
  error = function(e) conditionMessage(e)
)
cat("require_param('vision_subset_rule') message:\n", pending_msg, "\n", sep = "")

cat("Chunk A finished. No data were loaded. No statistical tests were run.\n")
