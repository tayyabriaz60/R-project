"""Focused read-only audit: columns, counts, mismatches vs dictionary."""
from __future__ import annotations

from pathlib import Path

import pandas as pd

root = Path(r"C:\Users\tayyab\Downloads\R-Project\data\synthetic")
out = Path(r"C:\Users\tayyab\Downloads\R-Project\docs\_synthetic_audit.txt")
lines: list[str] = []


def p(s: str = "") -> None:
    lines.append(s)
    print(s)


def show_file(path: Path, title: str) -> pd.DataFrame:
    df = pd.read_csv(path)
    p("=" * 80)
    p(title)
    p(f"path={path.name} rows={len(df)} cols={df.shape[1]} bytes={path.stat().st_size}")
    p(f"fully_blank_rows={int(df.isna().all(axis=1).sum())} duplicate_rows={int(df.duplicated().sum())}")
    p("COLUMNS:")
    for i, c in enumerate(df.columns, 1):
        s = df[c]
        miss = int(s.isna().sum())
        extra = ""
        if pd.api.types.is_numeric_dtype(s):
            nn = s.dropna()
            if len(nn):
                extra = f" min={nn.min()} max={nn.max()} n<=0={(nn<=0).sum()}"
        else:
            extra = f" nunique={s.nunique(dropna=True)}"
        p(f"  {i:3d}. {c!r} dtype={s.dtype} missing={miss}{extra}")
    return df


def vc(df, col, n=30):
    if col not in df.columns:
        p(f"  MISSING COLUMN {col}")
        return
    p(f"  VALUE COUNTS {col}:")
    counts = df[col].value_counts(dropna=False).head(n)
    for k, v in counts.items():
        p(f"    {k!r}: {v}")


# ---------- Study 1 ----------
g1 = show_file(root / "Study1/study1_discrimination_G1_SYNTHETIC.csv", "STUDY1 DISC G1")
g2 = show_file(root / "Study1/study1_discrimination_G2_SYNTHETIC.csv", "STUDY1 DISC G2")
disc = pd.concat([g1.assign(_src="G1"), g2.assign(_src="G2")], ignore_index=True)
p("=" * 80)
p("STUDY1 DISC COMBINED")
p(f"rows={len(disc)}")
for c in [
    "Participant Public ID",
    "Participant Private ID",
    "Task Name",
    "Response Type",
    "Object Name",
    "Spreadsheet: condition",
    "Spreadsheet: colormap",
    "Spreadsheet: num_classes",
    "Spreadsheet: variation",
    "Correct",
    "Response",
]:
    vc(disc, c)

p("\nStudy1 disc IDs:")
p(f"  public unique={disc['Participant Public ID'].nunique()} values={disc['Participant Public ID'].unique()[:10].tolist()}")
p(f"  private unique={disc['Participant Private ID'].nunique()}")
p(f"  rows per private: {disc.groupby('Participant Private ID').size().value_counts().to_dict()}")
p(f"  G1 private n={g1['Participant Private ID'].nunique()} G2 private n={g2['Participant Private ID'].nunique()}")
p(f"  private overlap G1&G2={len(set(g1['Participant Private ID']) & set(g2['Participant Private ID']))}")

# accuracy check
if "Response" in disc.columns and "Spreadsheet: correct_answer" in disc.columns:
    resp = pd.to_numeric(disc["Response"], errors="coerce")
    ans = pd.to_numeric(disc["Spreadsheet: correct_answer"], errors="coerce")
    recalc = (resp == ans).astype("float")
    if "Correct" in disc.columns:
        gor = pd.to_numeric(disc["Correct"], errors="coerce")
        mismatch = int(((recalc != gor) & resp.notna() & ans.notna() & gor.notna()).sum())
        p(f"  accuracy recalc vs Correct mismatches={mismatch}")
    p(f"  response missing={resp.isna().sum()} correct_answer missing={ans.isna().sum()}")
    p(f"  response range={resp.min()}..{resp.max()} answer range={ans.min()}..{ans.max()}")

if "Reaction Time" in disc.columns:
    rt = pd.to_numeric(disc["Reaction Time"], errors="coerce")
    p(f"  RT missing={rt.isna().sum()} min={rt.min()} max={rt.max()} n<=0={(rt<=0).sum()} skew={rt.skew()}")

