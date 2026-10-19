# Study 3 Q3/Q4 gates. 36 disc / 18 pairwise; one trial per Condition x Background x K x Difficulty.

source(file.path(PROJECT_ROOT, "R", "utils_logging.R"))
source(file.path(PROJECT_ROOT, "R", "utils_validation.R"))

study3_incomplete_cell_counts <- function(disc, pw) {
  ids <- unique(c(as.character(disc$participant_id), as.character(pw$participant_id)))
  exp_d <- as.integer(SAP$disc_trials_per_participant_study3)
  exp_p <- as.integer(SAP$pairwise_trials_per_participant_study3)
  n_disc <- vapply(ids, function(id) sum(as.character(disc$participant_id) == id), integer(1))
  n_pw <- vapply(ids, function(id) sum(as.character(pw$participant_id) == id), integer(1))
  n_short_disc <- as.integer(sum(n_disc != exp_d))
  n_short_pw <- as.integer(sum(n_pw != exp_p))
  cell_n <- stats::aggregate(
    accuracy ~ participant_id + condition + background + K + difficulty_index,
    data = disc,
    FUN = length
  )
  n_bad_cells <- as.integer(sum(cell_n$accuracy != 1L))
  n_expected_cells <- n_unique_nonempty(disc$participant_id) *
    length(unique(disc$condition)) *
    length(unique(disc$background)) *
    length(unique(disc$K)) *
    length(SAP$study3_difficulty_index_levels)
  n_missing_cells <- as.integer(n_expected_cells - nrow(cell_n))
  list(
    n_short_disc = n_short_disc,
    n_short_pw = n_short_pw,
    n_bad_cells = n_bad_cells,
    n_missing_cells = n_missing_cells
  )
}

gate_study3_pairwise_mapping_q3 <- function(pw, log_path) {
  n_fail <- as.integer(sum(pw$mapping_fail == 1L, na.rm = TRUE))
  log_msg(log_path, "Q3 gate mapping_fail_rows=", n_fail)
  if (n_fail > 0L) {
    stop(
      "Q3 GATE (Study 3): ", n_fail,
      " pairwise rows failed mapping. Flagged and stopped.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

gate_study3_incomplete_cells_q4 <- function(disc, pw, log_path) {
  cts <- study3_incomplete_cell_counts(disc, pw)
  log_msg(log_path, "Q4 gate n_short_disc_ids=", cts$n_short_disc,
          " n_short_pw_ids=", cts$n_short_pw,
          " n_cells_ne_1=", cts$n_bad_cells,
          " n_missing_cells=", cts$n_missing_cells)
  if (cts$n_short_disc > 0L || cts$n_short_pw > 0L ||
      cts$n_bad_cells > 0L || cts$n_missing_cells > 0L) {
    stop(
      "Q4 GATE (Study 3): incomplete structure. ",
      "disc_ne_36=", cts$n_short_disc,
      " pw_ne_18=", cts$n_short_pw,
      " cells_ne_1=", cts$n_bad_cells,
      " missing_cells=", cts$n_missing_cells,
      call. = FALSE
    )
  }
  invisible(TRUE)
}
