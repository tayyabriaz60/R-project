# Input validation. Fail with specific messages. No silent fixes.

require_columns <- function(df, columns, file_label) {
  missing <- setdiff(columns, names(df))
  if (length(missing) > 0L) {
    stop("Missing required columns in ", file_label, ": ",
         paste(missing, collapse = ", "), call. = FALSE)
  }
  invisible(TRUE)
}

n_unique_nonempty <- function(x) {
  x <- x[!is.na(x)]
  if (is.character(x)) {
    x <- x[nzchar(trimws(as.character(x)))]
  }
  length(unique(x))
}

n_missing <- function(x) {
  sum(is.na(x))
}

assert_allowed_values <- function(x, allowed, col_label, file_label) {
  obs <- unique(x[!is.na(x)])
  bad <- setdiff(as.character(obs), as.character(allowed))
  if (length(bad) > 0L) {
    stop(
      "Unexpected values in ", file_label, " / ", col_label, ": ",
      paste(bad, collapse = ", "),
      ". Allowed: ", paste(allowed, collapse = ", "),
      call. = FALSE
    )
  }
  invisible(TRUE)
}

assert_numeric_range <- function(x, min_ok, max_ok, col_label, file_label, allow_na = TRUE) {
  num <- suppressWarnings(as.numeric(x))
  failed_parse <- sum(!is.na(x) & is.na(num))
  if (failed_parse > 0L) {
    stop(file_label, " / ", col_label, ": ", failed_parse,
         " values could not be parsed as numeric.", call. = FALSE)
  }
  if (!allow_na && any(is.na(num))) {
    stop(file_label, " / ", col_label, ": missing values are not allowed.", call. = FALSE)
  }
  ok <- num[!is.na(num)]
  n_low <- sum(ok < min_ok)
  n_high <- sum(ok > max_ok)
  if (n_low > 0L || n_high > 0L) {
    stop(
      file_label, " / ", col_label, ": ", n_low, " values < ", min_ok,
      " and ", n_high, " values > ", max_ok, ".",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

count_duplicate_rows <- function(df) {
  if (nrow(df) < 2L) {
    return(0L)
  }
  sum(duplicated(df))
}

assert_expected_n <- function(observed, expected, label, data_source) {
  if (!identical(data_source, "synthetic")) {
    return(invisible(FALSE))
  }
  if (!identical(as.integer(observed), as.integer(expected))) {
    stop(
      "Synthetic structure mismatch for ", label,
      ": expected ", expected, ", observed ", observed, ".",
      call. = FALSE
    )
  }
  invisible(TRUE)
}
