# Shared participant-level summaries. SAP §1: inference uses these measures.

accuracy_cells_long <- function(disc) {
  stats::aggregate(
    accuracy ~ participant_anon_id + participant_id + condition + K,
    data = disc,
    FUN = function(x) mean(as.numeric(x), na.rm = TRUE)
  )
}

mean_by_id_condition <- function(disc, value_col, out_name) {
  form <- stats::as.formula(paste(value_col, "~ participant_anon_id + participant_id + condition"))
  out <- stats::aggregate(form, data = disc, FUN = function(x) mean(as.numeric(x), na.rm = TRUE))
  names(out)[names(out) == value_col] <- out_name
  out
}

pairwise_proportion <- function(pw) {
  if (any(is.na(pw$chose_optimized))) {
    stop(
      "chose_optimized has NA after the Q3 gate. Do not compute a pairwise proportion.",
      call. = FALSE
    )
  }
  stats::aggregate(
    chose_optimized ~ participant_anon_id + participant_id,
    data = pw,
    FUN = function(x) mean(as.numeric(x), na.rm = TRUE)
  )
}
