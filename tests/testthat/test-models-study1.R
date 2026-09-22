# Toy checks for Holm, CIs, zero-variance skip, and accuracy reshape.

test_that("holm_adjust matches stats::p.adjust method holm", {
  p <- c(0.04, 0.03, 0.20, 0.01)
  expect_equal(holm_adjust(p), stats::p.adjust(p, method = "holm"))
})

test_that("mean_sd_ci is hand-checkable for 1:5", {
  st <- mean_sd_ci(1:5, level = 0.95)
  expect_equal(st$n, 5L)
  expect_equal(st$mean, 3)
  expect_equal(st$sd, stats::sd(1:5))
  se <- stats::sd(1:5) / sqrt(5)
  tcrit <- stats::qt(0.975, df = 4)
  expect_equal(st$ci_low, 3 - tcrit * se)
  expect_equal(st$ci_high, 3 + tcrit * se)
})

test_that("zero-variance Optimized-Original difference is detected", {
  expect_true(is_zero_variance_diff(c(1, 1, 1), c(1, 1, 1)))
  expect_false(is_zero_variance_diff(c(1, 2, 3), c(0, 0, 1)))
})

test_that("accuracy_long_from_summary has 8 cells for one participant", {
  sm <- data.frame(
    participant_anon_id = "S1_P001",
    acc_Original_K5 = 0.0,
    acc_Original_K10 = 0.5,
    acc_Original_K20 = 1.0,
    acc_Original_K30 = 0.0,
    acc_Optimized_K5 = 1.0,
    acc_Optimized_K10 = 1.0,
    acc_Optimized_K20 = 0.5,
    acc_Optimized_K30 = 0.0,
    stringsAsFactors = FALSE
  )
  long <- accuracy_long_from_summary(sm)
  expect_equal(nrow(long), 8L)
  expect_equal(as.character(long$condition[1:4]), rep("Original", 4))
  expect_equal(long$accuracy[long$condition == "Optimized" & long$K == 5], 1)
})

test_that("Q30 figure_colours stays pending and placeholder is Okabe-Ito", {
  expect_error(require_param("figure_colours"), "PENDING a client answer")
  expect_identical(SAP$figure_palette_placeholder$name, "okabe_ito")
  expect_identical(SAP$figure_palette_placeholder$status, "placeholder_pending_Q30")
})
