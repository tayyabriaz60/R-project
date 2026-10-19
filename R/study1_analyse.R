# Study 1 primary tests, sensitivity, tables, figures.
# Q7 path open (Oct 2026): real inferential held until diagnostic review.

source(file.path(PROJECT_ROOT, "R", "study1_models.R"))
source(file.path(PROJECT_ROOT, "R", "study1_q7.R"))
source(file.path(PROJECT_ROOT, "R", "study1_export.R"))
source(file.path(PROJECT_ROOT, "R", "study1_summarise.R"))

vision_subset_ids <- function(vis) {
  keep <- unique(as.character(vis$participant_id[vis$vision_subset_flag == 1L]))
  keep <- keep[!is.na(keep) & nzchar(keep)]
  keep
}

run_study1_primary_bundle <- function(summary_df, log_path, label) {
  tests <- run_study1_h1_h2_h3(summary_df, log_path, label)
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
  an_title <- if (identical(DATA_SOURCE, "synthetic")) {
    "STUDY 1 ANALYSIS (aggregates only; SYNTHETIC DATA: pipeline test only)"
  } else {
    "STUDY 1 ANALYSIS (aggregates only; real export; no participant IDs in this log)"
  }
  start_log(log_path, an_title)
  log_msg(log_path, "Study 1 aligned with Study 2: vision primary, Difficulty levels, rank-diff rounding when rank tests used.")
  if (isTRUE(SAP$study1_primary_vision_exclusion)) {
    log_msg(log_path, "Primary vision exclusion: Ishihara 4/4 AND questionnaire pass (real data).")
  }

  summaries <- study1_prep$summaries
  extra_diag <- save_study1_assumption_hists(summaries, log_path)
  q8 <- list.files(OUTPUT_FIGURES, pattern = "study1_diag_.*\\.png$", full.names = TRUE)
  q7_path <- write_q7_client_report(sort(unique(c(q8, extra_diag))), log_path)
  log_effectsize_versions(log_path)
  log_study1_test_config(log_path)

  hold_inferential <- identical(DATA_SOURCE, "real") && isTRUE(SAP$study1_q7_hold_inferential)
  if (hold_inferential) {
    source(file.path(PROJECT_ROOT, "R", "utils_figures_study1.R"), local = FALSE)
    log_msg(log_path, "Q7 hold: inferential tables deferred until client reviews diagnostics and locks test path.")
    h3_fig <- h3_mean_ci_for_figure(summaries)
    rt_ms <- list(
      orig = mean_sd_ci(summaries$mean_rt_ms_Original),
      opt = mean_sd_ci(summaries$mean_rt_ms_Optimized)
    )
    write_study1_figures(
      study1$discrimination, study1$pairwise, h3_fig, rt_ms, log_path
    )
    log_msg(log_path, "ANALYSIS HELD at diagnostics + figures (Q7). No inferential tables written.")
    message("run_study1_analyse finished. Q7 hold: inferential outputs skipped on real data.")
    return(list(primary = NULL, vision = NULL, q7_path = q7_path, log_path = log_path, q7_hold = TRUE))
  }

  n_primary <- nrow(summaries)
  log_msg(log_path, "primary n_participants=", n_primary)
  primary <- run_study1_primary_bundle(summaries, log_path, "primary")
  log_msg(log_path, "RT inferential analysis scale=", primary$rt_scale)

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

  if (isTRUE(SAP$study1_primary_vision_exclusion)) {
    log_msg(log_path, "vision_sensitivity skipped: primary already applies Ishihara 4/4 rule.")
    vision_tab <- data.frame(
      analysis = character(),
      n = integer(),
      statistic = numeric(),
      df = numeric(),
      p = numeric(),
      effect_size = numeric(),
      es_name = character(),
      primary_p = numeric(),
      sig_agrees_with_primary = logical(),
      stringsAsFactors = FALSE
    )
    sens <- list(n = 0L)
  } else {
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
    sens <- run_study1_h1_h2_h3(sum_s, log_path, "vision_sens")
    vision_tab <- build_study1_vision_sensitivity_table(sens, primary)
    log_msg(log_path, "vision_sensitivity H1_sig_agrees=", vision_tab$sig_agrees_with_primary[1],
            " H2_sig_agrees=", vision_tab$sig_agrees_with_primary[2],
            " H3_sig_agrees=", vision_tab$sig_agrees_with_primary[3])
  }

  write_study1_tables(primary, vision_tab, ae_k, pw_rt, log_path)
  h3_fig <- list(
    mean = primary$h3$mean,
    ci_low = primary$h3$ci_low,
    ci_high = primary$h3$ci_high
  )
  write_study1_figures(
    disc, pw, h3_fig,
    list(orig = primary$rt_ms_orig, opt = primary$rt_ms_opt),
    log_path
  )

  log_msg(log_path, "ANALYSIS COMPLETE. Configured test path. Numbers are ",
          if (identical(DATA_SOURCE, "synthetic")) "synthetic pipeline output." else "from the loaded data.")
  message("run_study1_analyse finished.")
  list(
    primary = primary,
    vision = sens,
    q7_path = q7_path,
    log_path = log_path
  )
}
