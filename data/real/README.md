# Real Gorilla exports (local only)

Put the unedited Study 1 CSVs in this folder (or a subfolder). Do not rename columns, filter rows, or remove duplicates. The pipeline does that.

Filenames must contain these task ids (the rest of the Gorilla name can stay):

| File | Task id |
|------|---------|
| Discrimination G1 | `task-y3n9` |
| Discrimination G2 | `task-z8oq` |
| Pairwise | `task-yfcn` |
| Vision | `task-hxml` |

Then in `config/config.R` set `DATA_SOURCE <- "real"` and run `run_all.R`.

Study 2 real task ids are not set yet (Q33). Do not guess them. Study 2 real load will stop until Fatimah sends the ids or a combined filename.

Do not commit or email these files.
