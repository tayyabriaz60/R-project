# Categorical Colormap Optimization — R analysis (Studies 1–3)

Implementation of the **frozen SAP** (21 September 2026). Development uses **synthetic data only**. The client runs the final scripts on real data.

## Setup

- **Do not use renv.** Use `scripts/00_setup.R` (installs missing packages only).
- Chunk 1 needs **no extra packages** (base R).
- Analyst machine: R is not installed. Run on **Kaggle** — see `docs/KAGGLE_RUN.md`.
- Client machine: R 4.6.1 (2026-06-24) as specified in the Brief.

## How to run (after PROJECT_ROOT is set)

```r
PROJECT_ROOT <- "path/to/this/folder"   # Kaggle: /kaggle/input/your-dataset
source(file.path(PROJECT_ROOT, "run_all.R"))
```

Switch synthetic vs real in **one place**: `DATA_SOURCE` in `config/config.R`.

## Outputs

- Logs: `output/logs/` (on Kaggle: `/kaggle/working/output/logs/`)
- Synthetic runs are labelled `_SYNTHETIC` — pipeline test only, not findings.

## Documents

- `docs/QUESTIONS_FOR_CLIENT.md` — open decisions
- `docs/SAP_TRACEABILITY.md` — SAP item → code → output
- `docs/DECISIONS_LOG.md` — implementation decisions
- `docs/VERIFY_ON_KAGGLE.md` — what to confirm on Kaggle
