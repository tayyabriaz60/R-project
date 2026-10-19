# Study 3 inferential models. SAP §5. Reuses study1_models helpers.

source(file.path(PROJECT_ROOT, "R", "study1_models.R"))

study3_rank_diff_digits <- function() {
  as.integer(require_param("study3_rank_diff_round_digits"))
}

study3_round_rank_diff <- function(d) {
  round(as.numeric(d), study3_rank_diff_digits())
}

fit_study3_rm_anova <- function(long_acc) {
  if (any(is.na(long_acc$accuracy))) {
    stop("Study 3 RM-ANOVA: accuracy has NA.", call. = FALSE)
  }
  old_opt <- options(contrasts = c("contr.sum", "contr.poly"))
  on.exit(options(old_opt), add = TRUE)
  long_acc$participant_anon_id <- factor(as.character(long_acc$participant_anon_id))
  long_acc$condition <- factor(long_acc$condition, levels = require_param("condition_level_order"))
  long_acc$background <- factor(long_acc$background, levels = require_param("background_level_order"))
  afex::aov_ez(
    id = "participant_anon_id",
    dv = "accuracy",
    data = long_acc,
    within = c("condition", "background"),
    type = 3,
    anova_table = list(correction = "none", es = "none"),
    fun_aggregate = mean,
    include_aov = TRUE
  )
}

fit_study3_rt_rm_anova <- function(long_rt) {
  if (any(is.na(long_rt$rt))) {
    stop("Study 3 RT RM-ANOVA: rt has NA.", call. = FALSE)
  }
  old_opt <- options(contrasts = c("contr.sum", "contr.poly"))
  on.exit(options(old_opt), add = TRUE)
  long_rt$participant_anon_id <- factor(as.character(long_rt$participant_anon_id))
  long_rt$condition <- factor(long_rt$condition, levels = require_param("condition_level_order"))
  long_rt$background <- factor(long_rt$background, levels = require_param("background_level_order"))
  afex::aov_ez(
    id = "participant_anon_id",
    dv = "rt",
    data = long_rt,
    within = c("condition", "background"),
    type = 3,
    anova_table = list(correction = "none", es = "none"),
    fun_aggregate = mean,
    include_aov = TRUE
  )
}

study3_h5_followups <- function(summary_df, interaction_p) {
  alpha <- as.numeric(SAP$alpha)
  bg_order <- require_param("background_level_order")
  if (is.na(interaction_p) || interaction_p >= alpha) {
    return(list(ran = FALSE, reason = "interaction_not_significant", rows = data.frame()))
  }
  rows <- list()
  for (bg in bg_order) {
    opt <- summary_df[[paste0("acc_Optimized_", bg)]]
    orig <- summary_df[[paste0("acc_Original_", bg)]]
    if (is_zero_variance_diff(opt, orig)) {
      rows[[length(rows) + 1L]] <- data.frame(
        background = bg, estimable = FALSE, note = "zero_variance_diff",
        stringsAsFactors = FALSE
      )
    } else {
      tt <- paired_t_opt_minus_orig(opt, orig)
      rows[[length(rows) + 1L]] <- data.frame(
        background = bg,
        estimable = TRUE,
        n = tt$n,
        mean_diff = tt$mean_diff,
        ci_low = tt$ci_low,
        ci_high = tt$ci_high,
        t = tt$t,
        df = tt$df,
        p_raw = tt$p,
        p_holm = NA_real_,
        d_z = tt$d_z,
        note = "",
        stringsAsFactors = FALSE
      )
    }
  }
  out <- do.call(rbind, rows)
  estim <- which(out$estimable %in% TRUE)
  if (length(estim) > 0L) {
    out$p_holm[estim] <- holm_adjust(out$p_raw[estim])
  }
  list(ran = TRUE, reason = "interaction_significant", rows = out)
}

study3_rt_h5_followups <- function(summary_df, interaction_p) {
  alpha <- as.numeric(SAP$alpha)
  bg_order <- require_param("background_level_order")
  scale <- unique(as.character(summary_df$rt_analysis_scale))
  pref <- if (identical(scale, "log")) "mean_rt_analysis_" else "mean_rt_ms_"
  if (is.na(interaction_p) || interaction_p >= alpha) {
    return(list(ran = FALSE, reason = "interaction_not_significant", rows = data.frame()))
  }
  rows <- list()
  for (bg in bg_order) {
    opt <- summary_df[[paste0(pref, "Optimized_", bg)]]
    orig <- summary_df[[paste0(pref, "Original_", bg)]]
    if (is_zero_variance_diff(opt, orig)) {
      rows[[length(rows) + 1L]] <- data.frame(
        background = bg, estimable = FALSE, note = "zero_variance_diff",
        stringsAsFactors = FALSE
      )
    } else {
      tt <- paired_t_opt_minus_orig(opt, orig)
      rows[[length(rows) + 1L]] <- data.frame(
        background = bg, estimable = TRUE, t = tt$t, df = tt$df, p_raw = tt$p,
        p_holm = NA_real_, mean_diff = tt$mean_diff, note = "",
        stringsAsFactors = FALSE
      )
    }
  }
  out <- do.call(rbind, rows)
  estim <- which(out$estimable %in% TRUE)
  if (length(estim) > 0L) {
    out$p_holm[estim] <- holm_adjust(out$p_raw[estim])
  }
  list(ran = TRUE, reason = "interaction_significant", rows = out)
}

