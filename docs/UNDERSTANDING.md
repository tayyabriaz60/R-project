# Understanding document — Phase 1 (read-only)

**Date of this audit:** 21 September 2026  
**Source-of-truth order used here:** frozen SAP > Implementation Brief > Data Dictionary.  
**R status:** R is **not installed** on this machine. No R code was executed. All statistical claims below are readings of the documents, not test results.  
**Data used:** synthetic files only (`data/synthetic/`). Real data were not available.

**Rules file (found 22 September 2026):** the user placed `.cursor/rules/cursor_rules.md`. It is now also installed as `.cursor/rules/r-analysis.mdc` with frontmatter `alwaysApply: true` (body unchanged). Official question format is **Where / Issue / Options / Impact**. Official architecture is in Rules §4 (`run_all.R`, `config/config.R`, `R/utils_*.R`, `docs/DECISIONS_LOG.md`, `output/models/`). Hierarchy: SAP > Brief > Dictionary > this rules file.

---

## 0. What each client document actually is

| File | What it is | Studies | Verdict |
|------|------------|---------|---------|
| `SAP Categorical Colormap Optimization.docx` | **The frozen Statistical Analysis Plan itself.** Title in the file: “Categorical Colormap Optimization: Statistical Analysis Plan”. Author (core properties): Fatimah Alqahtani. Date in body: 21 September 2026. 9 pages (page numbers 1–9 appear as standalone Normal paragraphs). Covers general principles, RQ1–RQ4 / H1–H7, Study 1–3 methods, fallbacks, reporting, analysis order. | 1, 2, 3 | **Not** a colormap-only technical note. This **is** the methodological SAP. |
| `Final_Analysis_Implementation_Brief_Tayyab_FINAL.docx` | Implementation / QC companion for the R analyst. Title: “Final Analysis Implementation Brief”. Explicitly states it does **not** replace the SAP. | 1, 2, 3 | Companion, not the SAP. |
| `Data_Dictionary_Column_Structure_Studies_1_3_FINAL.docx` | Raw Gorilla column → canonical variable map, synthetic file structures, structural checks, row-selection rules. Document control table: SAP version Final; freeze 21 September 2026; R 4.6.1 (2026-06-24). | 1, 2, 3 | Column/structure source, not the SAP. |

**SAP completeness:** The SAP present in the zip/handoff is a complete 9-section analysis plan for all three studies. It does **not** contain a separate “reporting plan” with numbered tables/figures, colour specs, or exclusion SOPs. Those gaps are listed in §7 and in `QUESTIONS_FOR_CLIENT.md`. They are missing **content**, not a missing SAP file.

**Authority conflict (documents vs this audit’s order):**

- Brief cover / §1: “The frozen SAP is the governing methodological document.”
- Dictionary §1: “The Final Analysis Implementation Brief remains the governing source for analysis decisions, diagnostics, fallbacks, effect sizes, multiplicity, and reporting.”

This audit follows **SAP > Brief > Dictionary**, as instructed, and flags the dictionary sentence as an inconsistency.

---

## 1. File inventory

### 1.1 Client originals (copied, not modified, in `docs/spec/`)

| File | Size (bytes) | Role | Studies |
|------|-------------:|------|---------|
| `Data_Dictionary_Column_Structure_Studies_1_3_FINAL.docx` | 46672 | Data dictionary | 1–3 |
| `Final_Analysis_Implementation_Brief_Tayyab_FINAL.docx` | 45709 | Implementation brief | 1–3 |
| `SAP Categorical Colormap Optimization.docx` | 26832 | Frozen SAP | 1–3 |
| `Synthetic_Data_Tayyab_FINAL.zip` | 299873 | Synthetic archive (also extracted) | 1–3 |

The same three `.docx` files remain in the project root, untouched.

### 1.2 Converted / working copies (not source of truth)

| File | Role |
|------|------|
| `docs/Data_Dictionary_Column_Structure_Studies_1_3_FINAL.md` | pandoc GFM conversion |
| `docs/Final_Analysis_Implementation_Brief_Tayyab_FINAL.md` | pandoc GFM conversion; two 1×1 tables re-extracted from the `.docx` |
| `docs/SAP_Categorical_Colormap_Optimization.md` | pandoc GFM conversion |
| `docs/_docx_plaintext/*_PLAINTEXT.txt` | python-docx paragraph/table dump used for conversion verification |
| `docs/_conversion_verification.json` | machine-readable conversion counts |
| `docs/_synthetic_audit.txt` | Python profiling evidence |
| `docs/_synthetic_profile.json` | full column-level JSON profile |

### 1.3 Synthetic data (extracted, not modified)

| File | Size (bytes) | What it is | Study |
|------|-------------:|------------|-------|
| `data/synthetic/README_SYNTHETIC_DATA.md` | 3979 | Synthetic generation notes; **not** a SAP | 1–3 |
| `data/synthetic/SYNTHETIC_MANIFEST.csv` | 900 | File list / expected row counts | 1–3 |
| `data/synthetic/Study1/study1_discrimination_G1_SYNTHETIC.csv` | 276861 | Raw-style Gorilla discrimination, group G1 | 1 |
| `data/synthetic/Study1/study1_discrimination_G2_SYNTHETIC.csv` | 276883 | Raw-style Gorilla discrimination, group G2 | 1 |
| `data/synthetic/Study1/study1_pairwise_SYNTHETIC.csv` | 313453 | Raw-style Gorilla pairwise (mapping mismatch baked in) | 1 |
| `data/synthetic/Study1/study1_vision_SYNTHETIC.csv` | 79217 | Raw-style Gorilla vision check | 1 |
| `data/synthetic/Study2/study2_tasks_SYNTHETIC.csv` | 1014942 | Combined raw-style export (disc + pairwise + vision + researcher + 1 blank row) | 2 |
| `data/synthetic/Study3/study3_tasks_SYNTHETIC.csv` | 2085078 | Combined raw-style export (disc + pairwise + vision + 1 blank row) | 3 |

**Not present (Dictionary §8 recommended names):** `study1_discrimination.csv`, `study1_pairwise.csv`, `study1_vision.csv`, and the analogous Study 2/3 canonical files. The synthetic package is **raw Gorilla-header** data, which the README explicitly states.

`data/real/` is empty and gitignored except `.gitkeep`.

---

## 2. Per-study design summary (all three studies)

### 2.1 Study 1

| Item | Specified content | Source |
|------|-------------------|--------|
| Design | Within-subject. Condition = Original vs Optimized. K = 5, 10, 20, 30. Three **configuration instances** (variations 1/2/3) within each Condition × K cell. **Not** Difficulty. Condition order counterbalanced equally; not a predictor. | SAP §3.1, §3.4; Brief §5.1; Dict §4 |
| Between-subject structure in data | Two Gorilla task files / groups: Discrimination Task G1 and G2 (`randomiser-m119` = G1/G2). SAP treats this as counterbalancing, not a factor. | Dict §2, §10; synthetic data |
| Unit of analysis | Participant-level summary measures. Primary N = 50. | SAP §1, §3.1, §3.4 |
| Discrimination trial structure | 24 analysed trials / participant = 2 Condition × 4 K × 3 configuration instances. | Dict §9 |
| Pairwise trial structure | 12 analysed task trials / participant. Trial order fixed across participants (limitation only). | SAP §3.2, §3.4; Dict §9 |
| Vision | 4 items; keys 12, 16, 29, 26. Used only for sensitivity (subset N = 48). | SAP §3.4; Dict §7; Brief §11 |
| Outcomes | **Primary accuracy:** exact class-count (response == correct_answer). **Primary pairwise:** chose Optimized (clearer category separation). **Secondary:** RT (inferential Orig vs Opt, pairwise RT descriptive), Absolute Error (inferential Orig vs Opt), Signed Error (descriptive). | SAP §3 |
| Participant-level summaries required | (a) accuracy in each Condition × K cell, averaging 3 instances; (b) overall Orig vs Opt accuracy (for H1 / Wilcoxon fallback); (c) Optimized−Original accuracy difference at each K (H2 fallback / follow-up); (d) Optimized-choice proportion over 12 pairwise trials; (e) mean RT Orig vs Opt, averaging K, on raw or log scale per rule; (f) mean AE Orig vs Opt, averaging K; (g) mean signed error Orig vs Opt; (h) optional descriptive AE by Condition × K (Brief). | SAP §3; Brief §5, §8 |

