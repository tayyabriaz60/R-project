# Log where deliverables were written (paths only; no participant data).

source(file.path(PROJECT_ROOT, "R", "utils_logging.R"))

write_study3_output_manifest <- function(log_path) {
  ensure_output_dirs()
  figs <- list.files(OUTPUT_FIGURES, pattern = "^study3_", full.names = FALSE)
  tabs <- list.files(OUTPUT_TABLES, pattern = "^study3_", full.names = FALSE)
  logs <- list.files(OUTPUT_LOGS, pattern = "^study3_", full.names = FALSE)
  out_root <- normalizePath(OUTPUT_DIR, winslash = "/", mustWork = FALSE)
  manifest_path <- file.path(OUTPUT_LOGS, paste0("study3_output_manifest", OUTPUT_SUFFIX, ".txt"))
  lines <- c(
    "Study 3 output manifest (file names only).",
    paste("OUTPUT_DIR:", out_root),
    paste("time:", as.character(Sys.time())),
    "",
    paste0("figures/ (n=", length(figs), "):"),
    if (length(figs) == 0L) "  (none — run may have failed before export)" else paste0("  ", sort(figs)),
    "",
    paste0("tables/ (n=", length(tabs), "):"),
    if (length(tabs) == 0L) "  (none)" else paste0("  ", sort(tabs)),
    "",
    paste0("logs/ study3_* (n=", length(logs), "):"),
    if (length(logs) == 0L) "  (none)" else paste0("  ", sort(logs))
  )
  writeLines(lines, manifest_path, useBytes = TRUE)
  log_msg(log_path, "OUTPUT_DIR=", out_root)
  log_msg(log_path, "study3 figures n=", length(figs), " tables n=", length(tabs))
  log_msg(log_path, "wrote ", basename(manifest_path))
  message(
    "Study 3 outputs written under:\n  ",
    out_root,
    "\nFigures: ",
    file.path(out_root, "figures"),
    "\nManifest: ",
    manifest_path
  )
  invisible(manifest_path)
}
