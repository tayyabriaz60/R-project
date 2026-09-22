# Kaggle run guide

The analyst’s PC does **not** have R. You run R on **Kaggle**. The client later runs the same scripts on **R 4.6.1**.

**Now: re-run H1–H3 after the Mauchly row-name fix** (first run stopped: Mauchly rows `1; 2; 3; 4`). Internet ON if packages need a reinstall.

---

## H1–H3 chunk (now)

**Cell 1 — pull**

```r
setwd("/kaggle/working/R-project")
system("git pull origin main")
print(file.exists("R/study1_analyse.R"))
print(file.exists("R/study1_models.R"))
print(file.exists("R/study1_export.R"))
```

All three must print `TRUE`.

**Cell 2 — full pipeline (paste this whole console back)**

```r
PROJECT_ROOT <- "/kaggle/working/R-project"
source(file.path(PROJECT_ROOT, "kaggle", "run_notebook.R"))
```

**Cell 3 — helper tests (paste this whole console back)**

```r
PROJECT_ROOT <- "/kaggle/working/R-project"
source(file.path(PROJECT_ROOT, "kaggle", "run_tests.R"))
```

### What to paste back

1. Full Cell 2 console, including the **Q7 fallback review** block, the ANALYSIS log, table list, figure list, and `header_has_gorilla_id_column` lines.
2. Full Cell 3 console (`n_passed` / `n_failed` / `n_error`).
3. You do **not** need to paste participant summary rows.

### Send to Fatimah if she is deciding Q7

After Cell 2 succeeds, download and send:

- `/kaggle/working/output/logs/study1_q7_fallback_review_SYNTHETIC.txt`
- these diagnostic PNGs: `study1_diag_accuracy_cells_SYNTHETIC.png`, `study1_diag_h1_diff_SYNTHETIC.png`, `study1_diag_h2_k_diffs_SYNTHETIC.png`, `study1_diag_h3_prop_SYNTHETIC.png`, `study1_diag_rt_diff_SYNTHETIC.png`, `study1_diag_ae_diff_SYNTHETIC.png`

The report says fallback was **not** applied. Do not treat Wilcoxon/Friedman as the Study 1 tests unless she replies that she wants that switch.

### What Cell 2 should show if it actually ran

- Q7: `fallback_applied=FALSE` and the client-review text
- H1 and H2 lines with F, df, p, pes, and a sphericity correction (`none` or `GG`)
- H3 t / p / d
- RT scale `log` (from the last chunk’s Q12 result) and a paired t
- AE paired t
- vision_sensitivity `n_ids=48`
- tables named `study1_table_*_SYNTHETIC.csv` and `.docx`
- figures `study1_fig_*_SYNTHETIC.png` and `.pdf`
- every inferential CSV `header_has_gorilla_id_column=FALSE`
- no Wilcoxon / Friedman lines

If Mauchly extraction or `eta_squared` column names fail, paste the full error. Do not invent a workaround.

Nothing is “passed” until you paste the notebook output.

---

## Prepare chunk (verified 22 Sep 2026)

Internet must be **ON** (`e1071` may need to install).

---

## Prepare chunk (now)

**Cell 1 — pull the new files** (do not paste tokens into chat)

If `/kaggle/working/R-project` already exists:

```r
setwd("/kaggle/working/R-project")
system("git pull origin main")
print(file.exists("R/study1_prepare.R"))
print(file.exists("R/study1_diagnostics.R"))
print(file.exists("kaggle/run_notebook.R"))
```

All three must print `TRUE`. If the folder is missing, clone first (type a **fresh read-only token** only in the notebook, then delete that cell):

```r
setwd("/kaggle/working")
system("git clone https://<TOKEN>@github.com/tayyabriaz60/R-project.git R-project")
print(file.exists("/kaggle/working/R-project/R/study1_prepare.R"))
```

**Cell 2 — load + prepare** (this is the cell to paste back in full)

```r
PROJECT_ROOT <- "/kaggle/working/R-project"
source(file.path(PROJECT_ROOT, "kaggle", "run_notebook.R"))
```

**Cell 3 — helper tests** (paste this console back too)

