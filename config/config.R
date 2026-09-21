# config/config.R
# Single control file: paths, environment, data source, seed, SAP parameters.
# Base R only. Print R version at the start of every run.

message("R version: ", R.version.string)

# -----------------------------------------------------------------------------
# PROJECT_ROOT
# How to set it (first match wins):
#   1. Environment variable PROJECT_ROOT
#   2. An existing object named PROJECT_ROOT in the session (Kaggle cell)
#   3. On Kaggle: the unique /kaggle/input folder that contains config/config.R
#   4. getwd() if that folder contains config/config.R
# -----------------------------------------------------------------------------
.looks_like_project <- function(path) {
  is.character(path) && length(path) == 1L && nzchar(path) &&
    dir.exists(path) && file.exists(file.path(path, "config", "config.R"))
}

.resolve_project_root <- function() {
  env <- Sys.getenv("PROJECT_ROOT", unset = "")
  if (.looks_like_project(env)) {
    return(env)
  }
  if (exists("PROJECT_ROOT", inherits = TRUE, mode = "character")) {
    pr <- get("PROJECT_ROOT", inherits = TRUE)
    if (.looks_like_project(pr)) {
      return(pr)
    }
  }
  if (dir.exists("/kaggle")) {
    found <- list.files(
      "/kaggle/input",
      pattern = "^config\\.R$",
      recursive = TRUE,
      full.names = TRUE
    )
    roots <- unique(dirname(dirname(found)))
    roots <- roots[vapply(roots, .looks_like_project, logical(1))]
    if (length(roots) == 1L) {
      return(roots[[1]])
    }
    if (length(roots) > 1L) {
      stop(
        "Several folders under /kaggle/input look like the project. ",
        "Set PROJECT_ROOT to the one that directly contains config/ and data/.",
        call. = FALSE
      )
    }
  }
  wd <- getwd()
  if (.looks_like_project(wd)) {
    return(wd)
  }
  stop(
    "Could not resolve PROJECT_ROOT. Set it before sourcing config, e.g. ",
    "PROJECT_ROOT <- \"/kaggle/input/your-dataset-folder\" ",
    "or Sys.setenv(PROJECT_ROOT = \"...\"). The folder must contain config/config.R.",
    call. = FALSE
  )
}

PROJECT_ROOT <- .resolve_project_root()

# One allowed setwd (rules / environment constraint).
setwd(PROJECT_ROOT)

# -----------------------------------------------------------------------------
# Environment and output directory
# -----------------------------------------------------------------------------
IS_KAGGLE <- dir.exists("/kaggle")
ENV_NAME <- if (IS_KAGGLE) "kaggle" else "local"

if (IS_KAGGLE) {
  OUTPUT_DIR <- "/kaggle/working/output"
} else {
  OUTPUT_DIR <- file.path(PROJECT_ROOT, "output")
}

OUTPUT_TABLES <- file.path(OUTPUT_DIR, "tables")
OUTPUT_FIGURES <- file.path(OUTPUT_DIR, "figures")
OUTPUT_MODELS <- file.path(OUTPUT_DIR, "models")
OUTPUT_LOGS <- file.path(OUTPUT_DIR, "logs")

for (d in c(OUTPUT_DIR, OUTPUT_TABLES, OUTPUT_FIGURES, OUTPUT_MODELS, OUTPUT_LOGS)) {
  if (!dir.exists(d)) {
    dir.create(d, recursive = TRUE, showWarnings = FALSE)
  }
}

# -----------------------------------------------------------------------------
# Data source: change ONLY DATA_SOURCE to switch synthetic vs real
# -----------------------------------------------------------------------------
DATA_SOURCE <- "synthetic"  # "synthetic" or "real"

if (!DATA_SOURCE %in% c("synthetic", "real")) {
  stop("DATA_SOURCE must be \"synthetic\" or \"real\".", call. = FALSE)
}

DATA_DIR <- if (identical(DATA_SOURCE, "synthetic")) {
  file.path(PROJECT_ROOT, "data", "synthetic")
} else {
  file.path(PROJECT_ROOT, "data", "real")
}

OUTPUT_SUFFIX <- if (identical(DATA_SOURCE, "synthetic")) "_SYNTHETIC" else ""

# Synthetic file names from SYNTHETIC_MANIFEST.csv (Study 1). Real names NOT SPECIFIED.
SYNTHETIC_FILES <- list(
  study1_disc_g1 = file.path(DATA_DIR, "Study1", "study1_discrimination_G1_SYNTHETIC.csv"),
  study1_disc_g2 = file.path(DATA_DIR, "Study1", "study1_discrimination_G2_SYNTHETIC.csv"),
  study1_pairwise = file.path(DATA_DIR, "Study1", "study1_pairwise_SYNTHETIC.csv"),
  study1_vision = file.path(DATA_DIR, "Study1", "study1_vision_SYNTHETIC.csv"),
  study2_tasks = file.path(DATA_DIR, "Study2", "study2_tasks_SYNTHETIC.csv"),
  study3_tasks = file.path(DATA_DIR, "Study3", "study3_tasks_SYNTHETIC.csv")
)

