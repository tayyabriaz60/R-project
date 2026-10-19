# Study 3 load helpers. Toy data only.

test_that("filter_study3_trials keeps discrimination response rows", {
  raw <- data.frame(
    "Task Name" = c("Discrimination Task", "Discrimination Task", "Vision Check (Clone)"),
    "Response Type" = c("response", "response", "response"),
    "Response" = c(10, 20, 12),
    "Object Name" = c("Answer_10", "Answer_20", "Number Entry"),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  out <- filter_study3_trials(raw, "study3_disc", "Discrimination Task")
  expect_equal(nrow(out), 2L)
})

test_that("filter_study3_trials keeps pairwise Left/Right responses", {
  raw <- data.frame(
    "Task Name" = rep("Task 2 Pairwise Comparison", 3),
    "Response Type" = rep("response", 3),
    "Response" = c("Left", "Right", "Left image"),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  out <- filter_study3_trials(raw, "study3_pairwise", "Task 2 Pairwise Comparison")
  expect_equal(nrow(out), 2L)
})

test_that("drop_study3_researcher skips synthetic token when unmatched", {
  df <- data.frame(
    participant_id = c("S3P001", "S3P002"),
    stringsAsFactors = FALSE
  )
  out <- drop_study3_researcher(df, "toy_s3")
  expect_equal(nrow(out), 2L)
})
