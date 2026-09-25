# Decisions log

Every implementation decision with its SAP / brief / dictionary / rules reference.  
Methodological choices that the SAP leaves open are **not** decided here; they are `TODO(client-question #N)` until Fatimah answers.

**R status:** not installed locally. Study 1 through H1–H3 / Q13 tables and figures is verified from pasted Kaggle output (R 4.4.0, synthetic v3). Those numbers are pipeline tests, not findings.

| Date | Decision | Reference | Notes |
|------|----------|-----------|-------|
| 2026-09-21 | Source-of-truth order: SAP > Brief > Dictionary > rules file | Rules §1; Brief authority box | Dictionary §1 says the Brief governs analysis decisions; that sentence is logged as Q21, not adopted. |
| 2026-09-21 | Phase 1: read-only audit; no analysis scripts; no statistical tests | Phase 1 brief; Rules §8 steps 1–2 | Completed. |
| 2026-09-21 | Synthetic data only; `data/real/` empty and gitignored | Rules §3; Brief §13 | — |
| 2026-09-22 | Official rules file installed as `.cursor/rules/r-analysis.mdc` (`alwaysApply: true`); user-provided copy kept at `.cursor/rules/cursor_rules.md` | Phase 1 brief; Rules file itself | Content unchanged except YAML frontmatter on the `.mdc`. |
| 2026-09-22 | Planned architecture follows Rules §4 (`run_all.R`, `config/config.R`, `R/utils_*.R`, numbered `scripts/`, `output/models/`, `study{N}_{type}_{name}` filenames) | Rules §4, §7 | Replaces the Phase 1 draft names (`config/analysis.yml`, `scripts/run_all.R`) **when implementation starts**. Not implemented yet. |
| 2026-09-22 | Blocked methodology left as `TODO(client-question #N)` that must `stop()` if reached | Rules §1 | Applies to Q1–Q17 for Study 1. |
| 2026-09-22 | Logs will record **counts only**, not participant IDs or raw rows | Rules §3 | Compatible with SAP §1 “report missing/excluded observations and final N”. |
| 2026-09-22 | Synthetic outputs will be labelled `_SYNTHETIC` / watermark | Rules §2 | — |
| 2026-09-22 | Table export convention when SAP is silent: `.docx` + `.csv` (Rules §7 example); figure convention: PNG 300 dpi + PDF/SVG; diagnostic histograms are the only figures the SAP names | Rules §7 (priority 4); SAP §3.1–§3.2 histograms; Q13 for any other plots | Do not add extra *analyses*. Format is implementation convention, not a new hypothesis. |
| 2026-09-22 | Do not invent a numeric fallback cutoff | Brief §9; SAP qualitative wording; Rules §5 wants a programmatic trigger | **Blocked on Q7.** Code must not guess a threshold. |
| 2026-09-22 | Do not silently pick Cohen’s d / η² / rank-biserial convention | Brief §10; Rules §5 | **Blocked on Q9.** |
| 2026-09-22 | No `renv`. Use `scripts/00_setup.R` (install missing only). | User environment constraint (overrides Rules §4 renv) | Constraint is later and explicit. |
| 2026-09-22 | Paths: one `PROJECT_ROOT`; one `setwd` in `config/config.R`; Kaggle if `dir.exists("/kaggle")` → outputs `/kaggle/working/output` | User environment constraint; Rules §3 | `here` not used (Kaggle + PROJECT_ROOT is simpler). |
| 2026-09-22 | Chunk 1 load uses base `utils::read.csv` only (no dplyr/readr) | User: smallest package list; portability | Not run yet. |
| 2026-09-22 | Chunk 1 does not apply Object Name filters, ID recode, or exclusions | Q5, Q6, Q2, Q18; Rules §1 | Load + structure counts only. |
| 2026-09-22 | Do not write participant-level CSVs/RDS to `output/` | Rules §3 | Logs = counts only. |
| 2026-09-22 | Official rules rewritten from master prompt into `.cursor/rules/r-analysis.mdc` and `docs/PROJECT_RULES.md` | Master prompt PART 1 | Bodies identical except YAML frontmatter on the `.mdc`. |
| 2026-09-22 | `SEED <- 20260921L` (SAP freeze date as digits) | SAP does **not** specify a seed | **Non-methodological.** Only for any technical randomness. Primary tests are deterministic. |
| 2026-09-22 | Q1–Q14 stored as `SAP$... <- NA`; `require_param()` stops if used | Rules §6; QUESTIONS Q1–Q14 | No guessed fill-in. |
| 2026-09-22 | Chunk A verified on Kaggle R 4.4.0; testthat 3.2.2 | Real pasted output | Client target still 4.6.1. |
| 2026-09-22 | Study 1 load keeps both public/private IDs; `participant_id` NA until Q6 | Q6; Dict §3 | QC groups vision score by private ID only as a count, labelled PENDING Q6. |
| 2026-09-22 | Chunk B verified on Kaggle R 4.4.0: 1200 / 600 / 200; blocked Q1–Q3, Q5, Q6 not applied; no tests | Pasted QC log | Public ID unique count = 1 (`BLINDED`). Vision QC: 48 score-4, 2 below 4, subset not applied. |
| 2026-09-22 | `pairwise_mapping_fail_rows=0` is not a silent drop | Brief §4; Q3 | Fail = unmatched Response **or** not exactly one optimized filename. The synthetic “mapping mismatch” is option-label vs filename; reconstruction keeps those rows with `mapping_fail=0`. |
| 2026-09-22 | Chunk C tests use tiny handmade toy data only | Rules §7 | Do not load the full synthetic file in tests. Structure on the full synthetic file is the Chunk B QC log. |
| 2026-09-22 | Chunk C verified on Kaggle R 4.4.0: 38 passed, 0 failed, 0 error | Pasted test log | No synthetic load. No hypothesis tests. Phase 2A (A+B+C) complete. Phase 2B blocked on Q1–Q14. |
| 2026-09-22 | **Q1 answered.** Fatimah: “vision score = 4/4. Primary N=50; vision sensitivity subset N=48. Sensitivity analysis only, not a primary exclusion.” | SAP §3.4; Brief §11 | `SAP$vision_subset_rule = "score_equals_4"`. Flag computed at load; subset **not** applied as an exclusion. |
| 2026-09-22 | **Q2 answered.** Fatimah: “primary population = all 50 recruited participants, no outcome-based exclusion. Pre-recruitment self-test session is outside the sample. For duplicate discrimination responses: keep the earliest valid response per participant x configured trial, tie-broken by Event Index.” | SAP §1 | Recorded in `SAP$study1_exclusion_order`. Dedup **not** implemented this chunk (Q31). |
| 2026-09-22 | **Q3 answered.** Fatimah: “if a row can't be mapped unambiguously, do NOT guess/exclude/recode automatically. Flag it and stop; report to client before continuing pairwise analysis.” | Brief §4 | `SAP$pairwise_failed_row_rule = "flag_and_stop"`. Load still flags only; analysis-time stop is the next chunk. |
| 2026-09-22 | **Q4 answered.** Fatimah: “expected complete structure is 24 discrimination + 12 pairwise trials/participant. If real data don't meet this, FLAG and stop rather than auto-excluding or computing from incomplete cells.” | SAP §1; Dict §9 | `SAP$incomplete_cell_rule = "flag_and_stop"`. Not applied at load. |
| 2026-09-22 | **Q5 answered.** Fatimah: “keep the filter. Populated in real Gorilla files as: Discrimination -> Response, Pairwise -> Image Response, Vision -> Number Entry. Blank was a synthetic-data-only bug, now fixed in v3.” | Dict v2 §10 | Filter applied at load. v3 Object Name is populated. |
| 2026-09-22 | **Q6 answered.** Fatimah: “use Participant Public ID as the Study 1 identifier (configurable in code, not hard-coded). Participant Private ID may be kept for internal QA only. NEVER include the real ID in tables/figures/logs/exports meant for reporting - replace with an anonymous sequential ID like S1_P001, S1_P002, ... in any output.” | Dict v2 §3 | `study1_id_column` configurable; `participant_anon_id` for reporting. Logs stay counts-only. |
| 2026-09-22 | **Q7 answered.** Fatimah: “no new numerical cutoff. Generate the SAP-specified diagnostics, then STOP and send them to the client before switching to a fallback test. Do not auto-switch.” | SAP §3.1; Brief §9 | `fallback_normality_cutoff = "no_cutoff_diagnostics_then_stop"`. Two-pass workflow. Not implemented this chunk. |
| 2026-09-22 | **Q8 answered.** Fatimah: “histograms for (a) the 8 participant-level Condition x K accuracy vectors, (b) overall Optimized-Original accuracy difference for H1, (c) the four K-specific Optimized-Original difference vectors for H2.” | SAP §3.1 | Stored in `accuracy_histogram_which`. Not drawn this chunk. |
| 2026-09-22 | **Q9 answered.** Fatimah: “RM-ANOVA -> partial eta squared with two-sided 95% CI; paired comparisons -> Cohen's dz with two-sided 95% CI; H3 -> one-sample Cohen's d relative to 0.50; Wilcoxon -> rank-biserial correlation with two-sided 95% CI; Friedman -> Kendall's W with 95% CI. Use the effectsize package consistently; record package/function versions.” | Brief §10 | Conventions stored. `effectsize` not installed yet (no ES computed this chunk). Closes Q24. |
| 2026-09-22 | **Q10 answered.** Fatimah: “omit exact-zero paired differences before ranking, report the effective non-zero N, and use the same non-zero differences for the rank-biserial effect size.” | Brief §9.1 | `wilcox_zero_convention = "omit_zeros_report_nonzero_n"`. Not run this chunk. |
| 2026-09-22 | **Q11 answered.** Fatimah: “Type III sums of squares, sum-to-zero contrasts. Condition levels ordered Original, Optimized. K levels ordered 5, 10, 20, 30. Report paired differences as Optimized minus Original.” | SAP §3.1 | Stored. ANOVA not fit this chunk. |
| 2026-09-22 | **Q12 answered.** Fatimah: “e1071::skewness(x, type = 2, na.rm = TRUE), computed on valid Study 1 discrimination trial-level RTs BEFORE participant-level averaging. If skewness > 1, apply the SAP's natural-log transform.” | SAP §3.3.1 | Stored. Skewness not computed this chunk. |
| 2026-09-22 | **Q13 answered (list).** Fatimah: “Accuracy (Condition x K with 95% CI), Pairwise (Optimized-choice proportion with 95% CI and a 0.50 reference line), RT (descriptive RT by Condition), Absolute Error (Condition x K descriptives), Signed Error (table only), assumption histograms saved separately as diagnostics only.” | SAP §6; Brief §14 | `figure_list` filled. Colours remain NA → Q30. |
| 2026-09-22 | **Q14 answered.** Fatimah: “tables -> .docx + .csv; figures -> .png at 300dpi + vector .pdf; reusable outputs -> .csv/.rds; R scripts, README, an analysis log, and an renv lockfile. AE x K: descriptive mean/SD/95% CI only, no inferential test.” | Brief §14 | Formats stored. renv.lock is a **version record** only; restore remains `00_setup.R`. |
| 2026-09-22 | Discard old synthetic package; use `Synthetic_Data_Tayyab_FINAL_v3` + Dictionary v2 | Client files 22 Sep 2026 | Public IDs `S1PUB001`–`S1PUB050`; Object Name populated. |
| 2026-09-22 | Do not use `renv::init()` in the project root | Q14 vs no-renv restore rule | `scripts/write_renv_lock.R` writes a lockfile without activating renv. |
| 2026-09-22 | v3 load/QC verified on Kaggle R 4.4.0 | Pasted QC log | Object Name filter kept all rows; 50 public IDs; 48 vision score-4; no Gorilla IDs in log; no hypothesis tests. |
| 2026-09-22 | v3 helper tests verified: 46 passed, 0 failed (includes `select`) | Pasted test log | Toy data only. No synthetic load. No hypothesis tests. |
| 2026-09-22 | `renv.lock` written on Kaggle as a version record | Pasted console | testthat 3.2.2 + deps; R 4.4.0; some RSPM sources. Not used for restore. File still only on Kaggle until downloaded. |
| 2026-09-22 | Q2 primary population = all loaded IDs; no outcome-based drop; vision subset not applied | Q2; SAP §3.4 | `apply_study1_primary_population`. Synthetic must have N=50 or stop. Self-test session is not in these files. |
| 2026-09-22 | Q31 duplicate rule is audit-only until she names the key | Q2; Q31 | Guess key = `participant_id\|condition\|K\|configuration_instance`; keep-guess = min Event Index. Logs n_dup_keys / n_rows_would_drop. `duplicate_dedup_apply` stays FALSE and stops if flipped while `duplicate_trial_key` is NA. Swap `study1_duplicate_key_guess()` when she answers. |
| 2026-09-22 | Q3/Q4 are hard gates: mapping_fail>0 or incomplete 24/12 / not-3-instances **stop()** | Q3; Q4 | `gate_pairwise_mapping_q3`, `gate_incomplete_cells_q4`. Counts only in the message. No auto-drop, impute, or recode. |
| 2026-09-22 | Participant summaries use Public ID internally; written table is anon only | Q6; SAP §3.1–§3.3 | `write_study1_summaries` refuses Gorilla ID columns. Cells = mean of 3 instances. H1/H2 diffs = Optimized − Original (Q11). Pairwise = mean of `chose_optimized` over 12. |
| 2026-09-22 | Q12 skewness on trial-level valid RT before averaging; log if > 1 | Q12; SAP §3.3.1 | `e1071::skewness(..., type=2)`. Valid = non-missing and > 0. Untransformed ms always kept. `log()` is natural log. |
| 2026-09-22 | Q8 histograms are diagnostic greyscale PNGs only | Q8; Q7; Q30 | 8 Condition×K cells, H1 overall diff, four K diffs. 150 dpi. Q30 stays NA; no Q13 colours. Not report figures. |
| 2026-09-22 | Q7: write diagnostics and message; do not auto-switch; do not run H1–H3 | Q7 | `save_study1_q8_histograms` logs “fallback NOT applied”. Prepare does not `stop()` the whole run after a clean Q3/Q4 pass (that would look like a pipeline failure). Fallback tests remain unimplemented. |

