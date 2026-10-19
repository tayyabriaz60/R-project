# Study 2 Q32 locked mixed path: Wilcoxon H1, Friedman H2, t H3; rank-diff rounding.

study2_rank_diff_digits <- function() {
  as.integer(require_param("study2_rank_diff_round_digits"))
}

study2_round_rank_diff <- function(d) {
  round(as.numeric(d), study2_rank_diff_digits())
}

log_study2_q32_lock <- function(log_path) {
  log_msg(
    log_path,
    "Q32 locked mixed path: H1=", require_param("study2_h1_test"),
    " H2=", require_param("study2_h2_test"),
    " H3=", require_param("study2_h3_test"),
    " RT=", require_param("study2_rt_test"),
    " AE=", require_param("study2_ae_test"),
    " rank_diff_round_digits=", study2_rank_diff_digits()
  )
}

run_study2_mixed_h1_h2_h3 <- function(summary_df, log_path, label) {
  n <- nrow(summary_df)
  rd <- study2_rank_diff_digits()
  k_levels <- as.integer(SAP$k_levels_study2)
  log_msg(log_path, label, " n_participants=", n)
  log_study2_q32_lock(log_path)
  log_msg(
    log_path, label,
    " H1/H2 rank-based inputs: Optimized-Original difference scores rounded to ",
    rd, " decimal places before Wilcoxon/Friedman (float tie control)."
  )

  d_h1 <- study2_round_rank_diff(summary_df$acc_Optimized - summary_df$acc_Original)
  h1 <- paired_wilcoxon_on_diff(d_h1)
  log_msg(log_path, label, " H1 V=", sprintf("%.4f", h1$V),
          " p=", sprintf("%.4f", h1$p),
          " n_nonzero=", h1$n_nonzero, " n_zero=", h1$n_zero,
          " r_rb=", sprintf("%.4f", h1$r_rb))

  h2 <- friedman_h2_on_k_diffs(summary_df, k_levels = k_levels, round_digits = rd)
  log_msg(log_path, label, " H2 Friedman chi2=", sprintf("%.4f", h2$statistic),
          " df=", h2$df, " p=", sprintf("%.4f", h2$p),
          " W=", sprintf("%.4f", h2$kendalls_w))

  follow <- h2_friedman_followups(summary_df, h2$p, k_levels = k_levels, round_digits = rd)
  log_msg(log_path, label, " H2_followups_ran=", follow$ran, " reason=", follow$reason)
  if (isTRUE(follow$ran)) {
    log_msg(log_path, label, " H2_followups_n_estimable=", sum(follow$rows$estimable),
            " n_not_estimable=", sum(!follow$rows$estimable))
  }

  h3 <- onesample_t_vs(summary_df$pairwise_prop_optimized, as.numeric(SAP$h3_null))
  log_msg(log_path, label, " H3 t=", sprintf("%.4f", h3$t),
          " df=", sprintf("%.4f", h3$df),
          " p=", sprintf("%.4f", h3$p),
          " mean=", sprintf("%.4f", h3$mean))

  list(n = n, h1 = h1, h2 = h2, follow = follow, h3 = h3, rank_diff_digits = rd)
}