### 2.2 Study 2

| Item | Specified content | Source |
|------|-------------------|--------|
| Design | Same Condition × K within-subject framework as Study 1. Easy / Medium / Hard **were implemented**. Difficulty is **not** a standalone primary factor. Primary accuracy averages across the 3 Difficulty levels within each Condition × K cell. | SAP §4.1; Brief §6.2 |
| Unit of analysis | Participant-level. Primary N = 50 after excluding “the researcher session”. | SAP §4.4 |
| Discrimination trials | 24 / participant = 2 × 4 K × 3 Difficulty instances. | Dict §9 |
| Pairwise | 12 trials / participant. Same H3 procedure as Study 1. | SAP §4.2; Dict §9 |
| Vision subset | N = 43. | SAP §4.4; Brief §11 |
| Outcomes / summaries | Same as Study 1 (H1, H2, H3, RT, AE, signed error), with Difficulty averaged rather than treated as configuration-only. | SAP §4 |
| Colormap raw values | `distinctipy` / `distinctipysa` (traceability). Condition still baseline → Original, sa → Optimized. | Dict §5.1 |

### 2.3 Study 3

| Item | Specified content | Source |
|------|-------------------|--------|
| Design | Within-subject. Condition = Original vs background-aware Optimized. Background = White vs Black. K = 10, 20, 30 (averaged for primary accuracy). Difficulty = Easy / Medium / Hard (averaged for primary accuracy). Condition order and Background order counterbalanced; not primary predictors. | SAP §5.1, §5.4; Dict §6 |
| Unit of analysis | Participant-level. Primary N = 50. | SAP §5.4 |
| Discrimination trials | 36 / participant = 2 Condition × 2 Background × 3 K × 3 Difficulty. | Dict §9 |
| Pairwise | 18 trials / participant = 2 Background × 3 K × 3 Difficulty. | Dict §6.2, §9 |
| Vision subset | N = 46. | SAP §5.4; Brief §11 |
| Outcomes | H4 Condition main effect on accuracy; H5 Condition × Background interaction; H6 overall Optimized-choice proportion vs 0.50; H7 Optimized-choice proportion White vs Black. RT: 2 × 2 RM ANOVA on Condition × Background means. AE: same as Study 1, optional by-background descriptives. Signed error: descriptive as Study 1. | SAP §5 |
| Participant-level summaries | Accuracy in each Condition × Background cell (average K and Difficulty); overall Orig vs Opt accuracy; Opt−Orig difference per background; overall pairwise proportion (18 trials); pairwise proportion per background; mean RT per Condition × Background; mean AE Orig vs Opt; signed-error means. | SAP §5; Brief §7–8 |

**Between / within (all studies):** all primary factors named above are **within-subject**. No between-subject inferential factor is specified. Study 1 G1/G2 and Study 3 `participant_group` / orders are design/QA only.

---

## 3. Study 1 — atomic numbered requirements

Each item is a requirement the R pipeline must implement. Text is quoted or closely paraphrased from the named section. Status of all items: **not implemented** (Phase 1).

### 3.1 Governing rules and pipeline order

| ID | Source | Requirement |
|----|--------|-------------|
| R1.1 | SAP §1 | Use α = .05. Report effect estimates with 95% confidence intervals. |
| R1.2 | SAP §1; Brief §1 | Treat H1, H2, H3 as distinct questions; test each at α = .05 **without** across-hypothesis multiplicity adjustment. |
| R1.3 | SAP §1; Brief §1 | Apply Holm correction only when several follow-up comparisons are conducted after a significant effect, and only to the families the SAP names. |
| R1.4 | SAP §1; Brief §1 | Use the predefined primary analysis population and documented data-cleaning rules. **No** participant or trial exclusion based on observed outcomes. Report missing/excluded observations and the final N in each analysis. |
| R1.5 | SAP §1 | Primary inferential analyses use **participant-level summary measures**. |
| R1.6 | SAP §1; Brief §1 | Use predefined fallbacks **only** when assumptions of the corresponding primary analysis are violated. Do not use mixed-effects models as the primary strategy. |
| R1.7 | SAP §6 | Analysis/reporting order: (1) confirm populations and apply predefined exclusions; (2) calculate participant-level summaries; (3) descriptives and relevant visualizations; (4) assumption checks for primary analyses; (5) primary tests and required corrections/fallbacks; (6) if interaction significant, planned follow-ups with specified Holm; (7) report primary results with ES and 95% CIs and visualizations; (8) preprocess secondary outcomes including RT checks / log; (9) secondary participant-level summaries; (10) secondary assumption checks and analyses; (11) report secondaries; (12) vision-screen sensitivity on primary outcomes; (13) report whether conclusions change. |
| R1.8 | Brief §3 | Implementation order inserts an extra step **before** summaries: run data-structure and pairwise-mapping QA before deriving analysis variables. Then: summaries → descriptives/visuals → diagnostics → primary tests/fallbacks → triggered follow-ups + Holm → secondaries → vision sensitivity → export and regenerate end-to-end. |
| R1.9 | Brief §9 | Fallback decisions must be documented **before** examining the statistical significance or direction of the Condition effect. |
| R1.10 | Brief §9 | Do not invent a numerical fallback threshold (e.g. \|skewness\| > 1) for ANOVA/t-test decisions. The threshold skewness > 1 applies **only** to the RT transformation. For SAP wording “severe deviations / severely non-normal / very skewed / extremely skewed”, produce the diagnostic, flag to Fatimah before switching, and record the agreed decision. |
| R1.11 | Dict §1 | Do not use questionnaire fields as inferential predictors unless separately requested. |
| R1.12 | Dict §1 | Do not infer eligibility from raw export row counts. Apply predefined exclusions/reconciliation **before** creating final analysis datasets. |
| R1.13 | Dict §12; Brief authority box | If a field is ambiguous, absent, or inconsistent, stop at mapping/QA and flag Fatimah. Do not invent a factor or recode a condition from outcomes. If Brief conflicts with SAP, stop and ask. |

### 3.2 Analysis population and exclusions (Study 1)

| ID | Source | Requirement |
|----|--------|-------------|
| R1.14 | SAP §3.4 | Primary analyses use all N = 50 participants. |
| R1.15 | SAP §3.4 | Condition order was counterbalanced equally; **do not** include it as a predictor; document it as design. |
| R1.16 | SAP / Brief | **Named Study 1 exclusion list and exact exclusion order: NOT SPECIFIED** beyond “predefined primary analysis populations and documented data-cleaning rules” and “no outcome-based exclusions.” No researcher-session exclusion is specified for Study 1 (unlike Study 2). |
| R1.17 | SAP §3.3.1; Brief §8.1 | Trial-level RT exclusions only: missing RT, non-positive RT, or RT affected by a documented recording/technical error. No other trimming. |
| R1.18 | Dict §9 | Never drop participants/trials because results are unusual. Use only predefined exclusions and documented technical/data-quality rules. |

### 3.3 Import, identifiers, and row selection

