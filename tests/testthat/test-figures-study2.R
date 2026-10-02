# Study 2 figure helpers. Toy data only.

test_that("cousinau_morey returns one mean and CI per column", {
  mat <- matrix(c(0.5, 0.6, 0.7, 0.8, 0.55, 0.65, 0.75, 0.85), nrow = 2, byrow = TRUE)
  st <- cousinau_morey_cell_stats(mat, 0.95)
  expect_length(st$mean, 4L)
  expect_true(all(st$ci_low <= st$mean))
  expect_true(all(st$mean <= st$ci_high))
})

test_that("Study 2 export uses revised figure writers only", {
  src <- readLines(file.path(PROJECT_ROOT, "R", "study2_export.R"), warn = FALSE)
  body <- paste(src, collapse = "\n")
  expect_match(body, "plot_study2_accuracy_panels")
  expect_match(body, "plot_study2_h3_stacked_dots")
  expect_false(grepl("plot_rt_by_condition", body, fixed = TRUE))
})
