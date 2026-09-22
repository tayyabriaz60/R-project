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

test_that("coerce_mauchly_df keeps effect names from a 2x2 matrix or flattened table", {
  m <- matrix(
    c(0.80, 0.70, 0.12, 0.04),
    nrow = 2L,
    dimnames = list(c("K", "condition:K"), c("Test statistic", "p-value"))
  )
  d1 <- coerce_mauchly_df(m)
  expect_equal(rownames(d1), c("K", "condition:K"))
  expect_equal(d1["condition:K", "p-value"], 0.04)
  tab <- as.table(m)
  d2 <- coerce_mauchly_df(as.data.frame(tab))
  expect_true("condition:K" %in% rownames(d2))
  expect_equal(as.numeric(d2["condition:K", grep("p", names(d2), ignore.case = TRUE)[1]]), 0.04)
})

test_that("Q10 omit-zeros matches a hand-checkable Wilcoxon", {
  opt <- c(2, 2, 0, 1)
  orig <- c(0, 0, 0, 3)
  z <- nonzero_paired_diffs(opt, orig)
  expect_equal(z$n_pairs, 4L)
  expect_equal(z$n_zero, 1L)
  expect_equal(z$n_nonzero, 3L)
  expect_equal(sort(z$d_nonzero), sort(c(2, 2, -2)))
  ww <- paired_wilcoxon_opt_minus_orig(opt, orig)
  ref <- stats::wilcox.test(c(2, 2, -2), mu = 0, exact = FALSE, correct = TRUE)
  expect_equal(ww$V, unname(ref$statistic))
  expect_equal(ww$p, unname(ref$p.value))
})

test_that("H2 Friedman follow-ups stay off when p is not below alpha", {
  sm <- data.frame(
    acc_Original_K5 = c(1, 1, 1),
    acc_Optimized_K5 = c(1, 0, 1),
    acc_Original_K10 = c(1, 1, 0),
    acc_Optimized_K10 = c(0, 1, 1),
    acc_Original_K20 = c(0, 1, 0),
    acc_Optimized_K20 = c(1, 0, 1),
    acc_Original_K30 = c(0, 0, 1),
    acc_Optimized_K30 = c(1, 1, 0),
    stringsAsFactors = FALSE
  )
  fol <- h2_friedman_followups(sm, friedman_p = 0.20)
  expect_false(fol$ran)
  expect_identical(fol$reason, "friedman_not_significant")
})

test_that("H2 Friedman follow-ups make six K pairs when triggered", {
  sm <- data.frame(
    acc_Original_K5 = c(1, 1, 1, 1),
    acc_Optimized_K5 = c(0, 0, 1, 0),
    acc_Original_K10 = c(0, 0, 0, 1),
    acc_Optimized_K10 = c(1, 1, 1, 1),
    acc_Original_K20 = c(1, 0, 1, 0),
    acc_Optimized_K20 = c(0, 1, 0, 1),
    acc_Original_K30 = c(0, 1, 0, 1),
    acc_Optimized_K30 = c(1, 0, 1, 0),
    stringsAsFactors = FALSE
  )
  fol <- h2_friedman_followups(sm, friedman_p = 0.001)
  expect_true(fol$ran)
  expect_equal(nrow(fol$rows), 6L)
  expect_equal(sum(fol$rows$estimable), 6L)
  expect_false(any(is.na(fol$rows$p_holm[fol$rows$estimable])))
})

test_that("Q30 figure_colours is the confirmed Okabe-Ito pair", {
  pal <- require_param("figure_colours")
  expect_identical(pal$status, "confirmed_Q30")
  expect_identical(pal$Original, "#E69F00")
  expect_identical(pal$Optimized, "#0072B2")
})