| ID | Source | Requirement |
|----|--------|-------------|
| R1.19 | Dict §3 | Map `Participant Public ID` → `participant_id` (string) as the primary identifier **after** predefined reconciliation/exclusion. Synthetic IDs must be dummy IDs. |
| R1.20 | Dict §3 | Retain `external_session_id` from `Participant External Session ID` where applicable. |
| R1.21 | Synthetic README; observed data | Study 1 `Participant Public ID` is the single value `BLINDED`. README: use unique synthetic `Participant Private ID` to identify participants in this test data. **How this maps on real data: NOT SPECIFIED in SAP/Brief.** |
| R1.22 | Dict §10 | Discrimination rows to retain: Task Name = `Discrimination Task G1` **or** `Discrimination Task G2`; Response Type = `response`; Object Name = `Response`. |
| R1.23 | Dict §10 | Pairwise rows to retain: Task Name = `Pairwise Comparison Task2`; Response Type = `response`; Object Name = `Image Response`. Exclude confidence/comment responses. |
| R1.24 | Dict §10 | Vision rows to retain: Task Name = `Vision Check`; Response Type = `response`; Object Name = `Number Entry`. |
| R1.25 | Dict §9 | After selection: 24 discrimination trials, 12 pairwise trials, 4 vision items per included participant. |
| R1.26 | Dict §11 | Gorilla metadata (timestamps, device, screen IDs, etc.) may be kept for QA/traceability but must not be added as predictors. |

### 3.4 Discrimination variables and participant-level accuracy

| ID | Source | Requirement |
|----|--------|-------------|
| R1.27 | Dict §4.1 | `condition`: `baseline` → Original; `sa` → Optimized. Within-subject Condition. |
| R1.28 | Dict §4.1 | `colormap_raw` (`tab20`, `tab20sa`) is traceability only; Condition is the canonical factor. |
| R1.29 | Dict §4.1; SAP §3.1 | `K` from `num_classes`: 5, 10, 20, 30. |
| R1.30 | Dict §4.1; SAP §3.1, §3.4; Brief §5.1 | `configuration_instance` from `variation` ∈ {1,2,3}. Treat only as repeated configuration instances. Easy/Medium/Hard was **not** implemented; do not analyse or interpret as Difficulty. |
| R1.31 | Dict §4.1 | `response_count` = numeric class-count Response; `correct_answer` = numeric ground truth. |
| R1.32 | Dict §4.1, §9 | `accuracy` = 1 if `response_count == correct_answer`, else 0. Recalculate/validate against Gorilla `Correct`. **Any mismatch must be flagged, not silently overwritten.** |
| R1.33 | Dict §4.1 | `signed_error` = `response_count − correct_answer`; `absolute_error` = abs(signed_error). |
| R1.34 | Dict §4.1 | `reaction_time_ms` = raw Gorilla Reaction Time (ms) on the relevant response event. Do not trim here beyond documented invalid values. |
| R1.35 | SAP §3.1; Brief §5.1 | For each participant, exact class-count accuracy = **proportion of correct responses within each Condition × K combination, averaging across the three configuration instances.** |
| R1.36 | SAP §3.4; Brief §5.1 | Keep K = 30 in the analysis. Interpret as a palette-capacity boundary condition because Tab20 contains 20 base colours; interpret cautiously. |

### 3.5 Pairwise QA and `chose_optimized`

| ID | Source | Requirement |
|----|--------|-------------|
| R1.37 | Dict §4.2 | Analyse the 12 task trials; exclude non-task screens. |
| R1.38 | Brief §4; Dict §4.2, §9 | Before `chose_optimized`: verify `optimized_side` distribution within participants; every analysed pairwise trial must contain **exactly one** Optimized image and **one** Original/baseline image. |
| R1.39 | Brief §2, §4; Dict §4.2 | Gorilla mapping is fixed: clicking left records `left_option`; clicking right records `right_option`. **Do not** interpret the semantic label (`optimized.png` / `baseline.png`) as the selected stimulus type. **Do not** code `chose_optimized` from those words in Response. |
| R1.40 | Brief §4 | If `response == left_option`, `preferred_side = "left"`; if `response == right_option`, `preferred_side = "right"`. |
| R1.41 | Brief §4; Dict §4.2 | Independently derive `optimized_side` from filenames: Left if `image_left` is the `*_optimized*` stimulus; Right if `image_right` is the `*_optimized*` stimulus. |
| R1.42 | Brief §4 | `chose_optimized = (preferred_side == optimized_side)`. |
| R1.43 | Brief §4 | If a row fails mapping checks, flag it as a data-structure/QA issue; do not guess or recode from outcomes. **Whether a failed row is dropped from the participant proportion: NOT SPECIFIED.** |
| R1.44 | Brief §4 | Keep a QA record: response-to-side reconstruction, `optimized_side` derivation, validation results, and the final `chose_optimized` derivation. |
| R1.45 | SAP §3.4; Brief §5.2 | Fixed pairwise trial order: no analytical adjustment; report as a limitation. |
| R1.46 | Dict §4.2 | Pairwise RT retained for descriptive reporting only. |

### 3.6 Primary tests — accuracy H1 and H2

| ID | Source | Requirement |
|----|--------|-------------|
| R1.47 | SAP §3.1; Brief §5.1 | Primary model: 2 × 4 repeated-measures ANOVA; within-subject Condition (Original, Optimized) and K (5, 10, 20, 30). |
| R1.48 | SAP §3.1 | H1 = Condition main effect (accuracy differs between Optimized and Original averaged across K). Expected direction favours Optimized (SAP §2 H1) but the test is the ANOVA main effect (not a one-sided contrast). **Contrast coding / reference level: NOT SPECIFIED.** |
| R1.49 | SAP §3.1 | H2 = Condition × K interaction. |
| R1.50 | SAP §3.1 | **Trigger:** if the Condition × K interaction is significant, run paired-samples t-tests Original vs Optimized at K = 5, 10, 20, 30, Holm-corrected across the **four** comparisons. |
| R1.51 | SAP §3.1; Brief §5.1 | **Zero-variance rule:** if the within-participant Optimized − Original difference at a given K has **exactly zero variance**, do **not** compute the inferential follow-up or standardized paired effect size for that K. Report descriptives for that K. Apply Holm across the **remaining estimable** K-specific comparisons. |
| R1.52 | SAP §3.1 | Diagnostics: inspect **histograms** of the participant-level accuracy data for normality, focusing on **severe skewness** and **extreme outliers**. With N = 50, moderate deviations are “unlikely to be problematic.” **Which accuracy vector is plotted (8 cells vs Condition means vs residuals): NOT SPECIFIED.** No Shapiro–Wilk (or other formal normality test) is specified. |
| R1.53 | SAP §3.1 | Assess sphericity with **Mauchly’s test**. If violated, apply **Greenhouse–Geisser**. Huynh–Feldt is not mentioned. |
| R1.54 | SAP §3.1 | **Fallback trigger:** if participant-level accuracy data show **severe deviations from normality**, use non-parametrics. H1 and H2 tested separately. |
| R1.55 | SAP §3.1 | Fallback H1: paired Wilcoxon signed-rank test comparing **overall** Original vs Optimized accuracy. |
| R1.56 | SAP §3.1; Brief §9 | Fallback H2: calculate Optimized − Original accuracy difference at each K; Friedman test of whether those differences vary across K. If Friedman is significant: pairwise Wilcoxon signed-rank tests comparing those **difference scores between the four K values**, Holm across the **six** pairwise comparisons. **Do not** replace this with Original vs Optimized tests at each K. |
| R1.57 | SAP §3.1 | Reporting, parametric H1: Condition main effect F, degrees of freedom, p, **partial η²**, and **95% CI**. |
| R1.58 | SAP §3.1 | Reporting, parametric H2: interaction F, df, p, partial η², 95% CI. If significant, at each K: mean difference, 95% CI, t, df, Cohen’s d, Holm-adjusted p. |
| R1.59 | SAP §3.1 | Descriptives: mean and SD of participant-level accuracy for Original and Optimized. |
| R1.60 | SAP §3.1 | Fallback H1 reporting: Wilcoxon V, p, rank-biserial correlation, 95% CI. |
| R1.61 | SAP §3.1 | Fallback H2 reporting: Friedman statistic, df, p, Kendall’s W. Then the six pairwise Wilcoxon tests with Holm if Friedman is significant. |