study3_severe_nonnormality_flag <- function(summary_df, log_path) {
  vecs <- list(
    h4 = summary_df$acc_diff_h4,
    h5 = summary_df$acc_diff_h5_white_minus_black,
    h6 = summary_df$pairwise_prop_optimized,
    h7 = summary_df$pairwise_prop_optimized_White - summary_df$pairwise_prop_optimized_Black
  )
  flags <- list()
  for (nm in names(vecs)) {
    x <- as.numeric(vecs[[nm]])
    x <- x[!is.na(x)]
    if (length(x) < 3L) {
      sk <- NA_real_
    } else {
      sk <- e1071::skewness(x, type = 2, na.rm = TRUE)
    }
    flags[[nm]] <- sk
    log_msg(log_path, "Study3 normality diagnostic skew_", nm, "=",
            if (is.na(sk)) "NA" else sprintf("%.4f", sk))
  }
  severe <- vapply(flags, function(s) !is.na(s) && abs(s) > 2, logical(1))
  if (any(severe)) {
    log_msg(log_path, "Study3 SEVERE_NONNORMALITY_FLAG names=",
            paste(names(severe)[severe], collapse = ", "))
  }
  list(skewness = flags, severe = severe)
}

run_study3_accuracy_tests <- function(summary_df, log_path, use_fallback = FALSE) {
  n <- nrow(summary_df)
  log_msg(log_path, "study3 accuracy n=", n, " fallback=", use_fallback)
  long_acc <- accuracy_long_study3(summary_df)
  if (!use_fallback) {
    fit <- fit_study3_rm_anova(long_acc)
    sph <- mauchly_table(fit)
    es <- partial_eta_table(fit)
    h4 <- anova_effect_report(fit, "condition", 2L, sph, es)
    # 2×2 within design: interaction has 1 df; no Mauchly/GG (SAP §5.1), not 4 cells.
    h5 <- anova_effect_report(fit, "condition:background", 2L, sph, es)
    follow <- study3_h5_followups(summary_df, h5$p)
    list(mode = "anova", h4 = h4, h5 = h5, follow = follow, fit = fit, n = n)
  } else {
    d_h4 <- study3_round_rank_diff(summary_df$acc_diff_h4)
    h4 <- paired_wilcoxon_on_diff(d_h4)
    d_h5 <- study3_round_rank_diff(summary_df$acc_diff_h5_white_minus_black)
    h5 <- paired_wilcoxon_on_diff(d_h5)
    list(mode = "wilcoxon", h4 = h4, h5 = h5, follow = list(ran = FALSE), n = n)
  }
}

run_study3_pairwise_tests <- function(summary_df, log_path, use_fallback = FALSE) {
  n <- nrow(summary_df)
  if (!use_fallback) {
    h6 <- onesample_t_vs(summary_df$pairwise_prop_optimized, as.numeric(SAP$h3_null))
    h7 <- paired_t_opt_minus_orig(
      summary_df$pairwise_prop_optimized_White,
      summary_df$pairwise_prop_optimized_Black
    )
    list(mode = "t", h6 = h6, h7 = h7, n = n)
  } else {
    h6 <- wilcoxonesample_vs_median(
      summary_df$pairwise_prop_optimized, as.numeric(SAP$h3_null)
    )
    d7 <- study3_round_rank_diff(
      summary_df$pairwise_prop_optimized_White - summary_df$pairwise_prop_optimized_Black
    )
    h7 <- paired_wilcoxon_on_diff(d7)
    list(mode = "wilcoxon", h6 = h6, h7 = h7, n = n)
  }
}

wilcoxonesample_vs_median <- function(x, mu) {
  x <- as.numeric(x)
  d <- x - mu
  nz <- nonzero_paired_diffs(d)
  if (nz$n_nonzero < 1L) {
    stop("H6 Wilcoxon: no non-zero deviations.", call. = FALSE)
  }
  wt <- stats::wilcox.test(nz$d_nonzero, mu = 0, exact = FALSE, correct = TRUE)
  rb <- effectsize::rank_biserial(nz$d_nonzero, mu = 0, ci = SAP$ci_level, alternative = "two.sided")
  es <- extract_rank_biserial(rb)
  list(V = unname(wt$statistic), p = wt$p.value, n = length(x), n_nonzero = nz$n_nonzero,
       r_rb = es$r_rb, r_ci_low = es$r_ci_low, r_ci_high = es$r_ci_high)
}

run_study3_rt_tests <- function(summary_df, log_path) {
  long_rt <- rt_long_study3(summary_df)
  fit <- fit_study3_rt_rm_anova(long_rt)
  sph <- mauchly_table(fit)
  es <- partial_eta_table(fit)
  h_cond <- anova_effect_report(fit, "condition", 2L, sph, es)
  h_int <- anova_effect_report(fit, "condition:background", 2L, sph, es)
  follow <- study3_rt_h5_followups(summary_df, h_int$p)
  list(condition = h_cond, interaction = h_int, follow = follow, fit = fit)
}

run_study3_ae_test <- function(summary_df, log_path) {
  ae <- paired_t_opt_minus_orig(summary_df$mean_ae_Optimized, summary_df$mean_ae_Original)
  log_msg(log_path, "Study3 AE paired t p=", sprintf("%.4f", ae$p))
  ae
}
