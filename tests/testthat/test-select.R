# Q5 Object Name filter; Q6 anonymous reporting IDs. Toy data only.

test_that("filter_object_name keeps the expected token and drops others", {
  raw <- data.frame(
    "Object Name" = c("Response", "Image Response", "Response"),
    x = c(1, 2, 3),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  out <- filter_object_name(raw, "Response", "toy")
  expect_equal(nrow(out), 2L)
  expect_equal(out$x, c(1, 3))
})

test_that("filter_object_name stops if every row is dropped", {
  raw <- data.frame(
    "Object Name" = c(NA_character_, ""),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  expect_error(filter_object_name(raw, "Response", "toy"), "dropped all")
})

test_that("anonymous IDs are sequential and do not embed the source ID", {
  src <- c("S1PUB010", "S1PUB001", "S1PUB010")
  mp <- make_anonymous_id_map(src, prefix = "S1_P")
  expect_identical(unname(mp[c("S1PUB001", "S1PUB010")]), c("S1_P001", "S1_P002"))
  expect_false(any(grepl("S1PUB", unname(mp), fixed = TRUE)))
})

test_that("require_param returns filled Q1 and Q30 and still stops on pending Q15", {
  expect_identical(require_param("vision_subset_rule"), "score_equals_4")
  expect_identical(require_param("object_name_disc"), "Response")
  pal <- require_param("figure_colours")
  expect_identical(pal$Original, "#E69F00")
  expect_error(require_param("geometric_mean_rt_ratio"), "PENDING a client answer")
})