### 3.7 Primary test — pairwise H3

| ID | Source | Requirement |
|----|--------|-------------|
| R1.62 | SAP §3.2; Brief §5.2 | For each participant, proportion of the 12 pairwise trials in which Optimized was selected, **after** Section 4 QA/mapping. |
| R1.63 | SAP §3.2 | Two-sided one-sample t-test of the mean proportion against **0.50**. Expected direction favours Optimized; the test remains two-sided. |
| R1.64 | SAP §3.2 | Diagnostics: visual histogram of participant-level proportions; check they are approximately normal without **severe skewness**. With N = 50, visual inspection is sufficient. |
| R1.65 | SAP §3.2 | Fallback if proportions are **very skewed**: one-sample Wilcoxon signed-rank test against 0.50. Interpretation then is whether proportions tend to be above or below 0.50, not whether the mean differs from 0.50. |
| R1.66 | SAP §3.2 | Parametric reporting: mean Optimized-choice proportion, SD, 95% CI, t, df, p, Cohen’s d. |
| R1.67 | SAP §3.2 | Fallback reporting: V, p, rank-biserial, 95% CI. |

### 3.8 Secondary — response time

| ID | Source | Requirement |
|----|--------|-------------|
| R1.68 | SAP §3.3.1; Brief §8.1 | Include all **valid** trials regardless of accuracy. |
| R1.69 | SAP §3.3.1; Brief §8.1 | Exclude only missing or non-positive RT, or RT with documented recording/technical error. **No other trimming.** |
| R1.70 | SAP §3.3.1 | Calculate the **skewness coefficient** of the **trial-level** RT distribution. If skewness **> 1**, log-transform RT **before** calculating participant-level means. **Skewness formula / package: NOT SPECIFIED.** |
| R1.71 | Brief §8.1 | Use the natural-log transformation via `log()` in R (Brief states this is the SAP transformation rule). SAP itself says only “log-transform.” |
| R1.72 | SAP §3.3.1; Brief §8.1 | Participant-level mean RT separately for Original and Optimized, averaging across K, on the raw or log scale selected by the rule. Compare with a paired-samples t-test. |
| R1.73 | SAP §3.3.1; Brief §8.1 | Pairwise-task RT remains **descriptive** unless a separate inferential question is added to the frozen SAP. |
| R1.74 | SAP §3.3.1 | Histogram of each participant’s Original − Optimized difference in mean RT **on the analysis scale**. If differences are **severely non-normal**, use paired Wilcoxon instead. |
| R1.75 | SAP §3.3.1 | Reporting: mean and SD of participant-level RT for Original and Optimized (untransformed ms even if inference is on log). Paired mean difference, 95% CI, t, df, p, Cohen’s d. State if inference used log values. |
| R1.76 | Brief §8.1 | **Additional Brief reporting (not in SAP body):** if inference is on natural-log RT, exponentiate the estimated paired log difference and its 95% CI. If the contrast is Original − Optimized, label the back-transform as the **Original/Optimized geometric-mean ratio**. |
| R1.77 | SAP §3.3.1 | Wilcoxon fallback reporting: V, p, rank-biserial, 95% CI. |

### 3.9 Secondary — Absolute Error and Signed Error

| ID | Source | Requirement |
|----|--------|-------------|
| R1.78 | SAP §3.3.2; Brief §8.2 | Mean absolute error per participant for Original and Optimized, averaging across all K. Paired-samples t-test. Do **not** replace with a K-specific inferential model. |
| R1.79 | SAP §3.3.2 | Histogram of within-participant AE differences for **substantial skewness**. If differences are **extremely skewed**, paired Wilcoxon. |
| R1.80 | SAP §3.3.2 | Reporting: mean and SD of AE each condition; mean paired difference; 95% CI; t; df; p; paired-samples Cohen’s d. Fallback: V, p, rank-biserial, 95% CI. |
| R1.81 | Brief §8.2 | Additionally produce **descriptive** AE summaries by Condition × K (mean and SD; include a 95% CI **if this is part of the final reporting template**). No extra hypothesis tests. **Reporting template: not among the supplied files.** |
| R1.82 | SAP §3.3.3; Brief §8.3 | Signed error is **descriptive only**. No inferential test. Negative = underestimation; positive = overestimation. Report mean and SD separately for Original and Optimized. |

### 3.10 Vision-screen sensitivity

| ID | Source | Requirement |
|----|--------|-------------|
| R1.83 | SAP §3.4; Brief §11 | Primary analyses remain N = 50. Repeat **only** the SAP-defined primary accuracy and pairwise-choice analyses on the vision-screen subset **N = 48**. Report whether **substantive conclusions** change. Do not redefine the primary population. |
| R1.84 | Dict §7 | Four items: tags Q1_answer … Q4_answer; correct answers 12, 16, 29, 26. `vision_item_correct` = 1 if response equals key. `vision_score` = sum (0–4). |
| R1.85 | Dict §7 | `vision_subset_flag` must use the **already-defined** vision-screen sensitivity rule; do not redefine the threshold from the outcome data. **The SAP/Brief state the subset size (48) but not the item-level inclusion rule** (e.g. score == 4). Synthetic README constructs N = 48 as exactly the participants with score 4/4. |

### 3.11 Wilcoxon zeros, effect sizes, reporting conventions

| ID | Source | Requirement |
|----|--------|-------------|
| R1.86 | Brief §9.1 | Use **one** prespecified consistent convention for zero paired differences. If the standard convention is used: omit zeros from the signed-rank calculation and report the effective number of non-zero pairs. **Which convention is frozen: NOT SPECIFIED** (Brief asks that it be chosen consistently and documented). |
| R1.87 | Brief §9.1, §10 | Document exact R package/function for Wilcoxon, rank-biserial and its 95% CI, partial η², paired Cohen’s d, one-sample Cohen’s d, Kendall’s W, and their CIs. If more than one standard convention exists, **do not choose silently** — flag to Fatimah before code is frozen. Do not substitute a different effect-size family than the one named. |

### 3.12 Tables, figures, export formats

| ID | Source | Requirement |
|----|--------|-------------|
| R1.88 | SAP §3.1–3.3; Brief §14 | Produce publication-ready **summary tables** covering the statistics the SAP names for H1–H3, fallbacks, RT, AE, signed error, and vision sensitivity. **Table IDs, column layouts, titles, and note styles: NOT SPECIFIED.** |
| R1.89 | SAP §6 steps 3, 7, 11; Brief §3, §14 | Produce “relevant” / “planned” visualizations with clear labels and thesis/publication-suitable formatting. **Figure list, type (bar/line/boxplot), axes, tick labels, colours/colormap, sizes, DPI: NOT SPECIFIED in SAP, Brief, or Dictionary.** Brief §14 refers to “Figures/plots specified by the SAP/reporting plan”; no separate reporting plan was supplied. |
| R1.90 | Brief §14, §16 | Export analysis outputs, tables and figures in **reusable formats**. **Exact formats (CSV/RDS/DOCX/PNG/PDF/EPS): NOT SPECIFIED.** |
| R1.91 | Brief §12, §14 | One pipeline that regenerates everything without manual editing of numbers. `renv` lockfile. README with setup/run instructions. Analysis log recording: population/exclusions, missing observations, QA/mapping, assumption diagnostics, any fallback and why, zero-difference handling, zero-variance follow-ups, ES/CI package-functions, technical issues. |
| R1.92 | Brief §12, §16; Dict control table | Record SAP version = Final, freeze date = 21 September 2026, R version = 4.6.1 (2026-06-24). |
| R1.93 | Brief §13 | Develop/test on synthetic structure only. Do not hard-code dataset-specific values that would break on real data with the documented structure. |
| R1.94 | Brief §15–16 | Guardrails and acceptance checklist as written (mixed models; Difficulty misuse; Friedman follow-up swap; extra trimming; invented cutoffs; extra AE/signed-error tests; outcome-based remapping; unflagged methodological changes). |

