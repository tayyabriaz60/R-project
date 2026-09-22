# Categorical Colormap Optimization — R analysis (Studies 1–3)

Implementation of the **frozen SAP** (21 September 2026) for Fatimah Alqahtani’s PhD studies. This repo implements the SAP; it does not change methodology.

**Development uses synthetic data only** (`Synthetic_Data_Tayyab_FINAL_v3`). The client runs the final scripts on real data on her machine. Synthetic outputs are pipeline tests, not findings.

## Status (honest)

| Item | Status |
|------|--------|
| Chunk A (config + setup) | Verified on Kaggle **R 4.4.0** (22 Sep 2026) |
| Chunk B (Study 1 load + QC, v1 synthetic) | Verified on Kaggle **R 4.4.0**. Replaced by v3 reload — **re-verify**. |
| Chunk C (helper unit tests) | Verified on Kaggle **R 4.4.0** (38 passed). Extra select/ID tests added — **re-verify**. |
| Q1–Q14 | Answered 22 Sep 2026 (see `docs/DECISIONS_LOG.md`) |
| Exclusions / summaries / H1–H3 | **Not implemented yet** |
| Client target R | **4.6.1** (2026-06-24). Kaggle kernel used for development is 4.4.0. |

## Packages

Listed in `scripts/00_setup.R`. **Install and load with that script only.**

| Package | Why |
|---------|-----|
| base / utils | CSV read/write, session info |
| testthat | Helper unit tests on tiny toy data |

Later chunks will add `effectsize` and `e1071` (Q9, Q12) when those analyses are written — not before.

### renv.lock is a version record, not the restore path

Fatimah’s export list includes an `renv.lock`. This project **does not use renv to install or restore packages** (no local R on the analyst machine; Kaggle and the client machine use `scripts/00_setup.R`).

- **Do not run `renv::restore()` or `renv::init()` in this project.**
- After a successful Kaggle run, `scripts/write_renv_lock.R` (or `kaggle/run_renv_lock.R`) writes `renv.lock` from the **already-installed** versions of `required_packages`. That file is a record of versions used, so her machine can be compared. It is not how packages are installed here.

## How to run

Set `PROJECT_ROOT` to the folder that **directly** contains `config/`.

```r
PROJECT_ROOT <- "path/to/this/folder"   # Kaggle clone: /kaggle/working/R-project
source(file.path(PROJECT_ROOT, "run_all.R"))           # load + QC
source(file.path(PROJECT_ROOT, "tests", "run_tests.R")) # toy helper tests
# optional version record:
# source(file.path(PROJECT_ROOT, "kaggle", "run_renv_lock.R"))
```

Switch synthetic vs real in **one place**: `DATA_SOURCE` in `config/config.R`. Keep `"synthetic"` until real export file names are specified.

Study 1 identifier column is configurable: `SAP$study1_id_column` (default `participant_public_id` from `Participant Public ID`). Reporting outputs must use `participant_anon_id` (`S1_P001`, …), never Gorilla IDs.

## Outputs

- Logs: `output/logs/` (Kaggle: `/kaggle/working/output/logs/`)
- Synthetic runs use the `_SYNTHETIC` suffix and the label `SYNTHETIC DATA: pipeline test only`
- Logs are aggregates only (counts). No participant IDs or raw rows.

## Documents

- `docs/QUESTIONS_FOR_CLIENT.md` — Q1–Q14 answered; Q15–Q17, Q30, Q31 still open
- `docs/SAP_TRACEABILITY.md` — SAP item → code → output → status
- `docs/DECISIONS_LOG.md` — implementation decisions + quoted answers
- `docs/VERIFY_ON_KAGGLE.md` — what Kaggle output actually showed
- `docs/HANDOFF.md` — how to continue the work
- `docs/KAGGLE_RUN.md` — Kaggle cells
- `docs/Data_Dictionary_Column_Structure_Studies_1_3_FINAL_v2.md` — dictionary v2 working copy
