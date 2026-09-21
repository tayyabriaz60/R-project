# Decisions log

Every implementation decision with its SAP / brief / dictionary / rules reference.  
Methodological choices that the SAP leaves open are **not** decided here; they are `TODO(client-question #N)` until Fatimah answers.

**R status:** not installed locally. Chunk A and Chunk B were verified from pasted Kaggle output (R 4.4.0). No hypothesis tests have been run.

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

No statistical model, contrast, exclusion rule, or effect-size formula has been chosen beyond what the SAP states explicitly. Hypothesis tests have **not** been run.
