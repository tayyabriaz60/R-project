# Study 1 inferential helpers. SAP §3.1–§3.3. Q9, Q10, Q11.
# Locked Q7 path (22 Sep 2026): H1 Wilcoxon, H2 Friedman, H3 Wilcoxon; RT/AE paired t.

source(file.path(PROJECT_ROOT, "R", "utils_logging.R"))
source(file.path(PROJECT_ROOT, "R", "utils_format.R"))

holm_adjust <- function(p) {
  stats::p.adjust(as.numeric(p), method = require_param("holm_method"))
}

# Long Condition × K accuracy from the wide participant summary. SAP §3.1.
accuracy_long_from_summary <- function(summary_df) {
  cond_order <- require_param("condition_level_order")
  k_order <- as.integer(SAP$k_levels_study1)
  pieces <- list()
  for (cond in cond_order) {
    for (k in k_order) {
      col <- paste0("acc_", cond, "_K", k)
      if (!col %in% names(summary_df)) {
        stop("accuracy_long_from_summary: missing column ", col, ".", call. = FALSE)
      }
      pieces[[length(pieces) + 1L]] <- data.frame(
        participant_anon_id = as.character(summary_df$participant_anon_id),
        condition = cond,
        K = k,
        accuracy = as.numeric(summary_df[[col]]),
        stringsAsFactors = FALSE
      )
    }
  }
  out <- do.call(rbind, pieces)
  rownames(out) <- NULL
  out$condition <- factor(out$condition, levels = cond_order)
  out$K <- factor(out$K, levels = k_order)
  out
}

mean_sd_ci <- function(x, level = NULL) {
  if (is.null(level)) {
    level <- as.numeric(SAP$ci_level)
  }
  x <- as.numeric(x)
  x <- x[!is.na(x)]
  n <- length(x)
  if (n < 2L) {
    stop("mean_sd_ci needs at least 2 non-missing values.", call. = FALSE)
  }
  m <- mean(x)
  s <- stats::sd(x)
  se <- s / sqrt(n)
  tcrit <- stats::qt((1 + level) / 2, df = n - 1L)
  list(n = n, mean = m, sd = s, ci_low = m - tcrit * se, ci_high = m + tcrit * se)
}

is_zero_variance_diff <- function(x, y) {
  d <- as.numeric(x) - as.numeric(y)
  d <- d[!is.na(d)]
  if (length(d) < 2L) {
    return(TRUE)
  }
  stats::sd(d) == 0
}

# Q11: paired difference is Optimized minus Original.
paired_t_opt_minus_orig <- function(opt, orig) {
  opt <- as.numeric(opt)
  orig <- as.numeric(orig)
  if (length(opt) != length(orig)) {
    stop("paired_t_opt_minus_orig: lengths differ.", call. = FALSE)
  }
  if (is_zero_variance_diff(opt, orig)) {
    return(list(estimable = FALSE, n = sum(!is.na(opt) & !is.na(orig))))
  }
  tt <- stats::t.test(opt, orig, paired = TRUE, alternative = "two.sided",
                      conf.level = as.numeric(SAP$ci_level))
  d <- effectsize::cohens_d(
    opt, orig,
    paired = TRUE,
    ci = as.numeric(SAP$ci_level),
    alternative = "two.sided",
    verbose = FALSE
  )
  list(
    estimable = TRUE,
    n = as.integer(tt$parameter + 1),
    mean_diff = unname(tt$estimate),
    ci_low = unname(tt$conf.int[1]),
    ci_high = unname(tt$conf.int[2]),
    t = unname(tt$statistic),
    df = unname(tt$parameter),
    p = unname(tt$p.value),
    d_z = as.numeric(d$Cohens_d)[1],
    d_ci_low = as.numeric(d$CI_low)[1],
    d_ci_high = as.numeric(d$CI_high)[1]
  )
}

