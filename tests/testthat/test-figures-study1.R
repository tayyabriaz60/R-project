# Study 1 figure caption constants (must match study1_export.R).

test_that("Study 1 figure caption objects exist after sourcing utils", {
  source(file.path(PROJECT_ROOT, "R", "utils_figures_study1.R"), local = FALSE)
  expect_true(exists("STUDY1_ACCURACY_FIGURE_CAPTION"))
  expect_true(exists("STUDY1_AE_FIGURE_CAPTION"))
  expect_true(nzchar(STUDY1_ACCURACY_FIGURE_CAPTION))
})
