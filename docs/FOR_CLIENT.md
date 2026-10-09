# Note for Fatimah

**SYNTHETIC DATA: pipeline test only** when `DATA_SOURCE` is `"synthetic"`. Those numbers are not findings.

Study 1 is implemented with the Q7-locked non-parametric path for H1/H2/H3 (RT/AE paired t).

Study 2: load, prepare, thesis-style report figures, and (when enabled) inferential tables on the SAP recommended ANOVA/t path. Study 1's Wilcoxon/Friedman lock is **not** applied until you confirm Q32 after reviewing Study 2 diagnostics.

Study 3 is **not** implemented.

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

### Q32 / inferential hold (real data)

While `study2_q32_hold_inferential` is `TRUE` (default after Oct 2026), a real-data run writes **diagnostic plots**, the **Q7 review note**, and **report figures**, but **does not** write inferential H1/H2/H3/RT/AE tables until you review diagnostics and confirm the parametric vs non-parametric path. Set `study2_q32_hold_inferential <- FALSE` in `config/config.R` after that review to produce full inferential tables.

## Study 1 real export

Filenames must contain: `task-y3n9`, `task-z8oq`, `task-yfcn`, `task-hxml`.

## Privacy

Shareable logs and tables use anonymous IDs (`S1_P001`, `S2_P001`, …), never Gorilla Public/Private IDs.

## Recorded answers

- **Q30:** Original `#E69F00`, Optimized `#0072B2`.
- **Q31:** Participant × Condition × K × configuration_instance; earliest UTC Timestamp, Event Index tie-break.

## Study 1 Q7 path (locked 22 Sep 2026)

H1 Wilcoxon, H2 Friedman (+ Holm follow-ups if significant), H3 Wilcoxon vs 0.50, RT/AE paired t; vision sensitivity subset as previously locked for Study 1.