# SAP §3.2: one-sample t vs 0.50. Q9: Cohen's d vs 0.50.
onesample_t_vs <- function(x, mu) {
  x <- as.numeric(x)
  x <- x[!is.na(x)]
  tt <- stats::t.test(x, mu = mu, alternative = require_param("h3_alternative"),
                      conf.level = as.numeric(SAP$ci_level))
  d <- effectsize::cohens_d(
    x,
    mu = mu,
    ci = as.numeric(SAP$ci_level),
    alternative = "two.sided",
    verbose = FALSE
  )
  desc <- mean_sd_ci(x)
  list(
    n = desc$n,
    mean = desc$mean,
    sd = desc$sd,
    ci_low = unname(tt$conf.int[1]),
    ci_high = unname(tt$conf.int[2]),
    t = unname(tt$statistic),
    df = unname(tt$parameter),
    p = unname(tt$p.value),
    d = as.numeric(d$Cohens_d)[1],
    d_ci_low = as.numeric(d$CI_low)[1],
    d_ci_high = as.numeric(d$CI_high)[1],
    mu = mu
  )
}

# SAP §3.1; Q11: Type III, sum-to-zero. afex type=3 uses contr.sum.
fit_study1_rm_anova <- function(long_acc) {
  if (any(is.na(long_acc$accuracy))) {
    stop("RM-ANOVA: accuracy has NA. Q4 should have stopped earlier.", call. = FALSE)
  }
  old_opt <- options(contrasts = c("contr.sum", "contr.poly"))
  on.exit(options(old_opt), add = TRUE)
  long_acc$participant_anon_id <- factor(as.character(long_acc$participant_anon_id))
  afex::aov_ez(
    id = "participant_anon_id",
    dv = "accuracy",
    data = long_acc,
    within = c("condition", "K"),
    type = 3,
    anova_table = list(correction = "none", es = "none"),
    fun_aggregate = mean,
    include_aov = TRUE
  )
}

normalize_effect <- function(x) {
  parts <- unlist(strsplit(tolower(as.character(x)), "[^a-z0-9]+"))
  parts <- parts[nzchar(parts)]
  paste(sort(parts), collapse = ":")
}

resolve_effect_name <- function(rn, candidates) {
  keys <- vapply(rn, normalize_effect, character(1))
  for (cand in candidates) {
    hit <- which(keys == normalize_effect(cand))
    if (length(hit) == 1L) {
      return(rn[[hit]])
    }
  }
  stop("ANOVA effect not found. Rows: ", paste(rn, collapse = ", "),
       call. = FALSE)
}

# car/afex 1.4.1: as.data.frame() on the Mauchly object can flatten a 2x2
# table into 4 rows named 1:4 (Kaggle 22 Sep 2026). Keep effects on rows.
coerce_mauchly_df <- function(sph) {
  if (is.matrix(sph) || (is.array(sph) && length(dim(sph)) == 2L)) {
    return(as.data.frame.matrix(as.matrix(sph), stringsAsFactors = FALSE))
  }
  df <- as.data.frame(sph, stringsAsFactors = FALSE)
  nms <- names(df)
  if (nrow(df) >= 2L && all(c("Var1", "Var2", "Freq") %in% nms)) {
    effects <- unique(as.character(df$Var1))
    measures <- unique(as.character(df$Var2))
    wide <- data.frame(row.names = effects, check.names = FALSE)
    for (meas in measures) {
      wide[[meas]] <- vapply(effects, function(eff) {
        as.numeric(df$Freq[as.character(df$Var1) == eff &
                             as.character(df$Var2) == meas][1])
      }, numeric(1))
    }
    return(wide)
  }
  name_col <- intersect(nms, c("Effect", "effect", "Term", "term", "Parameter"))
  if (length(name_col) == 1L) {
    rn <- as.character(df[[name_col]])
    df[[name_col]] <- NULL
    rownames(df) <- rn
  }
  df
}

# Mauchly from the car Anova.mlm object stored by afex.
mauchly_table <- function(fit) {
  if (is.null(fit$Anova)) {
    stop("afex fit has no $Anova component; cannot run Mauchly (SAP §3.1).", call. = FALSE)
  }
  sm <- summary(fit$Anova, multivariate = FALSE)
  sph <- sm$sphericity.tests
  if (is.null(sph)) {
    stop(
      "car::Anova summary has no sphericity.tests. ",
      "Do not skip Mauchly. Print summary(fit$Anova) on Kaggle.",
      call. = FALSE
    )
  }
  coerce_mauchly_df(sph)
}

