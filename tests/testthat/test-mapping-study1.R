# Brief §4 / Dictionary §4.2: reconstruct sides; do not use Response words as condition.
# Q3: failed rows are flagged, not dropped.

test_that("preferred_side comes from Response vs left/right_option", {
  raw <- toy_pw_raw(
    response = c("optimized.png", "baseline.png"),
    left_option = c("optimized.png", "optimized.png"),
    right_option = c("baseline.png", "baseline.png"),
    image_left = c("k5_optimized.png", "k5_optimized.png"),
    image_right = c("k5_baseline.png", "k5_baseline.png")
  )
  mapped <- map_study1_pairwise(raw, "toy_pw")
  expect_identical(mapped$preferred_side, c("left", "right"))
  expect_identical(mapped$optimized_side, c("left", "left"))
  expect_identical(mapped$chose_optimized, c(1L, 0L))
  expect_identical(mapped$mapping_fail, c(0L, 0L))
})

test_that("filename/option label mismatch is reconstructed, not treated as fail", {
  # Baked-in synthetic pattern: left image is optimized, left_option says baseline.
  # Clicked left → Response records left_option ("baseline.png").
  # Side reconstruction: preferred=left, optimized=left → chose_optimized=1.
  # Wrong method (read Response words) would code this as Original.
  raw <- toy_pw_raw(
    response = "baseline.png",
    left_option = "baseline.png",
    right_option = "optimized.png",
    image_left = "stim_k10_optimized.png",
    image_right = "stim_k10_baseline.png"
  )
  mapped <- map_study1_pairwise(raw, "toy_pw")
  expect_identical(mapped$preferred_side, "left")
  expect_identical(mapped$optimized_side, "left")
  expect_identical(mapped$chose_optimized, 1L)
  expect_identical(mapped$mapping_fail, 0L)
})

test_that("unmatched Response and not-one-and-one images are flagged and kept", {
  raw <- toy_pw_raw(
    response = c("something_else.png", "optimized.png"),
    left_option = c("optimized.png", "optimized.png"),
    right_option = c("baseline.png", "baseline.png"),
    image_left = c("k5_optimized.png", "k5_optimized.png"),
    image_right = c("k5_baseline.png", "k5_optimized.png")
  )
  mapped <- map_study1_pairwise(raw, "toy_pw")
  expect_equal(nrow(mapped), 2L)
  expect_identical(mapped$mapping_fail, c(1L, 1L))
  expect_true(all(is.na(mapped$chose_optimized)))
  expect_true(all(is.na(mapped$participant_id)))
})
