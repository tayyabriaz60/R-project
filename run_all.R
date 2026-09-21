# Master entry. Chunk 1: setup + config + load only.
# Later chunks will be appended below, in SAP §6 / Brief §3 order.
# Requires PROJECT_ROOT to be set first (see docs/KAGGLE_RUN.md).

if (!exists("PROJECT_ROOT")) {
  stop(
    "Set PROJECT_ROOT before source(\"run_all.R\"). ",
    "Kaggle example: PROJECT_ROOT <- \"/kaggle/input/your-dataset-folder\"",
    call. = FALSE
  )
}

source(file.path(PROJECT_ROOT, "config", "config.R"))
source(file.path(PROJECT_ROOT, "scripts", "00_setup.R"))
source(file.path(PROJECT_ROOT, "scripts", "01_load.R"))

# End of every run: session info (environment constraint).
write_session_info()

message("run_all.R chunk 1 finished. No statistical tests were run.")
