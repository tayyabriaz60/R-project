# Chunk C: helper unit tests on toy data. No hypothesis tests. No synthetic load.
# Requires PROJECT_ROOT (or resolvable by config).

if (!exists("PROJECT_ROOT")) {
  env <- Sys.getenv("PROJECT_ROOT", unset = "")
  if (nzchar(env)) {
    PROJECT_ROOT <- env
  }
}

source(file.path(if (exists("PROJECT_ROOT")) PROJECT_ROOT else ".", "config", "config.R"))
source(file.path(PROJECT_ROOT, "scripts", "00_setup.R"))
source(file.path(PROJECT_ROOT, "R", "study1_load.R"))
source(file.path(PROJECT_ROOT, "R", "study2_load.R"))
source(file.path(PROJECT_ROOT, "R", "study2_prepare.R"))
source(file.path(PROJECT_ROOT, "R", "utils_format.R"))
source(file.path(PROJECT_ROOT, "R", "study1_clean.R"))
source(file.path(PROJECT_ROOT, "R", "study1_gates.R"))
source(file.path(PROJECT_ROOT, "R", "summarise_participants.R"))
source(file.path(PROJECT_ROOT, "R", "study1_models.R"))

test_dir_path <- file.path(PROJECT_ROOT, "tests", "testthat")
if (!dir.exists(test_dir_path)) {
  stop("tests/testthat/ is missing.", call. = FALSE)
}

results <- testthat::test_dir(test_dir_path, reporter = "summary", stop_on_failure = FALSE)

count_exp <- function(results, class_name) {
  n <- 0L
  if (!is.list(results)) {
    return(n)
  }
  for (item in results) {
    exps <- item$results
    if (is.null(exps)) {
      next
    }
    for (exp in exps) {
      if (inherits(exp, class_name)) {
        n <- n + 1L
      }
    }
  }
  n
}

n_failed <- count_exp(results, "expectation_failure")
n_error <- count_exp(results, "expectation_error")
n_ok <- count_exp(results, "expectation_success")

ensure_output_dirs()
log_path <- output_log_path("study1_log_chunk_c_tests")
start_log(log_path, "CHUNK C HELPER TESTS (toy data only; SYNTHETIC DATA: pipeline test only)")
log_msg(log_path, "n_passed=", n_ok, " n_failed=", n_failed, " n_error=", n_error)
log_msg(log_path, "No statistical tests were run. No synthetic data were loaded.")

if (n_ok < 1L) {
  stop(
    "Chunk C: no passing expectations were recorded. ",
    "The testthat result structure may have changed. See console.",
    call. = FALSE
  )
}

if (n_failed > 0L || n_error > 0L) {
  stop(
    "Chunk C helper tests failed: failed=", n_failed, " error=", n_error,
    ". See console. No statistical tests were run.",
    call. = FALSE
  )
}

message("Chunk C helper tests finished. All passed. No statistical tests were run.")