```r
PROJECT_ROOT <- "/kaggle/working/R-project"
source(file.path(PROJECT_ROOT, "kaggle", "run_tests.R"))
```

### What to paste back

1. The **full Cell 2 console**, including the PREPARE log, summary header, `n_data_rows=`, `header_has_gorilla_id_column=`, and the diagnostic PNG list.
2. The **full Cell 3 console**, including the testthat summary and `n_passed` / `n_failed` / `n_error`.

### What Cell 2 should look like if it actually ran (do not treat as pass until pasted)

- Q3 `mapping_fail_rows=0` (gate passed; no stop)
- Q4 all incomplete counts `=0` (gate passed; no stop)
- Q31 `applied=FALSE`; `n_dup_keys=0`; `n_rows_would_drop=0` on this synthetic
- Q2 `n_unique_participant_id=50`
- summaries `n_participants=50`
- summary `n_data_rows=50`
- `header_has_gorilla_id_column=FALSE`
- three PNGs: `study1_diag_accuracy_cells_SYNTHETIC.png`, `study1_diag_h1_diff_SYNTHETIC.png`, `study1_diag_h2_k_diffs_SYNTHETIC.png`
- Q7 line: fallback NOT applied; H1–H3 were not run
- Q12 `trial_rt_skewness=` a number (or NA) and `analysis_scale=` `raw` or `log`

If Q3 or Q4 fires a `stop()`, paste the full error. That is a real gate, not a crash to “fix” by dropping rows.

Nothing new is “passed” until you paste the notebook output.

---

## v3 reload (previous)

**Cell 1 — find or clone (do not `setwd` until the folder exists)**

```r
cat("R version: ", R.version.string, "\n", sep = "")
print(list.files("/kaggle/working", recursive = FALSE))
print(list.files("/kaggle/input", recursive = FALSE))
print(dir.exists("/kaggle/working/R-project"))
```

If that last line is `FALSE`, this session has no clone. Clone once (type a **fresh read-only token** only in the notebook, never paste it into chat, then delete the cell):

```r
setwd("/kaggle/working")
system("git clone https://<TOKEN>@github.com/tayyabriaz60/R-project.git R-project")
print(file.exists("/kaggle/working/R-project/config/config.R"))
print(file.exists("/kaggle/working/R-project/R/utils_select.R"))
```

If `dir.exists("/kaggle/working/R-project")` is already `TRUE`:

```r
setwd("/kaggle/working/R-project")
system("git pull origin main")
print(file.exists("R/utils_select.R"))
```

**Cell 2 — load + QC**

```r
PROJECT_ROOT <- "/kaggle/working/R-project"
source(file.path(PROJECT_ROOT, "kaggle", "run_notebook.R"))
```

**Cell 3 — helper tests**

```r
PROJECT_ROOT <- "/kaggle/working/R-project"
source(file.path(PROJECT_ROOT, "kaggle", "run_tests.R"))
```

**Cell 4 — optional version-record lockfile (not restore)**

```r
PROJECT_ROOT <- "/kaggle/working/R-project"
source(file.path(PROJECT_ROOT, "kaggle", "run_renv_lock.R"))
```

Paste the full console from Cells 2–3 (and 4 if you run it). Expect on Cell 2: disc/pw/vis **1200/600/200** after Object Name filter; **50** unique `participant_id`; Object Name missing **0**; vision n_score4 **48**; no Gorilla IDs in the log; “No tests run”.

Nothing new is “passed” until you paste the notebook output.

If the notebook already has a clone at `/kaggle/working/R-project`, pull first, then run the Chunk C cell below. Older Chunk A/B cells on this page are kept for a fresh setup.

---

## Chunk C (now) — helper tests

**Cell 1** (do not paste tokens into chat)

```r
setwd("/kaggle/working/R-project")
system("git pull origin main")
print(file.exists("tests/run_tests.R"))
print(file.exists("kaggle/run_tests.R"))
```

Both should print `TRUE`.

**Cell 2**

```r
PROJECT_ROOT <- "/kaggle/working/R-project"
source(file.path(PROJECT_ROOT, "kaggle", "run_tests.R"))
```

