# Master script. Study 1 load/QC + prepare + H1-H3 / RT / AE / tables / figures.
# Q7: writes a fallback-review report and does NOT apply Wilcoxon/Friedman.

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

source(file.path(PROJECT_ROOT, "R", "study1_analyse.R"))
study1_ana <- run_study1_analyse(study1, study1_prep)

message("run_all.R finished load + prepare + analysis. Q7 fallback was not applied.")
