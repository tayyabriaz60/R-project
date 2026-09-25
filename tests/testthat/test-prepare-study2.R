# Study 2 prepare helpers. Toy data only. No synthetic load. No hypothesis tests.

test_that("Study 2 accuracy cells average three Difficulty instances within Condition x K", {
  disc <- data.frame(
    participant_id = rep("A", 3L),
    participant_anon_id = rep("S2_P001", 3L),
    condition = rep("Original", 3L),
    K = rep(5L, 3L),
    accuracy = c(1, 0, 1),
    stringsAsFactors = FALSE
  )
  cells <- accuracy_cells_long(disc)
  expect_equal(nrow(cells), 1L)
  expect_equal(cells$accuracy, 2 / 3)
})

test_that("Study 2 Q32 remains unanswered and recommended tests are ANOVA/t", {
  expect_true(is.na(SAP$study2_q7_inherit_study1_lock))
  expect_identical(require_param("study2_h1_test"), "rm_anova_condition")
  expect_identical(require_param("study2_h2_test"), "rm_anova_condition_k")
  expect_identical(require_param("study2_h3_test"), "onesample_t")
  expect_identical(require_param("study2_rt_test"), "paired_t")
  expect_identical(require_param("study2_ae_test"), "paired_t")
  expect_identical(as.integer(SAP$vision_subset_n_study2), 43L)
})
