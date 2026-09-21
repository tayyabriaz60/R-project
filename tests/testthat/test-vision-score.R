# Dictionary §7: keys 12, 16, 29, 26; item correctness; score 0–4.
# Q1: vision_subset_flag stays NA. Q6: participant_id stays NA.

test_that("vision item correctness uses keys; score is 3 on this toy set", {
  raw <- toy_vis_raw()
  mapped <- map_study1_vision(raw, "toy_vis")
  expect_identical(mapped$vision_correct_answer, c(12, 16, 29, 26))
  expect_identical(mapped$vision_item_correct, c(1L, 1L, 1L, 0L))
  expect_equal(sum(mapped$vision_item_correct, na.rm = TRUE), 3)
  expect_true(all(is.na(mapped$vision_subset_flag)))
  expect_true(all(is.na(mapped$participant_id)))
})

test_that("all-correct toy vision scores 4", {
  raw <- toy_vis_raw(response = c("12", "16", "29", "26"))
  mapped <- map_study1_vision(raw, "toy_vis")
  expect_equal(sum(mapped$vision_item_correct), 4)
})
