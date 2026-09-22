# Kaggle run guide

The analyst’s PC does **not** have R. You run R on **Kaggle**. The client later runs the same scripts on **R 4.6.1**.

**Now: re-verify load/QC + helper tests on v3 synthetic** after Q1–Q14 were filled. Chunks A–C on the old synthetic package are already verified; this is a new data + filter pass.

---

## v3 reload (now)

**Cell 1**

```r
setwd("/kaggle/working/R-project")
system("git pull origin main")
print(file.exists("R/utils_select.R"))
print(file.exists("data/synthetic/README_SYNTHETIC_DATA.md"))
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
