# Study 2 master. Load + prepare + SAP recommended ANOVA/t.
# Do not source this from run_all.R (Study 1 real runs must keep working).
# Q32: Study 1 npar lock is not inherited.

if (!exists("PROJECT_ROOT")) {
  env <- Sys.getenv("PROJECT_ROOT", unset = "")
  if (nzchar(env)) {
    PROJECT_ROOT <- env
  }
}

source(file.path(if (exists("PROJECT_ROOT")) PROJECT_ROOT else ".", "config", "config.R"))
source(file.path(PROJECT_ROOT, "scripts", "00_setup.R"))
write_session_info()

source(file.path(PROJECT_ROOT, "R", "study2_load.R"))
study2 <- run_study2_load()

source(file.path(PROJECT_ROOT, "R", "study2_prepare.R"))
study2_prep <- run_study2_prepare(study2)

source(file.path(PROJECT_ROOT, "R", "study2_analyse.R"))
study2_ana <- run_study2_analyse(study2, study2_prep)

message("run_study2.R finished load + prepare + analysis. Q32 npar not applied.")
