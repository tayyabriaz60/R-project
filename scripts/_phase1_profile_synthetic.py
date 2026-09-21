"""Read-only profiling of synthetic CSVs against the data dictionary."""
from __future__ import annotations

import json
from collections import Counter
from pathlib import Path

import pandas as pd

root = Path(r"C:\Users\tayyab\Downloads\R-Project\data\synthetic")
out_path = Path(r"C:\Users\tayyab\Downloads\R-Project\docs\_synthetic_profile.json")


def series_profile(s: pd.Series, max_levels: int = 40) -> dict:
    non_null = s.dropna()
    info = {
        "dtype": str(s.dtype),
        "n": int(len(s)),
        "n_missing": int(s.isna().sum()),
        "n_empty_string": int((s.astype(str).str.strip() == "").sum()) if s.dtype == object or str(s.dtype) == "string" else None,
        "n_unique": int(s.nunique(dropna=True)),
    }
    if pd.api.types.is_numeric_dtype(s):
        if len(non_null):
            info.update(
                {
                    "min": float(non_null.min()),
                    "max": float(non_null.max()),
                    "mean": float(non_null.mean()),
                    "median": float(non_null.median()),
                    "n_nonpositive": int((non_null <= 0).sum()),
                }
            )
        else:
            info.update({"min": None, "max": None})
    levels = non_null.astype(str).value_counts(dropna=False)
    if info["n_unique"] <= max_levels:
        info["value_counts"] = {str(k): int(v) for k, v in levels.items()}
    else:
        info["top_10"] = {str(k): int(v) for k, v in levels.head(10).items()}
        info["sample_values"] = [str(x) for x in non_null.astype(str).unique()[:15]]
    return info


def profile_csv(path: Path) -> dict:
    df = pd.read_csv(path)
    cols = list(df.columns)
    # detect fully blank rows
    blank_rows = int(df.isna().all(axis=1).sum())
    # also rows that are all empty strings
    emptyish = int(((df.astype(str).apply(lambda c: c.str.strip()) == "") | df.isna()).all(axis=1).sum())
    report = {
        "file": str(path.relative_to(root)).replace("\\", "/"),
        "bytes": path.stat().st_size,
        "n_rows": int(len(df)),
        "n_cols": int(df.shape[1]),
        "columns": cols,
        "fully_blank_rows": blank_rows,
        "emptyish_rows": emptyish,
        "duplicate_rows": int(df.duplicated().sum()),
        "column_profiles": {c: series_profile(df[c]) for c in cols},
    }
    return report


def extra_study1(reports: dict) -> dict:
    g1 = pd.read_csv(root / "Study1/study1_discrimination_G1_SYNTHETIC.csv")
    g2 = pd.read_csv(root / "Study1/study1_discrimination_G2_SYNTHETIC.csv")
    pw = pd.read_csv(root / "Study1/study1_pairwise_SYNTHETIC.csv")
    vis = pd.read_csv(root / "Study1/study1_vision_SYNTHETIC.csv")
    disc = pd.concat([g1, g2], ignore_index=True)

    def id_col(df):
        for c in ["Participant Private ID", "Participant Public ID", "participant_id"]:
            if c in df.columns:
                return c
        return None

    extra = {}
    for name, df in [("disc_g1", g1), ("disc_g2", g2), ("disc_all", disc), ("pairwise", pw), ("vision", vis)]:
        pid = id_col(df)
        extra[name] = {
            "id_col": pid,
            "n_ids": int(df[pid].nunique()) if pid else None,
            "rows_per_id": df.groupby(pid).size().value_counts().to_dict() if pid else None,
            "public_id_uniques": df["Participant Public ID"].nunique() if "Participant Public ID" in df.columns else None,
            "public_id_values": df["Participant Public ID"].value_counts().head(5).to_dict() if "Participant Public ID" in df.columns else None,
        }

    # discrimination design cells
    cond_col = next((c for c in disc.columns if "condition" in c.lower()), None)
    k_col = next((c for c in disc.columns if "num_classes" in c.lower() or c == "K"), None)
    var_col = next((c for c in disc.columns if "variation" in c.lower()), None)
    extra["disc_factor_cols"] = {"condition": cond_col, "K": k_col, "variation": var_col}
    if cond_col and k_col and var_col:
        pid = id_col(disc)
        cell = disc.groupby([pid, cond_col, k_col, var_col]).size()
        extra["disc_rows_per_cell"] = {str(k): int(v) for k, v in cell.value_counts().items()}
        extra["disc_condition_levels"] = disc[cond_col].value_counts(dropna=False).to_dict()
        extra["disc_K_levels"] = disc[k_col].value_counts(dropna=False).to_dict()
        extra["disc_variation_levels"] = disc[var_col].value_counts(dropna=False).to_dict()

    # pairwise mapping check
    extra["pw_cols_containing"] = [c for c in pw.columns if any(x in c.lower() for x in ["left", "right", "image", "response", "option", "optimized"])]
    extra["vision_item_cols"] = [c for c in vis.columns if any(x in c.lower() for x in ["tag", "correct", "response", "answer"])]
    return extra


reports = {}
for p in sorted(root.rglob("*.csv")):
    if p.name == "SYNTHETIC_MANIFEST.csv":
        continue
    print("PROFILING", p)
    reports[str(p.relative_to(root)).replace("\\", "/")] = profile_csv(p)

summary = {
    "files": reports,
    "study1_extra": extra_study1(reports),
}

# Study 2 / 3 extras
for label, rel in [
    ("study2", "Study2/study2_tasks_SYNTHETIC.csv"),
    ("study3", "Study3/study3_tasks_SYNTHETIC.csv"),
]:
    df = pd.read_csv(root / rel)
    extra = {
        "task_name_counts": df["Task Name"].value_counts(dropna=False).to_dict() if "Task Name" in df.columns else None,
        "response_type_counts": df["Response Type"].value_counts(dropna=False).to_dict() if "Response Type" in df.columns else None,
        "object_name_counts": df["Object Name"].value_counts(dropna=False).to_dict() if "Object Name" in df.columns else None,
        "n_public": int(df["Participant Public ID"].nunique()) if "Participant Public ID" in df.columns else None,
        "n_private": int(df["Participant Private ID"].nunique()) if "Participant Private ID" in df.columns else None,
        "public_ids_sample": df["Participant Public ID"].dropna().astype(str).unique()[:20].tolist() if "Participant Public ID" in df.columns else None,
        "private_ids_sample": df["Participant Private ID"].dropna().astype(str).unique()[:20].tolist() if "Participant Private ID" in df.columns else None,
    }
    if "Participant Public ID" in df.columns:
        extra["public_id_counts_top"] = df["Participant Public ID"].value_counts(dropna=False).head(15).to_dict()
    summary[f"{label}_extra"] = extra

out_path.write_text(json.dumps(summary, indent=2, default=str), encoding="utf-8")
print("WROTE", out_path, "bytes", out_path.stat().st_size)
