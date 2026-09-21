# Categorical Colormap Optimization — R analysis (Studies 1–3)

Implementation of the **frozen SAP** (21 September 2026) for Fatimah Alqahtani’s PhD studies. This repo implements the SAP; it does not change methodology.

**Development uses synthetic data only.** The client runs the final scripts on real data on her machine. Synthetic outputs are pipeline tests, not findings.

## Status (honest)

| Item | Status |
|------|--------|
| Chunk A (config + setup) | Verified on Kaggle **R 4.4.0** (22 Sep 2026) |
| Chunk B (Study 1 load + QC) | Verified on Kaggle **R 4.4.0** (22 Sep 2026). Synthetic row counts: disc 1200, pairwise 600, vision 200. No hypothesis tests. |
| Chunk C (helper unit tests) | Verified on Kaggle **R 4.4.0** (22 Sep 2026). 38 passed, 0 failed. Toy data only. |
| Phase 2B (summaries, H1–H3, figures) | Blocked on client answers Q1–Q14 |
| Client target R | **4.6.1** (2026-06-24). Kaggle kernel used for development is 4.4.0. |

## Packages

Listed in `scripts/00_setup.R`. Install missing only. **Do not use renv.**

| Package | Why |
|---------|-----|
| base / utils | CSV read/write, session info |
| testthat | Helper unit tests on tiny toy data (Chunk C) |

No dplyr/readr. No extra CRAN packages until a later chunk needs them.

## How to run

Set `PROJECT_ROOT` to the folder that **directly** contains `config/`.

```r
PROJECT_ROOT <- "path/to/this/folder"   # Kaggle clone: /kaggle/working/R-project
source(file.path(PROJECT_ROOT, "run_all.R"))          # Chunk B: load + QC
source(file.path(PROJECT_ROOT, "tests", "run_tests.R")) # Chunk C: toy helper tests
```

Kaggle paste-cells: `docs/KAGGLE_RUN.md`, `kaggle/run_notebook.R` (load), `kaggle/run_tests.R` (tests).

Switch synthetic vs real in **one place**: `DATA_SOURCE` in `config/config.R`. Keep `"synthetic"` until real export file names are specified.

## Outputs

- Logs: `output/logs/` (Kaggle: `/kaggle/working/output/logs/`)
- Synthetic runs use the `_SYNTHETIC` suffix and the label `SYNTHETIC DATA: pipeline test only`
- Logs are aggregates only (counts). No participant IDs or raw rows.

## Documents

- `docs/QUESTIONS_FOR_CLIENT.md` — open decisions (Q1–Q14 block Phase 2B)
- `docs/SAP_TRACEABILITY.md` — SAP item → code → output → status
- `docs/DECISIONS_LOG.md` — implementation decisions
- `docs/VERIFY_ON_KAGGLE.md` — what Kaggle output actually showed
- `docs/HANDOFF.md` — how to continue the work
- `docs/KAGGLE_RUN.md` — Kaggle cells
