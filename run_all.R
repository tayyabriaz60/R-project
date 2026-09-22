# Master script. Study 1 load + QC (v3 synthetic; Object Name filter + Q6 IDs).
# Helper tests: source tests/run_tests.R. Version-record lockfile: scripts/write_renv_lock.R.
# Requires PROJECT_ROOT (or resolvable by config).
# Does not run exclusions, summaries, or hypothesis tests.

if (!exists("PROJECT_ROOT")) {
  env <- Sys.getenv("PROJECT_ROOT", unset = "")
  if (nzchar(env)) {
    PROJECT_ROOT <- env
  }
}

source(file.path(if (exists("PROJECT_ROOT")) PROJECT_ROOT else ".", "config", "config.R"))
source(file.path(PROJECT_ROOT, "scripts", "00_setup.R"))
write_session_info()

source(file.path(PROJECT_ROOT, "R", "study1_load.R"))
study1 <- run_study1_load()

# PENDING (client questions / Phase 2B) — do not uncomment until Q1–Q14 are answered:
#   exclusions / participant_id (Q2, Q6)
#   Object Name filter (Q5)
#   pairwise failed-row disposition (Q3)
#   participant-level summaries
#   assumption checks / fallbacks (Q7, Q8, Q12)
#   H1–H3 tests, Holm follow-ups, effect sizes (Q9–Q11)
#   RT / AE / signed error
#   vision-screen sensitivity (Q1)
#   tables / figures / exports (Q13, Q14)

message("run_all.R load/QC finished (v3 synthetic). No statistical tests were run.")