**Study 1 requirement count: 94 (R1.1–R1.94).**  
Of these, several contain an explicit **NOT SPECIFIED** sub-clause that must be resolved before the corresponding number can be frozen (see §7 and QUESTIONS).

---

## 4. Parameter register

| Parameter | Value | Source | Notes |
|-----------|-------|--------|-------|
| α (primary hypotheses) | .05 | SAP §1; Brief §1 | Per hypothesis; no across-H correction |
| CI level | 95% | SAP §1 | |
| Holm family H2 parametric follow-up | 4 comparisons (K = 5,10,20,30), or fewer if zero-variance K dropped | SAP §3.1 | |
| Holm family H2 Friedman follow-up | 6 pairwise K-difference comparisons | SAP §3.1 | |
| H3 test value | 0.50 | SAP §3.2 | Two-sided |
| Primary N Study 1 / 2 / 3 | 50 / 50 / 50 | SAP §3.4, §4.4, §5.4 | Study 2 after researcher exclusion |
| Vision-subset N | 48 / 43 / 46 | SAP; Brief §11 | **Inclusion rule NOT SPECIFIED** |
| Study 1 disc trials / person | 24 = 2 × 4 × 3 | Dict §9 | |
| Study 1 pairwise trials / person | 12 | SAP §3.2; Dict §9 | |
| Study 1 vision items | 4 | Dict §7 | |
| Condition levels | Original, Optimized | SAP | Raw codes baseline / sa (S1–S2); C1_original_distinctipy / C2_background_aware_optimized (S3) |
| K Study 1–2 | 5, 10, 20, 30 | SAP | |
| K Study 3 | 10, 20, 30 | Dict §6 | Averaged for H4/H5 |
| Configuration instances (S1) | 1, 2, 3 | Dict §4.1 | Not Difficulty |
| Difficulty (S2, S3) | 3 levels; averaged in primary accuracy | SAP §4.1, §5.1 | |
| Background (S3) | White, Black | SAP §5.1 | Raw: white, black |
| RT invalid | missing or ≤ 0, or documented technical error | SAP §3.3.1 | |
| Other RT / outlier trim | **none** | SAP §3.3.1 | |
| RT skewness trigger for log | **> 1** (trial-level RT) | SAP §3.3.1 | |
| RT log base | Brief: natural log via `log()`; SAP: “log-transform” only | Brief §8.1 | |
| ANOVA fallback normality cutoff | **NOT SPECIFIED** (qualitative “severe”) | SAP; Brief §9 | |
| t-test fallback cutoff | **NOT SPECIFIED** (“very” / “severely” / “extremely” skewed) | SAP | |
| Mauchly action | Greenhouse–Geisser if violated | SAP §3.1 | HF **NOT SPECIFIED** |
| S3 sphericity | None required (both factors 2 levels) | SAP §5.1 | |
| ANOVA type (I/II/III), contrasts, software | **NOT SPECIFIED** | | |
| Reference level for Condition | **NOT SPECIFIED** | | |
| Cohen’s d convention (paired / one-sample) | Named “Cohen’s d” / “paired-samples Cohen’s d”; **definition NOT SPECIFIED** | SAP; Brief §10 | |
| Partial η² definition and 95% CI method | Named; **method NOT SPECIFIED** | SAP; Brief §10 | |
| Rank-biserial definition and 95% CI method | Named; **method NOT SPECIFIED** | SAP; Brief §10 | |
| Kendall’s W definition / CI | W named; **CI not required by SAP for W**; method NOT SPECIFIED | SAP §3.1 | |
| Wilcoxon zero-difference convention | **NOT SPECIFIED** (Brief §9.1: pick one, document; standard = drop zeros) | Brief §9.1 | |
| Skewness estimator | **NOT SPECIFIED** | | |
| H7 contrast direction | White − Black | SAP §5.2 | |
| Geometric-mean ratio | Brief only; exp(paired log difference) if contrast Original − Optimized | Brief §8.1 | Not in SAP body |
| Mixed-effects | Do not use as primary | Brief §1, §15 | |
| R version for final run | 4.6.1 (2026-06-24) | Brief; Dict | **Not installed here** |
| Package versions | Pin with `renv` | Brief §12 | |
| Figure colours / sizes | **NOT SPECIFIED** | | |
| Export file formats | **NOT SPECIFIED** (“reusable formats”) | Brief §14 | |
| Vision pass threshold | **NOT SPECIFIED** (size given; synthetic uses 4/4) | | |
| Study 2 researcher ID on real data | **NOT SPECIFIED** (synthetic: `S2_RESEARCHER_EXCLUDE` / `S2_PRIV_RESEARCHER`) | SAP §4.4 | |
| `preferred_side` string case | Brief: `"left"` / `"right"`; S3 Response: `Left` / `Right` | Brief §4; Dict §6.2 | |
| Optimized filename token S1 | `*_optimized*` vs baseline | Dict §4.2 | |
| Optimized filename token S3 | `*_opt_*` vs `*_orig_*` | Dict §6.2 | |

---

## 5. Synthetic data audit vs Data Dictionary

**Profiling method:** Python 3.13.5 + pandas 2.2.3, read-only. Evidence: `docs/_synthetic_audit.txt` and `docs/_synthetic_profile.json`. **R was not used (NOT EXECUTED).**

### 5.1 Package vs Dictionary §8 canonical files

Dictionary §8 recommends one discrimination, one pairwise, and one vision table **per study** with short canonical names (`participant_id`, `condition`, `K`, …).

**Actual package:** raw Gorilla-style headers (`Participant Public ID`, `Spreadsheet: condition`, `Reaction Time`, …), Study 1 split by G1/G2, Studies 2–3 as single combined task exports. This matches `README_SYNTHETIC_DATA.md` (“real-export column headers are retained”) and is **usable**, but it is **not** the §8 file layout. The pipeline must implement Dict §3–§7 **mapping** from raw columns.

### 5.2 Study 1 — counts and balance

