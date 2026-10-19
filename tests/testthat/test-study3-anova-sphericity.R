# Study 3: 2x2 RM-ANOVA must not require Mauchly for the interaction (1 df).

test_that("condition:background interaction uses two-level sphericity rule", {
  skip_if_not_installed("afex")
  set.seed(1)
  n <- 12L
  ids <- sprintf("S3_P%03d", seq_len(n))
  long <- expand.grid(
    participant_anon_id = ids,
    condition = c("Original", "Optimized"),
    background = c("White", "Black"),
    stringsAsFactors = FALSE
  )
  long$accuracy <- stats::runif(nrow(long), 0.5, 0.95)
  fit <- fit_study3_rm_anova(long)
  sph <- mauchly_table(fit)
  es <- partial_eta_table(fit)
  expect_no_error(
    anova_effect_report(fit, "condition:background", 2L, sph, es)
  )
})
