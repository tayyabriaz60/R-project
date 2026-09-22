# Categorical Colormap Optimization — R analysis (Studies 1–3)

Implementation of the **frozen SAP** (21 September 2026). The scripts follow the SAP; they do not change the methodology.

**This repository contains synthetic data only.** Run the same scripts on the real Gorilla export on your own machine. Numbers from synthetic files are pipeline tests, not findings.

## What is ready (22 September 2026)

| Item | Status |
|------|--------|
| Study 1 load, Object Name filter, ID mapping, QC log | Ready (tested on synthetic v3) |
| Your Q1–Q14 answers | Recorded in `config/config.R` and `docs/DECISIONS_LOG.md` |
| Helper unit tests (toy data) | 46 passed on Kaggle |
| Study 1 summaries, H1–H3, RT/AE, figures, tables | **Not written yet** |
| Studies 2 and 3 analysis | **Not written yet** |

Development was tested on **Kaggle R 4.4.0**. Your specified version is **R 4.6.1**. Please run `scripts/00_setup.R` first on your machine and send any error text if something differs.

## How you run it

1. Install **R 4.6.1** if it is not already installed.
2. Open R. Set `PROJECT_ROOT` to this folder (the folder that contains `config/`).

```r
PROJECT_ROOT <- "C:/path/to/this/folder"
source(file.path(PROJECT_ROOT, "run_all.R"))
```

That loads Study 1 synthetic files, applies the Object Name filter, maps Public ID → `participant_id`, writes anonymous reporting IDs (`S1_P001`, …), and writes a QC log. It does **not** run hypothesis tests.

Optional helper tests:

```r
source(file.path(PROJECT_ROOT, "tests", "run_tests.R"))
```

Switch synthetic vs real in **one place**: `DATA_SOURCE` in `config/config.R`. Keep `"synthetic"` until the real export file names are set in that same file.

## Packages

Install with `scripts/00_setup.R` only (missing packages only). Do **not** run `renv::restore()` or `renv::init()`.

| Package | Why |
|---------|-----|
| base / utils | CSV read/write |
| testthat | Helper tests on tiny toy data |

An `renv.lock` may be added later as a **version record** from the test environment. It is not how packages are installed in this project.

## Folder structure

```
config/config.R          # paths, seed, SAP parameters (Q1–Q14 filled)
run_all.R                # Study 1 load + QC
R/                       # shared helpers + Study 1 loaders
scripts/00_setup.R       # install/load packages
tests/                   # toy-data helper tests
data/synthetic/          # v3 synthetic Gorilla-style files
data/real/               # empty; put real exports here on your machine (not in git)
kaggle/                  # cells used for pipeline testing
output/                  # created at run time (logs/tables/figures)
docs/FOR_CLIENT.md       # short run + privacy notes for you
docs/QUESTIONS_FOR_CLIENT.md
docs/DECISIONS_LOG.md
docs/SAP_TRACEABILITY.md
```

## Outputs and privacy

- Synthetic runs use the `_SYNTHETIC` suffix and the label `SYNTHETIC DATA: pipeline test only`.
- Logs are **counts only**. Gorilla IDs are not written to shareable logs.
- Reporting IDs are anonymous (`S1_P001`, …).
- Do not put real participant files in git or send them back to the analyst.

## Open items (do not block the load scripts)

- Q15 geometric-mean RT ratio (Brief only)
- Q16 left/right letter case
- Q17 which RT column if they disagree
- Q30 figure colours (needed when figures are drawn)
- Q31 duplicate-trial key / “earliest” clock (needed before duplicate cleaning)
