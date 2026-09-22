# Study 1 load + map + QC. Dictionary v2 §3–§4, §7–§10. SAP §3.4 N / trial structure.
# Applies: Object Name filter (Q5), configurable participant_id + anon reporting ID (Q6).
# Does NOT: Q2 duplicate-dedup / exclusions, Q3 analysis-time stop, Q4 incomplete-cell
# stop, Q1 vision-subset as a primary exclusion, or any hypothesis test.

source(file.path(PROJECT_ROOT, "R", "utils_paths.R"))
source(file.path(PROJECT_ROOT, "R", "utils_logging.R"))
source(file.path(PROJECT_ROOT, "R", "utils_validation.R"))
source(file.path(PROJECT_ROOT, "R", "utils_io.R"))
source(file.path(PROJECT_ROOT, "R", "utils_select.R"))

STUDY1_DISC_RAW <- c(
  "Participant Public ID", "Participant Private ID",
  "Task Name", "Response Type", "Object Name",
  "Response", "Reaction Time", "Correct",
  "Spreadsheet: condition", "Spreadsheet: colormap",
  "Spreadsheet: num_classes", "Spreadsheet: variation",
  "Spreadsheet: image", "Spreadsheet: correct_answer"
)

STUDY1_PW_RAW <- c(
  "Participant Public ID", "Participant Private ID",
  "Task Name", "Response Type", "Object Name",
  "Response", "Reaction Time",
  "Spreadsheet: trial_number", "Spreadsheet: image_left",
  "Spreadsheet: image_right", "Spreadsheet: left_option",
  "Spreadsheet: right_option"
)

STUDY1_VIS_RAW <- c(
  "Participant Public ID", "Participant Private ID",
  "Task Name", "Response Type", "Object Name",
  "Response", "Correct",
  "Spreadsheet: tag", "Spreadsheet: correct_answer"
)

# Dictionary §4.1: baseline → Original; sa → Optimized.
recode_condition_study1 <- function(x, file_label) {
  x <- as.character(x)
  out <- rep(NA_character_, length(x))
  out[x == "baseline"] <- "Original"
  out[x == "sa"] <- "Optimized"
  unknown <- unique(x[!is.na(x) & !x %in% c("baseline", "sa")])
  if (length(unknown) > 0L) {
    stop(file_label, ": unknown Spreadsheet: condition values: ",
         paste(unknown, collapse = ", "), call. = FALSE)
  }
  out
}

map_study1_discrimination <- function(raw, file_label) {
  require_columns(raw, STUDY1_DISC_RAW, file_label)
  resp <- suppressWarnings(as.numeric(raw[["Response"]]))
  ans <- suppressWarnings(as.numeric(raw[["Spreadsheet: correct_answer"]]))
  rt <- suppressWarnings(as.numeric(raw[["Reaction Time"]]))
  correct_raw <- suppressWarnings(as.numeric(raw[["Correct"]]))
  acc <- as.integer(resp == ans)
  acc[is.na(resp) | is.na(ans)] <- NA_integer_
  mismatch <- as.integer(!is.na(correct_raw) & !is.na(acc) & correct_raw != acc)
  event_index <- if ("Event Index" %in% names(raw)) {
    suppressWarnings(as.integer(raw[["Event Index"]]))
  } else {
    NA_integer_
  }
  data.frame(
    participant_public_id = as.character(raw[["Participant Public ID"]]),
    participant_private_id = as.character(raw[["Participant Private ID"]]),
    participant_id = NA_character_,  # set in run_study1_load (Q6)
    participant_anon_id = NA_character_,
    event_index = event_index,
    task_name = raw[["Task Name"]],
    response_type = raw[["Response Type"]],
    object_name = raw[["Object Name"]],
    condition = recode_condition_study1(raw[["Spreadsheet: condition"]], file_label),
    colormap_raw = raw[["Spreadsheet: colormap"]],
    K = as.integer(raw[["Spreadsheet: num_classes"]]),
    configuration_instance = as.integer(raw[["Spreadsheet: variation"]]),
    image = raw[["Spreadsheet: image"]],
    response_count = resp,
    correct_answer = ans,
    accuracy = acc,
    correct_raw = correct_raw,
    correct_mismatch = mismatch,
    reaction_time_ms = rt,
    signed_error = resp - ans,
    absolute_error = abs(resp - ans),
    stringsAsFactors = FALSE
  )
}