| 2026-09-22 | Prepare chunk verified on Kaggle R 4.4.0 | Pasted Cell 2+3 | Q2 N=50; Q3/Q4 passed (0); Q31 applied=FALSE n_dup_keys=0; 50 anon summary rows; 3 diag PNGs; Q12 skewness=1.1808 → log (synthetic pipeline only, not a finding); tests 57/0/0. No H1–H3. |

| 2026-09-22 | H1–H3 use the SAP recommended parametric path; Q7 report is written first | SAP §3.1–§3.3; Q7; Brief §9 | `write_q7_client_report` before any Condition p-value. Wilcoxon/Friedman are not called. No invented normality cutoff. |
| 2026-09-22 | RM-ANOVA via `afex::aov_ez` type=3, `contr.sum` | Q11; SAP §3.1 | Mauchly from `summary(fit$Anova)$sphericity.tests`. GG only if Mauchly p < alpha for effects with >2 levels. Condition (2 levels) uncorrected. |
| 2026-09-22 | Q9 ES via effectsize with two-sided 95% CI | Q9 | `eta_squared(..., partial=TRUE, alternative="two.sided")` — not the package default `"greater"`. Paired `cohens_d(..., paired=TRUE)` as dz. H3 `cohens_d(x, mu=0.50)`. Rank-biserial / Kendall W wrappers unused until a fallback is approved. |
| 2026-09-22 | H2 follow-ups only if interaction p < alpha; Holm on estimable K only | SAP §3.1 | Zero-variance K: descriptives only. Differences are Optimized − Original. |
| 2026-09-22 | RT paired t on the Q12 analysis scale (log on this synthetic run) | SAP §3.3.1; Q12 | Millisecond descriptives always reported. Pairwise RT descriptive only. |
| 2026-09-22 | AE paired t across K; AE × K descriptive only; signed error descriptive only | SAP §3.3.2–§3.3.3; Q14 | No AE-by-K inferential test. |
| 2026-09-22 | Vision sensitivity = repeat H1–H3 on score==4; not merged | SAP §3.4; Q1 | Synthetic expected N=48. Separate table. |
| 2026-09-22 | Q13 figures use Okabe–Ito placeholder pending Q30 | Q13; Q14; Q30 | Original `#E69F00`, Optimized `#0072B2`. Caption and DECISIONS mark it as placeholder. `SAP$figure_colours` stays NA. PNG 300 dpi + PDF. Tables csv + docx. |

