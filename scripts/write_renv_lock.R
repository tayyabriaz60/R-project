# Write renv.lock as a VERSION RECORD only.
# This is NOT the install/restore mechanism. Use scripts/00_setup.R to install.
# Do not call renv::init() here: that writes .Rprofile / renv/activate.R and
# would hijack later sessions. See README.

if (!exists("PROJECT_ROOT") || !exists("required_packages")) {
  stop("Source config/config.R and scripts/00_setup.R before this script.", call. = FALSE)
}

if (!"renv" %in% rownames(utils::installed.packages())) {
  message("Installing renv only to write the version-record lockfile.")
  repos <- "https://cloud.r-project.org"
  utils::install.packages("renv", repos = repos)
}

if (!requireNamespace("renv", quietly = TRUE)) {
  stop("renv could not be loaded. Cannot write the version-record lockfile.", call. = FALSE)
}

lock_path <- file.path(PROJECT_ROOT, "renv.lock")
pkgs <- required_packages
message(
  "Writing version-record renv.lock for packages: ",
  paste(pkgs, collapse = ", "),
  ". renv will not be used to restore this project."
)

wrote <- FALSE
snap_formals <- names(formals(renv::snapshot))
if ("packages" %in% snap_formals) {
  renv::snapshot(
    project = PROJECT_ROOT,
    lockfile = lock_path,
    packages = pkgs,
    prompt = FALSE,
    force = TRUE
  )
  wrote <- file.exists(lock_path)
}

if (!wrote && exists("plan", where = asNamespace("renv"), inherits = FALSE)) {
  renv::plan(packages = pkgs, lockfile = lock_path, project = PROJECT_ROOT)
  wrote <- file.exists(lock_path)
}

if (!wrote) {
  stop(
    "Could not write renv.lock with this renv version without renv::init(). ",
    "Do not run init() in the project root. Paste this error.",
    call. = FALSE
  )
}

# Refuse an accidental activator if some renv helper created one.
act <- file.path(PROJECT_ROOT, "renv", "activate.R")
if (file.exists(act)) {
  unlink(act)
  message("Removed renv/activate.R so renv cannot take over the session.")
}

message("Wrote version-record lockfile: renv.lock")
message("Restore mechanism remains scripts/00_setup.R. Do not run renv::restore().")