# cells
cell = disc.groupby(
    ["Participant Private ID", "Spreadsheet: condition", "Spreadsheet: num_classes", "Spreadsheet: variation"]
).size()
p(f"  rows per id x cond x K x var: {cell.value_counts().to_dict()}")
p(f"  cond x K x var counts:\n{pd.crosstab([disc['Spreadsheet: condition'], disc['Spreadsheet: num_classes']], disc['Spreadsheet: variation'])}")

pw = show_file(root / "Study1/study1_pairwise_SYNTHETIC.csv", "STUDY1 PAIRWISE")
for c in [
    "Participant Public ID",
    "Participant Private ID",
    "Task Name",
    "Response Type",
    "Object Name",
    "Spreadsheet: trial_number",
    "Spreadsheet: left_option",
    "Spreadsheet: right_option",
    "Response",
    "Spreadsheet: image_left",
    "Spreadsheet: image_right",
]:
    vc(pw, c)

p(f"  pw public unique={pw['Participant Public ID'].nunique()} values={pw['Participant Public ID'].unique()[:8].tolist()}")
p(f"  pw private unique={pw['Participant Private ID'].nunique()}")
p(f"  pw rows per private: {pw.groupby('Participant Private ID').size().value_counts().to_dict()}")
# mapping reconstruction
left_opt = pw["Spreadsheet: left_option"].astype(str)
right_opt = pw["Spreadsheet: right_option"].astype(str)
resp = pw["Response"].astype(str)
pref = pd.Series("UNMATCHED", index=pw.index)
pref[resp == left_opt] = "left"
pref[resp == right_opt] = "right"
p(f"  preferred_side reconstruction: {pref.value_counts().to_dict()}")
# optimized side from filenames
img_l = pw["Spreadsheet: image_left"].astype(str)
img_r = pw["Spreadsheet: image_right"].astype(str)
p(f"  image_left contains optimized: {(img_l.str.contains('optimized', case=False)).sum()}")
p(f"  image_right contains optimized: {(img_r.str.contains('optimized', case=False)).sum()}")
p(f"  image_left contains baseline: {(img_l.str.contains('baseline', case=False)).sum()}")
p(f"  image_right contains baseline: {(img_r.str.contains('baseline', case=False)).sum()}")
both_opt = img_l.str.contains("optimized", case=False) & img_r.str.contains("optimized", case=False)
both_base = img_l.str.contains("baseline", case=False) & img_r.str.contains("baseline", case=False)
neither = ~(img_l.str.contains("optimized", case=False) | img_r.str.contains("optimized", case=False))
p(f"  both optimized={both_opt.sum()} both baseline={both_base.sum()} neither optimized-token={neither.sum()}")
# label vs side mismatch demonstration
p("  sample of left_option vs image_left (first 8 unique combos):")
combos = pw[["Spreadsheet: image_left", "Spreadsheet: image_right", "Spreadsheet: left_option", "Spreadsheet: right_option", "Response"]].drop_duplicates().head(12)
for _, r in combos.iterrows():
    p(f"    Limg={r['Spreadsheet: image_left']} Rimg={r['Spreadsheet: image_right']} Lopt={r['Spreadsheet: left_option']} Ropt={r['Spreadsheet: right_option']} Resp={r['Response']}")

if "Reaction Time" in pw.columns:
    rt = pd.to_numeric(pw["Reaction Time"], errors="coerce")
    p(f"  PW RT missing={rt.isna().sum()} min={rt.min()} max={rt.max()} n<=0={(rt<=0).sum()}")

vis = show_file(root / "Study1/study1_vision_SYNTHETIC.csv", "STUDY1 VISION")
for c in [
    "Participant Public ID",
    "Participant Private ID",
    "Task Name",
    "Response Type",
    "Object Name",
    "Spreadsheet: tag",
    "Spreadsheet: correct_answer",
    "Response",
    "Correct",
]:
    vc(vis, c)
