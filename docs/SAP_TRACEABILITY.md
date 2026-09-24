# SAP / Brief traceability

**Phase:** Study 1 delivery (synthetic pipeline). Studies 2–3 not implemented.  
**Kaggle:** Q7 locked npar path verified on R 4.4.0 (v3 synthetic), 22 Sep 2026, commit `20ea55f`. H1 Wilcoxon / H2 Friedman / H3 Wilcoxon; RT/AE paired t. Helper tests 103 passed, 0 failed. Numbers are pipeline-test output, not findings.  
**Source order:** SAP > Brief > Dictionary.

Planned paths assume the structure in `docs/IMPLEMENTATION_PLAN.md`. Q30 colours and Q31 key are recorded in config.

---

## Study 1

| ID | SAP / brief section | Requirement | Planned function / script | Planned output file | Status |
|----|---------------------|-------------|---------------------------|---------------------|--------|
| R1.1 | SAP §1 | α = .05; 95% CIs | `config/config.R` (`SAP$alpha`, `SAP$ci_level`) | config + session log | implemented (params only; no inferential tables yet) |
| R1.2 | SAP §1; Brief §1 | No across-hypothesis multiplicity | `run_study1_analyse` (no extra p.adjust) | analysis log | implemented (Kaggle R 4.4.0 H1-H3) |
| R1.3 | SAP §1; Brief §1 | Holm only on named follow-up families | `holm_adjust` / `h2_followups` | `study1_table_h2_followups` | implemented (Kaggle R 4.4.0 H1-H3) |
| R1.4 | SAP §1; Brief §1 | No outcome-based exclusions; report N | `R/study1_clean.R` | prepare log | implemented (Kaggle R 4.4.0: N=50, no outcome drop) |
| R1.5 | SAP §1 | Participant-level summaries for inference | `R/study1_summarise.R` | `output/tables/study1_participant_summaries_SYNTHETIC.csv` | implemented (Kaggle R 4.4.0 prepare) |
| R1.6 | SAP §1; Brief §1, §15 | Fallbacks only if assumptions violated; no mixed models | `R/assumptions.R`; `R/models_npar.R` | analysis log | not implemented |
| R1.7 | SAP §6 | 13-step analysis/reporting order | `scripts/run_study1.R` | full output tree | not implemented |
| R1.8 | Brief §3 | QA/mapping before deriving analysis variables | `R/study1_load.R` | `output/logs/study1_log_data_qc_SYNTHETIC.txt` | implemented (load/QC; Kaggle synthetic) |
| R1.9 | Brief §9; Q7 | Document fallback **before** looking at Condition significance | `write_q7_client_report` then parametric tests | Q7 report + analysis log | implemented (Kaggle: report first; fallback not applied) |
| R1.10 | Brief §9 | No invented numeric ANOVA/t fallback cutoff | `R/study1_diagnostics.R` (Q7 no auto-switch) | prepare log | implemented (Kaggle: no numeric cutoff; fallback not applied) |
| R1.11 | Dict §1 | No questionnaire predictors | loaders omit those fields | — | not implemented |
| R1.12 | Dict §1; Q2 | Exclusions before summaries | `apply_study1_primary_population`; Q31 apply | prepare log | implemented (code). Last Kaggle run was audit-only; re-verify after this update. |
| R1.13 | Dict §12; Q3/Q4 | Stop/flag on ambiguity | `gate_pairwise_mapping_q3`; `gate_incomplete_cells_q4` | prepare log | implemented (Kaggle R 4.4.0 prepare) |
| R1.14 | SAP §3.4 | Primary N = 50 | `apply_study1_primary_population` | prepare log | implemented (Kaggle R 4.4.0 prepare) |
| R1.15 | SAP §3.4 | Document condition order; do not model it | `R/recode_factors.R` (G1/G2 as design note) | analysis log | not implemented |
| R1.16 | SAP §1; Q2; Q31 | Primary = all 50; Q31 key applied | `apply_study1_q31_dedup` | prepare log | implemented (code, 22 Sep). Key + UTC then Event Index. Kaggle re-run pending. |
| R1.17 | SAP §3.3.1; Brief §8.1 | RT drop missing / non-positive / documented technical error only | `valid_rt_rows` | prepare log `n_rt_dropped` | implemented (Kaggle: n_rt_dropped=0; n_valid_rt_trials=1200) |
| R1.18 | Dict §9; Q2 | No outcome-based trial drops | `apply_study1_primary_population` | prepare log | implemented (Kaggle R 4.4.0 prepare) |
| R1.19 | Dict §3 | Map Public ID → participant_id after reconciliation | `R/dictionary_map.R` | — | not implemented |
| R1.20 | Dict §3 | Retain external_session_id | `R/dictionary_map.R` | — | not implemented |
| R1.21 | Dict v2 §3; Q6 | Public ID → participant_id; anon on outputs | `apply_study1_analysis_id` | QC log | implemented (Kaggle v3: 50 IDs) |
| R1.22 | Dict §10; Q5 | Disc Object Name = Response | `filter_object_name` | QC log | implemented (Kaggle v3: dropped 0) |
| R1.23 | Dict §10 | Pairwise row filter + exclude confidence/comment | `R/select_trials.R` | QA log | not implemented |
| R1.24 | Dict §10 | Vision row filter | `R/select_trials.R` | QA log | not implemented |
| R1.25 | Dict §9 | 24 / 12 / 4 trials per included participant | `R/study1_load.R` QC | `output/logs/study1_log_data_qc_SYNTHETIC.txt` | implemented (synthetic QC: 50 × 24/12/4) |
| R1.26 | Dict §11 | No metadata predictors | mappers drop unused fields from analysis tables | — | not implemented |
| R1.27 | Dict §4.1 | baseline→Original; sa→Optimized | `R/study1_load.R` `recode_condition_study1` | QC condition counts | implemented (Kaggle: 600/600) |
| R1.28 | Dict §4.1 | colormap_raw traceability only | `map_study1_discrimination` keeps `colormap_raw` | — | implemented (column kept; not used as a factor) |
| R1.29 | Dict §4.1 | K ∈ {5,10,20,30} | `assert_allowed_values` in `run_study1_load` | QC K counts | implemented (Kaggle: 300 each) |
| R1.30 | SAP §3.1, §3.4; Brief §5.1 | variation = configuration instance, not Difficulty | mapped as `configuration_instance` | — | implemented (mapping only) |
| R1.31 | Dict §4.1 | response_count, correct_answer numeric | `map_study1_discrimination` | — | implemented |
| R1.32 | Dict §4.1, §9 | accuracy = (response==answer); flag Correct mismatch | `map_study1_discrimination` | QC `disc_correct_mismatch_rows` | implemented (Kaggle count 0) |
| R1.33 | Dict §4.1 | signed_error, absolute_error | `map_study1_discrimination` | trial columns only | implemented (derived; no AE tests yet) |
| R1.34 | Dict §4.1 | reaction_time_ms from Reaction Time | `map_study1_discrimination` | QC RT missing/nonpositive | implemented (mapped; RT preprocess / tests not done) |
| R1.35 | SAP §3.1; Brief §5.1 | Accuracy per participant × Condition × K, average 3 instances | `summarise_study1_participants` | summary CSV | implemented (Kaggle R 4.4.0 prepare) |
| R1.36 | SAP §3.4; Brief §5.1 | Keep K=30; palette-capacity caveat | table notes | accuracy tables | implemented (Kaggle R 4.4.0 H1-H3; note on tables) |
| R1.37 | Dict §4.2 | 12 pairwise task trials | `run_study1_load` QC | QC log | implemented (synthetic: 50 × 12) |
| R1.38 | Brief §4; Dict §4.2 | Exactly one Optimized + one Original image | `map_study1_pairwise` (`mapping_fail`) | QC `pairwise_mapping_fail_rows` | implemented (flag; Kaggle count 0) |
| R1.39 | Brief §2, §4 | Do not use semantic Response label as condition | `map_study1_pairwise` | toy test in Chunk C | implemented (Kaggle: mapping-study1 passed) |
| R1.40 | Brief §4 | preferred_side from response vs left/right_option | `map_study1_pairwise` | toy test in Chunk C | implemented (Kaggle: mapping-study1 passed) |
| R1.41 | Brief §4; Dict §4.2 | optimized_side from `*_optimized*` filenames | `map_study1_pairwise` | toy test in Chunk C | implemented (Kaggle: mapping-study1 passed) |
| R1.42 | Brief §4 | chose_optimized = sides equal | `map_study1_pairwise` | trial column + summary proportion | implemented (Kaggle: 50 pairwise proportions; no Gorilla ID in header) |
| R1.43 | Brief §4; Q3 | Failed rows: flag and stop | `gate_pairwise_mapping_q3` | prepare log | implemented (Kaggle R 4.4.0 prepare) |
| R1.44 | Brief §4 | Persist QA record of derivation | QC log fields for mapping_fail | `output/logs/study1_log_data_qc_SYNTHETIC.txt` | partial (counts in QC log; no separate pairwise_qa file) |
| R1.45 | SAP §3.4 | Fixed pairwise order = limitation only | H3 table notes | `study1_table_h3` | implemented (Kaggle R 4.4.0 H1-H3; note on tables) |
| R1.46 | Dict §4.2 | Pairwise RT descriptive only | `pairwise_rt_desc` | `study1_table_pairwise_rt_desc` | implemented (Kaggle R 4.4.0 H1-H3) |
| R1.47 | SAP §3.1; Brief §5.1 | 2×4 RM ANOVA Condition × K | `fit_study1_rm_anova` | `study1_table_h1_h2_anova` | implemented (Kaggle R 4.4.0 H1-H3) |
| R1.48 | SAP §3.1 | H1 = Condition main effect | `anova_effect_report` | same | implemented (Kaggle R 4.4.0 H1-H3) |
| R1.49 | SAP §3.1 | H2 = Condition × K | `anova_effect_report` | same | implemented (Kaggle R 4.4.0 H1-H3) |
| R1.50 | SAP §3.1 | If interaction sig: paired t at 4 K, Holm | `h2_followups` | `study1_table_h2_followups` | implemented (Kaggle R 4.4.0 H1-H3) |
| R1.51 | SAP §3.1; Brief §5.1 | Zero-variance K: no inferential follow-up/d; Holm on rest | `h2_followups` | follow-up table + log | implemented (Kaggle R 4.4.0 H1-H3) |
| R1.52 | SAP §3.1; Q8 | Diagnostic accuracy histograms (8 cells + H1 + H2 diffs) | `save_study1_q8_histograms` | `output/figures/study1_diag_*_SYNTHETIC.png` | implemented (Kaggle R 4.4.0 prepare) |
| R1.53 | SAP §3.1 | Mauchly; Greenhouse–Geisser if violated | `sphericity_choice` | ANOVA table + log | implemented (Kaggle R 4.4.0 H1-H3) |
| R1.54 | SAP §3.1; Q7 | Fallback if severe non-normality | locked H1 Wilcoxon / H2 Friedman / H3 Wilcoxon | H1/H2/H3 npar tables | implemented (Kaggle R 4.4.0 locked path) |
| R1.55 | SAP §3.1 | Fallback H1: paired Wilcoxon overall Orig vs Opt | `paired_wilcoxon_opt_minus_orig` | `study1_table_h1_wilcoxon` | implemented (Kaggle R 4.4.0 locked path) |
| R1.56 | SAP §3.1; Brief §9 | Fallback H2: Friedman on Opt−Orig diffs; pairwise Wilcoxon on diffs, Holm ×6 | `friedman_h2_on_k_diffs`; `h2_friedman_followups` | `study1_table_h2_friedman` | implemented (Kaggle R 4.4.0 locked path; follow-ups off when Friedman ns) |
| R1.57 | SAP §3.1 | Report H1 F, df, p, partial η², 95% CI | `partial_eta_table` + export | `study1_table_h1_h2_anova` | implemented (Kaggle R 4.4.0 H1-H3) |
| R1.58 | SAP §3.1 | Report H2 same; if sig, mean diff, CI, t, df, d, Holm p | `h2_followups` | follow-up table | implemented (Kaggle R 4.4.0 H1-H3) |
| R1.59 | SAP §3.1 | Mean and SD accuracy Original vs Optimized | `write_study1_tables` | `study1_table_accuracy_descriptives` | implemented (Kaggle R 4.4.0 H1-H3) |
| R1.60 | SAP §3.1 | Fallback H1: V, p, rank-biserial, 95% CI | `extract_rank_biserial` | `study1_table_h1_wilcoxon` | implemented (Kaggle R 4.4.0 locked path) |
| R1.61 | SAP §3.1 | Fallback H2: Friedman, df, p, Kendall’s W (+ pairwise if sig) | `effectsize::kendalls_w` | `study1_table_h2_friedman` | implemented (Kaggle R 4.4.0 locked path) |
| R1.62 | SAP §3.2; Brief §5.2 | Participant Optimized-choice proportion / 12 | `pairwise_proportion` | summary CSV | implemented (Kaggle R 4.4.0 prepare) |
| R1.63 | SAP §3.2 | Two-sided one-sample t vs 0.50 | `onesample_t_vs` | `study1_table_h3` | implemented (Kaggle R 4.4.0 H1-H3) |
| R1.64 | SAP §3.2 | Histogram of proportions | `save_study1_assumption_hists` | `study1_diag_h3_prop_SYNTHETIC.png` | implemented (Kaggle R 4.4.0 H1-H3) |
| R1.65 | SAP §3.2 | Fallback one-sample Wilcoxon vs 0.50 if very skewed | `onesample_wilcoxon_vs` | `study1_table_h3` | implemented (Kaggle R 4.4.0 locked path) |
| R1.66 | SAP §3.2 | Report mean, SD, 95% CI, t, df, p, d | `write_study1_tables` | `study1_table_h3` | implemented (Kaggle R 4.4.0 H1-H3) |
| R1.67 | SAP §3.2 | Fallback V, p, rank-biserial, 95% CI | `write_study1_tables` | `study1_table_h3` | implemented (Kaggle R 4.4.0 locked path) |
| R1.68 | SAP §3.3.1 | All valid trials regardless of accuracy | `valid_rt_rows` (no accuracy filter) | prepare log | implemented (Kaggle: n_rt_dropped=0; n_valid_rt_trials=1200) |
| R1.69 | SAP §3.3.1 | Only specified RT exclusions | `R/rt_preprocess.R` | RT QC | not implemented |
| R1.70 | SAP §3.3.1; Q12 | Trial-level e1071 type-2 skewness; log if > 1 | `trial_rt_skewness` | prepare log + summary scale column | implemented (Kaggle R 4.4.0 prepare) |
| R1.71 | Brief §8.1; Q12 | `log()` natural log if trial skew > 1 | `rt_analysis_scale` | summary `rt_analysis_scale` | implemented (Kaggle R 4.4.0 prepare) |
| R1.72 | SAP §3.3.1 | Mean RT Orig vs Opt averaging K; paired t | `paired_t_opt_minus_orig` | `study1_table_rt` | implemented (Kaggle R 4.4.0 H1-H3) |
| R1.73 | SAP §3.3.1 | Pairwise RT descriptive | `pairwise_rt_desc` | `study1_table_pairwise_rt_desc` | implemented (Kaggle R 4.4.0 H1-H3) |
| R1.74 | SAP §3.3.1 | Histogram of RT differences; Wilcoxon if severely non-normal | `save_study1_assumption_hists`; Q7 no switch | `study1_diag_rt_diff_SYNTHETIC.png` | implemented (Kaggle: hist written; Wilcoxon not applied) |
| R1.75 | SAP §3.3.1 | Report ms descriptives; inferential on analysis scale | `write_study1_tables` | `study1_table_rt` + descriptives | implemented (Kaggle R 4.4.0 H1-H3) |
| R1.76 | Brief §8.1 | Geometric-mean ratio — pending Q15 | `R/rt_preprocess.R` (optional) | RT table | not implemented |
| R1.77 | SAP §3.3.1 | RT Wilcoxon reporting | `R/export_tables.R` | RT fallback table | not implemented |
| R1.78 | SAP §3.3.2; Brief §8.2 | Mean AE Orig vs Opt averaging K; paired t | `paired_t_opt_minus_orig` | `study1_table_ae` | implemented (Kaggle R 4.4.0 H1-H3) |
| R1.79 | SAP §3.3.2 | AE difference histogram; Wilcoxon if extremely skewed | `save_study1_assumption_hists`; Q7 no switch | `study1_diag_ae_diff_SYNTHETIC.png` | implemented (Kaggle: hist written; Wilcoxon not applied) |
| R1.80 | SAP §3.3.2 | AE reporting + fallback | `write_study1_tables` | `study1_table_ae` | implemented (Kaggle R 4.4.0 H1-H3; fallback not applied) |
| R1.81 | Brief §8.2 | Descriptive AE by Condition × K (CI if template) | `cell_mean_ci` | `study1_table_ae_by_k_desc` | implemented (Kaggle R 4.4.0 H1-H3) |
| R1.82 | SAP §3.3.3; Brief §8.3 | Signed error mean/SD by condition; no test | `write_study1_tables` | `study1_table_signed_error` | implemented (Kaggle R 4.4.0 H1-H3) |
| R1.83 | SAP §3.4; Brief §11 | Repeat primary accuracy + pairwise on N=48 subset | `run_h1_h2_h3` on score==4 | `study1_table_vision_sensitivity` | implemented (Kaggle R 4.4.0 H1-H3) |
| R1.84 | Dict §7 | Vision items/keys/score 0–4 | `map_study1_vision`; QC score by private ID | QC log | partial (item map + QC count; no analysis population) |
| R1.85 | Dict §7; Q1 | vision_subset_flag score==4; not a primary exclusion | `map_study1_vision` + QC | QC log | implemented (Kaggle v3: 48/2; subset not applied) |
| R1.86 | Brief §9.1 | Wilcoxon zero convention (Q10) | `nonzero_paired_diffs` | analysis log `n_nonzero` | implemented (Kaggle R 4.4.0 locked path) |
| R1.87 | Brief §9.1, §10 | Document ES package/function/convention (Q9) | `log_effectsize_versions` | analysis log | implemented (Kaggle R 4.4.0 H1-H3) |
| R1.88 | SAP §3; Brief §14 | Publication-ready summary tables | `write_table_csv_docx` | `output/tables/study1_table_*` | implemented (Kaggle R 4.4.0 H1-H3) |
| R1.89 | SAP §6; Brief §14 | Figures (SAP-specified = histograms; others Q13) | `write_study1_figures` | `study1_fig_*` PNG+PDF | implemented (Kaggle: 4 fig png+pdf; Okabe-Ito placeholder) |
| R1.90 | Brief §14 | Reusable exports (Q14) | export helpers | `output/` | not implemented |
| R1.91 | Brief §12, §14 | Regenerating pipeline; renv; README; analysis log | `scripts/run_study1.R`; `renv.lock` | `output/logs/study1_analysis_log`; README | not implemented |
| R1.92 | Brief §12, §16 | Record SAP Final / 21 Sep 2026 / R 4.6.1 | README; log | those files | not implemented |
| R1.93 | Brief §13 | No real-data hard-coding | `config/analysis.yml` | — | not implemented |
| R1.94 | Brief §15–16 | Guardrails + acceptance checklist | README checklist | README | not implemented |