| 2026-09-22 | H1–H3 first Kaggle run stopped on Mauchly row names | Pasted Cell 2 | `as.data.frame(sphericity.tests)` yielded rows `1; 2; 3; 4`. Fixed with `as.data.frame.matrix` / unflatten. |
| 2026-09-22 | H1–H3 re-run verified on Kaggle R 4.4.0 | Pasted Cell 2+3 | Mauchly rows `K; condition:K`. H2 used GG (mauchly_p=0.0183). H2 follow-ups not run (interaction ns). Q7 fallback not applied. Vision N=48, sig_agrees H1/H2/H3. 12 table pairs, 4 figures png+pdf. Tests 75/0/0. Synthetic only; not findings. PDF warned on U+2013 in captions (now ASCII). |

| 2026-09-22 | Q31: halt if the guess key finds duplicates while the key is still NA | Q2; Q31; real-data safety | Was audit-and-continue. That would analyse undeduplicated real rows. Now `log_duplicate_audit` stops with `Q31 GATE` when `n_dup_keys > 0` and `duplicate_trial_key` is NA. Synthetic v3 had 0, so the verified run is unchanged. Dedup is still not applied. |
| 2026-09-22 | Study 1 delivery docs finalized for a fresh `run_all.R` check | Rules §4, §8 | README states R 4.4.0 vs 4.6.1, `00_setup.R`, renv.lock as version record only, SYNTHETIC label, Q30/Q31 open. |

