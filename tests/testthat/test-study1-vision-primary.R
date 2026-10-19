# Study 1 vision primary exclusion helpers. Toy data only.

source(file.path(PROJECT_ROOT, "R", "study1_vision_primary.R"), local = FALSE)

test_that("Study 1 questionnaire pass and exclude patterns are detected", {
  pass <- "Yes, I can see normally or am wearing glasses/contact lenses to see normally."
  fail <- "No, I don't have normal vision, and it is not corrected by glasses/contact lenses."
  expect_false(study1_questionnaire_fails_vision(pass))
  expect_true(study1_questionnaire_fails_vision(fail))
  expect_true(is.na(study1_questionnaire_fails_vision("Something else entirely")))
})

test_that("study1_ishihara_scores keeps participant_id names", {
  vis <- data.frame(
    participant_id = rep(c("A", "B"), each = 4L),
    vision_item_correct = c(1, 1, 1, 1, 1, 1, 0, 1),
    stringsAsFactors = FALSE
  )
  sc <- study1_ishihara_scores(vis)
  expect_equal(length(sc), 2L)
  expect_equal(names(sc), c("A", "B"))
  expect_equal(unname(sc), c(4L, 3L))
})
