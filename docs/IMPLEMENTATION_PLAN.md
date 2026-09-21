# Implementation plan

**Phase:** 1 only. No analysis code has been written. **R is not installed** — every R step below is **NOT EXECUTED** until R 4.6.1 (or the client-confirmed version) is available.

**Do not start Phase 2 until:** (1) you confirm this plan, and (2) Fatimah answers the BLOCKING Study 1 questions in `docs/QUESTIONS_FOR_CLIENT.md` (or you explicitly accept a documented interim default **after** she answers). I will not invent cutoffs, effect-size conventions, or figures.

---

## 1. Project structure (current + planned)

```
R-Project/
  .cursor/rules/
    cursor_rules.md       # user-placed official rules (present 22 Sep 2026)
    r-analysis.mdc        # same body + alwaysApply: true
  .gitignore              # data/real/**  (done)
  README.md               # PLANNED (Rules §4 / §9)
  renv.lock               # PLANNED
  run_all.R               # PLANNED master script at project root
  config/
    config.R              # PLANNED: paths, seed, alpha, study switches, palette
  data/
    synthetic/            # extracted zip; DO NOT EDIT
    real/                 # empty, gitignored
  docs/
    spec/                 # untouched client originals
    QUESTIONS_FOR_CLIENT.md
    SAP_TRACEABILITY.md
    DECISIONS_LOG.md
    UNDERSTANDING.md
    IMPLEMENTATION_PLAN.md
    *_FINAL.md            # conversions (working copies)
  R/                      # PLANNED: utils_*.R + study1_*.R / study2_*.R / study3_*.R
  scripts/                # PLANNED numbered 01_..., 02_... (Phase 1 Python profilers only for now)
  tests/testthat/         # PLANNED
  output/
    tables/
    figures/
    models/               # full statistical output (Rules §7)
    logs/
```

Client originals also remain in the project root, untouched.

---

## 2. Config design (one switch)

`config/config.R` is the **only** place that chooses data and records frozen parameters (Rules §3–§4). Switching synthetic vs real must require changing **only that file**. Paths via `here::here()`. No `setwd()`, no absolute paths.

Planned contents (not created until implementation, and only after client answers for blocked items):

- `data_source`: `"synthetic"` or `"real"`
- relative paths under `data/synthetic` and `data/real`
- `alpha = 0.05`, `ci_level = 0.95`, `h3_null = 0.50`, `rt_skewness_log_threshold = 1` (SAP-specified only)
- one seed (if any randomness is needed)
- study switches
- blocked items as `TODO(client-question #N)` that `stop()` — do not pre-fill vision rule, ES convention, Wilcoxon zeros, ANOVA type

Real-data mode must use the **same** column maps. File *names* for the real Gorilla zips are in Dictionary §2 (`data_exp_229051-v38 (1).zip`, etc.) but the inner CSV names on the client machine are **NOT SPECIFIED**. Config should allow Fatimah to point at her local paths without code edits.

Output names: `study{N}_{type}_{name}.{ext}` (Rules §4), with `_SYNTHETIC` suffix when `data_source` is synthetic (Rules §2).

---

## 3. Planned files and responsibilities

### 3.1 Shared `R/` (Studies 1–3)

| File | Responsibility |
|------|----------------|
| `config/config.R` | Paths, seed, alpha, study switches; `data_source`; renv/session checks |
| `R/utils_config.R` | Read config; `here::here()` path helpers |
| `R/load_data.R` | Read CSVs; drop all-NA housekeeping rows; do not interpret values |
| `R/dictionary_map.R` | Rename/select raw Gorilla → canonical names (Dict §3–§7) |
| `R/select_trials.R` | Task Name / Response Type / Object Name filters (Dict §10); log when Object Name is empty |
| `R/recode_factors.R` | Condition, K, background, configuration/difficulty, order-field aliases |
| `R/derive_discrimination.R` | accuracy, signed_error, absolute_error; flag Correct mismatches |
| `R/derive_pairwise.R` | preferred_side, optimized_side, chose_optimized, one-and-one QA; study-specific filename tokens |
| `R/derive_vision.R` | item correctness, score 0–4, subset flag **after** Q1 |
| `R/validate_structure.R` | Dict §9 counts; fail loudly on incomplete cells (Q4) |
| `R/exclusions.R` | Predefined exclusions only (Study 2 researcher; Study 1 none until Q2) |
| `R/summarise_participants.R` | Cell means: Condition×K (S1/S2); Condition×Background (S3); pairwise proportions; RT/AE/SE |
| `R/rt_preprocess.R` | Invalid RT drop; trial-level skewness; `log()` if > 1; untransformed ms kept |
| `R/assumptions.R` | SAP histograms; write diagnostics; **no auto-fallback** until Q7 |
| `R/models_anova.R` | 2×4 and 2×2 RM ANOVA; Mauchly; GG (S1/S2); no sphericity step for 2×2 |
| `R/models_ttest.R` | Paired and one-sample t; Holm families; zero-variance skip |
| `R/models_npar.R` | Wilcoxon, Friedman, named follow-up families |
| `R/effect_sizes.R` | partial η², d, rank-biserial, Kendall’s W + CIs **after** Q9 |
| `R/sensitivity_vision.R` | Re-run primary accuracy + pairwise on subset only |
| `R/export_tables.R` | SAP-named statistics to reusable files |
| `R/export_figures.R` | SAP-required diagnostic histograms; other figures only after Q13 |
| `R/analysis_log.R` | Brief §12 fields |
| `R/utils.R` | Small shared checks (not methodology) |

