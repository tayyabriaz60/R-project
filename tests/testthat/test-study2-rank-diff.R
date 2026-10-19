# Study 2 rank-diff rounding before Wilcoxon/Friedman (float 1/3 ties, exact zeros).

test_that("rounding collapses float noise on 1/3 accuracy differences", {
  one_third_a <- 1 / 3
  one_third_b <- 0.3333333333333333
  expect_false(identical(one_third_a, one_third_b))
  d_raw <- one_third_a - one_third_b
  expect_true(abs(d_raw) > 0 && abs(d_raw) < 1e-14)
  d_round <- round(one_third_a - one_third_b, as.integer(SAP$study2_rank_diff_round_digits))
  expect_equal(d_round, 0)
})

test_that("paired Wilcoxon on rounded 1/3 ties reports all pairs as exact zeros", {
  n <- 6L
  opt <- rep(1 / 3, n)
  orig <- rep(0.3333333333333333, n)
  d <- round(opt - orig, as.integer(SAP$study2_rank_diff_round_digits))
  z <- nonzero_paired_diffs(d, mu = 0)
  expect_equal(z$n_pairs, n)
  expect_equal(z$n_zero, n)
  expect_equal(z$n_nonzero, 0L)
  expect_error(paired_wilcoxon_on_diff(d), "no non-zero differences")
})

test_that("Friedman K-diff matrix uses study2 K levels with rounding", {
  summary_df <- data.frame(
    acc_Original_K5 = c(0.5, 0.6),
    acc_Optimized_K5 = c(0.6, 0.7),
    acc_Original_K10 = c(0.4, 0.5),
    acc_Optimized_K10 = c(0.5, 0.6),
    acc_Original_K20 = c(0.3, 0.4),
    acc_Optimized_K20 = c(0.4, 0.5),
    acc_Original_K30 = c(0.2, 0.3),
    acc_Optimized_K30 = c(0.3, 0.4),
    stringsAsFactors = FALSE
  )
  mat <- k_diff_matrix(
    summary_df,
    k_levels = SAP$k_levels_study2,
    round_digits = SAP$study2_rank_diff_round_digits
  )
  expect_equal(ncol(mat), length(SAP$k_levels_study2))
  expect_true(all(mat == 0.1))
})