mauchly_p_for <- function(sph, effect) {
  rn <- rownames(sph)
  if (is.null(rn)) {
    stop("Mauchly table has no row names.", call. = FALSE)
  }
  key <- normalize_effect(effect)
  hit <- which(vapply(rn, normalize_effect, character(1)) == key)
  if (length(hit) != 1L) {
    return(NA_real_)
  }
  pcol <- intersect(names(sph), c("p-value", "p.value", "p"))
  if (length(pcol) < 1L) {
    # matrix columns may be "Test statistic" and "p-value"
    nms <- names(sph)
    if (is.null(nms) && !is.null(colnames(sph))) {
      nms <- colnames(sph)
    }
    pcol <- nms[grepl("p", nms, ignore.case = TRUE)]
  }
  if (length(pcol) < 1L) {
    stop("Mauchly table has no p-value column. Names: ",
         paste(names(sph), collapse = ","), call. = FALSE)
  }
  as.numeric(sph[hit[1], pcol[1]])
}

# SAP §3.1: GG if Mauchly violated (p < alpha). Condition (2 levels) has no Mauchly.
sphericity_choice <- function(sph, effect, n_levels) {
  if (n_levels <= 2L) {
    return(list(use_gg = FALSE, mauchly_p = NA_real_, reason = "two_levels_no_sphericity"))
  }
  mp <- mauchly_p_for(sph, effect)
  if (is.na(mp)) {
    stop(
      "No Mauchly p-value for effect '", effect,
      "'. Mauchly rows: ", paste(rownames(sph), collapse = ", "),
      "; columns: ", paste(names(sph), collapse = ", "),
      ".",
      call. = FALSE
    )
  }
  use_gg <- mp < as.numeric(SAP$alpha)
  list(
    use_gg = use_gg,
    mauchly_p = mp,
    reason = if (use_gg) "mauchly_p_lt_alpha_gg" else "mauchly_ns_uncorrected"
  )
}

pick_anova_row <- function(tab, effect) {
  tab <- as.data.frame(tab)
  rn <- rownames(tab)
  if (is.null(rn)) {
    stop("ANOVA table has no row names.", call. = FALSE)
  }
  key <- normalize_effect(effect)
  hit <- which(vapply(rn, normalize_effect, character(1)) == key)
  if (length(hit) != 1L) {
    stop("ANOVA effect '", effect, "' not found. Rows: ",
         paste(rn, collapse = ", "), call. = FALSE)
  }
  tab[hit, , drop = FALSE]
}

num_from <- function(row, candidates) {
  nms <- names(row)
  for (cand in candidates) {
    if (cand %in% nms) {
      return(as.numeric(row[[cand]])[1])
    }
  }
  stop("ANOVA row missing columns. Have: ", paste(nms, collapse = ", "),
       call. = FALSE)
}

# One ANOVA effect with the SAP sphericity rule applied.
anova_effect_report <- function(fit, effect, n_levels, sph, es_tbl) {
  ch <- sphericity_choice(sph, effect, n_levels)
  corr <- if (isTRUE(ch$use_gg)) "GG" else "none"
  tab <- anova(fit, correction = corr, es = "none")
  row <- pick_anova_row(tab, effect)
  f <- num_from(row, c("F", "F.value"))
  df_num <- num_from(row, c("num Df", "num.Df", "num_Df"))
  df_den <- num_from(row, c("den Df", "den.Df", "den_Df"))
  p <- num_from(row, c("Pr(>F)", "p.value", "p", "p[GG]", "p[HF]"))
  es_row <- pick_eta_row(es_tbl, effect)
  list(
    effect = effect,
    F = f,
    df_num = df_num,
    df_den = df_den,
    p = p,
    pes = es_row$pes,
    pes_ci_low = es_row$ci_low,
    pes_ci_high = es_row$ci_high,
    mauchly_p = ch$mauchly_p,
    sphericity_correction = corr,
    sphericity_reason = ch$reason
  )
}

# Q9: partial eta-squared, two-sided 95% CI. effectsize default alternative is "greater".
partial_eta_table <- function(fit) {
  effectsize::eta_squared(
    fit,
    partial = TRUE,
    generalized = FALSE,
    ci = as.numeric(SAP$ci_level),
    alternative = "two.sided",
    verbose = FALSE
  )
}

