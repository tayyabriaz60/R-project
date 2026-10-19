# Study 3 variable mapping. Dictionary §6; Brief §7.

STUDY3_DISC_RAW <- c(
  "Participant Public ID", "Participant Private ID",
  "Event Index", "UTC Timestamp",
  "Task Name", "Response Type", "Object Name",
  "Response", "Reaction Time", "Correct",
  "Spreadsheet: condition", "Spreadsheet: background",
  "Spreadsheet: num_classes", "Spreadsheet: difficulty_num",
  "Spreadsheet: difficulty_label", "Spreadsheet: image",
  "Spreadsheet: correct_answer", "Spreadsheet: participant_group",
  "Spreadsheet: condition_order", "Spreadsheet: block_order"
)

STUDY3_PW_RAW <- c(
  "Participant Public ID", "Participant Private ID",
  "Event Index", "UTC Timestamp",
  "Task Name", "Response Type", "Object Name",
  "Response", "Reaction Time",
  "Spreadsheet: trial_number", "Spreadsheet: trial_id",
  "Spreadsheet: background", "Spreadsheet: num_classes",
  "Spreadsheet: difficulty_num", "Spreadsheet: difficulty_label",
  "Spreadsheet: image_left", "Spreadsheet: image_right",
  "Spreadsheet: optimized_side"
)

STUDY3_VIS_RAW <- c(
  "Participant Public ID", "Participant Private ID",
  "Event Index", "UTC Timestamp",
  "Task Name", "Response Type", "Object Name",
  "Response", "Correct",
  "Spreadsheet: tag", "Spreadsheet: correct_answer"
)

recode_condition_study3 <- function(x, file_label) {
  x <- as.character(x)
  out <- rep(NA_character_, length(x))
  out[grepl("^C1", x, ignore.case = TRUE)] <- "Original"
  out[grepl("^C2", x, ignore.case = TRUE)] <- "Optimized"
  unknown <- unique(x[!is.na(x) & is.na(out)])
  if (length(unknown) > 0L) {
    stop(file_label, ": unknown Spreadsheet: condition values: ",
         paste(unknown, collapse = ", "), call. = FALSE)
  }
  out
}

recode_background_study3 <- function(x, file_label) {
  x <- tolower(trimws(as.character(x)))
  out <- rep(NA_character_, length(x))
  out[x == "white"] <- "White"
  out[x == "black"] <- "Black"
  unknown <- unique(x[!is.na(x) & nzchar(x) & is.na(out)])
  if (length(unknown) > 0L) {
    stop(file_label, ": unknown Spreadsheet: background values: ",
         paste(unknown, collapse = ", "), call. = FALSE)
  }
  out
}

side_from_response_lr <- function(resp) {
  resp <- as.character(resp)
  out <- rep(NA_character_, length(resp))
  out[resp == "Left"] <- "left"
  out[resp == "Right"] <- "right"
  out
}

side_from_spreadsheet_lr <- function(x) {
  x <- as.character(x)
  out <- rep(NA_character_, length(x))
  out[tolower(x) == "left"] <- "left"
  out[tolower(x) == "right"] <- "right"
  out
}

optimized_side_from_images <- function(img_l, img_r) {
  img_l <- as.character(img_l)
  img_r <- as.character(img_r)
  left_opt <- grepl("_opt_", img_l, ignore.case = TRUE) | grepl("opt_", img_l, ignore.case = TRUE)
  right_opt <- grepl("_opt_", img_r, ignore.case = TRUE) | grepl("opt_", img_r, ignore.case = TRUE)
  left_orig <- grepl("_orig_", img_l, ignore.case = TRUE) | grepl("orig_", img_l, ignore.case = TRUE)
  right_orig <- grepl("_orig_", img_r, ignore.case = TRUE) | grepl("orig_", img_r, ignore.case = TRUE)
  opt_side <- rep(NA_character_, length(img_l))
  opt_side[left_opt & !right_opt] <- "left"
  opt_side[right_opt & !left_opt] <- "right"
  one_and_one <- xor(left_opt, right_opt) & xor(left_orig, right_orig)
  list(optimized_side = opt_side, filename_fail = as.integer(!one_and_one))
}

