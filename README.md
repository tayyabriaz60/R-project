# Categorical Colormap Optimization — R analysis (Studies 1–3)

Implementation of the **frozen SAP** (21 September 2026). The scripts follow the SAP; they do not change the methodology.

**This repository contains synthetic data only.** Run the same scripts on the real Gorilla export on your own machine. Numbers from synthetic files are pipeline tests, not findings.

## What is ready (22 September 2026)

| Item | Status |
|------|--------|
| Study 1 load, Object Name filter, ID mapping, QC log | Ready (tested on synthetic v3) |
| Your Q1–Q14 answers | Recorded in `config/config.R` and `docs/DECISIONS_LOG.md` |
| Helper unit tests (toy data) | 75 passed on Kaggle |
| Study 1 summaries + Q8 diagnostics | Ready (tested on synthetic v3) |
| Study 1 H1–H3, RT/AE, Q13 tables/figures | Ready (tested on synthetic v3; not findings) |
| Studies 2 and 3 analysis | **Not written yet** |

Development was tested on **Kaggle R 4.4.0**. Your specified version is **R 4.6.1**. Please run `scripts/00_setup.R` first on your machine and send any error text if something differs.

## How you run it

1. Install **R 4.6.1** if it is not already installed.
2. Open R. Set `PROJECT_ROOT` to this folder (the folder that contains `config/`).

```r
PROJECT_ROOT <- "C:/path/to/this/folder"
source(file.path(PROJECT_ROOT, "run_all.R"))
```

That loads Study 1 synthetic files, prepares participant summaries, writes the Q7 fallback-review note, and runs the SAP §3.1–§3.3 parametric tests plus Q13 tables/figures. It does **not** auto-switch to Wilcoxon/Friedman (Q7).

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
| e1071 | Q12 trial-level RT skewness |
| afex | Study 1 2×4 RM-ANOVA (Type III, Mauchly, Greenhouse–Geisser) |
| effectsize | Q9 effect sizes and 95% CIs |
| ggplot2 | Q13 figures |
| officer, flextable | Q14 .docx tables |

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
- Q30 figure colours. Report figures currently use an **Okabe–Ito placeholder** (`#E69F00` Original, `#0072B2` Optimized), labelled on every figure caption. This is a one-line change in `config/config.R` (`figure_colours` / `figure_palette_placeholder`) when you confirm a palette.
- Q31 duplicate-trial key / “earliest” clock (needed before duplicate cleaning)