### 3.2 Study scripts

| File | Responsibility |
|------|----------------|
| `run_all.R` | Master script at project root (Rules §4) |
| `scripts/01_study1.R` | Orchestrate R1.* in Brief §3 / SAP §6 order |
| `scripts/02_study2.R` | Same helpers; researcher exclusion; Difficulty averaging |
| `scripts/03_study3.R` | Same helpers; 2×2 cells; H6/H7; S3 pairwise side coding |
| `R/study1_*.R` `R/study2_*.R` `R/study3_*.R` | Study-specific wrappers only; shared logic stays in `R/utils_*.R` |

### 3.3 Tests

| File | Responsibility |
|------|----------------|
| `tests/testthat/test-structure-study1.R` | 50 IDs; 24/12/4; balanced Condition×K×instance |
| `tests/testthat/test-mapping-study1.R` | Reconstruct preferred_side; one-opt-one-orig; do **not** use Response words |
| `tests/testthat/test-accuracy-recalc.R` | accuracy == (response==answer); mismatch log if Correct differs |
| `tests/testthat/test-vision-score.R` | keys 12,16,29,26; score 0–4; synthetic 48 with score 4 (as a **data** check, not a SAP rule until Q1) |
| `tests/testthat/test-exclusions-study2.R` | researcher dropped; N=50 |
| `tests/testthat/test-no-outcome-exclusions.R` | helpers refuse “drop low accuracy” style APIs |
| `tests/testthat/test-config-switch.R` | changing `data_source` changes the input path only |

Tests assert **structure and derivations**, never that synthetic p-values are “significant.” README_SYNTHETIC_DATA.md: do not interpret synthetic statistics.

### 3.4 Phase 1 scripts already present (not analysis)

`scripts/_phase1_docx_verify.py`, `_phase1_extract_docx_text.py`, `_phase1_profile_synthetic.py`, `_phase1_audit_summary.py` — read-only profiling used for this audit.

---

## 4. How the same code generalizes to Studies 2 and 3

| Shared piece | Study 1 | Study 2 | Study 3 |
|--------------|---------|---------|---------|
| Load + blank-row drop | 4 CSVs | 1 combined | 1 combined |
| Row filters | G1/G2 task names | `(Clone)` task names | `Discrimination Task`; `Task 2 Pairwise Comparison`; `Vision Check (Clone)` |
| Condition recode | baseline/sa | baseline/sa | C1_… / C2_… |
| Accuracy cell | Condition × K (avg 3 configs) | Condition × K (avg 3 difficulties) | Condition × Background (avg K and Difficulty) |
| Pairwise chose_optimized | reconstruct side + filename `optimized` | same + validate raw optimized_side | Response is side; filename `opt`/`orig` |
| Primary ANOVA | 2×4 | 2×4 | 2×2 |
| H pairwise | H3 vs 0.50 | H3 vs 0.50 | H6 vs 0.50 and H7 White−Black |
| RT | paired Orig vs Opt | same | 2×2 ANOVA |
| Vision | N=48 rule | N=43 rule | N=46 rule |
| Fallbacks / ES / Holm | same helpers | same | same (different families) |

Do **not** write three copies of Wilcoxon/ANOVA/Holm.

---

## 5. Study 1 schedule (about one working day, **after** R is installed and BLOCKING questions are answered)

This is a coding schedule, not a claim that work was done.

| Block | Clock (indicative) | Work | Done when |
|-------|--------------------|------|-----------|
| A | 0:00–0:30 | Install R 4.6.1 if possible; `renv::init`; add packages from §8 of UNDERSTANDING **after** verifying they exist | `renv.lock` starts; sessionInfo in log |
| B | 0:30–1:30 | `config/analysis.yml` + `R/config.R` + `R/load_data.R` + `R/dictionary_map.R` + `R/select_trials.R` | Synthetic Study 1 files load; blank-row safe; Object Name emptiness logged |
| C | 1:30–2:30 | `derive_discrimination`, `derive_pairwise` (with QA record), `derive_vision`, `validate_structure`, `exclusions` | Canonical trial tables; 1200/600/200; mapping QA written |
| D | 2:30–3:15 | `summarise_participants` + `rt_preprocess` | 50 × 8 accuracy cells; pairwise proportions; RT scale decision recorded |
| E | 3:15–4:00 | `testthat` structure/mapping/accuracy tests on synthetic | Tests pass on **structure** (NOT EXECUTED until R exists) |
| F | 4:00–5:15 | `assumptions`, `models_anova`, `models_ttest`, `models_npar`, `effect_sizes` using **client-approved** conventions | H1–H3 + fallbacks coded; zero-variance and Holm families |
| G | 5:15–6:00 | Secondaries: RT, AE, signed error, AE×K descriptives | Tables named in SAP §3.3 |
| H | 6:00–6:30 | Vision sensitivity wrapper (primary only) | Parallel tables for N=48 |
| I | 6:30–7:15 | Exports + diagnostic figures + analysis log + README | `scripts/run_study1.R` regenerates outputs |
| J | 7:15–8:00 | Re-run from a clean session; fill Brief §16 checklist; list any still-open flags | No hand-edited numbers |

