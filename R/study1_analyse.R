# Study 1 primary tests, sensitivity, tables, figures.
# Q7 report is written BEFORE any Condition p-value is examined.
# Fallback tests are never run.

source(file.path(PROJECT_ROOT, "R", "study1_models.R"))
source(file.path(PROJECT_ROOT, "R", "study1_q7.R"))
source(file.path(PROJECT_ROOT, "R", "study1_export.R"))
source(file.path(PROJECT_ROOT, "R", "study1_summarise.R"))

vision_subset_ids <- function(vis) {
  keep <- unique(as.character(vis$participant_id[vis$vision_subset_flag == 1L]))
  keep <- keep[!is.na(keep) & nzchar(keep)]
  keep
}

run_h1_h2_h3 <- function(summary_df, log_path, label) {
  n <- nrow(summary_df)
  log_msg(log_path, label, " n_participants=", n)
  long_acc <- accuracy_long_from_summary(summary_df)
  fit <- fit_study1_rm_anova(long_acc)
  model_path <- file.path(OUTPUT_MODELS, paste0("study1_h1_h2_anova_", label, OUTPUT_SUFFIX, ".txt"))
  writeLines(utils::capture.output(print(summary(fit))), model_path)
  log_msg(log_path, "wrote ", basename(model_path))

  sph <- mauchly_table(fit)
  log_msg(log_path, label, " Mauchly table rows=", paste(rownames(sph), collapse = "; "))
  tab0 <- as.data.frame(anova(fit, correction = "none", es = "none"))
  log_msg(log_path, label, " ANOVA rows=", paste(rownames(tab0), collapse = "; "))
  h1_name <- resolve_effect_name(rownames(tab0), c("condition", "Condition"))
  h2_name <- resolve_effect_name(rownames(tab0), c("condition:K", "K:condition", "conditionK"))
  es_tbl <- partial_eta_table(fit)
  h1 <- anova_effect_report(fit, h1_name, 2L, sph, es_tbl)
  h2 <- anova_effect_report(fit, h2_name, 4L, sph, es_tbl)
  log_msg(log_path, label, " H1 F=", sprintf("%.4f", h1$F),
          " df=", h1$df_num, ",", h1$df_den,
          " p=", sprintf("%.4f", h1$p),
          " pes=", sprintf("%.4f", h1$pes),
          " sphericity=", h1$sphericity_correction)
  log_msg(log_path, label, " H2 F=", sprintf("%.4f", h2$F),
          " df=", h2$df_num, ",", h2$df_den,
          " p=", sprintf("%.4f", h2$p),
          " pes=", sprintf("%.4f", h2$pes),
          " mauchly_p=", if (is.na(h2$mauchly_p)) "NA" else sprintf("%.4f", h2$mauchly_p),
          " sphericity=", h2$sphericity_correction, " reason=", h2$sphericity_reason)

  follow <- h2_followups(summary_df, h2$p)
  log_msg(log_path, label, " H2_followups_ran=", follow$ran, " reason=", follow$reason)
  if (isTRUE(follow$ran)) {
    log_msg(log_path, label, " H2_followups_n_estimable=", sum(follow$rows$estimable),
            " n_zero_var=", sum(!follow$rows$estimable))
  }

  h3 <- onesample_t_vs(summary_df$pairwise_prop_optimized, as.numeric(SAP$h3_null))
  log_msg(log_path, label, " H3 t=", sprintf("%.4f", h3$t),
          " df=", h3$df, " p=", sprintf("%.4f", h3$p),
          " mean=", sprintf("%.4f", h3$mean), " d=", sprintf("%.4f", h3$d))

  list(n = n, fit = fit, h1 = h1, h2 = h2, follow = follow, h3 = h3)
}

