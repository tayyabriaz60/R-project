# Study 3 load + map + QC. SAP §5.4; Dictionary §6, §9–§10.

source(file.path(PROJECT_ROOT, "R", "study1_load.R"))
source(file.path(PROJECT_ROOT, "R", "utils_select_study3.R"))
source(file.path(PROJECT_ROOT, "R", "study3_map.R"))

study3_researcher_ids <- function() {
  if (identical(DATA_SOURCE, "synthetic")) {
    ids <- SAP$study3_researcher_ids_synthetic
    if (is.null(ids) || length(ids) == 0L || all(is.na(ids))) {
      stop("Synthetic Study 3 researcher ID is missing from config.", call. = FALSE)
    }
    return(as.character(ids))
  }
  ids <- SAP$study3_researcher_ids_real
  if (is.null(ids) || length(ids) == 0L || all(is.na(ids)) ||
      !any(nzchar(trimws(as.character(ids))))) {
    stop("Real Study 3 researcher identifier is not set.", call. = FALSE)
  }
  as.character(ids)
}

drop_study3_researcher <- function(df, file_label, log_path = NULL) {
  ids <- study3_researcher_ids()
  n0 <- nrow(df)
  is_r <- df$participant_id %in% ids
  n_id <- n_unique_nonempty(df$participant_id[is_r])
  if (n_id == 0L) {
    if (identical(DATA_SOURCE, "synthetic") &&
        isTRUE(SAP$study3_researcher_skip_if_unmatched_synthetic)) {
      if (!is.null(log_path)) {
        log_msg(
          log_path, file_label,
          " researcher exclusion skipped (synthetic token unmatched; N unchanged)."
        )
      }
      return(df)
    }
    stop(
      file_label, ": researcher exclusion matched 0 participant_id values.",
      call. = FALSE
    )
  }
  if (n_id > 1L) {
    stop(
      file_label, ": researcher exclusion matched ", n_id,
      " participant_id values (expected 1 session).",
      call. = FALSE
    )
  }
  out <- df[!is_r, , drop = FALSE]
  if (!is.null(log_path)) {
    log_n_flow(log_path, paste0(file_label, "_researcher_exclude"), n0, nrow(out))
    log_msg(log_path, file_label, " researcher_n_ids_matched=", n_id)
  }
  out
}

load_study3_from_path <- function(path, role, task_names, log_path) {
  raw <- read_gorilla_csv(path)
  n0 <- nrow(raw)
  raw <- drop_blank_rows(raw)
  log_n_flow(log_path, paste0(role, "_blank_drop"), n0, nrow(raw))
  raw <- filter_study3_trials(raw, role, task_names, log_path)
  raw
}

