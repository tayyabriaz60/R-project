# Tiny formatters for later tables. Not used for results in Chunk B.

fmt_p <- function(p) {
  p <- as.numeric(p)
  out <- ifelse(is.na(p), NA_character_, sprintf("%.3f", p))
  out[!is.na(p) & p < 0.001] <- "< .001"
  out
}

fmt_num <- function(x, digits = 3L) {
  ifelse(is.na(x), NA_character_, sprintf(paste0("%.", as.integer(digits), "f"), as.numeric(x)))
}

fmt_ci <- function(low, high, digits = 3L) {
  paste0("[", fmt_num(low, digits), ", ", fmt_num(high, digits), "]")
}

fmt_df <- function(num, den, digits = 2L) {
  paste0(fmt_num(num, digits), ", ", fmt_num(den, digits))
}