pick_eta_row <- function(es_tbl, effect) {
  es_tbl <- as.data.frame(es_tbl)
  if (!"Parameter" %in% names(es_tbl)) {
    stop("eta_squared() table has no Parameter column.", call. = FALSE)
  }
  key <- normalize_effect(effect)
  hit <- which(vapply(es_tbl$Parameter, normalize_effect, character(1)) == key)
  if (length(hit) != 1L) {
    stop("eta_squared row for '", effect, "' not found. Parameters: ",
         paste(es_tbl$Parameter, collapse = ", "), call. = FALSE)
  }
  pes_col <- intersect(names(es_tbl), c("Eta2_partial", "Eta2 (partial)", "Eta2"))
  if (length(pes_col) < 1L) {
    stop("eta_squared table missing eta column. Names: ",
         paste(names(es_tbl), collapse = ", "), call. = FALSE)
  }
  list(
    pes = as.numeric(es_tbl[[pes_col[1]]][hit]),
    ci_low = as.numeric(es_tbl$CI_low[hit]),
    ci_high = as.numeric(es_tbl$CI_high[hit])
  )
}

# SAP §3.1: follow-ups only if the Condition × K interaction is significant.
# Zero-variance K: descriptives only; Holm on the remaining estimable tests.
h2_followups <- function(summary_df, interaction_p) {
  k_order <- as.integer(SAP$k_levels_study1)
  alpha <- as.numeric(SAP$alpha)
  if (is.na(interaction_p) || interaction_p >= alpha) {
    return(list(
      ran = FALSE,
      reason = "interaction_not_significant",
      rows = data.frame()
    ))
  }
  rows <- list()
  for (k in k_order) {
    opt <- summary_df[[paste0("acc_Optimized_K", k)]]
    orig <- summary_df[[paste0("acc_Original_K", k)]]
    if (is_zero_variance_diff(opt, orig)) {
      rows[[length(rows) + 1L]] <- data.frame(
        K = k,
        estimable = FALSE,
        n = sum(!is.na(opt) & !is.na(orig)),
        mean_orig = mean(orig, na.rm = TRUE),
        mean_opt = mean(opt, na.rm = TRUE),
        mean_diff = mean(opt - orig, na.rm = TRUE),
        ci_low = NA_real_,
        ci_high = NA_real_,
        t = NA_real_,
        df = NA_real_,
        p_raw = NA_real_,
        p_holm = NA_real_,
        d_z = NA_real_,
        d_ci_low = NA_real_,
        d_ci_high = NA_real_,
        note = "zero_variance_diff_descriptive_only",
        stringsAsFactors = FALSE
      )
    } else {
      tt <- paired_t_opt_minus_orig(opt, orig)
      rows[[length(rows) + 1L]] <- data.frame(
        K = k,
        estimable = TRUE,
        n = tt$n,
        mean_orig = mean(orig, na.rm = TRUE),
        mean_opt = mean(opt, na.rm = TRUE),
        mean_diff = tt$mean_diff,
        ci_low = tt$ci_low,
        ci_high = tt$ci_high,
        t = tt$t,
        df = tt$df,
        p_raw = tt$p,
        p_holm = NA_real_,
        d_z = tt$d_z,
        d_ci_low = tt$d_ci_low,
        d_ci_high = tt$d_ci_high,
        note = "",
        stringsAsFactors = FALSE
      )
    }
  }
  out <- do.call(rbind, rows)
  estim <- which(out$estimable)
  if (length(estim) > 0L) {
    out$p_holm[estim] <- holm_adjust(out$p_raw[estim])
  }
  list(ran = TRUE, reason = "interaction_significant", rows = out)
}

log_effectsize_versions <- function(log_path) {
  log_msg(log_path, "Q9 effectsize_version=", as.character(utils::packageVersion("effectsize")))
  log_msg(log_path, "Q9 paired_d: effectsize::cohens_d(opt, orig, paired=TRUE, ci=",
          SAP$ci_level, ", alternative=\"two.sided\")  # Cohen's dz; used for RT/AE")
  log_msg(log_path, "Q9 rank_biserial: effectsize::rank_biserial(..., ci=",
          SAP$ci_level, ", alternative=\"two.sided\") on Q10 non-zero diffs")
  log_msg(log_path, "Q9 kendalls_w: effectsize::kendalls_w(mat, ci=",
          SAP$ci_level, ", alternative=\"two.sided\")")
}