---

## Study 2

Study 2 “uses the same … as Study 1 unless otherwise stated” (SAP §4). Rows below are the **distinct** Study 2 requirements plus the explicit inheritances that must still be traced.

| ID | SAP / brief section | Requirement | Planned function / script | Planned output file | Status |
|----|---------------------|-------------|---------------------------|---------------------|--------|
| R2.1 | SAP §4 | Same analytical approach as Study 1 unless stated | `run_study2.R` (load only this chunk) | `output/logs/study2_log_data_qc` | load coded; prepare/tests not implemented |
| R2.2 | SAP §4.4; Brief §6.1 | Exclude researcher session; primary N = 50 | `drop_study2_researcher` (real ID pending Q18) | study2 QC log | implemented in code (Kaggle: NOT EXECUTED) |
| R2.3 | SAP §4.1; Brief §6.2 | 2×4 RM ANOVA as Study 1 | `R/models_anova.R` | `output/tables/study2_h1_h2_anova` | not implemented |
| R2.4 | SAP §4.1; Brief §6.2 | Average accuracy across 3 Difficulty levels within Condition × K | `R/summarise_participants.R` | participant summaries | not implemented |
| R2.5 | SAP §4.1; Brief §6.2, §15 | Do not add standalone Difficulty or Condition × Difficulty models | orchestrator (no extra models) | — | not implemented |
| R2.6 | Dict §5.1 | variation → difficulty_index 1,2,3; no outcome-inferred labels | `R/recode_factors.R` | — | not implemented |
| R2.7 | Dict §5.1 | colormap distinctipy / distinctipysa traceability only | QA only | — | not implemented |
| R2.8 | SAP §4.2; Brief §6.3 | H3 same as Study 1 after pairwise QA | shared pairwise + t-test | `output/tables/study2_h3` | not implemented |
| R2.9 | Dict §5.2 | Reconstruct preferred_side; validate raw optimized_side vs filenames | `R/derive_pairwise.R` | `output/logs/study2_pairwise_qa` | not implemented |
| R2.10 | Dict §10 | Task names: Discrimination Task G1/G2 (Clone); Pairwise Comparison Task2 (Clone); Vision Check | `filter_task_name` + `load_study2_role` | study2 QC log | implemented in code (Kaggle: NOT EXECUTED) |
| R2.11 | Dict §9 | 24 disc + 12 pairwise + 4 vision after exclusion | `R/validate_structure.R` | structure log | not implemented |
| R2.12 | SAP §4.3.1–4.3.3 | RT, AE, signed error as Study 1 | shared secondary helpers | `output/tables/study2_rt`, `_absolute_error`, `_signed_error` | not implemented |
| R2.13 | SAP §4.4 | Vision sensitivity N = 43; primary remains 50 | `R/sensitivity_vision.R` | `output/tables/study2_vision_sensitivity` | not implemented |
| R2.14 | SAP §4.4 | Condition order: same rules as Study 1 (document only) | analysis log | — | not implemented |
| R2.15 | SAP §4.1 | Same assumptions, fallbacks, follow-ups, reporting as Study 1 | shared assumption/model helpers | study2 tables + log | not implemented |
| R2.16 | README / data | Drop blank housekeeping row | `drop_blank_rows` in `load_study2_role` | study2 QC log | implemented in code (Kaggle: NOT EXECUTED) |
| R2.17 | Combined raw file vs Dict §8 | Map from single `study2_tasks_*.csv` | `resolve_study2_file` + task split | study2 QC log | implemented in code (Kaggle: NOT EXECUTED) |
| R2.18 | Brief §11, §14 | Same deliverable classes as Study 1 for H1–H3 + secondaries + sensitivity | `scripts/run_study2.R` | `output/{tables,figures,logs}/study2_*` | not implemented |
| R2.19 | SAP §4.1 inherit R1.50–R1.61 | H2 follow-ups / zero-variance / Friedman logic | shared | study2 follow-up tables | not implemented |
| R2.20 | SAP §4.2 inherit R1.62–R1.67 | H3 t / Wilcoxon reporting | shared | study2 H3 tables | not implemented |
| R2.21 | Brief §8.2 | Descriptive AE by Condition × K | shared | `output/tables/study2_ae_by_K_desc` | not implemented |
| R2.22 | Dict §5.2 | Pairwise K/difficulty from filename for QA only; H3 = overall proportion | `R/derive_pairwise.R` | QA log | not implemented |
| R2.23 | SAP §4.4 | Stimulus-generalization caveat | reporting note | log | not implemented |
| R2.24 | Brief §12 | Same renv / R 4.6.1 / analysis-log fields | shared log | study2 log | not implemented |
| R2.25 | Brief §1 | α = .05 per H1–H3; Holm only on named families | shared | — | not implemented |
| R2.26 | Dict §7 | Same vision items/keys 12,16,29,26 | `R/derive_vision.R` | vision summary | not implemented |
| R2.27 | Q18 | Real researcher ID — NOT SPECIFIED | `SAP$study2_researcher_ids_real` | config | coded as NA; real load `stop()` |
| R2.28 | Brief §16 | Acceptance checklist items that apply to Study 2 | README | README | not implemented |