If BLOCKING questions are **not** answered, stop after block E (load, derive, validate, tests). Do not freeze models or effect sizes.

Studies 2–3 are **not** in the one-day Study 1 path; they reuse helpers once Study 1 is accepted.

---

## 6. Testing strategy

| Layer | What | Data | Must not do |
|-------|------|------|-------------|
| Unit | Recodes, accuracy formula, side reconstruction, vision keys | Tiny hand-made tibbles + synthetic slices | Use real data |
| Structure | Dict §9 counts, balance, ID overlap | Full synthetic Study 1 (then 2/3) | Soften a failed count |
| QA | Mapping mismatch **is** present in synthetic pairwise — tests must still recover the correct side | Study 1 pairwise synthetic | Code from `optimized.png` in Response |
| Exclusion | Study 2 researcher removed; N=50 | Study 2 synthetic | Drop anyone for low accuracy |
| Config | `data_source: real` looks in `data/real/` and errors clearly if empty | empty real dir | Hard-code synthetic IDs into real mode |
| Golden-value | Optional: store derivation checksums (row counts, n score==4) | synthetic | Store synthetic p-values as “expected science” |
| Client run | Fatimah runs `scripts/run_study1.R` on real data | real, local | We do not need the real file |

**NOT EXECUTED** on this machine (no R).

---

## 7. Runtime / dependency risk list (client machine)

| Risk | Why it can break | Mitigation |
|------|------------------|------------|
| R version ≠ 4.6.1 (2026-06-24) | Brief/Dictionary pin this version; this PC has **no R** | README states required version; `R/config.R` warns on mismatch |
| Package not installed / different version | ES and ANOVA defaults differ by version | `renv.lock`; document `sessionInfo()` |
| `afex` / `effectsize` function names or CI methods | TO VERIFY when R exists | Pin versions; record function + arguments in the log |
| Windows paths / spaces (`SAP Categorical Colormap Optimization.docx` already has spaces) | Scripts fail if paths are unquoted | Use `here` or explicit `file.path`; keep data under `data/synthetic` |
| CSV encoding / BOM / `;` vs `,` | Gorilla exports sometimes differ by locale | `readr` locale documented; fail if required columns missing |
| `Participant Public ID` blinded or recycled | Study 1 synthetic is all `BLINDED` | Q6; config `id_column` |
| `Object Name` blank | Dict §10 filters drop all rows | Q5; log and fallback filter only after confirmation |
| Factor level spelling (`sa` vs `SA`, `Left` vs `left`) | `chose_optimized` all 0 | Explicit maps + case policy (Q16) |
| Blank terminal rows (Study 2 and 3) | Types become all-character or extra NA participant | Always drop all-NA rows |
| Missing `renv` / no internet on client PC | Cannot restore packages | README: offline restore instructions; ship `renv.lock` |
| Locale / decimal comma | RT and K parsed wrong | Force `.` decimal in readr |
| Figure devices (cairo, ragg) | PNG/PDF fail | Prefer base png device first |
| Memory | Unlikely (synthetic < 3 MB) | Still avoid holding unused Gorilla metadata in analysis tables |
| Accidental interpretation of synthetic p-values | README forbids it | Scripts print a banner when `data_source: synthetic` |
| We implement before Q7–Q12 | Wrong frozen test/ES | Phase 2 gate |

---

## 8. Implementation gates (do not skip)

1. Fatimah answers BLOCKING Study 1 questions (Q1–Q17), especially Q1–Q12.
2. You confirm this plan.
3. R is installed (target 4.6.1) — until then all R remains **NOT EXECUTED**.
4. Then implement Study 1 only, using shared `R/` so Study 2/3 can follow without a rewrite.
5. Do not change methodology if a helper is inconvenient. Flag instead.

---

## 9. What Phase 1 already did

- Environment check (see close-out in chat).
- Folders, `.gitignore`, copy of originals to `docs/spec/`, zip extract, pandoc conversions, conversion verification, full read, synthetic Python audit.
- Wrote `UNDERSTANDING.md`, `QUESTIONS_FOR_CLIENT.md`, `SAP_TRACEABILITY.md`, this plan.

**Did not do:** any analysis script, any statistical test, any figure that claims to be a SAP result, any move of `cursor_rules.md` (file absent).

---

*End of implementation plan — waiting for confirmation.*