# Brief §4 / Dictionary §4.2: reconstruct side; do not use Response words as condition.
# Q3: do not drop failed rows; flag only.
map_study1_pairwise <- function(raw, file_label) {
  require_columns(raw, STUDY1_PW_RAW, file_label)
  resp <- as.character(raw[["Response"]])
  left_opt <- as.character(raw[["Spreadsheet: left_option"]])
  right_opt <- as.character(raw[["Spreadsheet: right_option"]])
  img_l <- as.character(raw[["Spreadsheet: image_left"]])
  img_r <- as.character(raw[["Spreadsheet: image_right"]])
  preferred <- rep(NA_character_, nrow(raw))
  preferred[resp == left_opt] <- "left"
  preferred[resp == right_opt] <- "right"
  side_unmatched <- as.integer(is.na(preferred))
  left_is_opt <- grepl("optimized", img_l, ignore.case = TRUE)
  right_is_opt <- grepl("optimized", img_r, ignore.case = TRUE)
  opt_side <- rep(NA_character_, nrow(raw))
  opt_side[left_is_opt & !right_is_opt] <- "left"
  opt_side[right_is_opt & !left_is_opt] <- "right"
  one_and_one_fail <- as.integer(!(xor(left_is_opt, right_is_opt)))
  chose <- as.integer(!is.na(preferred) & !is.na(opt_side) & preferred == opt_side)
  chose[side_unmatched == 1L | one_and_one_fail == 1L] <- NA_integer_
  mapping_fail <- as.integer(side_unmatched == 1L | one_and_one_fail == 1L)
  event_index <- if ("Event Index" %in% names(raw)) {
    suppressWarnings(as.integer(raw[["Event Index"]]))
  } else {
    NA_integer_
  }
  data.frame(
    participant_public_id = as.character(raw[["Participant Public ID"]]),
    participant_private_id = as.character(raw[["Participant Private ID"]]),
    participant_id = NA_character_,  # set in run_study1_load (Q6)
    participant_anon_id = NA_character_,
    event_index = event_index,
    task_name = raw[["Task Name"]],
    response_type = raw[["Response Type"]],
    object_name = raw[["Object Name"]],
    trial_number = as.integer(raw[["Spreadsheet: trial_number"]]),
    image_left = img_l,
    image_right = img_r,
    left_option = left_opt,
    right_option = right_opt,
    response_raw = resp,
    preferred_side = preferred,
    optimized_side = opt_side,
    chose_optimized = chose,
    mapping_fail = mapping_fail,
    reaction_time_ms = suppressWarnings(as.numeric(raw[["Reaction Time"]])),
    stringsAsFactors = FALSE
  )
}

map_study1_vision <- function(raw, file_label) {
  require_columns(raw, STUDY1_VIS_RAW, file_label)
  resp <- suppressWarnings(as.numeric(raw[["Response"]]))
  ans <- suppressWarnings(as.numeric(raw[["Spreadsheet: correct_answer"]]))
  item_ok <- as.integer(resp == ans)
  item_ok[is.na(resp) | is.na(ans)] <- NA_integer_
  event_index <- if ("Event Index" %in% names(raw)) {
    suppressWarnings(as.integer(raw[["Event Index"]]))
  } else {
    NA_integer_
  }
  data.frame(
    participant_public_id = as.character(raw[["Participant Public ID"]]),
    participant_private_id = as.character(raw[["Participant Private ID"]]),
    participant_id = NA_character_,  # set in run_study1_load (Q6)
    participant_anon_id = NA_character_,
    event_index = event_index,
    task_name = raw[["Task Name"]],
    response_type = raw[["Response Type"]],
    object_name = raw[["Object Name"]],
    vision_item = raw[["Spreadsheet: tag"]],
    vision_response = resp,
    vision_correct_answer = ans,
    vision_item_correct = item_ok,
    vision_subset_flag = NA,  # set in run_study1_load (Q1 flag only; not an exclusion)
    stringsAsFactors = FALSE
  )
}

