# Shared thesis table formatters (Study 1 / Study 2).

source(file.path(PROJECT_ROOT, "R", "utils_format.R"))

cond_mean_table <- function(n, mean_a, sd_a, lo_a, hi_a, mean_b, sd_b, lo_b, hi_b) {
  data.frame(
    Condition = c("Original", "Optimized"),
    N = n,
    Mean = c(fmt_num(mean_a, 3), fmt_num(mean_b, 3)),
    SD = c(fmt_num(sd_a, 3), fmt_num(sd_b, 3)),
    `95% CI` = c(fmt_ci(lo_a, hi_a, 3), fmt_ci(lo_b, hi_b, 3)),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
}

paired_test_table <- function(diff, lo, hi, t, df, p, d, d_lo, d_hi) {
  data.frame(
    Comparison = "Optimized - Original",
    `Mean difference` = fmt_num(diff, 3),
    `95% CI` = fmt_ci(lo, hi, 3),
    t = fmt_num(t, 3),
    df = fmt_num(df, 2),
    p = fmt_p(p),
    `Cohen's dz` = fmt_num(d, 3),
    `dz 95% CI` = fmt_ci(d_lo, d_hi, 3),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
}
