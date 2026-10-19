# Study 3 participant summaries. SAP §5.1–§5.3.

source(file.path(PROJECT_ROOT, "R", "summarise_participants.R"))
source(file.path(PROJECT_ROOT, "R", "study1_summarise.R"))

study3_accuracy_cells_long <- function(disc) {
  stats::aggregate(
    accuracy ~ participant_anon_id + participant_id + condition + background,
    data = disc,
    FUN = function(x) mean(as.numeric(x), na.rm = TRUE)
  )
}

mean_by_id_condition_background <- function(disc, value_col, out_name) {
  form <- stats::as.formula(
    paste(value_col, "~ participant_anon_id + participant_id + condition + background")
  )
  out <- stats::aggregate(form, data = disc, FUN = function(x) mean(as.numeric(x), na.rm = TRUE))
  names(out)[names(out) == value_col] <- out_name
  out
}

pairwise_proportion_by_background <- function(pw) {
  stats::aggregate(
    chose_optimized ~ participant_anon_id + participant_id + background,
    data = pw,
    FUN = function(x) mean(as.numeric(x), na.rm = TRUE)
  )
}

pick_cbg <- function(tab, pid, cond, bg, col) {
  hit <- tab$participant_id == pid & tab$condition == cond & tab$background == bg
  if (!any(hit)) {
    NA_real_
  } else {
    tab[[col]][hit][1]
  }
}

summarise_study3_participants <- function(disc, pw, log_path) {
  cells <- study3_accuracy_cells_long(disc)
  cond_order <- require_param("condition_level_order")
  bg_order <- require_param("background_level_order")
  ids <- unique(cells[, c("participant_anon_id", "participant_id")])
  ids <- ids[order(ids$participant_anon_id), , drop = FALSE]
  n <- nrow(ids)
  out <- data.frame(participant_anon_id = ids$participant_anon_id, stringsAsFactors = FALSE)
  out$.pid <- ids$participant_id

  for (cond in cond_order) {
    for (bg in bg_order) {
      col <- paste0("acc_", cond, "_", bg)
      out[[col]] <- NA_real_
      for (i in seq_len(n)) {
        hit <- cells$participant_id == out$.pid[i] &
          cells$condition == cond & cells$background == bg
        if (any(hit)) {
          out[[col]][i] <- cells$accuracy[hit][1]
        }
      }
    }
  }

  out$acc_Original <- rowMeans(
    out[, paste0("acc_Original_", bg_order), drop = FALSE], na.rm = TRUE
  )
  out$acc_Optimized <- rowMeans(
    out[, paste0("acc_Optimized_", bg_order), drop = FALSE], na.rm = TRUE
  )
  out$acc_diff_h4 <- out$acc_Optimized - out$acc_Original
  out$acc_diff_opt_orig_White <- out$acc_Optimized_White - out$acc_Original_White
  out$acc_diff_opt_orig_Black <- out$acc_Optimized_Black - out$acc_Original_Black
  out$acc_diff_h5_white_minus_black <- out$acc_diff_opt_orig_White - out$acc_diff_opt_orig_Black

  pw_all <- pairwise_proportion(pw)
  out$pairwise_prop_optimized <- pw_all$chose_optimized[match(out$.pid, pw_all$participant_id)]
  pw_bg <- pairwise_proportion_by_background(pw)
  for (bg in bg_order) {
    sub <- pw_bg[pw_bg$background == bg, , drop = FALSE]
    col <- paste0("pairwise_prop_optimized_", bg)
    out[[col]] <- sub$chose_optimized[match(out$.pid, sub$participant_id)]
  }
  out$pairwise_n_trials <- as.integer(SAP$pairwise_trials_per_participant_study3)

  valid <- valid_rt_rows(disc)
  sk <- trial_rt_skewness(disc)
  scale <- rt_analysis_scale(sk)
  log_msg(log_path, "Study3 trial_rt_skewness=", if (is.na(sk)) "NA" else sprintf("%.4f", sk),
          " analysis_scale=", scale)
  valid$rt_analysis <- if (identical(scale, "log")) {
    log(valid$reaction_time_ms)
  } else {
    valid$reaction_time_ms
  }
  rt_ms <- mean_by_id_condition_background(valid, "reaction_time_ms", "mean_rt_ms")
  rt_an <- mean_by_id_condition_background(valid, "rt_analysis", "mean_rt_analysis")
  for (cond in cond_order) {
    for (bg in bg_order) {
      out[[paste0("mean_rt_ms_", cond, "_", bg)]] <- vapply(
        out$.pid, pick_cbg, numeric(1),
        tab = rt_ms, cond = cond, bg = bg, col = "mean_rt_ms"
      )
      out[[paste0("mean_rt_analysis_", cond, "_", bg)]] <- vapply(
        out$.pid, pick_cbg, numeric(1),
        tab = rt_an, cond = cond, bg = bg, col = "mean_rt_analysis"
      )
    }
  }
  out$rt_analysis_scale <- scale

  ae <- mean_by_id_condition_background(disc, "absolute_error", "mean_ae")
  se <- mean_by_id_condition_background(disc, "signed_error", "mean_se")
  for (cond in cond_order) {
    for (bg in bg_order) {
      out[[paste0("mean_ae_", cond, "_", bg)]] <- vapply(
        out$.pid, pick_cbg, numeric(1),
        tab = ae, cond = cond, bg = bg, col = "mean_ae"
      )
      out[[paste0("mean_se_", cond, "_", bg)]] <- vapply(
        out$.pid, pick_cbg, numeric(1),
        tab = se, cond = cond, bg = bg, col = "mean_se"
      )
    }
  }
  out$mean_ae_Original <- rowMeans(
    out[, paste0("mean_ae_Original_", bg_order), drop = FALSE], na.rm = TRUE
  )
  out$mean_ae_Optimized <- rowMeans(
    out[, paste0("mean_ae_Optimized_", bg_order), drop = FALSE], na.rm = TRUE
  )
  out$mean_se_Original <- rowMeans(
    out[, paste0("mean_se_Original_", bg_order), drop = FALSE], na.rm = TRUE
  )
  out$mean_se_Optimized <- rowMeans(
    out[, paste0("mean_se_Optimized_", bg_order), drop = FALSE], na.rm = TRUE
  )

  out$.pid <- NULL
  if (any(is.na(out$pairwise_prop_optimized))) {
    stop("Study 3 pairwise proportion missing after gates.", call. = FALSE)
  }
  log_msg(log_path, "study3 summaries n_participants=", nrow(out))
  out
}

