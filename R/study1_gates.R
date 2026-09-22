# Q3 / Q4 analysis gates. Flag and STOP. Do not auto-drop, impute, or recode.

source(file.path(PROJECT_ROOT, "R", "utils_logging.R"))
source(file.path(PROJECT_ROOT, "R", "utils_validation.R"))

count_mapping_fail <- function(pw) {
  as.integer(sum(pw$mapping_fail == 1L, na.rm = TRUE))
}

# Incomplete: not 24 disc / 12 pairwise, or a Condition×K cell without 3 instances.
incomplete_cell_counts <- function(disc, pw) {
  ids <- unique(c(as.character(disc$participant_id), as.character(pw$participant_id)))
  exp_d <- as.integer(SAP$disc_trials_per_participant)
  exp_p <- as.integer(SAP$pairwise_trials_per_participant)
  n_disc <- vapply(ids, function(id) sum(as.character(disc$participant_id) == id), integer(1))
  n_pw <- vapply(ids, function(id) sum(as.character(pw$participant_id) == id), integer(1))
  n_short_disc <- as.integer(sum(n_disc != exp_d))
  n_short_pw <- as.integer(sum(n_pw != exp_p))
  cell_n <- stats::aggregate(
    accuracy ~ participant_id + condition + K,
    data = disc,
    FUN = length
  )
  exp_inst <- as.integer(SAP$n_configuration_instances)
  n_bad_cells <- as.integer(sum(cell_n$accuracy != exp_inst))
  n_expected_cells <- n_unique_nonempty(disc$participant_id) *
    length(unique(disc$condition)) * length(unique(disc$K))
  n_missing_cells <- as.integer(n_expected_cells - nrow(cell_n))
  list(
    n_short_disc = n_short_disc,
    n_short_pw = n_short_pw,
    n_bad_cells = n_bad_cells,
    n_missing_cells = n_missing_cells
  )
}

gate_pairwise_mapping_q3 <- function(pw, log_path) {
  n_fail <- count_mapping_fail(pw)
  log_msg(log_path, "Q3 gate mapping_fail_rows=", n_fail, " rule=", require_param("pairwise_failed_row_rule"))
  if (n_fail > 0L) {
    stop(
      "Q3 GATE: ", n_fail,
      " pairwise rows could not be mapped unambiguously. ",
      "Flagged and stopped. Do not guess, exclude, or recode automatically. ",
      "See the QC / clean log (counts only).",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

gate_incomplete_cells_q4 <- function(disc, pw, log_path) {
  cts <- incomplete_cell_counts(disc, pw)
  log_msg(log_path, "Q4 gate n_short_disc_ids=", cts$n_short_disc,
          " n_short_pw_ids=", cts$n_short_pw,
          " n_cells_not_3_instances=", cts$n_bad_cells,
          " n_missing_cells=", cts$n_missing_cells)
  if (cts$n_short_disc > 0L || cts$n_short_pw > 0L ||
      cts$n_bad_cells > 0L || cts$n_missing_cells > 0L) {
    stop(
      "Q4 GATE: incomplete structure. ",
      "n_ids_with_disc_ne_24=", cts$n_short_disc,
      " n_ids_with_pw_ne_12=", cts$n_short_pw,
      " n_cells_ne_3=", cts$n_bad_cells,
      " n_missing_cells=", cts$n_missing_cells,
      ". Flagged and stopped. Do not auto-exclude or compute from incomplete cells.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}
