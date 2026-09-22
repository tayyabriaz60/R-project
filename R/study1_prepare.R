# Study 1: population, Q31 audit, Q3/Q4 gates, summaries, Q8 diagnostics.
# Does not run H1-H3, effect sizes, or Q13 report figures.

source(file.path(PROJECT_ROOT, "R", "study1_clean.R"))
source(file.path(PROJECT_ROOT, "R", "study1_gates.R"))
source(file.path(PROJECT_ROOT, "R", "study1_summarise.R"))
source(file.path(PROJECT_ROOT, "R", "study1_diagnostics.R"))

run_study1_prepare <- function(study1) {
  ensure_output_dirs()
  log_path <- output_log_path("study1_log_prepare")
  start_log(log_path, "STUDY 1 PREPARE (aggregates only; SYNTHETIC DATA: pipeline test only)")
  log_msg(log_path, "H1-H3 not run. Effect sizes not computed. Q13 figures not drawn.")

  study1 <- apply_study1_primary_population(study1, log_path)
  disc <- study1$discrimination
  pw <- study1$pairwise
  vis <- study1$vision

  aud <- log_duplicate_audit(disc, log_path)
  gate_pairwise_mapping_q3(pw, log_path)
  gate_incomplete_cells_q4(disc, pw, log_path)

  summaries <- summarise_study1_participants(disc, pw, log_path)
  sum_path <- write_study1_summaries(summaries)
  log_msg(log_path, "wrote ", basename(sum_path))

  diag_paths <- save_study1_q8_histograms(summaries, log_path)

  list(
    study1 = study1,
    duplicate_audit = aud,
    summaries = summaries,
    diagnostic_files = diag_paths,
    log_path = log_path
  )
}
