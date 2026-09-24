# Study 2 load + map + QC. SAP §4; Dictionary §5, §9–§10.
# Applies: Object Name filter (Q5), Task Name split, participant_id, researcher
# exclusion (SAP §4.4; synthetic ID only — real ID is Q18).
# Does NOT: Q31 dedup, Q3/Q4 gates, vision-subset as a primary exclusion,
# H1–H3, or any Q7 test choice (Q32).

source(file.path(PROJECT_ROOT, "R", "study1_load.R"))

study2_researcher_ids <- function() {
  if (identical(DATA_SOURCE, "synthetic")) {
    ids <- SAP$study2_researcher_ids_synthetic
    if (is.null(ids) || length(ids) == 0L || all(is.na(ids))) {
      stop("Synthetic Study 2 researcher ID is missing from config.", call. = FALSE)
    }
    return(as.character(ids))
  }
  ids <- SAP$study2_researcher_ids_real
  if (is.null(ids) || length(ids) == 0L || all(is.na(ids)) ||
      !any(nzchar(trimws(as.character(ids))))) {
    todo_client_question(
      18,
      "real Study 2 researcher identifier is not set. Cannot exclude the researcher session."
    )
  }
  as.character(ids)
}

# SAP §4.4 / Brief §6.1. Logs aggregates only. Never prints the source ID.
drop_study2_researcher <- function(df, file_label, log_path = NULL) {
  ids <- study2_researcher_ids()
  n0 <- nrow(df)
  is_r <- df$participant_id %in% ids
  n_id <- n_unique_nonempty(df$participant_id[is_r])
  out <- df[!is_r, , drop = FALSE]
  if (!is.null(log_path)) {
    log_n_flow(log_path, paste0(file_label, "_researcher_exclude"), n0, nrow(out))
    log_msg(log_path, file_label, " researcher_n_ids_matched=", n_id)
  }
  if (n_id == 0L) {
    stop(
      file_label, ": researcher exclusion matched 0 participant_id values. ",
      if (identical(DATA_SOURCE, "synthetic")) {
        "Synthetic expected one researcher session."
      } else {
        "Check the Q18 identifier. Do not guess another ID."
      },
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
  out
}

load_study2_role <- function(role, object_name_expected, task_name_expected, log_path) {
  path <- resolve_study2_file(role)
  raw <- read_gorilla_csv(path)
  n0 <- nrow(raw)
  raw <- drop_blank_rows(raw)
  log_n_flow(log_path, paste0(role, "_blank_drop"), n0, nrow(raw))
  raw <- filter_task_name(raw, task_name_expected, role, log_path)
  raw <- filter_object_name(raw, object_name_expected, role, log_path)
  raw
}

run_study2_load <- function() {
  ensure_output_dirs()
  qc_txt <- output_log_path("study2_log_data_qc")
  qc_csv <- file.path(OUTPUT_LOGS, paste0("study2_log_data_qc", OUTPUT_SUFFIX, ".csv"))
  qc_title <- if (identical(DATA_SOURCE, "synthetic")) {
    "STUDY 2 DATA QC (aggregates only; SYNTHETIC DATA: pipeline test only)"
  } else {
    "STUDY 2 DATA QC (aggregates only; real export; no participant IDs in this log)"
  }
  start_log(qc_txt, qc_title)
  log_msg(qc_txt, "DATA_SOURCE=", DATA_SOURCE)
  log_msg(qc_txt, "Applied at load: Q5 Object Name; Dict §10 Task Name; Q6-style ID; SAP §4.4 researcher exclude")
  log_msg(qc_txt, "Not applied at load: Q31 dedup; Q3/Q4 gates; Q1 vision subset as exclusion; H1-H3; Q32 test path")

  p_g1 <- resolve_study2_file("study2_disc_g1")
  p_g2 <- resolve_study2_file("study2_disc_g2")
  p_pw <- resolve_study2_file("study2_pairwise")
  p_vis <- resolve_study2_file("study2_vision")
  log_msg(qc_txt, "resolved files: disc_g1=", basename(p_g1),
          " disc_g2=", basename(p_g2),
          " pairwise=", basename(p_pw),
          " vision=", basename(p_vis))

  g1 <- load_study2_role(
    "study2_disc_g1", require_param("object_name_disc"),
    require_param("study2_task_disc_g1"), qc_txt
  )
  g2 <- load_study2_role(
    "study2_disc_g2", require_param("object_name_disc"),
    require_param("study2_task_disc_g2"), qc_txt
  )
  disc <- rbind(
    map_study1_discrimination(g1, "study2_disc_g1"),
    map_study1_discrimination(g2, "study2_disc_g2")
  )
  disc$difficulty_index <- disc$configuration_instance
  pw_raw <- load_study2_role(
    "study2_pairwise", require_param("object_name_pairwise"),
    require_param("study2_task_pairwise"), qc_txt
  )
  pw <- map_study1_pairwise(pw_raw, "study2_pairwise")
  vis_raw <- load_study2_role(
    "study2_vision", require_param("object_name_vision"),
    require_param("study2_task_vision"), qc_txt
  )
  vis <- map_study1_vision(vis_raw, "study2_vision")

  disc <- apply_study2_analysis_id(disc, "study2_disc")
  pw <- apply_study2_analysis_id(pw, "study2_pairwise")
  vis <- apply_study2_analysis_id(vis, "study2_vision")

  log_msg(qc_txt, "before_researcher_exclude n_unique_participant_id=",
          n_unique_nonempty(c(disc$participant_id, pw$participant_id, vis$participant_id)))
  disc <- drop_study2_researcher(disc, "study2_disc", qc_txt)
  pw <- drop_study2_researcher(pw, "study2_pairwise", qc_txt)
  vis <- drop_study2_researcher(vis, "study2_vision", qc_txt)

  anon_map <- make_anonymous_id_map(
    c(disc$participant_id, pw$participant_id, vis$participant_id),
    prefix = require_param("anonymous_id_prefix_study2")
  )
  disc$participant_anon_id <- unname(anon_map[disc$participant_id])
  pw$participant_anon_id <- unname(anon_map[pw$participant_id])
  vis$participant_anon_id <- unname(anon_map[vis$participant_id])
  if (any(is.na(disc$participant_anon_id)) || any(is.na(pw$participant_anon_id)) ||
      any(is.na(vis$participant_anon_id))) {
    stop("Anonymous ID mapping left NA values. Do not print source IDs.", call. = FALSE)
  }

  assert_allowed_values(disc$condition, c("Original", "Optimized"), "condition", "study2_disc")
  assert_allowed_values(disc$K, SAP$k_levels_study2, "K", "study2_disc")
  assert_allowed_values(disc$difficulty_index, SAP$study2_difficulty_index_levels,
                       "difficulty_index", "study2_disc")
  assert_allowed_values(disc$response_type, "response", "response_type", "study2_disc")
  if (identical(DATA_SOURCE, "synthetic")) {
    assert_allowed_values(
      disc$task_name,
      c(SAP$study2_task_disc_g1, SAP$study2_task_disc_g2),
      "task_name", "study2_disc"
    )
    assert_allowed_values(pw$task_name, SAP$study2_task_pairwise, "task_name", "study2_pairwise")
    assert_allowed_values(vis$task_name, SAP$study2_task_vision, "task_name", "study2_vision")
  } else {
    log_msg(qc_txt, "real task_name unique_n disc=", n_unique_nonempty(disc$task_name),
            " pairwise=", n_unique_nonempty(pw$task_name),
            " vision=", n_unique_nonempty(vis$task_name),
            " (names not logged)")
  }
  assert_allowed_values(vis$vision_item, c("Q1_answer", "Q2_answer", "Q3_answer", "Q4_answer"),
                       "vision_item", "study2_vision")
  assert_allowed_values(vis$vision_correct_answer, SAP$vision_correct_keys,
                       "vision_correct_answer", "study2_vision")

  exp_disc <- as.integer(SAP$primary_n_study2) * as.integer(SAP$disc_trials_per_participant)
  exp_pw <- as.integer(SAP$primary_n_study2) * as.integer(SAP$pairwise_trials_per_participant)
  exp_vis <- as.integer(SAP$primary_n_study2) * as.integer(SAP$vision_n_items)
  log_msg(qc_txt, "expected_disc_rows (primary_n * 24)=", exp_disc)
  log_msg(qc_txt, "expected_pairwise_rows (primary_n * 12)=", exp_pw)
  log_msg(qc_txt, "expected_vision_rows (primary_n * 4)=", exp_vis)
  assert_expected_n(nrow(disc), exp_disc, "study2_disc", DATA_SOURCE)
  assert_expected_n(nrow(pw), exp_pw, "study2_pairwise", DATA_SOURCE)
  assert_expected_n(nrow(vis), exp_vis, "study2_vision", DATA_SOURCE)

  log_msg(qc_txt, "disc_rows=", nrow(disc),
          " n_unique_participant_id=", n_unique_nonempty(disc$participant_id),
          " n_unique_anon=", n_unique_nonempty(disc$participant_anon_id))
  log_msg(qc_txt, "disc_rows_per_participant_id (count of n_rows): ",
          rows_per_id_counts(disc$participant_id))
  log_msg(qc_txt, "disc_condition_counts: Original=", sum(disc$condition == "Original"),
          " Optimized=", sum(disc$condition == "Optimized"))
  log_msg(qc_txt, "disc_K_counts: ", paste(names(table(disc$K)), "=", as.integer(table(disc$K)),
                                          collapse = "; "))
  log_msg(qc_txt, "disc_difficulty_index_counts: ",
          paste(names(table(disc$difficulty_index)), "=",
                as.integer(table(disc$difficulty_index)), collapse = "; "))
  log_msg(qc_txt, "disc_object_name_missing=", n_missing(disc$object_name),
          " disc_object_name_expected=", require_param("object_name_disc"))
  log_msg(qc_txt, "disc_correct_mismatch_rows=", sum(disc$correct_mismatch == 1L, na.rm = TRUE))
  log_msg(qc_txt, "disc_duplicate_rows=", count_duplicate_rows(disc))
  log_msg(qc_txt, "disc_rt_missing=", n_missing(disc$reaction_time_ms),
          " disc_rt_nonpositive=", sum(!is.na(disc$reaction_time_ms) & disc$reaction_time_ms <= 0))

  log_msg(qc_txt, "pairwise_rows=", nrow(pw),
          " n_unique_participant_id=", n_unique_nonempty(pw$participant_id))
  log_msg(qc_txt, "pairwise_rows_per_participant_id: ", rows_per_id_counts(pw$participant_id))
  log_msg(qc_txt, "pairwise_mapping_fail_rows=", sum(pw$mapping_fail == 1L, na.rm = TRUE),
          " (Q3: counted at load; flag-and-stop runs in prepare)")
  log_msg(qc_txt, "pairwise_object_name_missing=", n_missing(pw$object_name),
          " pairwise_object_name_expected=", require_param("object_name_pairwise"))
  log_msg(qc_txt, "pairwise_duplicate_rows=", count_duplicate_rows(pw))

  log_msg(qc_txt, "vision_rows=", nrow(vis),
          " n_unique_participant_id=", n_unique_nonempty(vis$participant_id))
  log_msg(qc_txt, "vision_rows_per_participant_id: ", rows_per_id_counts(vis$participant_id))
  log_msg(qc_txt, "vision_object_name_missing=", n_missing(vis$object_name),
          " vision_object_name_expected=", require_param("object_name_vision"))
  vis_score <- tapply(vis$vision_item_correct, vis$participant_id, sum, na.rm = TRUE)
  vis$vision_subset_flag <- as.integer(unname(vis_score[vis$participant_id]) == 4)
  log_msg(qc_txt, "vision_score_by_participant_id: n_score4=",
          sum(vis_score == 4, na.rm = TRUE), " n_below4=", sum(vis_score < 4, na.rm = TRUE),
          " (SAP §4.4 expected 43; flag only; not a primary exclusion)")
  log_msg(qc_txt, "vision_subset_flag n_true_rows=",
          sum(vis$vision_subset_flag == 1L, na.rm = TRUE),
          " n_false_rows=", sum(vis$vision_subset_flag == 0L, na.rm = TRUE))
  log_msg(qc_txt, "participant_id missing=",
          sum(is.na(disc$participant_id)) + sum(is.na(pw$participant_id)) +
            sum(is.na(vis$participant_id)),
          " (must be 0)")
  log_msg(qc_txt, "reporting_id_scheme=", require_param("anonymous_id_prefix_study2"),
          "001..; source Gorilla IDs are not written to this log")

  qc_tab <- data.frame(
    item = c(
      "disc_rows", "pairwise_rows", "vision_rows",
      "disc_n_participant_id", "pairwise_n_participant_id", "vision_n_participant_id",
      "disc_n_anon", "disc_correct_mismatch", "pairwise_mapping_fail",
      "vision_n_score4", "vision_subset_applied_as_exclusion",
      "researcher_excluded", "object_name_filter_applied"
    ),
    value = c(
      nrow(disc), nrow(pw), nrow(vis),
      n_unique_nonempty(disc$participant_id),
      n_unique_nonempty(pw$participant_id),
      n_unique_nonempty(vis$participant_id),
      n_unique_nonempty(disc$participant_anon_id),
      sum(disc$correct_mismatch == 1L, na.rm = TRUE),
      sum(pw$mapping_fail == 1L, na.rm = TRUE),
      sum(vis_score == 4, na.rm = TRUE),
      0, 1, 1
    ),
    stringsAsFactors = FALSE
  )
  write_qc_csv(qc_tab, qc_csv)
  log_msg(qc_txt, "Wrote study2_log_data_qc CSV (aggregates). LOAD COMPLETE. No tests run.")

  list(discrimination = disc, pairwise = pw, vision = vis, qc = qc_tab)
}