map_study3_discrimination <- function(raw, file_label) {
  require_columns(raw, STUDY3_DISC_RAW, file_label)
  resp <- suppressWarnings(as.numeric(raw[["Response"]]))
  ans <- suppressWarnings(as.numeric(raw[["Spreadsheet: correct_answer"]]))
  rt <- suppressWarnings(as.numeric(raw[["Reaction Time"]]))
  correct_raw <- suppressWarnings(as.numeric(raw[["Correct"]]))
  acc <- as.integer(resp == ans)
  acc[is.na(resp) | is.na(ans)] <- NA_integer_
  mismatch <- as.integer(!is.na(correct_raw) & !is.na(acc) & correct_raw != acc)
  diff_num <- as.integer(raw[["Spreadsheet: difficulty_num"]])
  event_index <- suppressWarnings(as.integer(raw[["Event Index"]]))
  utc_timestamp <- parse_utc_timestamp(raw[["UTC Timestamp"]], file_label)
  data.frame(
    participant_public_id = as.character(raw[["Participant Public ID"]]),
    participant_private_id = as.character(raw[["Participant Private ID"]]),
    participant_id = NA_character_,
    participant_anon_id = NA_character_,
    event_index = event_index,
    utc_timestamp = utc_timestamp,
    task_name = raw[["Task Name"]],
    response_type = raw[["Response Type"]],
    object_name = raw[["Object Name"]],
    participant_group = raw[["Spreadsheet: participant_group"]],
    condition_order = raw[["Spreadsheet: condition_order"]],
    block_order = raw[["Spreadsheet: block_order"]],
    condition = recode_condition_study3(raw[["Spreadsheet: condition"]], file_label),
    background = recode_background_study3(raw[["Spreadsheet: background"]], file_label),
    K = as.integer(raw[["Spreadsheet: num_classes"]]),
    difficulty_index = diff_num,
    configuration_instance = diff_num,
    difficulty_label = raw[["Spreadsheet: difficulty_label"]],
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

map_study3_pairwise <- function(raw, file_label) {
  require_columns(raw, STUDY3_PW_RAW, file_label)
  resp <- as.character(raw[["Response"]])
  preferred <- side_from_response_lr(resp)
  img_l <- as.character(raw[["Spreadsheet: image_left"]])
  img_r <- as.character(raw[["Spreadsheet: image_right"]])
  fn <- optimized_side_from_images(img_l, img_r)
  opt_fn <- fn$optimized_side
  opt_ss <- side_from_spreadsheet_lr(raw[["Spreadsheet: optimized_side"]])
  opt_side <- opt_fn
  has_ss <- !is.na(opt_ss)
  opt_side[has_ss] <- opt_ss[has_ss]
  ss_mismatch <- as.integer(
    !is.na(opt_fn) & !is.na(opt_ss) & opt_fn != opt_ss
  )
  side_unmatched <- as.integer(is.na(preferred))
  filename_fail <- fn$filename_fail
  mapping_fail <- as.integer(
    side_unmatched == 1L | filename_fail == 1L | ss_mismatch == 1L
  )
  chose <- as.integer(!is.na(preferred) & !is.na(opt_side) & preferred == opt_side)
  chose[mapping_fail == 1L] <- NA_integer_
  event_index <- suppressWarnings(as.integer(raw[["Event Index"]]))
  utc_timestamp <- parse_utc_timestamp(raw[["UTC Timestamp"]], file_label)
  data.frame(
    participant_public_id = as.character(raw[["Participant Public ID"]]),
    participant_private_id = as.character(raw[["Participant Private ID"]]),
    participant_id = NA_character_,
    participant_anon_id = NA_character_,
    event_index = event_index,
    utc_timestamp = utc_timestamp,
    task_name = raw[["Task Name"]],
    response_type = raw[["Response Type"]],
    object_name = raw[["Object Name"]],
    trial_number = as.integer(raw[["Spreadsheet: trial_number"]]),
    trial_id = raw[["Spreadsheet: trial_id"]],
    background = recode_background_study3(raw[["Spreadsheet: background"]], file_label),
    K = as.integer(raw[["Spreadsheet: num_classes"]]),
    difficulty_index = as.integer(raw[["Spreadsheet: difficulty_num"]]),
    image_left = img_l,
    image_right = img_r,
    response_raw = resp,
    preferred_side = preferred,
    optimized_side = opt_side,
    optimized_side_spreadsheet = opt_ss,
    optimized_side_filename = opt_fn,
    spreadsheet_filename_mismatch = ss_mismatch,
    chose_optimized = chose,
    mapping_fail = mapping_fail,
    reaction_time_ms = suppressWarnings(as.numeric(raw[["Reaction Time"]])),
    stringsAsFactors = FALSE
  )
}

map_study3_vision <- function(raw, file_label) {
  map_study1_vision(raw, file_label)
}
