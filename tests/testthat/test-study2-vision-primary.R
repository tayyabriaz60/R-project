# Study 2 vision primary exclusion helpers. Toy data only.

source(file.path(PROJECT_ROOT, "R", "study2_vision_primary.R"), local = FALSE)

test_that("questionnaire pass and exclude patterns are detected", {
  pass <- "Yes, I can see normally or am wearing glasses/contact lenses to see normally."
  fail <- "No, I don't have normal vision, and it is not corrected by glasses/contact lenses."
  expect_false(questionnaire_fails_vision(pass))
  expect_true(questionnaire_fails_vision(fail))
  expect_true(is.na(questionnaire_fails_vision("Something else entirely")))
})

test_that("read_study2_questionnaire_vision returns one row per participant", {
  td <- tempfile(fileext = ".csv")
  on.exit(unlink(td), add = TRUE)
  lines <- c(
    paste(
      "Question,Response Type,Key,Response,Participant Public ID",
      sep = ","
    ),
    paste0(
      "Do you have normal or corrected-to-normal vision?,response,value,",
      shQuote("Yes, I can see normally or am wearing glasses/contact lenses to see normally."),
      ",P1"
    )
  )
  writeLines(lines, td)
  old <- SAP$study2_id_column
  SAP$study2_id_column <<- "participant_public_id"
  on.exit({ SAP$study2_id_column <<- old }, add = TRUE)
  out <- read_study2_questionnaire_vision(td)
  expect_equal(nrow(out), 1L)
  expect_equal(out$participant_id, "P1")
})
