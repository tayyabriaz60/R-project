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

# Synthetic file names from SYNTHETIC_MANIFEST.csv (Study 1).
SYNTHETIC_FILES <- list(
  study1_disc_g1 = file.path(PROJECT_ROOT, "data", "synthetic", "Study1", "study1_discrimination_G1_SYNTHETIC.csv"),
  study1_disc_g2 = file.path(PROJECT_ROOT, "data", "synthetic", "Study1", "study1_discrimination_G2_SYNTHETIC.csv"),
  study1_pairwise = file.path(PROJECT_ROOT, "data", "synthetic", "Study1", "study1_pairwise_SYNTHETIC.csv"),
  study1_vision = file.path(PROJECT_ROOT, "data", "synthetic", "Study1", "study1_vision_SYNTHETIC.csv"),
  study2_tasks = file.path(PROJECT_ROOT, "data", "synthetic", "Study2", "study2_tasks_SYNTHETIC.csv"),
  study3_tasks = file.path(PROJECT_ROOT, "data", "synthetic", "Study3", "study3_tasks_SYNTHETIC.csv")
)

# Real Study 1 Gorilla task IDs (22 Sep 2026). Files stay unedited under data/real/.
# The loader finds a CSV whose filename contains the task id (e.g. task-y3n9.csv
# or data_exp_..._task-y3n9.csv). Cleaning stays in the pipeline.
REAL_STUDY1_TASK_IDS <- list(
  study1_disc_g1 = "task-y3n9",
  study1_disc_g2 = "task-z8oq",
  study1_pairwise = "task-yfcn",
  study1_vision = "task-hxml"
)

# Optional exact path under data/real/ (relative or absolute). NA = find by task id.
REAL_STUDY1_FILES <- list(
  study1_disc_g1 = NA_character_,
  study1_disc_g2 = NA_character_,
  study1_pairwise = NA_character_,
  study1_vision = NA_character_
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
  # --- answered Q1-Q14 (22 Sep 2026); recorded in DECISIONS_LOG ------------
  vision_subset_rule = "score_equals_4", # Q1; sensitivity only, not a primary exclusion
  vision_subset_is_primary_exclusion = FALSE, # Q1
  study1_exclusion_order = "primary_all_50_no_outcome_exclusion; self_test_outside_sample; duplicate_keep_earliest_utc_timestamp_tiebreak_event_index", # Q2; Q31 applied in prepare
  pairwise_failed_row_rule = "flag_and_stop", # Q3; gate in prepare
  incomplete_cell_rule = "flag_and_stop", # Q4; gate in prepare
  object_name_filter_when_blank = "keep_filter", # Q5
  object_name_disc = "Response",         # Dict §10; Q5
  object_name_pairwise = "Image Response",
  object_name_vision = "Number Entry",
  study1_id_raw_column = "Participant Public ID", # Q6; configurable
  study1_id_column = "participant_public_id",     # Q6 canonical after map
  anonymous_id_prefix_study1 = "S1_P",   # Q6 reporting IDs: S1_P001, ...
  fallback_normality_cutoff = "no_cutoff_diagnostics_then_stop", # Q7
  accuracy_histogram_which = c(
    "condition_k_cells_8",
    "h1_opt_minus_orig",
    "h2_opt_minus_orig_by_k"
  ),                                     # Q8
  paired_d_convention = "cohens_dz",     # Q9; effectsize
  onesample_d_convention = "cohens_d_vs_0.50",
  partial_eta_squared_ci_method = "effectsize_partial_eta_squared_two_sided_95",
  rank_biserial_convention = "effectsize_rank_biserial_two_sided_95",
  kendall_w_ci_method = "effectsize_kendalls_w_95", # Q9; also closes Q24
  effectsize_package = "effectsize",
  wilcox_zero_convention = "omit_zeros_report_nonzero_n", # Q10
  anova_ss_type = "III",                 # Q11
  anova_contrasts = "sum_to_zero",
  condition_reference_level = "Original",
  condition_level_order = c("Original", "Optimized"),
  difference_direction = "Optimized_minus_Original",
  skewness_function = "e1071::skewness(x, type = 2, na.rm = TRUE)", # Q12
  figure_list = c(
    "accuracy_condition_k_ci",
    "pairwise_prop_ci_ref50",
    "rt_by_condition_desc",
    "ae_condition_k_desc",
    "signed_error_table",
    "assumption_histograms_diagnostics"
  ),                                     # Q13
  export_table_formats = c("docx", "csv"), # Q14
  export_figure_formats = c("png_300dpi", "pdf"),
  export_reusable_formats = c("csv", "rds"),
  ae_by_k_include_ci = TRUE,             # Q14; descriptive only, no inferential test
  # Q30 confirmed 22 Sep 2026: keep current Okabe-Ito pair
  figure_colours = list(
    name = "okabe_ito",
    status = "confirmed_Q30",
    Original = "#E69F00",
    Optimized = "#0072B2",
    reference = "#000000"
  ),
  # Q31 confirmed 22 Sep 2026: Participant x Condition x K x configuration_instance
  duplicate_trial_key = "participant_id|condition|K|configuration_instance",
  duplicate_keep_rule = "min_utc_timestamp_then_min_event_index",
  duplicate_dedup_apply = TRUE,
  # --- still pending (must stay NA; do not guess) --------------------------
  geometric_mean_rt_ratio = NA,          # PENDING client answer Q15
  side_label_case = NA,                  # PENDING client answer Q16
  rt_column_if_disagree = NA             # PENDING client answer Q17
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
