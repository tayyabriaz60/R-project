# Study 2 entry. This chunk: load + QC only. No prepare, no H1–H3, no Q7 path.
# Do not source this from run_all.R (Study 1 real runs must keep working).

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

message("run_study2.R finished load + QC only. Prepare / H1-H3 not run.")
