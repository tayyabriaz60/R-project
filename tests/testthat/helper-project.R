# Sourced automatically by testthat. Toy-data tests only; no hypothesis tests.
# Resolves PROJECT_ROOT and loads mapping helpers. Does not call run_study1_load().

if (!exists("PROJECT_ROOT") || !is.character(PROJECT_ROOT) ||
    !file.exists(file.path(PROJECT_ROOT, "config", "config.R"))) {
  env <- Sys.getenv("PROJECT_ROOT", unset = "")
  if (nzchar(env) && file.exists(file.path(env, "config", "config.R"))) {
    PROJECT_ROOT <- env
  } else {
    walk <- normalizePath(getwd(), winslash = "/", mustWork = FALSE)
    found <- NA_character_
    for (i in seq_len(6L)) {
      if (file.exists(file.path(walk, "config", "config.R"))) {
        found <- walk
        break
      }
      parent <- dirname(walk)
      if (identical(parent, walk)) {
        break
      }
      walk <- parent
    }
    if (is.na(found)) {
      stop(
        "tests: could not resolve PROJECT_ROOT. Set it before running tests.",
        call. = FALSE
      )
    }
    PROJECT_ROOT <- found
  }
}

if (!exists("SAP")) {
  source(file.path(PROJECT_ROOT, "config", "config.R"), local = FALSE)
}
if (!exists("map_study1_discrimination")) {
  source(file.path(PROJECT_ROOT, "R", "study1_load.R"), local = FALSE)
}
if (!exists("filter_object_name")) {
  source(file.path(PROJECT_ROOT, "R", "utils_select.R"), local = FALSE)
}
if (!exists("fmt_p")) {
  source(file.path(PROJECT_ROOT, "R", "utils_format.R"), local = FALSE)
}

# Hand-checkable toy rows. IDs are placeholders, not real participants.
toy_disc_raw <- function(condition = c("baseline", "sa"),
                         response = c("5", "7"),
                         correct_answer = c("5", "6"),
                         correct = c("1", "1"),
                         rt = c("800", "900")) {
  n <- length(response)
  data.frame(
    "Participant Public ID" = rep("TOY_PUB", n),
    "Participant Private ID" = rep("TOY_PRIV", n),
    "Task Name" = rep("Discrimination Task G1", n),
    "Response Type" = rep("response", n),
    "Object Name" = rep(NA_character_, n),
    Response = as.character(response),
    "Reaction Time" = as.character(rt),
    Correct = as.character(correct),
    "Spreadsheet: condition" = as.character(condition),
    "Spreadsheet: colormap" = rep("toy", n),
    "Spreadsheet: num_classes" = rep("5", n),
    "Spreadsheet: variation" = rep("1", n),
    "Spreadsheet: image" = paste0("img", seq_len(n), ".png"),
    "Spreadsheet: correct_answer" = as.character(correct_answer),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
}

toy_pw_raw <- function(response,
                       left_option,
                       right_option,
                       image_left,
                       image_right) {
  n <- length(response)
  data.frame(
    "Participant Public ID" = rep("TOY_PUB", n),
    "Participant Private ID" = rep("TOY_PRIV", n),
    "Task Name" = rep("Pairwise Comparison Task2", n),
    "Response Type" = rep("response", n),
    "Object Name" = rep(NA_character_, n),
    Response = as.character(response),
    "Reaction Time" = rep("1000", n),
    "Spreadsheet: trial_number" = as.character(seq_len(n)),
    "Spreadsheet: image_left" = as.character(image_left),
    "Spreadsheet: image_right" = as.character(image_right),
    "Spreadsheet: left_option" = as.character(left_option),
    "Spreadsheet: right_option" = as.character(right_option),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
}

toy_vis_raw <- function(response = c("12", "16", "29", "0"),
                        correct_answer = c("12", "16", "29", "26")) {
  n <- length(response)
  data.frame(
    "Participant Public ID" = rep("TOY_PUB", n),
    "Participant Private ID" = rep("TOY_PRIV", n),
    "Task Name" = rep("Vision Check", n),
    "Response Type" = rep("response", n),
    "Object Name" = rep(NA_character_, n),
    Response = as.character(response),
    Correct = rep("1", n),
    "Spreadsheet: tag" = paste0("Q", seq_len(n), "_answer"),
    "Spreadsheet: correct_answer" = as.character(correct_answer),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
}