# -----------------------------------------------------------------------------
# Seed (technical only; SAP does not specify a seed)
# Logged in docs/DECISIONS_LOG.md as non-methodological.
# -----------------------------------------------------------------------------
SEED <- 20260921L
set.seed(SEED)

# -----------------------------------------------------------------------------
# SAP / Brief / Dictionary parameters
# Filled only when the document states the value. Pending Q1-Q14 stay NA.
# -----------------------------------------------------------------------------
SAP <- list(
  # --- specified -------------------------------------------------------------
  alpha = 0.05,                          # SAP §1
  ci_level = 0.95,                       # SAP §1
  holm_method = "holm",                  # SAP §1
  across_hypothesis_correction = FALSE,  # SAP §1; Brief §1
  h3_null = 0.50,                        # SAP §3.2
  h3_alternative = "two.sided",          # SAP §3.2
  rt_include_incorrect_trials = TRUE,    # SAP §3.3.1
  rt_no_extra_trimming = TRUE,           # SAP §3.3.1
  rt_skew_log_threshold = 1,             # SAP §3.3.1 (trial-level RT)
  primary_n_study1 = 50L,                # SAP §3.4
  vision_subset_n_study1 = 48L,          # SAP §3.4 (size only; rule is Q1)
  k_levels_study1 = c(5, 10, 20, 30),    # SAP §3.1
  n_configuration_instances = 3L,        # SAP §3.1
  disc_trials_per_participant = 24L,     # Dictionary §9
  pairwise_trials_per_participant = 12L, # SAP §3.2; Dictionary §9
  vision_n_items = 4L,                   # Dictionary §7
  vision_correct_keys = c(12, 16, 29, 26), # Dictionary §7
  sphericity_correction = "greenhouse_geisser", # SAP §3.1 if Mauchly violated
  keep_k30 = TRUE,                       # SAP §3.4
  mixed_effects_as_primary = FALSE,      # Brief §1 / §15
  # --- PENDING client answer Q1-Q14 (must stay NA; do not guess) ------------
  vision_subset_rule = NA,               # PENDING client answer Q1
  study1_exclusion_order = NA,           # PENDING client answer Q2
  pairwise_failed_row_rule = NA,         # PENDING client answer Q3
  incomplete_cell_rule = NA,             # PENDING client answer Q4
  object_name_filter_when_blank = NA,    # PENDING client answer Q5
  study1_id_column = NA,                 # PENDING client answer Q6
  fallback_normality_cutoff = NA,        # PENDING client answer Q7
  accuracy_histogram_which = NA,         # PENDING client answer Q8
  paired_d_convention = NA,              # PENDING client answer Q9
  onesample_d_convention = NA,           # PENDING client answer Q9
  partial_eta_squared_ci_method = NA,    # PENDING client answer Q9
  rank_biserial_convention = NA,         # PENDING client answer Q9
  wilcox_zero_convention = NA,           # PENDING client answer Q10
  anova_ss_type = NA,                    # PENDING client answer Q11
  anova_contrasts = NA,                  # PENDING client answer Q11
  condition_reference_level = NA,        # PENDING client answer Q11
  skewness_function = NA,                # PENDING client answer Q12
  figure_list = NA,                      # PENDING client answer Q13
  figure_colours = NA,                   # PENDING client answer Q13
  export_table_formats = NA,             # PENDING client answer Q14
  ae_by_k_include_ci = NA                # PENDING client answer Q14
)

# Stops if a pending (NA) parameter is requested.
require_param <- function(name) {
  if (!is.character(name) || length(name) != 1L || !nzchar(name)) {
    stop("require_param() needs a single parameter name.", call. = FALSE)
  }
  if (!name %in% names(SAP)) {
    stop("Unknown SAP parameter: ", name, call. = FALSE)
  }
  val <- SAP[[name]]
  if (length(val) == 1L && is.na(val)) {
    stop(
      "SAP parameter '", name, "' is NA (PENDING a client answer). ",
      "See docs/QUESTIONS_FOR_CLIENT.md. Do not guess this value.",
      call. = FALSE
    )
  }
  val
}

message(
  "PROJECT_ROOT resolved; ENV_NAME=", ENV_NAME,
  "; DATA_SOURCE=", DATA_SOURCE,
  "; SEED=", SEED
)
message("OUTPUT_DIR set for ", ENV_NAME, " mode")
