# Study 2 load helpers. Toy data only. No synthetic file load. No hypothesis tests.

test_that("filter_task_name keeps the expected Clone task token", {
  raw <- data.frame(
    "Task Name" = c(
      "Discrimination Task G1 (Clone)",
      "Discrimination Task G2 (Clone)",
      "Discrimination Task G1 (Clone)"
    ),
    x = c(1, 2, 3),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  out <- filter_task_name(raw, "Discrimination Task G1 (Clone)", "toy")
  expect_equal(nrow(out), 2L)
  expect_equal(out$x, c(1, 3))
})

test_that("filter_task_name stops if every row is dropped", {
  raw <- data.frame(
    "Task Name" = c("Vision Check", "Vision Check"),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  expect_error(
    filter_task_name(raw, "Discrimination Task G1 (Clone)", "toy"),
    "dropped all"
  )
})

test_that("drop_study2_researcher removes the synthetic researcher ID only", {
  df <- data.frame(
    participant_id = c("S2P001", "S2_RESEARCHER_EXCLUDE", "S2P002", "S2_RESEARCHER_EXCLUDE"),
    accuracy = c(1, 0, 1, 0),
    stringsAsFactors = FALSE
  )
  out <- drop_study2_researcher(df, "toy_s2")
  expect_equal(nrow(out), 2L)
  expect_identical(sort(out$participant_id), c("S2P001", "S2P002"))
})

test_that("drop_study2_researcher stops if the configured ID matches nobody", {
  df <- data.frame(
    participant_id = c("S2P001", "S2P002"),
    stringsAsFactors = FALSE
  )
  expect_error(drop_study2_researcher(df, "toy_s2"), "matched 0")
})

test_that("study2_researcher_ids on synthetic is the README token, not a guessed real ID", {
  expect_identical(study2_researcher_ids(), "S2_RESEARCHER_EXCLUDE")
  expect_true(is.na(SAP$study2_researcher_ids_real))
  expect_true(is.na(SAP$study2_q7_inherit_study1_lock))
})

test_that("Study 2 disc mapping reuses Study 1 recode and stores difficulty_index", {
  raw <- toy_disc_raw()
  raw[["Task Name"]] <- "Discrimination Task G1 (Clone)"
  raw[["Object Name"]] <- "Response"
  mapped <- map_study1_discrimination(raw, "toy_s2")
  mapped$difficulty_index <- mapped$configuration_instance
  expect_identical(mapped$condition, c("Original", "Optimized"))
  expect_identical(mapped$difficulty_index, c(1L, 1L))
  expect_identical(mapped$accuracy, c(1L, 0L))
})
