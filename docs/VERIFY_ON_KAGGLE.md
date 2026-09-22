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

## v3 reload + Q1–Q14 config — load/QC verified 22 Sep 2026 (pasted console)

Helper tests (including `select`): **verified 22 Sep 2026** (46 passed, 0 failed).

| Item | What to check | Result |
|------|----------------|--------|
| V-v3-1 Object Name filter | N_FLOW; 1200/600/200 | disc/pw/vis filter dropped 0; 1200/600/200 |
| V-v3-2 Public ID | n_unique_participant_id = 50 | 50 (not BLINDED) |
| V-v3-3 rows per ID | 24 / 12 / 4 | 50 at each |
| V-v3-4 expected tokens | Response / Image Response / Number Entry; missing = 0 | all 0 missing |
| V-v3-5 anon IDs | n_unique_anon = 50; no S1PUB in log | 50; scheme `S1_P001..` only |
| V-v3-6 Q1 flag | n_score4 = 48; not an exclusion | 48 / 2; flag rows 192 / 8; exclusion not applied |
| V-v3-7 no tests | “No tests run” | present |
| V-v3-8 helper tests | all passed, including `select` | 46 passed, 0 failed, 0 error; no synthetic load |

## Packages

| Package | Status |
|---------|--------|
| base / utils | Chunk A+B + prepare verified (R 4.4.0) |
| testthat 3.2.2 | 57 passed (prepare toys included) |
| e1071 1.7.16 | Q12 skewness on Kaggle; already installed |
| renv | optional version-record writer only; **not** restore |

## renv.lock version record — verified 22 Sep 2026 (pasted console)

Wrote `/kaggle/working/R-project/renv.lock` (318 lines). `testthat` 3.2.2 plus its dependencies. R recorded as **4.4.0** (Kaggle), not the client target 4.6.1. Some dependency `Repository` fields are `RSPM` (Kaggle). Script printed: do not run `renv::restore()`.

This file is **not yet in the local git repo**. Download it from the Kaggle working folder and add it here before the next commit.

## Prepare chunk — verified 22 Sep 2026 (pasted console)

| Item | What to check | Result |
|------|----------------|--------|
| V-P1 Q2 N | n_unique_participant_id = 50; no outcome drop | 50; “no outcome-based exclusion”; vision subset not applied |
| V-P2 Q31 audit | n_dup_keys=0; n_rows_would_drop=0; applied=FALSE | n_keys=1200; n_dup_keys=0; n_rows_would_drop=0; event_index_available=TRUE; applied=FALSE |
| V-P3 Q3 gate | mapping_fail_rows=0; pipeline continues | 0; rule=flag_and_stop; no stop |
| V-P4 Q4 gate | all incomplete counts 0; pipeline continues | n_short_disc=0; n_short_pw=0; n_cells_ne_3=0; n_missing_cells=0 |
| V-P5 summaries | 50 rows; header has participant_anon_id only | n_data_rows=50; first column `participant_anon_id` |
| V-P6 no Gorilla IDs | header_has_gorilla_id_column=FALSE | FALSE |
| V-P7 Q8 PNGs | three `study1_diag_*_SYNTHETIC.png` | all three written |
| V-P8 Q7 | “fallback NOT applied”; no H1–H3 | present; “H1-H3 were not run” |
| V-P9 Q12 | trial_rt_skewness printed; e1071 loaded | e1071 1.7.16; skewness=1.1808; threshold=1; analysis_scale=log; n_valid_rt=1200; n_rt_dropped=0 |
| V-P10 helper tests | all previous + prepare toys pass | n_passed=57 n_failed=0 n_error=0; no synthetic load in tests |

## H1–H3 chunk — first Kaggle run 22 Sep 2026 (pasted console)

Stopped on Mauchly rows `1; 2; 3; 4`. Fixed in `0689ebe`. Helper tests that run: 71 passed.

## H1–H3 chunk — verified 22 Sep 2026 after Mauchly fix (pasted console)

Packages: afex 1.4.1, effectsize 1.0.0, ggplot2 3.5.1, officer 0.6.7, flextable 0.9.7. Helper tests: **75 passed, 0 failed**.

Synthetic pipeline numbers below are **not findings**.

| Item | What to check | Result |
|------|----------------|--------|
| V-H1 Q7 report | fallback_applied=FALSE; client text printed | present; six diagnostic PNGs listed |
| V-H1b Mauchly | named rows including condition:K | rows=`K; condition:K`; columns=`Test statistic; p-value` |
| V-H2 H1/H2 ANOVA | F, df, p, pes; Mauchly/GG logged | H1 F=2.5310 df=1,49 p=0.1181 pes=0.0491 sphericity=none; H2 F=0.2402 GG df p=0.8367 pes=0.0049 mauchly_p=0.0183 |
| V-H3 H2 follow-ups | only if interaction p < alpha | `H2_followups_ran=FALSE reason=interaction_not_significant` |
| V-H4 H3 | one-sample t vs 0.50; d vs 0.50 | t=4.9138 df=49 p=0.0000 mean=0.5933 d=0.6949 |
| V-H5 RT | analysis_scale=log; paired t | t=-0.3574 p=0.7223 scale=log |
| V-H6 AE / SE | AE paired t; SE table written | AE t=-1.5909 p=0.1181; signed-error table written |
| V-H7 vision | n_ids=48; separate table | 48; H1/H2/H3 sig_agrees=TRUE; not merged |
| V-H8 tables | csv+docx; no Gorilla ID columns | 12 csv + 12 docx; all `header_has_gorilla_id_column=FALSE` |
| V-H9 figures | 4 report fig png+pdf; Okabe-Ito caption | all eight files written; PDF warned on en-dash (caption fix pending next run) |
| V-H10 no fallback | no Wilcoxon/Friedman in the log | none; Q9 unused ES logged as not computed |