Paste the full console (including the testthat summary and the Chunk C test log).

Expected when it is actually OK: `n_failed=0`, `n_error=0`, and the line `No statistical tests were run. No synthetic data were loaded.`

---

## 1. Create a private Dataset from the project

1. On your computer, select these files/folders (you can zip the whole project):
   - `config/config.R`
   - `scripts/00_setup.R`
   - `kaggle/run_notebook.R`
   - `docs/KAGGLE_RUN.md` (optional)
   - `data/synthetic/` (needed from Chunk B onward; harmless to include now)
2. Go to [kaggle.com](https://www.kaggle.com) → **Datasets** → **New Dataset**.
3. Upload the zip or folder.
4. Set visibility to **Private**.
5. Create the dataset. Note the name you gave it (the “slug”).

After upload, Kaggle mounts it under `/kaggle/input/<slug>/`. If the zip had a top folder, there is one extra directory.

---

## 2. Create an R notebook and attach the dataset

1. **Create** → **New Notebook**.
2. In the notebook settings, set the language / kernel to **R** (not Python).
3. **Add Data** → select your private dataset.
4. **Internet**: turn **ON** for Chunk A (`testthat` may need to install).
   - If Kaggle asks for **phone verification** before Internet works, complete that first. Without Internet, setup will skip install only if `testthat` is already on the image; if install is required and Internet is off, the script will stop with a clear message.

---

## 3. Cell 1 — print R version and find PROJECT_ROOT

Paste and run:

```r
cat("R version: ", R.version.string, "\n", sep = "")
print(list.files("/kaggle/input", recursive = FALSE))
input_top <- list.files("/kaggle/input", full.names = TRUE)
print(input_top)
if (length(input_top) >= 1L) {
  print(list.files(input_top[[1]], recursive = FALSE))
}
```

`PROJECT_ROOT` must be the folder that **directly** contains `config/` (so `config/config.R` exists).

Check:

```r
# EDIT this path after you inspect the listing above
PROJECT_ROOT <- "/kaggle/input/YOUR_DATASET_SLUG"
print(file.exists(file.path(PROJECT_ROOT, "config", "config.R")))
```

That last line must print `TRUE`. If it is `FALSE`, you are one folder too high or too low. List again and fix the path.

You can also set:

```r
Sys.setenv(PROJECT_ROOT = PROJECT_ROOT)
```

---

## 4. Cell 2 — run Chunk A (config + setup)

```r
source(file.path(PROJECT_ROOT, "kaggle", "run_notebook.R"))
```

`kaggle/run_notebook.R` for Chunk A will:

1. Print `R.version.string`
2. Source `config/config.R`
3. Source `scripts/00_setup.R` (install `testthat` if missing, then load it)
4. Print which `SAP` parameters are filled vs `NA`
5. Prove `require_param("alpha")` works and `require_param("vision_subset_rule")` **stops** (caught only for this demo print)
6. Write `/kaggle/working/output/logs/session_info.txt`

---

## 5. Cell 3 — show logs (paste this whole output back)

```r
log_dir <- "/kaggle/working/output/logs"
print(list.files(log_dir, full.names = TRUE))
cat(readLines(file.path(log_dir, "session_info.txt")), sep = "\n")
```

Also paste the **full console** from Cells 1–2, including any error.

---

## 6. Where outputs are

| Path | What |
|------|------|
| `/kaggle/working/output/logs/session_info.txt` | R version, env, seed, package versions, `sessionInfo()` |

Download: notebook **Output** / `/kaggle/working` → download `output`.

---

## 7. What “looks complete” for Chunk A (do not treat as pass until pasted)

- A line starting `R version:`
- `ENV_NAME=kaggle` (or equivalent message)
- `DATA_SOURCE=synthetic`
- `SEED=20260921`
- `testthat` version printed
- `session_info.txt` exists
- `require_param("vision_subset_rule")` produces a stop message about PENDING a client answer (that is intended)

---

## 8. Later (client machine, not now)

Set `PROJECT_ROOT` to her project folder. `IS_KAGGLE` will be false. Outputs go to `output/` inside the project. Keep `DATA_SOURCE <- "synthetic"` until real file names are specified.
