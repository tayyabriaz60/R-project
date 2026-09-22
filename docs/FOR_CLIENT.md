# Note for Fatimah

This folder is the Study 1 **pipeline so far** (load, QC, your Q1–Q14 answers in config). It is **not** the finished Study 1 analysis. Summaries, H1–H3, RT/AE, figures, and tables are the next coding step.

## Run on your machine (R 4.6.1)

```r
PROJECT_ROOT <- "put/the/path/to/this/folder/here"
source(file.path(PROJECT_ROOT, "scripts", "00_setup.R"))  # after sourcing config via run_all, or:
source(file.path(PROJECT_ROOT, "run_all.R"))
```

`run_all.R` sources config and setup for you. After it finishes, look at `output/logs/study1_log_data_qc_SYNTHETIC.txt`.

Keep `DATA_SOURCE <- "synthetic"` in `config/config.R` until we add your real file names to that same file. Put real exports only under `data/real/` on your computer. Do not email raw participant files.

## Privacy

Shareable logs and tables must use anonymous IDs (`S1_P001`, …), never Gorilla Public/Private IDs.

## If something fails on R 4.6.1

Send the **full console text** (no data rows, no IDs). Development was checked on Kaggle with R 4.4.0. Any difference will be fixed from that output.

## Still needed from you before the next analysis pieces

- **Q31:** For duplicate discrimination rows, what is the “configured trial” key, and does “earliest” mean Event Index only or UTC Timestamp then Event Index?
- **Q30:** Colours for the Study 1 figures (or say greyscale / that we may propose a colourblind-safe default).
