# Study 3 master. Load + prepare + analysis.

if (!exists("PROJECT_ROOT")) {
  env <- Sys.getenv("PROJECT_ROOT", unset = "")
  if (nzchar(env)) {
    PROJECT_ROOT <- env
  }
}

source(file.path(if (exists("PROJECT_ROOT")) PROJECT_ROOT else ".", "config", "config.R"))
source(file.path(PROJECT_ROOT, "scripts", "00_setup.R"))
write_session_info()

source(file.path(PROJECT_ROOT, "R", "study3_load.R"))
study3 <- run_study3_load()

source(file.path(PROJECT_ROOT, "R", "study3_prepare.R"))
study3_prep <- run_study3_prepare(study3)

source(file.path(PROJECT_ROOT, "R", "study3_analyse.R"))
study3_ana <- run_study3_analyse(study3_prep$study3, study3_prep)

message("run_study3.R finished load + prepare + analysis.")