---

## Study 3

| ID | SAP / brief section | Requirement | Planned function / script | Planned output file | Status |
|----|---------------------|-------------|---------------------------|---------------------|--------|
| R3.1 | SAP §5.1; Brief §7.1 | Accuracy in each Condition × Background cell, averaging K and Difficulty | `R/summarise_participants.R` | `output/intermediate/study3_participant_summaries` | not implemented |
| R3.2 | SAP §5.1 | 2×2 RM ANOVA Condition × Background | `R/models_anova.R` | `output/tables/study3_h4_h5_anova` | not implemented |
| R3.3 | SAP §5.1 | H4 = Condition main effect | same | same | not implemented |
| R3.4 | SAP §5.1 | H5 = Condition × Background interaction | same | same | not implemented |
| R3.5 | SAP §5.1; Brief §7.1 | If interaction sig: paired Orig vs Opt within White and within Black; Holm ×2 | `R/models_ttest.R` | `output/tables/study3_h5_followups` | not implemented |
| R3.6 | SAP §5.1 | Histograms for severe skew / extreme outliers; no sphericity correction (2-level factors) | `R/assumptions.R` | `output/figures/study3_accuracy_histograms` | not implemented |
| R3.7 | SAP §5.1 | Fallback if severe non-normality: H4 paired Wilcoxon overall Orig vs Opt; H5 Wilcoxon on (Opt−Orig | White) vs (Opt−Orig | Black) | `R/models_npar.R` | fallback tables | not implemented |
| R3.8 | SAP §5.1 | If H5 Wilcoxon sig: Orig vs Opt within each background, Wilcoxon, Holm ×2 | `R/models_npar.R` | fallback follow-ups | not implemented |
| R3.9 | SAP §5.1 | Report mean/SD accuracy each Condition × Background; H4/H5 F, df, p, partial η², 95% CI; follow-up mean diff, CI, t, df, d, Holm p | `R/export_tables.R` | ANOVA + follow-up tables | not implemented |
| R3.10 | SAP §5.1 | Fallback reporting V, p, rank-biserial, 95% CI | `R/export_tables.R` | npar tables | not implemented |
| R3.11 | SAP §5.2; Brief §7.2 | H6: overall Optimized proportion over 18 trials; two-sided one-sample t vs 0.50 | `R/models_ttest.R` | `output/tables/study3_h6` | not implemented |
| R3.12 | SAP §5.2; Brief §7.2 | H7: proportion White vs Black; paired t; report White − Black | `R/models_ttest.R` | `output/tables/study3_h7` | not implemented |
| R3.13 | SAP §5.2 | Histograms of proportions and paired differences | `R/assumptions.R` | figures | not implemented |
| R3.14 | SAP §5.2 | Fallback: one-sample Wilcoxon H6; paired Wilcoxon H7 if very skewed | `R/models_npar.R` | fallback tables | not implemented |
| R3.15 | SAP §5.2 | H6/H7 reporting (mean, SD, CI, t, df, p, d; fallback V etc.) | `R/export_tables.R` | H6/H7 tables | not implemented |
| R3.16 | SAP §5.3.1 | Same RT preprocess / log rule as Study 1 | `R/rt_preprocess.R` | — | not implemented |
| R3.17 | SAP §5.3.1; Brief §8.1 | Mean RT per Condition × Background; 2×2 RM ANOVA; same assumption/fallback spirit as S3 accuracy | `R/models_anova.R` | `output/tables/study3_rt_anova` | not implemented |
| R3.18 | SAP §5.3.1 | If Condition × Background sig: Orig vs Opt within each background, paired t, Holm ×2 | `R/models_ttest.R` | `output/tables/study3_rt_followups` | not implemented |
| R3.19 | SAP §5.3.1 | Report Condition, Background, and interaction: F, df, p, partial η², 95% CI; ms descriptives if log inference | `R/export_tables.R` | RT tables | not implemented |
| R3.20 | SAP §5.3.2; Brief §8.2 | AE as Study 1; optional descriptive by White/Black | shared + extra desc | `output/tables/study3_absolute_error` | not implemented |
| R3.21 | SAP §5.3.3 | Signed error as Study 1 (descriptive) | shared | `output/tables/study3_signed_error` | not implemented |
| R3.22 | SAP §5.4; Brief §7.1 | Do not enter condition_order / block_order as predictors; document | analysis log | log | not implemented |
| R3.23 | SAP §5.4; Brief §11 | Primary N = 50; vision subset N = 46; repeat primary accuracy + pairwise | `R/sensitivity_vision.R` | `output/tables/study3_vision_sensitivity` | not implemented |
| R3.24 | Dict §6.1 | Recode C1_original_distinctipy → Original; C2_background_aware_optimized → Optimized | `R/recode_factors.R` | — | not implemented |
| R3.25 | Dict §6.1 | background white/black; K 10/20/30; difficulty 1–3 / easy–medium–hard | `R/recode_factors.R` | — | not implemented |
| R3.26 | Dict §6.2 | Pairwise: Response is Left/Right; chose_optimized vs validated optimized_side; filenames `*_opt_*` / `*_orig_*` | `R/derive_pairwise.R` | pairwise QA | not implemented |
| R3.27 | Dict §9–10 | 36 disc + 18 pairwise + 4 vision; task-name filters; Object Name issue Q20 | `R/select_trials.R`; `R/validate_structure.R` | structure log | not implemented |
| R3.28 | README | Drop fully blank terminal row | `R/load_data.R` | — | not implemented |
| R3.29 | Dict §8 vs combined file | Map from `study3_tasks_*.csv` | `R/load_data.R` | — | not implemented |
| R3.30 | Q19 | condition_order / block_order token map | `R/recode_factors.R` | QA log | not implemented |
| R3.31 | Dict §6.1 | participant_group / scale_factor / layout_id = design/QA only | QA tables | — | not implemented |
| R3.32 | Dict §11 | Do not add provenance/palette metrics as predictors | mappers | — | not implemented |
| R3.33 | Brief §12–14 | Same reproducibility / deliverable classes | `scripts/run_study3.R` | study3 output tree | not implemented |
| R3.34 | SAP §6 | Same overall reporting order | orchestrator | — | not implemented |
| R3.35 | Brief §1 | α = .05 per H4–H7; Holm only on named families (H5 follow-up ×2; RT interaction follow-up ×2) | shared | — | not implemented |
| R3.36 | SAP §5.4 | Stimulus-generalization caveat | reporting note | log | not implemented |