accuracy_long_study3 <- function(summary_df) {
  cond_order <- require_param("condition_level_order")
  bg_order <- require_param("background_level_order")
  rows <- list()
  for (i in seq_len(nrow(summary_df))) {
    for (cond in cond_order) {
      for (bg in bg_order) {
        col <- paste0("acc_", cond, "_", bg)
        rows[[length(rows) + 1L]] <- data.frame(
          participant_anon_id = summary_df$participant_anon_id[i],
          condition = cond,
          background = bg,
          accuracy = summary_df[[col]][i],
          stringsAsFactors = FALSE
        )
      }
    }
  }
  do.call(rbind, rows)
}

rt_long_study3 <- function(summary_df) {
  cond_order <- require_param("condition_level_order")
  bg_order <- require_param("background_level_order")
  scale <- unique(as.character(summary_df$rt_analysis_scale))
  if (length(scale) != 1L) {
    stop("rt_analysis_scale not unique.", call. = FALSE)
  }
  pref <- if (identical(scale[[1]], "log")) {
    "mean_rt_analysis_"
  } else {
    "mean_rt_ms_"
  }
  rows <- list()
  for (i in seq_len(nrow(summary_df))) {
    for (cond in cond_order) {
      for (bg in bg_order) {
        col <- paste0(pref, cond, "_", bg)
        rows[[length(rows) + 1L]] <- data.frame(
          participant_anon_id = summary_df$participant_anon_id[i],
          condition = cond,
          background = bg,
          rt = summary_df[[col]][i],
          stringsAsFactors = FALSE
        )
      }
    }
  }
  do.call(rbind, rows)
}

pairwise_rt_desc_study3 <- function(pw) {
  stats::aggregate(
    reaction_time_ms ~ background,
    data = pw,
    FUN = function(x) c(
      n = sum(!is.na(x)),
      mean = mean(x, na.rm = TRUE),
      sd = stats::sd(x, na.rm = TRUE)
    )
  )
}
