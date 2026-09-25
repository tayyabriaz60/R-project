# Q8 diagnostic histograms only. Not Q13 report figures.

source(file.path(PROJECT_ROOT, "R", "utils_paths.R"))
source(file.path(PROJECT_ROOT, "R", "utils_logging.R"))

diag_png <- function(name, width_in, height_in) {
  ensure_output_dirs()
  path <- file.path(OUTPUT_FIGURES, paste0(name, OUTPUT_SUFFIX, ".png"))
  grDevices::png(
    filename = path,
    width = width_in,
    height = height_in,
    units = "in",
    res = 150
  )
  path
}

save_q8_histograms <- function(summary_df, log_path, file_prefix, after_note) {
  if (isTRUE(require_param("fallback_normality_cutoff") == "no_cutoff_diagnostics_then_stop")) {
    log_msg(log_path, "Q7: no numeric cutoff; histograms only")
  }

  k_order <- as.integer(SAP$k_levels_study1)
  cond_order <- require_param("condition_level_order")
  cell_cols <- character(0)
  for (cond in cond_order) {
    for (k in k_order) {
      cell_cols <- c(cell_cols, paste0("acc_", cond, "_K", k))
    }
  }

  p1 <- diag_png(paste0(file_prefix, "_diag_accuracy_cells"), 10, 6)
  graphics::par(mfrow = c(2, 4), mar = c(3, 3, 2, 1))
  for (col in cell_cols) {
    graphics::hist(
      summary_df[[col]],
      main = col,
      xlab = "accuracy",
      col = "grey80",
      border = "grey30"
    )
  }
  grDevices::dev.off()
  log_msg(log_path, "wrote diagnostic ", basename(p1))

  p2 <- diag_png(paste0(file_prefix, "_diag_h1_diff"), 5, 4)
  graphics::hist(
    summary_df$acc_diff_h1,
    main = "H1 Optimized-Original (diagnostic)",
    xlab = "accuracy difference",
    col = "grey80",
    border = "grey30"
  )
  grDevices::dev.off()
  log_msg(log_path, "wrote diagnostic ", basename(p2))

  p3 <- diag_png(paste0(file_prefix, "_diag_h2_k_diffs"), 8, 6)
  graphics::par(mfrow = c(2, 2), mar = c(3, 3, 2, 1))
  for (k in k_order) {
    col <- paste0("acc_diff_K", k)
    graphics::hist(
      summary_df[[col]],
      main = paste0("H2 Opt-Orig K=", k, " (diagnostic)"),
      xlab = "accuracy difference",
      col = "grey80",
      border = "grey30"
    )
  }
  grDevices::dev.off()
  log_msg(log_path, "wrote diagnostic ", basename(p3))

  log_msg(log_path, after_note)
  message(after_note)
  c(p1, p2, p3)
}

save_study1_q8_histograms <- function(summary_df, log_path) {
  save_q8_histograms(
    summary_df,
    log_path,
    "study1",
    "Q8 diagnostics saved. Locked Q7 tests run in analyse, not here."
  )
}