p(f"  vis private unique={vis['Participant Private ID'].nunique()}")
p(f"  vis rows per private: {vis.groupby('Participant Private ID').size().value_counts().to_dict()}")
resp = pd.to_numeric(vis["Response"], errors="coerce")
ans = pd.to_numeric(vis["Spreadsheet: correct_answer"], errors="coerce")
item_ok = (resp == ans).astype(int)
score = vis.assign(_ok=item_ok).groupby("Participant Private ID")["_ok"].sum()
p(f"  vision_score distribution: {score.value_counts().sort_index().to_dict()}")
p(f"  n with score==4: {(score==4).sum()} n<4: {(score<4).sum()}")

# ID overlap across tasks
ids_d = set(disc["Participant Private ID"])
ids_p = set(pw["Participant Private ID"])
ids_v = set(vis["Participant Private ID"])
p(f"  ID overlap disc&pw={len(ids_d&ids_p)} disc&vis={len(ids_d&ids_v)} all3={len(ids_d&ids_p&ids_v)}")
p(f"  only disc={len(ids_d-ids_p-ids_v)} only pw={len(ids_p-ids_d)} only vis={len(ids_v-ids_d)}")

# ---------- Study 2 ----------
s2 = show_file(root / "Study2/study2_tasks_SYNTHETIC.csv", "STUDY2 COMBINED")
for c in ["Task Name", "Response Type", "Object Name", "Participant Public ID"]:
    vc(s2, c, n=40)
p(f"  S2 public unique={s2['Participant Public ID'].nunique()}")
p(f"  S2 private unique={s2['Participant Private ID'].nunique() if 'Participant Private ID' in s2.columns else 'NO PRIVATE COL'}")
if "Participant Private ID" in s2.columns:
    p(f"  private sample={s2['Participant Private ID'].dropna().unique()[:15].tolist()}")
    p(f"  researcher rows public={(s2['Participant Public ID']=='S2_RESEARCHER_EXCLUDE').sum()}")
    p(f"  researcher in private={(s2['Participant Private ID']=='S2_RESEARCHER_EXCLUDE').sum() if 'Participant Private ID' in s2.columns else 'n/a'}")

# split by task
if "Task Name" in s2.columns:
    for tname, sub in s2.groupby("Task Name", dropna=False):
        p(f"  TASK {tname!r}: rows={len(sub)} public_n={sub['Participant Public ID'].nunique()}")
        if "Response Type" in sub.columns:
            p(f"    Response Type: {sub['Response Type'].value_counts(dropna=False).to_dict()}")
        if "Object Name" in sub.columns:
            p(f"    Object Name: {sub['Object Name'].value_counts(dropna=False).to_dict()}")

# researcher
p(f"  IDs containing RESEARCHER: public={[x for x in s2['Participant Public ID'].dropna().unique() if 'RESEARCH' in str(x).upper() or 'EXCLUDE' in str(x).upper()]}")
if "Participant Private ID" in s2.columns:
    p(f"  private containing RESEARCHER: {[x for x in s2['Participant Private ID'].dropna().unique() if 'RESEARCH' in str(x).upper() or 'EXCLUDE' in str(x).upper()]}")

# condition/K for disc
s2_disc = s2[s2["Task Name"].astype(str).str.contains("Discrimination", na=False)].copy()
p(f"  S2 disc rows={len(s2_disc)}")
for c in ["Spreadsheet: condition", "Spreadsheet: num_classes", "Spreadsheet: variation", "Spreadsheet: colormap"]:
    vc(s2_disc, c)

# vision
s2_vis = s2[s2["Task Name"].astype(str).str.contains("Vision", na=False)].copy()
if "Response Type" in s2_vis.columns:
    s2_vis_r = s2_vis[s2_vis["Response Type"] == "response"]
else:
    s2_vis_r = s2_vis
p(f"  S2 vision response rows={len(s2_vis_r)}")
if "Spreadsheet: tag" in s2_vis_r.columns:
    vc(s2_vis_r, "Spreadsheet: tag")
