# scripts/00_setup.R
# Install only packages that are missing. Base R + listed CRAN packages.
# Source config/config.R first so OUTPUT_LOGS exists.
# renv is NOT the restore mechanism. A lockfile, if written, is a version record
# only (scripts/write_renv_lock.R). Do not run renv::restore() or renv::init().

# Package names only. Reasons in comments. Only packages we are sure exist on CRAN.
required_packages <- c(
  "testthat"  # hand-checkable unit tests for helpers (Phase 2A Chunk C)
)
# Data reading uses utils::read.csv (base). No readr.

install_missing_packages <- function(pkgs) {
  if (length(pkgs) == 0L) {
    message("No extra packages required.")
    return(invisible(character(0)))
  }
  installed <- rownames(utils::installed.packages())
  missing <- setdiff(pkgs, installed)
  if (length(missing) == 0L) {
    message("All required packages already installed; nothing reinstalled.")
    return(invisible(character(0)))
  }
  message("Installing missing packages: ", paste(missing, collapse = ", "))
  repos <- "https://cloud.r-project.org"
  inst_formals <- names(formals(utils::install.packages))
  if ("Ncpus" %in% inst_formals) {
    utils::install.packages(missing, repos = repos, Ncpus = 2)
  } else {
    utils::install.packages(missing, repos = repos)
  }
  still <- setdiff(missing, rownames(utils::installed.packages()))
  if (length(still) > 0L) {
    stop(
      "Package install failed for: ", paste(still, collapse = ", "),
      ". On Kaggle, turn Internet on (may require phone verification) and retry.",
      call. = FALSE
    )
  }
  invisible(missing)
}

load_required_packages <- function(pkgs) {
  for (pkg in pkgs) {
    ok <- require(pkg, character.only = TRUE, quietly = TRUE)
    if (!isTRUE(ok)) {
      stop("Failed to load package: ", pkg, call. = FALSE)
    }
  }
  invisible(NULL)
}

package_version_lines <- function(pkgs) {
  vapply(pkgs, function(pkg) {
    if (pkg %in% rownames(utils::installed.packages())) {
      paste0(pkg, " ", as.character(utils::packageVersion(pkg)))
    } else {
      paste0(pkg, " NOT INSTALLED")
    }
  }, character(1))
}

write_session_info <- function(log_dir = OUTPUT_LOGS) {
  if (!exists("OUTPUT_LOGS")) {
    stop("OUTPUT_LOGS is missing. Source config/config.R first.", call. = FALSE)
  }
  if (!dir.exists(log_dir)) {
    dir.create(log_dir, recursive = TRUE, showWarnings = FALSE)
  }
  out_file <- file.path(log_dir, "session_info.txt")
  lines <- c(
    paste("R.version.string:", R.version.string),
    paste("ENV_NAME:", if (exists("ENV_NAME")) ENV_NAME else NA),
    paste("IS_KAGGLE:", if (exists("IS_KAGGLE")) IS_KAGGLE else NA),
    paste("DATA_SOURCE:", if (exists("DATA_SOURCE")) DATA_SOURCE else NA),
    paste("SEED:", if (exists("SEED")) SEED else NA),
    paste("PROJECT_ROOT_resolved:", exists("PROJECT_ROOT") && dir.exists(PROJECT_ROOT)),
    "required_package_versions:",
    package_version_lines(required_packages),
    "",
    "sessionInfo():",
    utils::capture.output(print(utils::sessionInfo()))
  )
  writeLines(lines, out_file)
  message("Wrote ", "output/logs/session_info.txt")
  invisible(out_file)
}

install_missing_packages(required_packages)
load_required_packages(required_packages)
message("R version: ", R.version.string)
message(paste(package_version_lines(required_packages), collapse = " | "))
