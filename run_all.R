# Master script. Study 1 load/QC + prepare (population, gates, summaries, Q8 diagnostics).
# Does not run H1-H3, effect sizes, or Q13 report figures.

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

source(file.path(PROJECT_ROOT, "R", "study1_prepare.R"))
study1_prep <- run_study1_prepare(study1)

# PENDING next chunk:
#   H1-H3 tests, Holm follow-ups, effect sizes (Q9-Q11)
#   RT / AE inferential tests
#   vision-screen sensitivity
#   Q13 tables / figures / exports

message("run_all.R finished load + prepare. No hypothesis tests were run.")