| Check | Expected | Observed (Python) | Match? |
|-------|----------|-------------------|--------|
| Primary participants | 50 | 50 distinct `Participant Private ID` shared across disc/pairwise/vision | Yes |
| Public ID | primary identifier | Single value `BLINDED` on all Study 1 rows | Conflicts with Dict §3 if applied without Private ID |
| Disc trials / person | 24 | 24 for all 50 private IDs (G1: 25 IDs × 24; G2: 25 IDs × 24; overlap 0) | Yes |
| Disc rows | 1200 | 1200 | Yes |
| Pairwise / person | 12 | 12 for all 50 | Yes |
| Pairwise rows | 600 | 600 | Yes |
| Vision / person | 4 | 4 for all 50 | Yes |
| Vision rows | 200 | 200 | Yes |
| Condition | baseline / sa balanced | 600 / 600 | Yes |
| K | 5,10,20,30 | 300 rows each | Yes |
| variation | 1,2,3 | 400 each; 1 row per id × cond × K × var | Yes |
| Vision score 4 | 48/50 (README) | 48 score 4; 2 score 3 | Yes |
| Duplicate rows | — | 0 on all Study 1 files | — |
| Blank rows | — | 0 | — |
| Disc Task Name | G1 or G2 | `Discrimination Task G1` / `G2` | Yes |
| Pairwise Task Name | Pairwise Comparison Task2 | exact | Yes |
| Vision Task Name | Vision Check | exact | Yes |
| Response Type | response | all `response` | Yes |
| Object Name | Response / Image Response / Number Entry | **100% missing (NA)** on disc, pairwise, vision | **Mismatch vs Dict §10** |
| Accuracy vs Correct | must match or flag | 0 mismatches (recalc Response == correct_answer vs Correct) | OK on synthetic |
| Response range | class counts | 4–36; answers 5–30 | Some responses outside {5,10,20,30} — valid as errors |
| RT | positive ms | disc 1202.9–18731.5; 0 non-positive; 0 missing; skew ≈ 1.181 | Exercises log rule |
| Pairwise one-opt-one-orig | required | 0 both-optimized, 0 both-baseline | Yes |
| Mapping mismatch | deliberate | e.g. left image `…optimized.png` with `left_option=baseline.png` | Yes, as designed |
| preferred_side reconstructable | all rows | left 302, right 298, unmatched 0 | Yes |
| Pairwise filename Difficulty tokens | S1 Difficulty not implemented | names contain `easy`/`medium`/`hard` | Tokens present; SAP forbids treating as Difficulty |
| `external_session_id` | string, used where applicable | **all missing** in Study 1 | Present as column, empty |
| `Object Name` | required for row filter | missing | See Q |
| Canonical columns (`accuracy`, `chose_optimized`, …) | §8 | **absent** (must be derived) | Expected if raw |

G1 vs G2: `Spreadsheet: group_number` 1 vs 2; `randomiser-m119` G1/G2. Not a SAP factor.

### 5.3 Study 2 — counts and balance

| Check | Expected | Observed | Match? |
|-------|----------|----------|--------|
| Raw sessions | 51 | 51 public IDs + 1 fully blank row (2041 rows) | README said blank terminal row for **Study 3**; Study 2 **also** has a blank last row |
| Researcher | exclude `S2_RESEARCHER_EXCLUDE` | 40 rows; private ID `S2_PRIV_RESEARCHER`; sits in G2 discrimination (G2 26 public IDs / 624 rows; G1 25 / 600) | Matches README |
| Primary N after exclusion | 50 | 50 public IDs remain | Yes |
| Rows after exclusion | 2000 | 51×40 − 40 researcher = 2000 non-blank | Yes |
| Disc 24 / pairwise 12 / vision 4 | yes | 40 rows/session = 24+12+4 | Yes |
| Vision 4/4 among primary | 43 | 43 score 4, 7 score 3 (researcher excluded from that count) | Yes |
| condition / colormap | baseline/sa; distinctipy / distinctipysa | balanced 612/612 including researcher | Yes |
| variation 1,2,3 | Difficulty index | present; no text Difficulty column (README + Dict) | Yes |
| Object Name | required for filters | **all NA** | Mismatch |
| `Spreadsheet: optimized_side` | Left/Right on pairwise | Left 296, Right 316, NA on non-pairwise | Present |
| Combined file vs §8 three files | §8 wants 3 files | 1 combined file | Layout mismatch, content present |

### 5.4 Study 3 — counts and balance

| Check | Expected | Observed | Match? |
|-------|----------|----------|--------|
| Participants | 50 | 50 public + 50 private | Yes |
| Disc 36 / pairwise 18 / vision 4 | 58 rows/person | 58 for each of 50 | Yes |
| Totals | 1800 / 900 / 200 | exact; plus 1 blank terminal row (2901) | Yes (blank as README) |
| Vision 4/4 | 46 | 46 score 4, 4 score 3 | Yes |
| Condition | C1_original_distinctipy / C2_background_aware_optimized | 900 / 900 | Yes |
| Background | white / black | disc 900/900; pairwise 450/450 | Yes |
| K | 10,20,30 | disc 600 each; pairwise 300 each | Yes |
| Difficulty | 1/2/3 and easy/medium/hard | 600 each on disc | Yes |
| scale_factor | 0.8, 1.0, 1.3 | 600 each | Yes |
| participant_group | four G_* labels | present; **not equal** (468, 468, 432, 432 rows = 13+13+12+12 participants) | Levels match; balance not specified as equal |
| condition_order | Dict: `optimized_first` / `original_first` | **`OptimizedFirst` / `OriginalFirst`** | Token mismatch |
| block_order | Dict: `black_first` / `white_first` | **`BlackWhite` / `WhiteBlack`** (864 / 936 rows) | Token mismatch |
| Pairwise Response | Left / Right | Left 444, Right 456 | Yes |
| optimized_side | Left / Right | Left 446, Right 454 | Yes |
| Object Name | Select_Left / Select_Right for pairwise | **all NA** | Mismatch vs Dict §10 |
| Filenames | `*_opt_*` / `*_orig_*` | e.g. `disc_K10_D1_orig_black.png` | Pattern present |
| Many provenance columns | Dict §11: not required | Present, often empty (objective scores etc. all missing) | Allowed |

### 5.5 Columns in data but not in SAP/Brief (and vice versa)

**In synthetic, not needed for frozen analyses (Dict §11):** timestamps, device/OS/browser, monitor/viewport, Experiment ID/version, tree/schedule keys, randomiser columns, screen IDs, onset/clock times, Response Duration, Absolute Reaction Time, Study 3 palette/provenance/rendering fields, `Spreadsheet: confidence_rating` (empty), `Spreadsheet: preferred_side` / `optimized_selected` (empty; must be derived, not trusted).

**Required by Dictionary §8 canonical tables, absent as columns (must be derived):** `accuracy`, `signed_error`, `absolute_error`, `preferred_side`, `optimized_side` (S1 pairwise — no raw optimized_side column), `chose_optimized`, `vision_score`, `vision_subset_flag`, canonical `condition` labels Original/Optimized.

**Required by Dict §10 filters, absent in all synthetic files:** `Object Name` (entirely NA).

**In Study 1 pairwise filenames but forbidden as a Study 1 factor:** Easy/Medium/Hard tokens.

### 5.6 Evidence excerpts (actual Python output)

From `docs/_synthetic_audit.txt`:

- Study 1 disc combined: `private unique=50`, `rows per private: {24: 50}`, `accuracy recalc vs Correct mismatches=0`, `RT … skew=1.1808242996650984`, cells fully balanced 50 per Condition × K × variation.
- Study 1 pairwise: `preferred_side reconstruction: {'left': 302, 'right': 298}`, `both optimized=0 both baseline=0`.
- Study 1 vision: `vision_score distribution: {3: 2, 4: 48}`.
- Study 2: `S2 public unique=51`, `researcher rows public=40`, `S2 vision scores primary … score4=43`.
- Study 3: `S3 vision scores: n=50 score4=46`, `S3 last row all-NA=True`.

---

## 6. Cross-study commonalities (shared `R/` helpers)

These pieces should **not** be copy-pasted per study.

