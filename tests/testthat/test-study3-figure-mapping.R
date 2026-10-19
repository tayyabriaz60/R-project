# Study 3 figure wide-matrix column order vs participant summaries.

test_that("cousinau panel aligns Original_White column to White x Original", {
  skip_if_not_installed("ggplot2")
  source(file.path(PROJECT_ROOT, "R", "utils_figures_study3.R"), local = TRUE)
  ord <- c("Original", "Optimized")
  bg <- c("White", "Black")
  cols <- study3_wide_cols(ord, bg)
  expect_equal(cols, c("Original_White", "Optimized_White", "Original_Black", "Optimized_Black"))
  mat <- matrix(c(0.7, 0.8, 0.75, 0.85), nrow = 1L)
  colnames(mat) <- cols
  panel <- study3_panel_from_wide_mat(mat, ord, bg, "background")
  expect_equal(as.character(panel$condition[1]), "Original")
  expect_equal(as.character(panel$background[1]), "White")
  expect_equal(panel$mean[1], 0.7)
  expect_equal(as.character(panel$condition[3]), "Original")
  expect_equal(as.character(panel$background[3]), "Black")
  expect_equal(panel$mean[3], 0.75)
})

test_that("panel rows match summary arithmetic means not CM-only means", {
  skip_if_not_installed("ggplot2")
  source(file.path(PROJECT_ROOT, "R", "utils_figures_study3.R"), local = TRUE)
  ord <- c("Original", "Optimized")
  bg <- c("White", "Black")
  cols <- study3_wide_cols(ord, bg)
  mat <- matrix(
    c(0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 0.4, 0.3),
    nrow = 2L,
    byrow = TRUE
  )
  colnames(mat) <- cols
  panel <- study3_panel_from_wide_mat(mat, ord, bg, "background")
  expect_equal(panel$mean[panel$background == "White" & panel$condition == "Original"], 0.7)
  expect_equal(panel$mean[panel$background == "Black" & panel$condition == "Optimized"], 0.3)
})

test_that("K columns match Study 2 t(outer) order", {
  source(file.path(PROJECT_ROOT, "R", "utils_figures_study3.R"), local = TRUE)
  ord <- c("Original", "Optimized")
  k <- c(10L, 20L, 30L)
  expect_equal(
    study3_wide_cols(ord, k),
    c("Original_10", "Optimized_10", "Original_20", "Optimized_20", "Original_30", "Optimized_30")
  )
})

test_that("summary_to_wide_mat reads acc columns in Study 2 column order", {
  source(file.path(PROJECT_ROOT, "R", "utils_figures_study3.R"), local = TRUE)
  ord <- c("Original", "Optimized")
  bg <- c("White", "Black")
  summary_df <- data.frame(
    participant_anon_id = "P1",
    acc_Original_White = 0.1,
    acc_Optimized_White = 0.2,
    acc_Original_Black = 0.3,
    acc_Optimized_Black = 0.4,
    stringsAsFactors = FALSE
  )
  mat <- summary_to_wide_mat(summary_df, ord, bg, "acc")
  expect_equal(as.numeric(mat[1, ]), c(0.1, 0.2, 0.3, 0.4))
})
