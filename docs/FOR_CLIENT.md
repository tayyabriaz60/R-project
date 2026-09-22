# Note for Fatimah

**SYNTHETIC DATA: pipeline test only.** Numbers, tables, and figures from the files in this package are pipeline tests, not findings.

Study 1 load through H1–H3, RT/AE, tables, and figures is implemented. Studies 2 and 3 are not.

## Run on your machine (R 4.6.1)

```r
PROJECT_ROOT <- "put/the/path/to/this/folder/here"
source(file.path(PROJECT_ROOT, "run_all.R"))
```

`run_all.R` sources `config/config.R` and `scripts/00_setup.R` for you. Do **not** run `renv::restore()`.

Keep `DATA_SOURCE <- "synthetic"` in `config/config.R` until real file names are set in that same file. Put real exports only under `data/real/` on your computer. Do not email raw participant files.

## Privacy

Shareable logs and tables use anonymous IDs (`S1_P001`, …), never Gorilla Public/Private IDs.

## If something fails on R 4.6.1

Send the **full console text** (no data rows, no IDs). Development was checked on Kaggle with R 4.4.0.

## Still needed from you

- **Q31:** If the real export has duplicate discrimination rows, the scripts will **stop** until you confirm the “configured trial” key and what “earliest” means (Event Index only, or UTC Timestamp then Event Index).
- **Q30:** Colours for the Study 1 figures. Current figures use an Okabe-Ito placeholder, labelled as such.
- **Q7:** Review the diagnostic histograms before any switch to Wilcoxon/Friedman. The scripts do not auto-switch.