run_study3_load <- function() {
  ensure_output_dirs()
  qc_txt <- output_log_path("study3_log_data_qc")
  qc_csv <- file.path(OUTPUT_LOGS, paste0("study3_log_data_qc", OUTPUT_SUFFIX, ".csv"))
  qc_title <- if (identical(DATA_SOURCE, "synthetic")) {
    "STUDY 3 DATA QC (aggregates only; SYNTHETIC DATA: pipeline test only)"
  } else {
    "STUDY 3 DATA QC (aggregates only; real export; no participant IDs in this log)"
  }
  start_log(qc_txt, qc_title)
  log_msg(qc_txt, "DATA_SOURCE=", DATA_SOURCE)
  log_msg(qc_txt, "Study 3 combined-file split by Task Name; Q20 pairwise Response Left/Right.")

  p <- resolve_study3_file("study3_disc")
  log_msg(qc_txt, "resolved combined file=", basename(p))

  disc_raw <- load_study3_from_path(
    p, "study3_disc", c(require_param("study3_task_disc")), qc_txt
  )
  pw_raw <- load_study3_from_path(
    p, "study3_pairwise", c(require_param("study3_task_pairwise")), qc_txt
  )
  vis_raw <- load_study3_from_path(
    p, "study3_vision", c(require_param("study3_task_vision")), qc_txt
  )

  disc <- map_study3_discrimination(disc_raw, "study3_disc")
  pw <- map_study3_pairwise(pw_raw, "study3_pairwise")
  vis <- map_study3_vision(vis_raw, "study3_vision")

  disc <- apply_study3_analysis_id(disc, "study3_disc")
  pw <- apply_study3_analysis_id(pw, "study3_pairwise")
  vis <- apply_study3_analysis_id(vis, "study3_vision")

  n_raw <- n_unique_nonempty(c(disc$participant_id, pw$participant_id, vis$participant_id))
  log_msg(qc_txt, "n_unique_participant_id_before_researcher=", n_raw)
  if (identical(DATA_SOURCE, "real")) {
    log_msg(qc_txt, "real raw sessions expected=", as.integer(SAP$study3_raw_sessions_real))
  }

  disc <- drop_study3_researcher(disc, "study3_disc", qc_txt)
  pw <- drop_study3_researcher(pw, "study3_pairwise", qc_txt)
  vis <- drop_study3_researcher(vis, "study3_vision", qc_txt)

  anon_map <- make_anonymous_id_map(
    c(disc$participant_id, pw$participant_id, vis$participant_id),
    prefix = require_param("anonymous_id_prefix_study3")
  )
  disc$participant_anon_id <- unname(anon_map[disc$participant_id])
  pw$participant_anon_id <- unname(anon_map[pw$participant_id])
  vis$participant_anon_id <- unname(anon_map[vis$participant_id])

  assert_allowed_values(disc$condition, c("Original", "Optimized"), "condition", "study3_disc")
  assert_allowed_values(disc$background, SAP$background_level_order, "background", "study3_disc")
  assert_allowed_values(disc$K, SAP$k_levels_study3, "K", "study3_disc")
  assert_allowed_values(disc$difficulty_index, SAP$study3_difficulty_index_levels,
                       "difficulty_index", "study3_disc")
  assert_allowed_values(pw$background, SAP$background_level_order, "background", "study3_pairwise")

  exp_n <- as.integer(SAP$primary_n_study3)
  exp_disc <- exp_n * as.integer(SAP$disc_trials_per_participant_study3)
  exp_pw <- exp_n * as.integer(SAP$pairwise_trials_per_participant_study3)
  exp_vis <- exp_n * as.integer(SAP$vision_n_items)
  log_msg(qc_txt, "expected after researcher exclude n=", exp_n)
  log_msg(qc_txt, "expected_disc_rows=", exp_disc, " expected_pairwise_rows=", exp_pw,
          " expected_vision_rows=", exp_vis)
  assert_expected_n(nrow(disc), exp_disc, "study3_disc", DATA_SOURCE)
  assert_expected_n(nrow(pw), exp_pw, "study3_pairwise", DATA_SOURCE)
  assert_expected_n(nrow(vis), exp_vis, "study3_vision", DATA_SOURCE)

  n_id <- n_unique_nonempty(disc$participant_id)
  if (identical(DATA_SOURCE, "synthetic") && n_id != exp_n) {
    stop("Study 3: synthetic N after researcher exclude is not ", exp_n, ".", call. = FALSE)
  }
  if (identical(DATA_SOURCE, "real")) {
    exp_raw <- as.integer(SAP$study3_raw_sessions_real)
    if (n_raw != exp_raw) {
      stop(
        "Study 3 real load: unique participant_id before researcher exclude is ",
        n_raw, " but expected ", exp_raw, ".",
        call. = FALSE
      )
    }
    exp_after_r <- as.integer(SAP$study3_primary_n_after_researcher)
    if (n_id != exp_after_r) {
      stop(
        "Study 3 real load: N after researcher exclude is ", n_id,
        " but expected ", exp_after_r, ".",
        call. = FALSE
      )
    }
    log_msg(qc_txt, "real session counts verified: raw=", n_raw,
            " after_researcher=", n_id)
  }

  vis_score <- tapply(vis$vision_item_correct, vis$participant_id, sum, na.rm = TRUE)
  log_msg(qc_txt, "vision_score4_n=", sum(vis_score == 4, na.rm = TRUE),
          " vision_below4_n=", sum(vis_score < 4, na.rm = TRUE))

  qc_tab <- data.frame(
    item = c(
      "disc_rows", "pairwise_rows", "vision_rows", "n_participant_id",
      "pairwise_mapping_fail", "vision_n_score4"
    ),
    value = c(
      nrow(disc), nrow(pw), nrow(vis), n_id,
      sum(pw$mapping_fail == 1L, na.rm = TRUE),
      sum(vis_score == 4, na.rm = TRUE)
    ),
    stringsAsFactors = FALSE
  )
  write_qc_csv(qc_tab, qc_csv)
  log_msg(qc_txt, "LOAD COMPLETE.")

  list(discrimination = disc, pairwise = pw, vision = vis, qc = qc_tab)
}