log_study1_q7_lock <- function(log_path) {
  log_msg(log_path, "Q7 locked path: H1=", require_param("study1_h1_test"),
          " H2=", require_param("study1_h2_test"),
          " H3=", require_param("study1_h3_test"),
          " RT=", require_param("study1_rt_test"),
          " AE=", require_param("study1_ae_test"))
}

# Q10: drop exact-zero paired diffs before ranking; same vector for the ES.
nonzero_paired_diffs <- function(x, y = NULL, mu = 0) {
  x <- as.numeric(x)
  if (is.null(y)) {
    d <- x - as.numeric(mu)
  } else {
    y <- as.numeric(y)
    if (length(x) != length(y)) {
      stop("nonzero_paired_diffs: lengths differ.", call. = FALSE)
    }
    d <- x - y
  }
  ok <- !is.na(d)
  list(
    n_pairs = as.integer(sum(ok)),
    n_zero = as.integer(sum(ok & d == 0)),
    n_nonzero = as.integer(sum(ok & d != 0)),
    d_nonzero = d[ok & d != 0]
  )
}

extract_rank_biserial <- function(rb) {
  rb <- as.data.frame(rb)
  col <- intersect(names(rb), "r_rank_biserial")
  if (length(col) < 1L) {
    stop("rank_biserial() table missing r_rank_biserial. Names: ",
         paste(names(rb), collapse = ", "), call. = FALSE)
  }
  list(
    r_rb = as.numeric(rb[[col[1]]])[1],
    r_ci_low = as.numeric(rb$CI_low)[1],
    r_ci_high = as.numeric(rb$CI_high)[1]
  )
}

# SAP §3.1 H1 / §3.2 H3 / Q10. Two-sided Wilcoxon on non-zero diffs.
paired_wilcoxon_opt_minus_orig <- function(opt, orig) {
  z <- nonzero_paired_diffs(opt, orig)
  if (z$n_nonzero < 1L) {
    stop("Paired Wilcoxon: no non-zero differences after Q10 omit-zeros.", call. = FALSE)
  }
  wt <- stats::wilcox.test(
    z$d_nonzero,
    mu = 0,
    alternative = "two.sided",
    exact = FALSE,
    correct = TRUE
  )
  rb <- extract_rank_biserial(effectsize::rank_biserial(
    z$d_nonzero,
    mu = 0,
    ci = as.numeric(SAP$ci_level),
    alternative = "two.sided",
    verbose = FALSE
  ))
  list(
    n_pairs = z$n_pairs,
    n_zero = z$n_zero,
    n_nonzero = z$n_nonzero,
    V = unname(wt$statistic),
    p = unname(wt$p.value),
    r_rb = rb$r_rb,
    r_ci_low = rb$r_ci_low,
    r_ci_high = rb$r_ci_high
  )
}

onesample_wilcoxon_vs <- function(x, mu) {
  x <- as.numeric(x)
  x <- x[!is.na(x)]
  desc <- mean_sd_ci(x)
  z <- nonzero_paired_diffs(x, mu = mu)
  if (z$n_nonzero < 1L) {
    stop("One-sample Wilcoxon: no non-zero (x - mu) after Q10 omit-zeros.", call. = FALSE)
  }
  wt <- stats::wilcox.test(
    z$d_nonzero,
    mu = 0,
    alternative = require_param("h3_alternative"),
    exact = FALSE,
    correct = TRUE
  )
  rb <- extract_rank_biserial(effectsize::rank_biserial(
    z$d_nonzero,
    mu = 0,
    ci = as.numeric(SAP$ci_level),
    alternative = "two.sided",
    verbose = FALSE
  ))
  list(
    n = desc$n,
    mean = desc$mean,
    sd = desc$sd,
    ci_low = desc$ci_low,
    ci_high = desc$ci_high,
    n_zero = z$n_zero,
    n_nonzero = z$n_nonzero,
    V = unname(wt$statistic),
    p = unname(wt$p.value),
    r_rb = rb$r_rb,
    r_ci_low = rb$r_ci_low,
    r_ci_high = rb$r_ci_high,
    mu = mu
  )
}

