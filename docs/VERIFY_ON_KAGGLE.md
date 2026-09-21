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

## Chunk B — NOT EXECUTED yet

| Item | What to check | Result |
|------|----------------|--------|
| V-B1 disc rows | 1200 after blank drop | |
| V-B2 pairwise rows | 600 | |
| V-B3 vision rows | 200 | |
| V-B4 condition recode | Original=600, Optimized=600 | |
| V-B5 Object Name | missing count = row count; filter **not** applied | |
| V-B6 participant_id | all NA (Q6) | |
| V-B7 vision_subset_flag | all NA (Q1) | |
| V-B8 mapping_fail | counted; rows **not** dropped (Q3) | |
| V-B9 correct_mismatch | count (synthetic was 0 in Phase 1 Python) | |
| V-B10 no IDs in log | only counts | |
| V-B11 `fileEncoding=UTF-8` | no read error | |
| V-B12 no hypothesis tests | log says none run | |

## Packages

| Package | Status |
|---------|--------|
| base / utils | Chunk A+B |
| testthat 3.2.2 | Chunk A verified; tests = Chunk C |
