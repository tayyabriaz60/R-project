# To verify on Kaggle

R has **not** been run on the analyst machine. Leave the Result column empty until real Kaggle output is pasted.

| Item | Why unverified | What to check on Kaggle | Result once known |
|------|----------------|-------------------------|-------------------|
| V-A1 `R.version.string` | NOT EXECUTED | Printed at start of Cell 2 | |
| V-A2 `dir.exists("/kaggle")` | NOT EXECUTED | `ENV_NAME` should be `kaggle` | |
| V-A3 `PROJECT_ROOT` resolve | NOT EXECUTED | Config sources without “Could not resolve PROJECT_ROOT” | |
| V-A4 `setwd(PROJECT_ROOT)` | NOT EXECUTED | No permission error on `/kaggle/input` | |
| V-A5 `OUTPUT_DIR` | NOT EXECUTED | `/kaggle/working/output` exists; `logs/` created | |
| V-A6 `session_info.txt` | NOT EXECUTED | File written under `/kaggle/working/output/logs/` | |
| V-A7 `testthat` install | NOT EXECUTED; needs Internet | Installed only if missing; version printed | |
| V-A8 `Ncpus` argument | Guarded; install may not need it | If install runs: no error about unused argument `Ncpus` | |
| V-A9 `require_param("alpha")` | NOT EXECUTED | Prints `0.05` | |
| V-A10 `require_param("vision_subset_rule")` | NOT EXECUTED | Error/message about PENDING a client answer | |
| V-A11 `SEED` | NOT EXECUTED | `20260921` in console and session_info | |
| V-A12 `DATA_SOURCE` | NOT EXECUTED | `synthetic` | |
| V-A13 Pending SAP names | NOT EXECUTED | `vision_subset_rule` and other Q1–Q14 names listed as NA | |

## Packages used in Chunk A

| Package | Sure on CRAN? | Notes |
|---------|---------------|--------|
| base / utils | yes | `read.csv` not used until Chunk B |
| `testthat` | yes (long-standing CRAN) | Installed/loaded in setup; tests themselves are Chunk C |

No other packages. If a name is not in this table, it must not be used until listed here.

## Later chunks

Add rows when Chunk B (load/QC) and Chunk C (tests) are written. Do not mark them verified without pasted output.