| Pipeline part | Shared helper (planned) | Study-specific arguments |
|---------------|-------------------------|--------------------------|
| Paths / synthetic vs real switch | `R/config.R` + `config/analysis.yml` | input directory, ID column |
| Load Gorilla CSV, drop blank housekeeping rows | `R/load_data.R` | file list |
| Column rename raw → canonical | `R/dictionary_map.R` | per-study map |
| Response-row selection | `R/select_trials.R` | Task Name / Response Type / Object Name sets |
| Condition / K / background recodes | `R/recode_factors.R` | level maps |
| Accuracy + error derivation + Correct-mismatch flag | `R/derive_discrimination.R` | — |
| Pairwise side reconstruction + one-and-one QA | `R/derive_pairwise.R` | filename token rule (`optimized` vs `opt`/`orig`); S3 uses Response as side |
| Vision score + subset flag | `R/derive_vision.R` | subset rule once confirmed |
| Structural N / trials-per-cell checks | `R/validate_structure.R` | expected 24/12/4 vs 24/12/4 vs 36/18/4 |
| Participant-level cell means | `R/summarise_participants.R` | grouping factors |
| Predefined exclusions | `R/exclusions.R` | Study 2 researcher rule |
| Histograms + Mauchly/GG + qualitative-fallback gate | `R/assumptions.R` | — |
| 2×f RM ANOVA + named effects | `R/models_anova.R` | factor lists |
| Paired / one-sample t + Holm | `R/models_ttest.R` | families |
| Wilcoxon / Friedman / Kendall W | `R/models_npar.R` | — |
| Effect sizes + 95% CIs | `R/effect_sizes.R` | **after client convention approval** |
| RT skewness > 1 → `log()` then means | `R/rt_preprocess.R` | — |
| Vision sensitivity wrapper (rerun primary only) | `R/sensitivity_vision.R` | subset N |
| Tables / figures / exports | `R/export_tables.R`, `R/export_figures.R` | **after figure/table spec** |
| Analysis log | `R/analysis_log.R` | — |
| Study orchestrators | `scripts/run_study1.R` etc. | call shared helpers |

Study 3 adds Background cells and H6/H7; the same ANOVA/t/Wilcoxon helpers should accept factor lists rather than being Study-1-only.

---

## 7. Inconsistencies, ambiguities, and methodological concerns

Each item is expanded in `docs/QUESTIONS_FOR_CLIENT.md`.

| # | Location | Issue | Plausible readings | Impact on results |
|---|----------|-------|--------------------|-------------------|
| C1 | Brief authority vs Dict §1 | Who governs if texts differ: SAP or Brief? | (A) SAP wins (Brief’s own rule + this project’s order). (B) Brief wins (Dictionary §1). | Any Brief-only extra (e.g. geometric-mean ratio) included or excluded. |
| C2 | SAP §3.1 / §4.1 / §5.1 “severe deviations from normality” + Brief §9 | No numeric cutoff for switching to Wilcoxon/Friedman. | (A) Analyst flags and waits (Brief). (B) Silent visual judgement. (C) Invent \|skew\|>1 — **forbidden by Brief**. | Changes which p-values/ES are reported as primary. |
| C3 | SAP §3.1 “histograms of the participant-level accuracy data” | Which vectors? | (A) 8 Condition×K cells. (B) 2 Condition means. (C) ANOVA residuals. (D) all of these. | Can change whether fallback is triggered. |
| C4 | Brief §10; SAP ES names | Multiple standard definitions of paired/one-sample d, partial η² CI, rank-biserial CI. | Several published conventions. | Numerically different ES/CIs. |
| C5 | Brief §9.1 | Wilcoxon zeros convention not frozen. | (A) Drop zeros (`wilcox.test` default). (B) Pratt. (C) Other. | Changes V, p, n, rank-biserial. |
| C6 | SAP §3.4 N=48; Dict §7 | Vision subset **size** given; **rule** not written. | (A) score == 4 (matches synthetic 48/43/46). (B) another prespecified rule not in these files. | Changes sensitivity sample and possibly “did conclusions change?” |
| C7 | SAP §1 “predefined … data-cleaning rules”; Study 1 has no named exclusions | What is the Study 1 exclusion SOP and order? | (A) no participant exclusions; N=50 completers. (B) a reconciliation SOP not supplied. | Changes primary N on real data. |
| C8 | Brief §4 failed mapping rows | Flag vs drop vs set NA. | (A) drop trial from proportion. (B) keep participant but NA that trial. (C) stop pipeline. | Changes H3 proportions. |
| C9 | Missing cells / incomplete participants | Not specified. | (A) drop participant from that analysis. (B) use available trials. (C) stop and flag. | Changes N and cell means. |
| C10 | Dict §10 Object Name vs synthetic (and possibly real) all-NA Object Name | Filter would drop **all** rows. | (A) filter Task Name + Response Type only when Object Name missing. (B) require Object Name on real data. | Could yield empty datasets. |
| C11 | Dict §3 participant_id = Public ID vs Study 1 Public ID = `BLINDED` | Which ID to use. | (A) Private ID when Public is BLINDED. (B) always Public on real data. (C) client-specified reconciliation. | Wrong joining / duplicated N. |
| C12 | ANOVA implementation | Type I/II/III, sum vs treatment contrasts, which R function. | Common: Type III + sum contrasts (`afex`). | Can change F/p for unbalanced data (S3 groups already unequal). |
| C13 | Condition reference level | Not specified. | Original first vs Optimized first. | Sign of some contrasts; not the omnibus F if Type III. |
| C14 | SAP “log-transform” vs Brief `log()` | ln vs log10. | (A) Brief: natural log. (B) log10. | Changes log means and back-transform. |
| C15 | Brief §8.1 geometric-mean ratio | Not in SAP body. | (A) extra reporting allowed by Brief. (B) new method requiring SAP confirmation. | Extra number in RT output. |
| C16 | Brief §8.2 AE×K 95% CI “if … reporting template” | No template supplied. | (A) mean/SD only. (B) add 95% CI. | Extra/omitted interval. |
| C17 | SAP §6 “relevant visualizations”; Brief “SAP/reporting plan” | No figure specs. | Client to supply types/colours/sizes. | Cannot claim SAP-compliant figures. |
| C18 | Brief §14 “reusable formats” | No list. | CSV+PNG vs DOCX/PDF, etc. | Delivery mismatch. |
| C19 | Skewness coefficient | Formula not named. | e1071 type 1/2/3; moments; psych. | Could flip RT log decision near 1.0 (synthetic disc RT skew ≈ 1.18). |
| C20 | Study 1 pairwise filenames contain easy/medium/hard | SAP: Difficulty not implemented. | (A) ignore tokens. (B) something else. | Risk of wrongly adding Difficulty. |
| C21 | Brief `"left"`/`"right"` vs S3 `Left`/`Right` | Case. | (A) casefold. (B) exact Brief strings only for S1. | Failed equality → wrong `chose_optimized`. |
| C22 | Dict §8 tokens vs S3 `OriginalFirst` / `WhiteBlack` | Order-field coding. | Map aliases vs require dictionary strings. | QA failures; not primary predictors. |
| C23 | Study 2 researcher ID on real data | Only synthetic IDs given. | Need real-data identifier from Fatimah. | Wrong N if mis-identified. |
| C24 | Dict §9 “flag Correct mismatch, do not overwrite” | What if mismatch on real data? | Flag and keep recalculated vs stop. | Accuracy values. |
| C25 | SAP H1 “expected direction favouring Optimized” vs two-sided/omnibus tests | Directional language vs two-sided tests. | Follow test as written (two-sided / ANOVA). | Interpretation, not the test, if we follow SAP test text. |
| C26 | Partial η² 95% CI | SAP requires CI for partial η². | Several methods; some software omits CI. | Missing or non-comparable CIs. |
| C27 | Kendall’s W CI | SAP does not ask a CI for W; Brief §10 says document CIs “where applicable.” | Report W only vs add CI. | Extra number. |
| C28 | Which RT column | Dict: `Reaction Time`. Data also have Absolute Reaction Time and Response Duration (equal on synthetic S1). | Use `Reaction Time` only. | Could diverge on real data. |
| C29 | Housekeeping blank rows | README: Study 3; data: Study 2 **and** 3. | Always drop all-NA rows as housekeeping. | One extra NA row if not dropped. |
| C30 | `cursor_rules.md` missing | Process file not in handoff. | Client/user to supply. | Project rules (question format, folder extras) not verifiable. |
| C31 | No Shapiro, no outlier rule | Only visual histograms; “extreme outliers” with no rule. | Flag visuals; do not drop outliers. | Subjective fallback trigger. |
| C32 | Study 3 pairwise Dict §10 `Select_Left` / `Select_Right` | Object Name NA; Response already Left/Right. | Filter Task Name + Response Type + Response ∈ {Left,Right}. | Row retention. |
| C33 | R 4.6.1 pin | Specified for client machine. | Must match at delivery. | Scripts may fail on other R versions. |
| C34 | Dictionary says Brief governs analysis | Conflicts with Brief and with project order. | See C1. | Same as C1. |