if "Spreadsheet: correct_answer" in s2_vis_r.columns and "Response" in s2_vis_r.columns:
    idcol = "Participant Public ID"
    resp = pd.to_numeric(s2_vis_r["Response"], errors="coerce")
    ans = pd.to_numeric(s2_vis_r["Spreadsheet: correct_answer"], errors="coerce")
    tmp = s2_vis_r.assign(_ok=(resp == ans).astype(int))
    # exclude researcher if present
    scores = tmp.groupby(idcol)["_ok"].sum()
    p(f"  S2 vision scores all sessions: {scores.value_counts().sort_index().to_dict()}")
    primary = scores[scores.index != "S2_RESEARCHER_EXCLUDE"]
    p(f"  S2 vision scores primary (excl researcher id if present): n={len(primary)} score4={(primary==4).sum()} {primary.value_counts().sort_index().to_dict()}")

# ---------- Study 3 ----------
s3 = show_file(root / "Study3/study3_tasks_SYNTHETIC.csv", "STUDY3 COMBINED")
for c in ["Task Name", "Response Type", "Object Name", "Participant Public ID"]:
    vc(s3, c, n=40)
p(f"  S3 public unique={s3['Participant Public ID'].nunique()}")
if "Participant Private ID" in s3.columns:
    p(f"  S3 private unique={s3['Participant Private ID'].nunique()}")
if "Task Name" in s3.columns:
    for tname, sub in s3.groupby("Task Name", dropna=False):
        p(f"  TASK {tname!r}: rows={len(sub)} public_n={sub['Participant Public ID'].nunique()}")
        if "Response Type" in sub.columns:
            p(f"    Response Type: {sub['Response Type'].value_counts(dropna=False).head(10).to_dict()}")
        if "Object Name" in sub.columns:
            p(f"    Object Name: {sub['Object Name'].value_counts(dropna=False).head(10).to_dict()}")

s3_disc = s3[s3["Task Name"].astype(str).str.contains("Discrimination", na=False)].copy()
p(f"  S3 disc rows={len(s3_disc)}")
for c in [
    "Spreadsheet: participant_group",
    "Spreadsheet: condition_order",
    "Spreadsheet: block_order",
    "Spreadsheet: background",
    "Spreadsheet: condition",
    "Spreadsheet: num_classes",
    "Spreadsheet: difficulty_num",
    "Spreadsheet: difficulty_label",
    "Spreadsheet: scale_factor",
]:
    vc(s3_disc, c)

s3_pw = s3[s3["Task Name"].astype(str).str.contains("Pairwise", na=False)].copy()
p(f"  S3 pairwise rows={len(s3_pw)}")
for c in ["Spreadsheet: background", "Spreadsheet: num_classes", "Spreadsheet: difficulty_label", "Spreadsheet: optimized_side", "Response", "Object Name"]:
    vc(s3_pw, c)

s3_vis = s3[s3["Task Name"].astype(str).str.contains("Vision", na=False)].copy()
if "Response Type" in s3_vis.columns:
    s3_vis_r = s3_vis[s3_vis["Response Type"] == "response"]
else:
    s3_vis_r = s3_vis
p(f"  S3 vision response rows={len(s3_vis_r)}")
if "Spreadsheet: correct_answer" in s3_vis_r.columns and "Response" in s3_vis_r.columns:
    resp = pd.to_numeric(s3_vis_r["Response"], errors="coerce")
    ans = pd.to_numeric(s3_vis_r["Spreadsheet: correct_answer"], errors="coerce")
    tmp = s3_vis_r.assign(_ok=(resp == ans).astype(int))
    scores = tmp.groupby("Participant Public ID")["_ok"].sum()
    p(f"  S3 vision scores: n={len(scores)} score4={(scores==4).sum()} {scores.value_counts().sort_index().to_dict()}")

# blank terminal row
p(f"  S3 last row all-NA={s3.iloc[-1].isna().all()} last public={s3.iloc[-1].get('Participant Public ID')}")

# Compare dictionary required canonical columns vs actual
p("\n" + "=" * 80)
p("CANONICAL vs ACTUAL: synthetic files use RAW Gorilla headers, not dictionary section 8 names")
p("Study1 disc example headers (first 25):")
for c in list(g1.columns)[:25]:
    p(f"  {c}")
p(f"  ... total {len(g1.columns)} columns")

out.write_text("\n".join(lines), encoding="utf-8")
print("WROTE", out, "lines", len(lines))