k_diff_matrix <- function(summary_df) {
  k_order <- as.integer(SAP$k_levels_study1)
  cols <- lapply(k_order, function(k) {
    summary_df[[paste0("acc_Optimized_K", k)]] - summary_df[[paste0("acc_Original_K", k)]]
  })
  mat <- do.call(cbind, cols)
  colnames(mat) <- paste0("K", k_order)
  if (any(is.na(mat))) {
    stop("H2 Friedman: NA in Optimized-Original K differences. Q4 should have stopped.", call. = FALSE)
  }
  mat
}

# SAP §3.1 H2 fallback: Friedman on Opt-Orig diffs across K. Q9 Kendall's W.
friedman_h2_on_k_diffs <- function(summary_df) {
  mat <- k_diff_matrix(summary_df)
  ft <- stats::friedman.test(mat)
  w <- as.data.frame(effectsize::kendalls_w(
    mat,
    ci = as.numeric(SAP$ci_level),
    alternative = "two.sided",
    verbose = FALSE
  ))
  wcol <- intersect(names(w), c("Kendalls_W", "Kendall_W", "W"))
  if (length(wcol) < 1L) {
    stop("kendalls_w() table missing W column. Names: ",
         paste(names(w), collapse = ", "), call. = FALSE)
  }
  list(
    n = nrow(mat),
    n_k = ncol(mat),
    statistic = unname(ft$statistic),
    df = unname(ft$parameter),
    p = unname(ft$p.value),
    kendalls_w = as.numeric(w[[wcol[1]]])[1],
    w_ci_low = as.numeric(w$CI_low)[1],
    w_ci_high = as.numeric(w$CI_high)[1]
  )
}

# SAP §3.1: if Friedman sig, pairwise Wilcoxon on the K-difference scores, Holm x 6.
h2_friedman_followups <- function(summary_df, friedman_p) {
  k_order <- as.integer(SAP$k_levels_study1)
  alpha <- as.numeric(SAP$alpha)
  if (is.na(friedman_p) || friedman_p >= alpha) {
    return(list(
      ran = FALSE,
      reason = "friedman_not_significant",
      rows = data.frame()
    ))
  }
  mat <- k_diff_matrix(summary_df)
  pairs <- utils::combn(k_order, 2)
  rows <- list()
  for (j in seq_len(ncol(pairs))) {
    ka <- pairs[1, j]
    kb <- pairs[2, j]
    da <- mat[, paste0("K", ka)]
    db <- mat[, paste0("K", kb)]
    z <- nonzero_paired_diffs(da, db)
    if (z$n_nonzero < 1L) {
      rows[[length(rows) + 1L]] <- data.frame(
        K_a = ka,
        K_b = kb,
        estimable = FALSE,
        n_pairs = z$n_pairs,
        n_zero = z$n_zero,
        n_nonzero = z$n_nonzero,
        V = NA_real_,
        p_raw = NA_real_,
        p_holm = NA_real_,
        r_rb = NA_real_,
        r_ci_low = NA_real_,
        r_ci_high = NA_real_,
        note = "all_zero_diffs_descriptive_only",
        stringsAsFactors = FALSE
      )
    } else {
      ww <- paired_wilcoxon_opt_minus_orig(da, db)
      rows[[length(rows) + 1L]] <- data.frame(
        K_a = ka,
        K_b = kb,
        estimable = TRUE,
        n_pairs = ww$n_pairs,
        n_zero = ww$n_zero,
        n_nonzero = ww$n_nonzero,
        V = ww$V,
        p_raw = ww$p,
        p_holm = NA_real_,
        r_rb = ww$r_rb,
        r_ci_low = ww$r_ci_low,
        r_ci_high = ww$r_ci_high,
        note = "",
        stringsAsFactors = FALSE
      )
    }
  }
  out <- do.call(rbind, rows)
  estim <- which(out$estimable)
  if (length(estim) > 0L) {
    out$p_holm[estim] <- holm_adjust(out$p_raw[estim])
  }
  list(ran = TRUE, reason = "friedman_significant", rows = out)
}