---

## 8. R package plan (nothing executed)

R is **not available**. Every function below that is not base/`stats` is **TO VERIFY when R is available** (existence, arguments, defaults, and whether it matches the SAP’s named statistic).

| Task | Proposed package / function | Reason | Caution |
|------|----------------------------|--------|---------|
| Project hygiene | `renv` | Required by Brief §12 | TO VERIFY install on client R 4.6.1 |
| Config | base + a YAML parser (`yaml`) | Single synthetic/real switch | TO VERIFY |
| I/O | `readr::read_csv` | Gorilla CSVs | encoding/column-type surprises |
| Wrangling | `dplyr`, `tidyr` | Standard | — |
| Factors | `forcats` | Level control **after** client confirms reference | — |
| RM ANOVA + Mauchly + GG | `afex::aov_ez` (or `afex::aov_car`) | Common for 2×4 / 2×2 RM; reports GG | ANOVA type/contrasts must match client decision; TO VERIFY |
| Follow-up paired t / Holm | `stats::t.test`; `stats::p.adjust(..., "holm")` | Matches named tests | — |
| One-sample t | `stats::t.test` | H3 / H6 | — |
| Wilcoxon | `stats::wilcox.test` | Reports V as SAP names | Zero handling = default drop zeros unless client says otherwise; TO VERIFY exact args (`exact`, `correct`) |
| Friedman | `stats::friedman.test` | Named | Long-format reshape |
| Kendall’s W | `effectsize::kendalls_w` **or** `rstatix::friedman_effsize` | SAP names W | Which function exists / which formula: TO VERIFY |
| Partial η² + CI | `effectsize::eta_squared` | Named ES | CI method TO VERIFY; must be partial, not generalized η² |
| Cohen’s d (paired / one-sample) + CI | `effectsize::cohens_d` | Named | `d_z` vs `d_av` etc. — **do not silently pick** (Brief §10) |
| Rank-biserial + CI | `effectsize::rank_biserial` **or** `rcompanion::wilcoxonPairedR` | Named | Convention + CI method TO VERIFY |
| Skewness | `e1071::skewness` or `moments::skewness` | SAP “skewness coefficient” | Type/bias TO VERIFY after client answer |
| Histograms | `ggplot2` | Specified diagnostic | Appearance NOT SPECIFIED |
| Tables | `gt` or `flextable` | Publication-ready | Template NOT SPECIFIED |
| Export | `write.csv`, `ggsave`, maybe `openxlsx` | Reusable | Formats NOT SPECIFIED |
| Tests | `testthat` | Structure/mapping tests on synthetic | Do not assert real-study scientific results |
| Logging | base `sink` / custom log writer | Brief §12 | — |

**Will not use as primary models:** `lme4`, `nlme`, `glmmTMB`, `brms` (Brief forbids mixed-effects as primary).

**Will not invent:** extra post-hocs, outlier filters, Difficulty models, Signed Error tests, K-specific AE inference.

---

## 9. Conversion verification (Phase 1 Step 0.4)

Tooling: pandoc 3.8.1 `-t gfm`; python-docx 1.1.2; zip/XML inspection. Full dump: `docs/_conversion_verification.json`.

### 9.1 Data Dictionary

| Feature | Original .docx | Converted .md | Lost / garbled? |
|---------|----------------|---------------|-----------------|
| Heading 1/2 | 12 + 6 = 18 | 18 ATX headings, same titles | No |
| Tables | 13 | 13 GFM tables | No (headers/row counts match python-docx) |
| Lists | 4 paragraphs styled List Bullet; 0 w:numPr | 6 MD list items | Two extra list items likely from hyphenated bullets; content present |
| Footnotes | 0 | 0 | — |
| Comments | 0 | 0 | — |
| Tracked changes | ins=0 del=0 | — | None |
| Images | 0 | 0 | — |
| Header | none | — | — |
| Footer | “Data Dictionary and Column Structure — Final SAP implementation support” (em dash showed as `�` in XML extract) | Footer not in body MD | Footer not needed for implementation; encoding of footer dash only |

Title paragraph converted. All 13 tables readable.

### 9.2 Implementation Brief

| Feature | Original .docx | Converted .md | Lost / garbled? |
|---------|----------------|---------------|-----------------|
| Headings | 27 | 27 | No |
| Tables | 5 | First pass: 3 GFM + 2 broken 1×1 HTML | **Yes, initially.** Tables 2 and 5 were single-cell “box” tables. **Re-extracted** from python-docx into the MD as lists. Tables 1, 3, 4 converted cleanly. |
| Lists | 80 bullets + 10 numbered | 90 list items | Count consistent |
| Footnotes / comments / revisions / images | 0 | 0 | — |
| Header | “Categorical Colormap Optimization \| Final Analysis Implementation Brief” | not in body | Header only |
| Footer | “For R implementation by Tayyab Riaz \| Page” | page field not converted | Page numbers only |

### 9.3 SAP

| Feature | Original .docx | Converted .md | Lost / garbled? |
|---------|----------------|---------------|-----------------|
| Word heading styles | **0** (all Normal except one `pdq2pg_selectionanchorcontainer` on H1) | 0 ATX headings | Structure is numbered plain paragraphs in **both** source and MD |
| Tables | 0 | 0 | — |
| Lists | 13 w:numPr (the §6 numbered order) | 15 list items | Order 1–13 present; two extras from wrapping |
| Footnotes / comments / revisions / images | 0 | 0 | — |
| Hyphenation | Source already contains `sepa- rately`, `Op- timized`, `his- togram`, etc. | Same | **Not introduced by pandoc.** Looks like a PDF→Word paste. Meaning is recoverable; I did not “fix” hyphens in the spec copy. |
| Page numbers | Paragraphs that are just `1` … `9` | Same | Not body content |
| H1 paragraph style | `pdq2pg_selectionanchorcontainer` | Normal text “H1. …” | Style name lost; **text kept** |

**Nothing in the three .docx files was unreadable** except: Brief tables 2 and 5 (recovered), footer/page chrome, and SAP soft-hyphen line breaks (present in the original).

---

## 10. Requirement counts (for the Phase 1 close-out)

| Study | Numbered requirements in this document / traceability | Notes |
|-------|------------------------------------------------------|-------|
| Study 1 | **94** (R1.1–R1.94) | Includes items whose implementation is blocked by NOT SPECIFIED details |
| Study 2 | **28** unique + inherit Study 1 analytic machinery (see `SAP_TRACEABILITY.md` R2.*) | Same H1–H3 / secondaries / fallbacks as Study 1 unless stated |
| Study 3 | **36** (R3.*) | H4–H7, 2×2 accuracy and RT, different pairwise derivation |

---

*End of UNDERSTANDING.md — Phase 1. No analysis code was written or run.*
