# Categorical Colormap Optimization — R analysis (Studies 1–3)

Implementation of the **frozen SAP** (21 September 2026). The scripts follow the SAP; they do not change the methodology.

**SYNTHETIC DATA: pipeline test only.** This package contains synthetic Gorilla-style files. Every number, table, and figure produced from them is a pipeline test, not a finding. Run the same scripts on the real export on your own machine.

## What is ready (Study 1)

| Item | Status |
|------|--------|
| Load, Object Name filter, ID mapping, QC | Ready (tested on synthetic v3) |
| Q1–Q14 answers in `config/config.R` | Recorded |
| Exclusions / flags (Q2 population, Q3/Q4 gates, Q31 clean) | Ready |
| Participant summaries + Q8 diagnostic histograms | Ready |
| H1–H3, RT, AE, signed error, vision sensitivity | Ready (Q7 locked: H1/H2/H3 npar; RT/AE paired t) |
| Q13/Q14 tables (`.csv` + `.docx`) and figures (`.png` 300 dpi + `.pdf`) | Ready |
| Helper unit tests (toy data) | 79 passed on Kaggle (fresh session) |
| Study 2 load, prepare, H1–H3, RT/AE, tables, figures | Coded (Kaggle of this pipeline: **NOT EXECUTED**) |
| Study 2 test path | SAP recommended ANOVA / t. Study 1 npar lock **not** inherited (Q32) |
| Study 3 | **Not written yet** |

## R versions

| Environment | Version |
|-------------|---------|
| Development / Kaggle test | **R 4.4.0** (2024-04-24) |
| Your target machine | **R 4.6.1** |

Please run `scripts/00_setup.R` first on your machine (or just `run_all.R`, which sources it). If anything fails on 4.6.1, send the full console text (no participant rows, no Gorilla IDs).

## How you run it

1. Install **R 4.6.1** if it is not already installed.
2. Open a **new** R session. Set `PROJECT_ROOT` to this folder (the folder that contains `config/`).

```r
PROJECT_ROOT <- "C:/path/to/this/folder"
source(file.path(PROJECT_ROOT, "run_all.R"))
```

`run_all.R` does, in order, with no manual steps:

1. `config/config.R` (paths, seed, SAP parameters)
2. `scripts/00_setup.R` (install missing packages only, then load them)
3. Study 1 load + QC
4. Population / Q31 duplicate clean / Q3–Q4 gates / participant summaries / Q8 diagnostics
5. Q7 report, then the locked H1/H2/H3 / RT / AE tests
6. H1–H3, RT, AE, signed-error descriptives, vision sensitivity
7. Tables and figures

Optional helper tests (toy data only; no synthetic load):

```r
PROJECT_ROOT <- "C:/path/to/this/folder"
source(file.path(PROJECT_ROOT, "tests", "run_tests.R"))
```

Study 2 (separate from `run_all.R`):

```r
PROJECT_ROOT <- "C:/path/to/this/folder"
source(file.path(PROJECT_ROOT, "run_study2.R"))
```

Switch synthetic vs real in **one place**: `DATA_SOURCE` in `config/config.R`.

For the real export: put the unedited Gorilla CSVs under `data/real/` (filenames must contain `task-y3n9`, `task-z8oq`, `task-yfcn`, `task-hxml`). Do not filter or rename columns. Then set `DATA_SOURCE <- "real"` and run `run_all.R`.

## Packages

Install with `scripts/00_setup.R` only (missing packages only).

**Do not run `renv::restore()` or `renv::init()`.** If an `renv.lock` is present, it is a **version record** from the test environment only. It is not how packages are installed in this project.

| Package | Why |
|---------|-----|
| base / utils | CSV read/write |
| testthat | Helper tests on tiny toy data |
| e1071 | Q12 trial-level RT skewness |
| afex | Study 1 2×4 RM-ANOVA (Type III, Mauchly, Greenhouse–Geisser) |
| effectsize | Q9 effect sizes and 95% CIs |
| ggplot2 | Q13 figures |
| officer, flextable | Q14 `.docx` tables |

## Outputs and privacy

- Synthetic runs use the `_SYNTHETIC` suffix and the label `SYNTHETIC DATA: pipeline test only`.
- Logs are **counts only**. Gorilla IDs are not written to shareable logs.
- Reporting IDs are anonymous (`S1_P001`, …).
- Do not put real participant files in git or send them back to the analyst.

Look first at:

- `output/logs/study1_log_data_qc_SYNTHETIC.txt`
- `output/logs/study1_log_prepare_SYNTHETIC.txt`
- `output/logs/study1_q7_fallback_review_SYNTHETIC.txt`
- `output/logs/study1_log_analysis_SYNTHETIC.txt`
- `output/tables/study1_table_*_SYNTHETIC.csv` (and `.docx`)
- `output/figures/study1_fig_*_SYNTHETIC.png` (and `.pdf`)

## Still open (do not guess)

- Q15 geometric-mean RT ratio (Brief only)
- Q16 left/right letter case
- Q17 which RT column if they disagree

Q30 colours (`#E69F00` Original, `#0072B2` Optimized) and Q31 (Participant × Condition × K × configuration_instance; earliest UTC Timestamp, Event Index tie-break) are recorded and applied.

Q7 is locked (22 Sep 2026, real-data plots): H1 paired Wilcoxon, H2 Friedman (pairwise Wilcoxon + Holm only if Friedman is significant), H3 one-sample Wilcoxon vs 0.50, RT and AE paired t. Vision subset uses the same tests. Primary N stays 50.

## Folder structure

```
config/config.R          # paths, seed, SAP parameters
run_all.R                # Study 1 end-to-end
R/                       # shared helpers + Study 1 analysis
scripts/00_setup.R       # install/load packages (not renv restore)
tests/                   # toy-data helper tests
data/synthetic/          # v3 synthetic Gorilla-style files
data/real/               # empty; put real exports here on your machine
kaggle/                  # optional pipeline-test cells
output/                  # created at run time
docs/FOR_CLIENT.md
docs/QUESTIONS_FOR_CLIENT.md
docs/DECISIONS_LOG.md
docs/SAP_TRACEABILITY.md
```