load_one_raw <- function(path, file_label, log_path, object_name_expected) {
  raw <- read_gorilla_csv(path)
  n0 <- nrow(raw)
  raw <- drop_blank_rows(raw)
  log_n_flow(log_path, paste0(file_label, "_blank_drop"), n0, nrow(raw))
  raw <- filter_object_name(raw, object_name_expected, file_label, log_path)
  raw
}

rows_per_id_counts <- function(id) {
  tab <- table(id, useNA = "ifany")
  paste(names(table(as.integer(tab))), "=", as.integer(table(as.integer(tab))), collapse = "; ")
}

run_study1_load <- function() {
  if (!identical(DATA_SOURCE, "synthetic")) {
    stop(
      "DATA_SOURCE is not synthetic. Real-export file names are NOT SPECIFIED. ",
      "Keep DATA_SOURCE <- \"synthetic\" until the client documents real paths.",
      call. = FALSE
    )
  }
  ensure_output_dirs()
  qc_txt <- output_log_path("study1_log_data_qc")
  qc_csv <- file.path(OUTPUT_LOGS, paste0("study1_log_data_qc", OUTPUT_SUFFIX, ".csv"))
  start_log(qc_txt, "STUDY 1 DATA QC (aggregates only; SYNTHETIC DATA: pipeline test only)")
  log_msg(qc_txt, "Applied at load: Q5 Object Name filter; Q6 participant_id from ",
          require_param("study1_id_column"), " + anonymous reporting IDs")
  log_msg(qc_txt, "Not applied at load: Q2 exclusions/dedup; Q3 pairwise analysis stop; Q4 incomplete-cell stop; Q1 vision subset as exclusion")

  g1 <- load_one_raw(SYNTHETIC_FILES$study1_disc_g1, "study1_disc_g1", qc_txt, require_param("object_name_disc"))
  g2 <- load_one_raw(SYNTHETIC_FILES$study1_disc_g2, "study1_disc_g2", qc_txt, require_param("object_name_disc"))
  disc <- rbind(
    map_study1_discrimination(g1, "study1_disc_g1"),
    map_study1_discrimination(g2, "study1_disc_g2")
  )
  pw_raw <- load_one_raw(SYNTHETIC_FILES$study1_pairwise, "study1_pairwise", qc_txt, require_param("object_name_pairwise"))
  pw <- map_study1_pairwise(pw_raw, "study1_pairwise")
  vis_raw <- load_one_raw(SYNTHETIC_FILES$study1_vision, "study1_vision", qc_txt, require_param("object_name_vision"))
  vis <- map_study1_vision(vis_raw, "study1_vision")

  disc <- apply_study1_analysis_id(disc, "study1_disc")
  pw <- apply_study1_analysis_id(pw, "study1_pairwise")
  vis <- apply_study1_analysis_id(vis, "study1_vision")
  anon_map <- make_anonymous_id_map(
    c(disc$participant_id, pw$participant_id, vis$participant_id),
    prefix = require_param("anonymous_id_prefix_study1")
  )
  disc$participant_anon_id <- unname(anon_map[disc$participant_id])
  pw$participant_anon_id <- unname(anon_map[pw$participant_id])
  vis$participant_anon_id <- unname(anon_map[vis$participant_id])
  if (any(is.na(disc$participant_anon_id)) || any(is.na(pw$participant_anon_id)) ||
      any(is.na(vis$participant_anon_id))) {
    stop("Anonymous ID mapping left NA values. Do not print source IDs.", call. = FALSE)
  }

  assert_allowed_values(disc$condition, c("Original", "Optimized"), "condition", "study1_disc")
  assert_allowed_values(disc$K, SAP$k_levels_study1, "K", "study1_disc")
  assert_allowed_values(disc$configuration_instance, c(1, 2, 3), "configuration_instance", "study1_disc")
  assert_allowed_values(disc$task_name, c("Discrimination Task G1", "Discrimination Task G2"), "task_name", "study1_disc")
  assert_allowed_values(disc$response_type, "response", "response_type", "study1_disc")
  assert_allowed_values(pw$task_name, "Pairwise Comparison Task2", "task_name", "study1_pairwise")
  assert_allowed_values(vis$task_name, "Vision Check", "task_name", "study1_vision")
  assert_allowed_values(vis$vision_item, c("Q1_answer", "Q2_answer", "Q3_answer", "Q4_answer"), "vision_item", "study1_vision")
  assert_allowed_values(vis$vision_correct_answer, SAP$vision_correct_keys, "vision_correct_answer", "study1_vision")

  exp_disc <- as.integer(SAP$primary_n_study1) * as.integer(SAP$disc_trials_per_participant)
  exp_pw <- as.integer(SAP$primary_n_study1) * as.integer(SAP$pairwise_trials_per_participant)
  exp_vis <- as.integer(SAP$primary_n_study1) * as.integer(SAP$vision_n_items)
  log_msg(qc_txt, "expected_disc_rows (primary_n * 24)=", exp_disc)
  log_msg(qc_txt, "expected_pairwise_rows (primary_n * 12)=", exp_pw)
  log_msg(qc_txt, "expected_vision_rows (primary_n * 4)=", exp_vis)
  assert_expected_n(nrow(disc), exp_disc, "study1_disc", DATA_SOURCE)
  assert_expected_n(nrow(pw), exp_pw, "study1_pairwise", DATA_SOURCE)
  assert_expected_n(nrow(vis), exp_vis, "study1_vision", DATA_SOURCE)

  log_msg(qc_txt, "disc_rows=", nrow(disc),
          " n_unique_participant_id=", n_unique_nonempty(disc$participant_id),
          " n_unique_anon=", n_unique_nonempty(disc$participant_anon_id),
          " n_unique_private_qa_only=", n_unique_nonempty(disc$participant_private_id))
  log_msg(qc_txt, "disc_rows_per_participant_id (count of n_rows): ",
          rows_per_id_counts(disc$participant_id))
  log_msg(qc_txt, "disc_condition_counts: Original=", sum(disc$condition == "Original"),
          " Optimized=", sum(disc$condition == "Optimized"))
  log_msg(qc_txt, "disc_K_counts: ", paste(names(table(disc$K)), "=", as.integer(table(disc$K)), collapse = "; "))
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
  # Score by analysis ID for QC count only. Flag is computed; population is not reduced (Q1).
  vis_score <- tapply(vis$vision_item_correct, vis$participant_id, sum, na.rm = TRUE)
  vis$vision_subset_flag <- as.integer(unname(vis_score[vis$participant_id]) == 4)
  log_msg(qc_txt, "vision_score_by_participant_id: n_score4=",
          sum(vis_score == 4, na.rm = TRUE), " n_below4=", sum(vis_score < 4, na.rm = TRUE),
          " (Q1: flag computed; not used as a primary exclusion)")
  log_msg(qc_txt, "vision_subset_flag n_true_rows=",
          sum(vis$vision_subset_flag == 1L, na.rm = TRUE),
          " n_false_rows=", sum(vis$vision_subset_flag == 0L, na.rm = TRUE))
  log_msg(qc_txt, "participant_id missing=",
          sum(is.na(disc$participant_id)) + sum(is.na(pw$participant_id)) + sum(is.na(vis$participant_id)),
          " (must be 0)")
  log_msg(qc_txt, "reporting_id_scheme=", require_param("anonymous_id_prefix_study1"),
          "001..; source Gorilla IDs are not written to this log")

  qc_tab <- data.frame(
    item = c(
      "disc_rows", "pairwise_rows", "vision_rows",
      "disc_n_participant_id", "pairwise_n_participant_id", "vision_n_participant_id",
      "disc_n_anon", "disc_correct_mismatch", "pairwise_mapping_fail",
      "vision_n_score4", "vision_subset_applied_as_exclusion",
      "exclusions_applied", "object_name_filter_applied"
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
      0, 0, 1
    ),
    stringsAsFactors = FALSE
  )
  write_qc_csv(qc_tab, qc_csv)
  log_msg(qc_txt, "Wrote study1_log_data_qc CSV (aggregates). LOAD COMPLETE. No tests run.")

  list(discrimination = disc, pairwise = pw, vision = vis, qc = qc_tab)
}
