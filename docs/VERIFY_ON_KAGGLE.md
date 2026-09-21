# To verify on Kaggle

Local R: **NOT EXECUTED**. Results below are only from pasted Kaggle output.

## Chunk A — verified 22 Sep 2026 (pasted console)

| Item | Result |
|------|--------|
| V-A1 R version | R 4.4.0 (2024-04-24), Ubuntu 22.04, x86_64 |
| V-A2 ENV_NAME | kaggle; IS_KAGGLE TRUE |
| V-A3 PROJECT_ROOT | resolved; `config/config.R` exists TRUE |
| V-A5 OUTPUT_DIR | kaggle mode; `session_info.txt` written |
| V-A7 testthat | already installed; 3.2.2; nothing reinstalled |
| V-A9 require_param(alpha) | 0.05 |
| V-A10 require_param(vision_subset_rule) | PENDING message (intended) |
| V-A11 SEED | 20260921 |
| V-A12 DATA_SOURCE | synthetic |
| V-A13 pending Q1–Q14 names | listed as NA |

Client target remains **R 4.6.1**. Kaggle is 4.4.0.

## Chunk B — verified 22 Sep 2026 (pasted console + QC log)

| Item | What to check | Result |
|------|----------------|--------|
| V-B1 disc rows | 1200 after blank drop | 1200 (G1 600→600, G2 600→600) |
| V-B2 pairwise rows | 600 | 600 (blank drop 600→600) |
| V-B3 vision rows | 200 | 200 (blank drop 200→200) |
| V-B4 condition recode | Original=600, Optimized=600 | Original=600, Optimized=600 |
| V-B4b K counts | 5/10/20/30 | 300 each |
| V-B4c rows per private ID | 24 / 12 / 4 | 50 private IDs at each of those counts |
| V-B5 Object Name | missing count = row count; filter **not** applied | disc 1200, pairwise 600, vision 200; Q5 not applied |
| V-B6 participant_id | all NA (Q6) | TRUE |
| V-B7 vision_subset_flag | all NA (Q1) | TRUE |
| V-B8 mapping_fail | counted; rows **not** dropped (Q3) | count = 0; 600 rows kept. Zero is expected: the baked-in synthetic mismatch is option-label vs filename, which reconstruction handles. Unmatched-Response / not-one-and-one fails were 0 on this file. |
| V-B9 correct_mismatch | count | 0 (matches Phase 1 Python audit) |
| V-B10 no IDs in log | only counts | QC log is aggregates only |
| V-B11 UTF-8 read | no read error | completed |
| V-B12 no hypothesis tests | log says none run | “LOAD COMPLETE. No tests run.” |
| V-B13 vision QC score | private-ID count only, labelled PENDING Q6 | n_score4=48, n_below4=2; subset **not** applied |

## Chunk C — verified 22 Sep 2026 (pasted console + test log)

| Item | What to check | Result |
|------|----------------|--------|
| V-C1 reporter | testthat summary prints | accuracy-recalc / io-helpers / mapping-study1 / vision-score all printed |
| V-C2 n_failed / n_error | both 0 | n_passed=38 n_failed=0 n_error=0 |
| V-C3 log line | “No statistical tests were run. No synthetic data were loaded.” | present |
| V-C4 files | four toy-data files only | no synthetic load; no hypothesis tests |

## Packages

| Package | Status |
|---------|--------|
| base / utils | Chunk A+B verified |
| testthat 3.2.2 | Chunk A+C verified |
