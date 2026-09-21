# Handoff — Categorical Colormap Optimization (R / SAP)

Last updated: 22 September 2026. This file is for Tayyab (and any assistant) so work can continue if another chat hits a usage limit.

---

## Business

- **Freelancer:** Tayyab Riaz (Upwork).
- **Client:** Fatimah Alqahtani (PhD student).
- **Contract:** Active. Fixed price **$150** total. Three milestones of **$50**: Study 1, Study 2, Study 3.
- **Scope:** Implementation only, in R, of her **frozen SAP** for three visualization/HCI studies. Follow SAP, then Implementation Brief, then Data Dictionary. Do not change methodology. Flag every ambiguity in `docs/QUESTIONS_FOR_CLIENT.md` **before** changing anything.
- **Privacy:** Synthetic data only in this repo. Fatimah runs the final scripts locally on real data with **R 4.6.1**. Troubleshooting from errors / non-sensitive outputs she shares is in scope.
- **Study 1 deadline:** Originally **Tuesday 22 September 2026**. Q1–Q14 were sent; a ~24-hour extension after her answers was **proposed, not confirmed**. Waiting for her reply.

---

## Technical

- **No local R.** Testing is on **Kaggle** (observed kernel: **R 4.4.0**). Client target: **R 4.6.1**. Write portable R. **No renv.** Use `scripts/00_setup.R`.
- **Private GitHub:** https://github.com/tayyabriaz60/R-project.git  
  On Kaggle: clone into `/kaggle/working/R-project`. Clone already worked (`file.exists(config/config.R)` was TRUE).
- **Rules:** `.cursor/rules/r-analysis.mdc` (always apply). Human copy: `docs/PROJECT_RULES.md`. Old `cursor_rules.md` copies were removed (commit `889d934`).
- **Do not edit:** `docs/spec/`, `data/synthetic/`.
- **Never commit:** real data, `data/real/`, client `.docx`, `*.zip`, `output/`.

---

## Security

- A GitHub token was **accidentally shown in a screenshot**. **Confirm it is revoked** on GitHub (Settings → Developer settings → Personal access tokens).
- Future Kaggle clone: use a **fresh, fine-grained, read-only, short-expiry** token, typed only at runtime, never stored in any file, deleted from the notebook, then **revoked**. Never paste tokens into chat or files.
- Keep the repo **private**. After the project: delete or archive it.

---

## Chunk status

| Chunk | What | Status |
|-------|------|--------|
| Phase 1 | Read specs, questions, plan, synthetic audit | Done (docs only) |
| Chunk A | `config/config.R`, `scripts/00_setup.R`, Kaggle docs | **Verified on Kaggle R 4.4.0** (22 Sep 2026). `testthat` 3.2.2; pending params stay NA. |
| Pre-2A leftovers | `scripts/01_load.R`, old `R/utils_load.R` | **Superseded.** Do not source `01_load.R`. |
| Chunk B | `R/utils_*.R`, `R/study1_load.R`, QC, `run_all.R` | **Verified on Kaggle R 4.4.0** (22 Sep 2026). 1200/600/200; Q1–Q3/Q5/Q6 not applied; no tests. |
| Chunk C | `tests/testthat/`, `tests/run_tests.R`, README | **Written. NOT run on Kaggle yet.** |
| Phase 2B | Summaries, exclusions, tests, ES/CIs, RT/errors, vision, tables/figures | **Blocked on Q1–Q14** |

---

## Pending client questions (Q1–Q14)

Full text: `docs/QUESTIONS_FOR_CLIENT.md`.

1. Q1 — Vision-subset **rule** (size 48 given; inclusion rule missing)
2. Q2 — Study 1 exclusion list and order
3. Q3 — Failed pairwise-mapping rows (drop / NA / stop)
4. Q4 — Incomplete cells / missing trials
5. Q5 — `Object Name` blank: how to filter
6. Q6 — Study 1 participant ID when Public ID is `BLINDED`
7. Q7 — “Severe” non-normality fallback trigger (no invented cutoff)
8. Q8 — Which accuracy vectors for normality histograms
9. Q9 — Effect-size conventions (d, partial η², rank-biserial, CIs)
10. Q10 — Wilcoxon zero-difference convention
11. Q11 — ANOVA Type / contrasts / Condition reference
12. Q12 — Skewness formula (RT log if skewness > 1)
13. Q13 — Figure list / colours / sizes
14. Q14 — Export formats; AE × K 95% CI yes/no

Also open (not 1–14): SAP vs Brief authority (Q21); Brief-only geometric-mean ratio (Q15).

---

## Ordered next steps

1. **Confirm leaked GitHub token is revoked.**
2. **Run Chunk C on Kaggle** (after `git pull`). Paste full console + `study1_log_chunk_c_tests_SYNTHETIC.txt`.
3. When Fatimah answers Q1–Q14: record each answer in `docs/DECISIONS_LOG.md` and `docs/QUESTIONS_FOR_CLIENT.md`, then Phase 2B in small Kaggle-testable chunks (SAP only).
4. **Before delivery:** `run_all.R` clean on a fresh Kaggle session; every SAP item in `docs/SAP_TRACEABILITY.md`; synthetic outputs labelled pipeline-test only; README with setup.
5. **Delivery message (English, honest):** tested on synthetic data on Kaggle with R 4.4.0; her target is R 4.6.1; she should run `scripts/00_setup.R` first; send any difference on her machine for a fix. Then send the Study 1 milestone message.

---

## Git

- Repo: https://github.com/tayyabriaz60/R-project.git (private)
- Branch: `main`
- Known commits: `421aff0` initial; `889d934` remove duplicate rules files; `742806b` HANDOFF; `591a9a9` Chunk B load/QC

---

## Assistant rules (short)

- Never claim code ran without real Kaggle output. Say NOT EXECUTED.
- Never invent results or change SAP methodology.
- If about to leak a secret, over-promise, or skip a check: stop and say so plainly.
- “What next?” → only the **single** next step, with exact cells/commands.