run_study1_primary_bundle <- function(summary_df, log_path, label) {
  tests <- run_h1_h2_h3(summary_df, log_path, label)
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

pairwise_rt_desc <- function(pw) {
  rt <- pw$reaction_time_ms
  ok <- !is.na(rt) & rt > 0
  part <- stats::aggregate(
    rt[ok] ~ pw$participant_anon_id[ok],
    FUN = mean
  )
  names(part) <- c("participant_anon_id", "mean_rt_ms")
  st <- mean_sd_ci(part$mean_rt_ms)
  data.frame(
    n = st$n,
    mean_rt_ms = st$mean,
    sd_rt_ms = st$sd,
    ci_low = st$ci_low,
    ci_high = st$ci_high,
    n_trials_dropped = sum(!ok),
    stringsAsFactors = FALSE
  )
}

run_study1_analyse <- function(study1, study1_prep) {
  ensure_output_dirs()
  log_path <- output_log_path("study1_log_analysis")
  start_log(log_path, "STUDY 1 ANALYSIS (aggregates only; SYNTHETIC DATA: pipeline test only)")
  log_msg(log_path, "SAP §3.1 H1/H2; §3.2 H3; §3.3 RT/AE/SE; §3.4 vision sensitivity.")
  log_msg(log_path, "Q7: fallback will NOT be applied. Q30/Q31 still pending.")

  summaries <- study1_prep$summaries
  extra_diag <- save_study1_assumption_hists(summaries, log_path)
  q8 <- list.files(OUTPUT_FIGURES, pattern = "study1_diag_.*\\.png$", full.names = TRUE)
  q7_path <- write_q7_client_report(sort(unique(c(q8, extra_diag))), log_path)
  log_effectsize_versions(log_path)

  primary <- run_study1_primary_bundle(summaries, log_path, "primary")

  disc <- study1$discrimination
  pw <- study1$pairwise
  vis <- study1$vision
  ae_part <- stats::aggregate(
    absolute_error ~ participant_anon_id + condition + K,
    data = disc,
    FUN = function(x) mean(as.numeric(x), na.rm = TRUE)
  )
  ae_k <- cell_mean_ci(ae_part, "absolute_error")
  pw_rt <- pairwise_rt_desc(pw)

  keep <- vision_subset_ids(vis)
  log_msg(log_path, "vision_sensitivity n_ids=", length(keep),
          " (SAP expected ", as.integer(SAP$vision_subset_n_study1), ")")
  if (identical(DATA_SOURCE, "synthetic") &&
      length(keep) != as.integer(SAP$vision_subset_n_study1)) {
    stop("Vision sensitivity N is not ", SAP$vision_subset_n_study1, ".", call. = FALSE)
  }
  disc_s <- disc[disc$participant_id %in% keep, , drop = FALSE]
  pw_s <- pw[pw$participant_id %in% keep, , drop = FALSE]
  sum_s <- summarise_study1_participants(disc_s, pw_s, log_path)
  sens <- run_h1_h2_h3(sum_s, log_path, "vision_sens")
  vision_tab <- data.frame(
    analysis = c("H1_Condition", "H2_Condition_x_K", "H3_onesample"),
    n = sens$n,
    statistic = c(sens$h1$F, sens$h2$F, sens$h3$t),
    df_num = c(sens$h1$df_num, sens$h2$df_num, NA_real_),
    df_den = c(sens$h1$df_den, sens$h2$df_den, sens$h3$df),
    p = c(sens$h1$p, sens$h2$p, sens$h3$p),
    effect_size = c(sens$h1$pes, sens$h2$pes, sens$h3$d),
    es_name = c("partial_eta_sq", "partial_eta_sq", "cohens_d_vs_0.50"),
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
  write_study1_tables(primary, vision_tab, ae_k, pw_rt, log_path)
  write_study1_figures(
    acc_cells,
    primary$h3,
    list(orig = primary$rt_ms_orig, opt = primary$rt_ms_opt),
    ae_k,
    log_path
  )

  log_msg(log_path, "ANALYSIS COMPLETE. Fallback not applied. Numbers are ",
          if (identical(DATA_SOURCE, "synthetic")) "synthetic pipeline output." else "from the loaded data.")
  message("run_study1_analyse finished. Q7 fallback was not applied.")
  list(
    primary = primary,
    vision = sens,
    q7_path = q7_path,
    log_path = log_path
  )
}
