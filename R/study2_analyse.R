# Study 2 primary tests. SAP §4: same approach as Study 1 unless stated.
# Recommended path: 2x4 RM-ANOVA, one-sample t, paired t. Q32 npar not applied.

source(file.path(PROJECT_ROOT, "R", "study1_models.R"))
source(file.path(PROJECT_ROOT, "R", "study1_q7.R"))
source(file.path(PROJECT_ROOT, "R", "study2_q7.R"))
source(file.path(PROJECT_ROOT, "R", "study2_export.R"))
source(file.path(PROJECT_ROOT, "R", "study1_summarise.R"))
source(file.path(PROJECT_ROOT, "R", "study1_analyse.R"))

run_study2_h1_h2_h3 <- function(summary_df, log_path, label) {
  n <- nrow(summary_df)
  log_msg(log_path, label, " n_participants=", n)
  log_msg(log_path, label, " SAP recommended H1=rm_anova H2=rm_anova H3=onesample_t (Q32 npar not applied)")

  long_acc <- accuracy_long_from_summary(summary_df)
  fit <- fit_study1_rm_anova(long_acc)
  sph <- mauchly_table(fit)
  es <- partial_eta_table(fit)
  h1 <- anova_effect_report(fit, "condition", 2L, sph, es)
  h2 <- anova_effect_report(fit, "condition:K", 4L, sph, es)
  log_msg(log_path, label, " H1 F=", sprintf("%.4f", h1$F),
          " df=", sprintf("%.4f", h1$df_num), ",", sprintf("%.4f", h1$df_den),
          " p=", sprintf("%.4f", h1$p),
          " pes=", sprintf("%.4f", h1$pes),
          " sphericity=", h1$sphericity_correction)
  log_msg(log_path, label, " H2 F=", sprintf("%.4f", h2$F),
          " df=", sprintf("%.4f", h2$df_num), ",", sprintf("%.4f", h2$df_den),
          " p=", sprintf("%.4f", h2$p),
          " pes=", sprintf("%.4f", h2$pes),
          " mauchly_p=", if (is.na(h2$mauchly_p)) "NA" else sprintf("%.4f", h2$mauchly_p),
          " sphericity=", h2$sphericity_correction, " reason=", h2$sphericity_reason)

  follow <- h2_followups(summary_df, h2$p)
  log_msg(log_path, label, " H2_followups_ran=", follow$ran, " reason=", follow$reason)

  h3 <- onesample_t_vs(summary_df$pairwise_prop_optimized, as.numeric(SAP$h3_null))
  log_msg(log_path, label, " H3 t=", sprintf("%.4f", h3$t),
          " df=", sprintf("%.4f", h3$df),
          " p=", sprintf("%.4f", h3$p),
          " mean=", sprintf("%.4f", h3$mean))

  list(n = n, h1 = h1, h2 = h2, follow = follow, h3 = h3, fit = fit)
}

run_study2_primary_bundle <- function(summary_df, log_path, label) {
  tests <- run_study2_h1_h2_h3(summary_df, log_path, label)
  acc_orig <- mean_sd_ci(summary_df$acc_Original)
  acc_opt <- mean_sd_ci(summary_df$acc_Optimized)
  rt_scale <- unique(as.character(summary_df$rt_analysis_scale))
  if (length(rt_scale) != 1L) {
    stop("rt_analysis_scale is not unique in the summary table.", call. = FALSE)
  }
  rt <- paired_t_opt_minus_orig(
    summary_df$mean_rt_analysis_Optimized,
    summary_df$mean_rt_analysis_Original
  )
  if (!isTRUE(rt$estimable)) {
    stop("RT paired t is not estimable (zero-variance difference).", call. = FALSE)
  }
  log_msg(log_path, label, " RT paired t=", sprintf("%.4f", rt$t),
          " p=", sprintf("%.4f", rt$p), " scale=", rt_scale)
  ae <- paired_t_opt_minus_orig(summary_df$mean_ae_Optimized, summary_df$mean_ae_Original)
  if (!isTRUE(ae$estimable)) {
    stop("AE paired t is not estimable (zero-variance difference).", call. = FALSE)
  }
  log_msg(log_path, label, " AE paired t=", sprintf("%.4f", ae$t),
          " p=", sprintf("%.4f", ae$p))
  c(tests, list(
    acc_orig = acc_orig,
    acc_opt = acc_opt,
    rt = rt,
    rt_scale = rt_scale,
    rt_ms_orig = mean_sd_ci(summary_df$mean_rt_ms_Original),
    rt_ms_opt = mean_sd_ci(summary_df$mean_rt_ms_Optimized),
    rt_an_orig = mean_sd_ci(summary_df$mean_rt_analysis_Original),
    rt_an_opt = mean_sd_ci(summary_df$mean_rt_analysis_Optimized),
    ae = ae,
    ae_orig = mean_sd_ci(summary_df$mean_ae_Original),
    ae_opt = mean_sd_ci(summary_df$mean_ae_Optimized),
    se_orig = mean_sd_ci(summary_df$mean_se_Original),
    se_opt = mean_sd_ci(summary_df$mean_se_Optimized)
  ))
}