| 2026-09-22 | Fresh Kaggle session reproduced `run_all.R` end-to-end | Pasted Cell 2+3 | Empty working dir; clone; load through figures. Q31 n_dup_keys=0 (no GATE). Tests 79/0/0. Synthetic only. |

| 2026-09-22 | Q30 confirmed: Original `#E69F00`, Optimized `#0072B2` | Q30 | `SAP$figure_colours` filled. Same pair as the earlier placeholder. |
| 2026-09-22 | Q31 confirmed and applied | Q2; Q31 | Key = `participant_id\|condition\|K\|configuration_instance`. Keep min UTC Timestamp, then min Event Index. Cleaning runs in prepare. Real files found by task id under `data/real/`. |
| 2026-09-22 | Real Study 1 paths configurable | Client 22 Sep | G1 `task-y3n9`, G2 `task-z8oq`, pairwise `task-yfcn`, vision `task-hxml`. `DATA_SOURCE <- "real"`. No manual edit of raw Gorilla files. |

| 2026-09-22 | Q30/Q31/real-path run on Kaggle R 4.4.0 | Pasted Cell 2 | Q31 applied=TRUE, n_rows_dropped=0. Q30 confirmed. Same synthetic H1–H3 path as before. Tests 89 pass / 1 leftover pending-Q30 assert (fixed after paste). |

