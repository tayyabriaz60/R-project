# Study 1 participant summaries. SAP §3.1–§3.3. Q6 anon IDs on any written table.
# Q12: trial-level RT skewness before averaging; log if > 1. Keep untransformed ms.

source(file.path(PROJECT_ROOT, "R", "summarise_participants.R"))
source(file.path(PROJECT_ROOT, "R", "utils_logging.R"))
source(file.path(PROJECT_ROOT, "R", "utils_paths.R"))
source(file.path(PROJECT_ROOT, "R", "utils_io.R"))

valid_rt_rows <- function(disc) {
  rt <- disc$reaction_time_ms
  disc[!is.na(rt) & rt > 0, , drop = FALSE]
}

trial_rt_skewness <- function(disc) {
  valid <- valid_rt_rows(disc)
  if (nrow(valid) < 3L) {
    return(NA_real_)
  }
  e1071::skewness(valid$reaction_time_ms, type = 2, na.rm = TRUE)
}

rt_analysis_scale <- function(skewness_value) {
  thr <- as.numeric(require_param("rt_skew_log_threshold"))
  if (!is.na(skewness_value) && skewness_value > thr) {
    "log"
  } else {
    "raw"
  }
}

summarise_study1_participants <- function(disc, pw, log_path) {
  cells <- accuracy_cells_long(disc)
  cond_order <- require_param("condition_level_order")
  k_order <- as.integer(SAP$k_levels_study1)

  ids <- unique(cells[, c("participant_anon_id", "participant_id")])
  ids <- ids[order(ids$participant_anon_id), , drop = FALSE]
  n <- nrow(ids)
  out <- data.frame(
    participant_anon_id = ids$participant_anon_id,
    stringsAsFactors = FALSE
  )
  # Keep analysis id only in memory for joins; strip before write.
  out$.pid <- ids$participant_id

  for (cond in cond_order) {
    for (k in k_order) {
      col <- paste0("acc_", cond, "_K", k)
      out[[col]] <- NA_real_
      for (i in seq_len(n)) {
        hit <- cells$participant_id == out$.pid[i] &
          cells$condition == cond & cells$K == k
        if (any(hit)) {
          out[[col]][i] <- cells$accuracy[hit][1]
        }
      }
    }
  }

  orig_cols <- paste0("acc_Original_K", k_order)
  opt_cols <- paste0("acc_Optimized_K", k_order)
  out$acc_Original <- rowMeans(out[, orig_cols, drop = FALSE], na.rm = TRUE)
  out$acc_Optimized <- rowMeans(out[, opt_cols, drop = FALSE], na.rm = TRUE)
  out$acc_diff_h1 <- out$acc_Optimized - out$acc_Original
  for (k in k_order) {
    out[[paste0("acc_diff_K", k)]] <- out[[paste0("acc_Optimized_K", k)]] -
      out[[paste0("acc_Original_K", k)]]
  }

  pw_prop <- pairwise_proportion(pw)
  out$pairwise_prop_optimized <- pw_prop$chose_optimized[match(out$.pid, pw_prop$participant_id)]
  out$pairwise_n_trials <- as.integer(SAP$pairwise_trials_per_participant)

  valid <- valid_rt_rows(disc)
  sk <- trial_rt_skewness(disc)
  scale <- rt_analysis_scale(sk)
  log_msg(log_path, "Q12 trial_rt_skewness=", if (is.na(sk)) "NA" else sprintf("%.4f", sk),
          " threshold=", require_param("rt_skew_log_threshold"),
          " analysis_scale=", scale,
          " n_valid_rt_trials=", nrow(valid),
          " n_rt_dropped=", nrow(disc) - nrow(valid))
  valid$rt_analysis <- if (identical(scale, "log")) {
    log(valid$reaction_time_ms)
  } else {
    valid$reaction_time_ms
  }
  rt_ms <- mean_by_id_condition(valid, "reaction_time_ms", "mean_rt_ms")
  rt_an <- mean_by_id_condition(valid, "rt_analysis", "mean_rt_analysis")
  pick_cond <- function(tab, pid, cond, col) {
    hit <- tab$participant_id == pid & tab$condition == cond
    if (!any(hit)) NA_real_ else tab[[col]][hit][1]
  }
  out$mean_rt_ms_Original <- vapply(out$.pid, pick_cond, numeric(1), tab = rt_ms, cond = "Original", col = "mean_rt_ms")
  out$mean_rt_ms_Optimized <- vapply(out$.pid, pick_cond, numeric(1), tab = rt_ms, cond = "Optimized", col = "mean_rt_ms")
  out$mean_rt_analysis_Original <- vapply(out$.pid, pick_cond, numeric(1), tab = rt_an, cond = "Original", col = "mean_rt_analysis")
  out$mean_rt_analysis_Optimized <- vapply(out$.pid, pick_cond, numeric(1), tab = rt_an, cond = "Optimized", col = "mean_rt_analysis")
  out$rt_analysis_scale <- scale

  ae <- mean_by_id_condition(disc, "absolute_error", "mean_ae")
  se <- mean_by_id_condition(disc, "signed_error", "mean_se")
  out$mean_ae_Original <- vapply(out$.pid, pick_cond, numeric(1), tab = ae, cond = "Original", col = "mean_ae")
  out$mean_ae_Optimized <- vapply(out$.pid, pick_cond, numeric(1), tab = ae, cond = "Optimized", col = "mean_ae")
  out$mean_se_Original <- vapply(out$.pid, pick_cond, numeric(1), tab = se, cond = "Original", col = "mean_se")
  out$mean_se_Optimized <- vapply(out$.pid, pick_cond, numeric(1), tab = se, cond = "Optimized", col = "mean_se")

  out$.pid <- NULL
  if (any(is.na(out$pairwise_prop_optimized))) {
    stop("Pairwise proportion missing after Q3/Q4 gates.", call. = FALSE)
  }
  log_msg(log_path, "summaries n_participants=", nrow(out),
          " n_anon=", n_unique_nonempty(out$participant_anon_id),
          " (Gorilla IDs not written)")
  out
}

write_study1_summaries <- function(summary_df) {
  ensure_output_dirs()
  path <- file.path(OUTPUT_TABLES, paste0("study1_participant_summaries", OUTPUT_SUFFIX, ".csv"))
  if ("participant_id" %in% names(summary_df) || "participant_public_id" %in% names(summary_df)) {
    stop("Refusing to write a summary table that still has a Gorilla ID column.", call. = FALSE)
  }
  write_qc_csv(summary_df, path)
  path
}
