# Note for Fatimah

**SYNTHETIC DATA: pipeline test only** when `DATA_SOURCE` is `"synthetic"`. Those numbers are not findings.

Study 1 load through H1–H3, RT/AE, tables, and figures is implemented. Studies 2 and 3 are not.

## Run on your machine (R 4.6.1)

```r
PROJECT_ROOT <- "put/the/path/to/this/folder/here"
source(file.path(PROJECT_ROOT, "run_all.R"))
```

`run_all.R` sources `config/config.R` and `scripts/00_setup.R` for you. Do **not** run `renv::restore()`.

## Real export

1. Put the unedited Gorilla CSVs under `data/real/` (subfolders are fine). Filenames must contain: Discrimination G1 `task-y3n9`, G2 `task-z8oq`, Pairwise `task-yfcn`, Vision `task-hxml`.
2. Do not filter rows, rename columns, or remove duplicates. Object Name filter and Q31 cleaning run inside the pipeline.
3. In `config/config.R` set `DATA_SOURCE <- "real"`.
4. Run `run_all.R` as above.

If more than one file matches a task id, set `REAL_STUDY1_FILES$...` in `config/config.R` to the exact filename.

Do not email raw participant files. If something fails, send the full console text (no data rows, no IDs) and, if needed, the Q7 diagnostic plots.

## Recorded answers (22 Sep 2026)

- **Q30:** Original `#E69F00`, Optimized `#0072B2`.
- **Q31:** key = Participant × Condition × K × configuration_instance (variation). Keep earliest UTC Timestamp; Event Index is the tie-breaker.

## Privacy

Shareable logs and tables use anonymous IDs (`S1_P001`, …), never Gorilla Public/Private IDs.

## Q7 path (locked 22 Sep 2026)

After your review of the real-data diagnostic plots:

- H1: paired Wilcoxon (overall Original vs Optimized accuracy)
- H2: Friedman on Optimized−Original differences at K = 5, 10, 20, 30. Pairwise Wilcoxon + Holm only if Friedman is significant
- H3: one-sample Wilcoxon vs 0.50
- RT: paired t on the analysis scale (log if trial-level skewness > 1)
- AE: paired t
- Vision subset (N = 48): the same tests. Primary N stays 50
