# Study 3 tables export.

source(file.path(PROJECT_ROOT, "R", "study1_export.R"))
source(file.path(PROJECT_ROOT, "R", "export_table_helpers.R"))

write_study3_tables <- function(acc_tests, pw_tests, rt_tests, ae_test, log_path) {
  n <- acc_tests$n
  note <- paste0("N = ", n, " (primary after vision exclusions).")
  write_table_csv_docx(
    data.frame(
      hypothesis = c("H4_condition", "H5_condition_x_background"),
      test_mode = acc_tests$mode,
      p_h4 = if (acc_tests$mode == "anova") acc_tests$h4$p else acc_tests$h4$p,
      p_h5 = if (acc_tests$mode == "anova") acc_tests$h5$p else acc_tests$h5$p,
      stringsAsFactors = FALSE
    ),
    "study3_table_h4_h5",
    "Study 3: H4/H5 accuracy tests",
    note,
    log_path
  )
  write_table_csv_docx(
    data.frame(
      hypothesis = c("H6_overall_pairwise", "H7_white_vs_black"),
      test_mode = pw_tests$mode,
      p_h6 = pw_tests$h6$p,
      p_h7 = pw_tests$h7$p,
      stringsAsFactors = FALSE
    ),
    "study3_table_h6_h7",
    "Study 3: H6/H7 pairwise proportion tests",
    note,
    log_path
  )
  write_table_csv_docx(
    data.frame(
      effect = c("condition", "condition:background"),
      p = c(rt_tests$condition$p, rt_tests$interaction$p),
      stringsAsFactors = FALSE
    ),
    "study3_table_rt_anova",
    "Study 3: RT 2x2 RM ANOVA",
    note,
    log_path
  )
  write_table_csv_docx(
    data.frame(
      test = "AE_paired_t",
      t = ae_test$t,
      df = ae_test$df,
      p = ae_test$p,
      stringsAsFactors = FALSE
    ),
    "study3_table_ae",
    "Study 3: Absolute error Original vs Optimized (paired t)",
    note,
    log_path
  )
  invisible(TRUE)
}
