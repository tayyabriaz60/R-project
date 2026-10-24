# Note for Fatimah

**SYNTHETIC DATA: pipeline test only** when `DATA_SOURCE` is `"synthetic"`. Those numbers are not findings.

Study 1 is implemented with the Q7-locked non-parametric path for H1/H2/H3 (RT/AE paired t).

Study 2: load, prepare, thesis-style report figures, and inferential tables on the **Q32 locked mixed path** (H1 Wilcoxon, H2 Friedman + conditional Holm Wilcoxon follow-ups, H3 one-sample t vs 0.50, RT/AE paired t). Rank-based tests round Optimized−Original difference scores to 10 decimals before ranking. Expected real primary **N = 42** after vision exclusions.

Study 3: full pipeline via `run_study3.R`. Real primary **N = 46** after researcher + vision rules. Inferential path **locked parametric** (Oct 2026 diagnostics): H4/H5 RM-ANOVA, H6/H7 *t*, log RT when trial skew > 1. See `docs/STUDY3_Q7_RECOMMENDATION.md`. Real loader defaults: `REAL_STUDY3_COMBINED_FILE` + `REAL_STUDY3_FILES$study3_questionnaire`.

Study 3 tables (Oct 2026): exported `.csv`/`.docx` pairs under `output/tables/` include full RM-ANOVA rows (Condition, Background, interaction) with *F*, df, *p*, partial ηp² and 95% CIs; Condition × Background descriptives for accuracy, RT (ms), AE, and signed error; H6/H7 inferential and background descriptives; accuracy-by-K descriptives; follow-up tables when interactions are significant. Tests and models are unchanged—only reporting was expanded.

## Run on your machine (R 4.6.1)

```r
PROJECT_ROOT <- "put/the/path/to/this/folder/here"
source(file.path(PROJECT_ROOT, "run_all.R"))
```

Study 2 only:

```r
PROJECT_ROOT <- "put/the/path/to/this/folder/here"
source(file.path(PROJECT_ROOT, "run_study2.R"))
```

Study 3 only:

```r
PROJECT_ROOT <- "put/the/path/to/this/folder/here"
source(file.path(PROJECT_ROOT, "run_study3.R"))
```

**Where outputs go:** The zip does not include pre-run results. After `run_study3.R`, figures and tables are created under `PROJECT_ROOT/output/` (`figures/`, `tables/`, `logs/`). Read `output/README.txt` in the package. The run prints the full path and writes `output/logs/study3_output_manifest*.txt` listing every Study 3 file produced.

Do **not** run `renv::restore()`.

## Study 2 real export

1. Put unedited Gorilla CSVs under `data/real/` (subfolders are fine). Filenames should contain:
   - Discrimination G1: `task-fxg1`
   - Discrimination G2: `task-a5wf`
   - Pairwise: `task-44yr`
   - Vision (Ishihara): `task-e9t3`
   - Background questionnaire: `questionnaire-z5c3` (vision item for primary inclusion)
2. Do not filter rows, rename columns, or deduplicate. Cleaning runs in the pipeline.
3. Set `DATA_SOURCE <- "real"` in `config/config.R`.
4. Run `run_study2.R`.

### Primary sample (Study 2, confirmed Oct 2026)

After researcher exclusion at load, the **primary** analysis includes participants who:

- score **4/4** on the Ishihara colour-vision screening, **and**
- answer the background questionnaire with normal or corrected-to-normal vision (not the uncorrected abnormal-vision option).

Participants failing either criterion are excluded from the primary analysis. Missing or ambiguous Ishihara or questionnaire responses **stop** the run with a count-only message (no guessing).

Figure captions for report plots are in `output/logs/study2_figure_captions*.txt` (not inside the PNG/PDF).

### Q32 (answered Oct 2026)

The locked mixed path is in `config/config.R` (`study2_h1_test`, etc.). The Q7 review note (`output/logs/study2_q7_fallback_review*.txt`) documents that H1/H2 fallback rationale should cite **participant-level difference-score diagnostics** and SAP fallback rules, not raw accuracy histograms alone. Check `study2_log_prepare` and `study2_log_analysis` for `n_participants=42`, vision exclusion flags, and RT analysis scale.

## Study 3 real export

1. Put unedited Gorilla CSVs under `data/real/` (subfolders are fine). Either one **combined** export or separate files whose filenames contain:
   - Vision (Ishihara): `task-42o4`
   - Discrimination blocks: `task-vq91`, `task-kywx`, `task-pni8`, `task-3dnm`
   - Pairwise blocks: `task-z9og`, `task-xj8i`, `task-efvq`, `task-bjwl`
   - Background questionnaire (vision item): `questionnaire-woc5` (and `questionnaire-bvmq` if separate)
2. If you use one combined CSV, set `REAL_STUDY3_COMBINED_FILE` in `config/config.R` to that filename under `data/real/`.
3. Set `DATA_SOURCE <- "real"` and run `run_study3.R`.

### Primary sample (Study 3)

- Exclude researcher session Public ID `68780190e411d08beb1f706d` at load (pipeline verifies **51 → 50** sessions on your export).
- Primary analysis: Ishihara **4/4** and questionnaire normal/corrected-to-normal vision. Missing/ambiguous vision data **stops** the run (no guessing). Expected primary **N = 46** after exclusions (pipeline verifies, not hard-coded silently).
- Default config includes Fatimah’s combined export filenames under `data/real/`. Inferential tables are enabled (`study3_q_hold_inferential = FALSE`) after diagnostic lock.

Pairwise rows: Task Name + `Response` ∈ {Left, Right} when Object Name is blank (Q20). Side and Optimized stimulus are reconstructed from image filenames and cross-checked against `Spreadsheet: optimized_side`.

## Study 1 real export

Filenames must contain: `task-y3n9`, `task-z8oq`, `task-yfcn`, `task-hxml`, and background questionnaire `questionnaire-oj8k`.

Researcher session (`9lwz9o9r`) is dropped at load. Primary sample: Ishihara 4/4 plus questionnaire pass (same rules as Study 2). While `study1_q7_hold_inferential` is `TRUE`, real runs produce diagnostics and report figures only; send updated diagnostic plots before the final H1–H3 path is locked.

## Privacy

Shareable logs and tables use anonymous IDs (`S1_P001`, `S2_P001`, …), never Gorilla Public/Private IDs.

## Recorded answers

- **Q30:** Original `#E69F00`, Optimized `#0072B2`.
- **Q31:** Participant × Condition × K × configuration_instance; earliest UTC Timestamp, Event Index tie-break.

## Study 1 Q7 path (open pending review, Oct 2026)

The September 2026 Wilcoxon lock is not assumed. After vision-filtered rerun, review difference-score diagnostics with Tayyab, then lock tests in `config/config.R` and set `study1_q7_hold_inferential <- FALSE` for inferential tables.