| 2026-09-22 | Q7 path locked from real-data plots | Q7; SAP §3.1–§3.3 | H1 paired Wilcoxon; H2 Friedman on Opt-Orig by K (pairwise Wilcoxon + Holm x6 only if Friedman sig); H3 one-sample Wilcoxon vs 0.50; RT paired t (analysis scale); AE paired t. Same tests on N=48. Primary N=50. Q10 omit-zeros. ANOVA is not the reported primary path. |
| 2026-09-22 | Q7 locked path verified on Kaggle R 4.4.0 | Pasted Cell 2+3; commit 20ea55f | Synthetic only, not findings. Primary H1 V=552.5 p=0.1106 n_nonzero=41; H2 chi2=1.2711 p=0.7360 followups=FALSE; H3 V=867 p=0.0000 n_nonzero=44; RT t=-0.3574 log; AE t=-1.5909. Vision N=48, sig_agrees TRUE. Tests 103/0/0. Prepare-log wording later cleaned in 1484dc6. |

| 2026-09-24 | Start Study 2 with load/QC only | SAP §4; Fatimah “start study2” | Combined synthetic file split by Dict §10 Clone task names. Researcher drop uses synthetic Public ID `S2_RESEARCHER_EXCLUDE` only. Real researcher ID (Q18) and real task ids (Q33) stay NA and `stop()`. Study 1 Q7 lock is not inherited (Q32). `run_all.R` stays Study 1 only. |
| 2026-09-25 | Study 2 uses SAP recommended ANOVA/t | SAP §4.1–§4.3; Q32 | H1/H2 2x4 RM-ANOVA; H3 one-sample t; RT/AE paired t; vision N=43 same tests. Difficulty averaged in Condition x K cells; no Difficulty model. Study 1 npar lock not inherited. |
| 2026-09-25 | Study 2 pipeline verified on Kaggle R 4.4.0 | Pasted Cell 2+3; commit 1550fe8 | Synthetic only, not findings. Researcher 51→50. H1 F=0.2363 p=0.6290; H2 GG F=2.6179 p=0.0678 followups=FALSE; H3 t=3.4357 p=0.0012; RT t=-0.9902 log; AE t=0.4861. Vision N=43, sig_agrees TRUE. Tests 124/0/0. |

Q15–Q17 remain NA. Study 2 Q18 / Q32 / Q33 remain NA.