---

## Shared / project-level (not study-specific hypotheses)

| ID | Section | Requirement | Planned function / script | Planned output | Status |
|----|---------|-------------|---------------------------|----------------|--------|
| P1 | Brief §2, §12 | Frozen SAP Final; 21 September 2026; R 4.6.1; renv | README; `renv.lock` | those files | not implemented |
| P2 | Brief §13 | Config switch synthetic vs real | `config/config.R` (`DATA_SOURCE`) | — | partial (code written; **not run**) |
| P3 | Brief §12 | Analysis log fields | `R/analysis_log.R` | `output/logs/*` | not implemented |
| P4 | Phase 1 brief | `data/real/` empty, gitignored | `.gitignore` | done in Phase 1 | **setup only** |
| P5 | Phase 1 brief | Tests on synthetic structure | `tests/testthat/*` | test output | not implemented |

---

**Counts:** Study 1 = 94 (R1.1–R1.94); Study 2 = 28 (R2.1–R2.28); Study 3 = 36 (R3.1–R3.36); plus 5 project rows (P1–P5).  
Study 1 locked Q7 path (H1 Wilcoxon / H2 Friedman / H3 Wilcoxon; RT/AE t) is **verified** on Kaggle R 4.4.0 (v3 synthetic, 22 Sep 2026). Helper tests 103 passed, 0 failed. Numbers are pipeline tests, not findings.
