# Safe CSV I/O. Base utils::read.csv only.

read_gorilla_csv <- function(path) {
  if (!file.exists(path)) {
    stop("CSV not found: ", basename(path), " (directory not printed).", call. = FALSE)
  }
  # UTF-8; stringsAsFactors=FALSE for R < 4.0; check.names=FALSE keeps
  # "Spreadsheet: condition" exactly (Dictionary raw names).
  df <- utils::read.csv(
    file = path,
    header = TRUE,
    stringsAsFactors = FALSE,
    check.names = FALSE,
    na.strings = c("", "NA"),
    comment.char = "",
    fileEncoding = "UTF-8"
  )
  # Strip UTF-8 BOM from the first header if present.
  if (ncol(df) > 0L) {
    names(df)[1] <- sub("^\ufeff", "", names(df)[1])
  }
  df
}

drop_blank_rows <- function(df) {
  if (ncol(df) == 0L || nrow(df) == 0L) {
    return(df)
  }
  keep <- rowSums(!is.na(df)) > 0L
  df[keep, , drop = FALSE]
}

write_qc_csv <- function(df, path) {
  utils::write.csv(df, file = path, row.names = FALSE, fileEncoding = "UTF-8")
  invisible(path)
}
