# Dictionary §4.1 / §9: accuracy = (response == answer); flag Correct mismatch.
# Hand-checkable: row 1 match; row 2 response 7 vs answer 6, Gorilla Correct still 1.

test_that("accuracy is recalculated from response vs answer", {
  mapped <- map_study1_discrimination(toy_disc_raw(), "toy_disc")
  expect_identical(mapped$accuracy, c(1L, 0L))
  expect_identical(mapped$correct_mismatch, c(0L, 1L))
  expect_equal(mapped$signed_error, c(0, 1))
  expect_equal(mapped$absolute_error, c(0, 1))
})

test_that("baseline/sa recode to Original/Optimized (Dictionary §4.1)", {
  mapped <- map_study1_discrimination(toy_disc_raw(), "toy_disc")
  expect_identical(mapped$condition, c("Original", "Optimized"))
  expect_true(all(is.na(mapped$participant_id)))
})

test_that("unknown condition stops (no silent recode)", {
  raw <- toy_disc_raw(condition = c("baseline", "other"))
  expect_error(
    map_study1_discrimination(raw, "toy_disc"),
    "unknown Spreadsheet: condition"
  )
})

test_that("missing response or answer yields NA accuracy, not a guessed 0/1", {
  raw <- toy_disc_raw(response = c(NA_character_, "5"), correct_answer = c("5", NA_character_))
  mapped <- map_study1_discrimination(raw, "toy_disc")
  expect_true(all(is.na(mapped$accuracy)))
})