run_study2_analyse <- function(study2, study2_prep) {
  ensure_output_dirs()
  log_path <- output_log_path("study2_log_analysis")
  an_title <- if (identical(DATA_SOURCE, "synthetic")) {
    "STUDY 2 ANALYSIS (aggregates only; SYNTHETIC DATA: pipeline test only)"
  } else {
    "STUDY 2 ANALYSIS (aggregates only; real export; no participant IDs in this log)"
  }
  start_log(log_path, an_title)
  log_msg(log_path, "SAP §4.1 H1/H2 ANOVA; §4.2 H3 t; §4.3 RT/AE t; §4.4 vision N=43.")
  log_msg(log_path, "Q32: Study 1 npar lock not inherited. Recommended parametric path used.")

  if (!is.na(SAP$study2_q7_inherit_study1_lock) && isTRUE(SAP$study2_q7_inherit_study1_lock)) {
    stop("study2_q7_inherit_study1_lock is TRUE but the npar Study 2 path is not implemented.",
         call. = FALSE)
  }

  summaries <- study2_prep$summaries
  extra_diag <- save_assumption_hists(summaries, log_path, "study2")
  q8 <- list.files(OUTPUT_FIGURES, pattern = "study2_diag_.*\\.png$", full.names = TRUE)
  q7_path <- write_study2_q7_report(sort(unique(c(q8, extra_diag))), log_path)
  log_effectsize_versions(log_path)
  log_msg(log_path, "Study 2 tests: H1=", require_param("study2_h1_test"),
          " H2=", require_param("study2_h2_test"),
          " H3=", require_param("study2_h3_test"),
          " RT=", require_param("study2_rt_test"),
          " AE=", require_param("study2_ae_test"))

  primary <- run_study2_primary_bundle(summaries, log_path, "primary")

  disc <- study2$discrimination
  pw <- study2$pairwise
  vis <- study2$vision
  ae_part <- stats::aggregate(
    absolute_error ~ participant_anon_id + condition + K,
    data = disc,
    FUN = function(x) mean(as.numeric(x), na.rm = TRUE)
  )
  ae_k <- cell_mean_ci(ae_part, "absolute_error")
  pw_rt <- pairwise_rt_desc(pw)

  keep <- vision_subset_ids(vis)
  log_msg(log_path, "vision_sensitivity n_ids=", length(keep),
          " (SAP expected ", as.integer(SAP$vision_subset_n_study2), ")")
  if (identical(DATA_SOURCE, "synthetic") &&
      length(keep) != as.integer(SAP$vision_subset_n_study2)) {
    stop("Vision sensitivity N is not ", SAP$vision_subset_n_study2, ".", call. = FALSE)
  }
  disc_s <- disc[disc$participant_id %in% keep, , drop = FALSE]
  pw_s <- pw[pw$participant_id %in% keep, , drop = FALSE]
  sum_s <- summarise_study1_participants(disc_s, pw_s, log_path)
  sens <- run_study2_h1_h2_h3(sum_s, log_path, "vision_sens")
  vision_tab <- data.frame(
    analysis = c("H1_condition", "H2_condition_K", "H3_onesample_t"),
    n = sens$n,
    statistic = c(sens$h1$F, sens$h2$F, sens$h3$t),
    df_num = c(sens$h1$df_num, sens$h2$df_num, sens$h3$df),
    df_den = c(sens$h1$df_den, sens$h2$df_den, NA_real_),
    p = c(sens$h1$p, sens$h2$p, sens$h3$p),
    effect_size = c(sens$h1$pes, sens$h2$pes, sens$h3$d),
    es_name = c("partial_eta_sq", "partial_eta_sq", "cohens_d"),
    primary_p = c(primary$h1$p, primary$h2$p, primary$h3$p),
    sig_agrees_with_primary = c(
      (sens$h1$p < SAP$alpha) == (primary$h1$p < SAP$alpha),
      (sens$h2$p < SAP$alpha) == (primary$h2$p < SAP$alpha),
      (sens$h3$p < SAP$alpha) == (primary$h3$p < SAP$alpha)
    ),
    stringsAsFactors = FALSE
  )
  log_msg(log_path, "vision_sensitivity H1_sig_agrees=", vision_tab$sig_agrees_with_primary[1],
          " H2_sig_agrees=", vision_tab$sig_agrees_with_primary[2],
          " H3_sig_agrees=", vision_tab$sig_agrees_with_primary[3])

  acc_cells <- cell_mean_ci(accuracy_long_from_summary(summaries), "accuracy")
  write_study2_tables(primary, vision_tab, ae_k, pw_rt, log_path)
  write_study2_figures(
    acc_cells,
    primary$h3,
    list(orig = primary$rt_ms_orig, opt = primary$rt_ms_opt),
    ae_k,
    log_path
  )

  log_msg(log_path, "ANALYSIS COMPLETE. SAP recommended ANOVA/t. Q32 npar not applied. Numbers are ",
          if (identical(DATA_SOURCE, "synthetic")) "synthetic pipeline output." else "from the loaded data.")
  message("run_study2_analyse finished. Recommended parametric path applied.")
  list(
    primary = primary,
    vision = sens,
    q7_path = q7_path,
    log_path = log_path
  )
}
