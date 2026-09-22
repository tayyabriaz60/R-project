# Questions for the client (Fatimah)

**Purpose:** Every inconsistency or missing decision from `docs/UNDERSTANDING.md` §7, written so it can be sent without changing the frozen SAP on our side.  
**Format:** official fields from `.cursor/rules/cursor_rules.md` §1 — **Where / Issue / Options / Impact**. Rank, blocked-code note, and suggested wording are extra for you.  
**Blocked code rule:** each unanswered blocking item will be `TODO(client-question #N)` and must `stop()` if reached; no guessed fill-in.  
**R:** not installed; nothing below is a statistical result.

**Q1–Q14 were answered by Fatimah on 22 September 2026.** Quoted answers and implementation notes are in `docs/DECISIONS_LOG.md`. Status on each item below is **Answered** unless a follow-up is marked.

Still open for Study 1: Q15–Q17, Q30 (figure colours), Q31 (Q2 duplicate-trial key / “earliest” clock). Study 2–3: Q18–Q20. Non-blocking: Q21–Q23, Q25–Q26, Q28–Q29. Q24 is closed by Q9 (Kendall’s W 95% CI).

---

## How to send

A short polite cover note is at the bottom. You can paste the BLOCKING Study 1 questions first.

---

## BLOCKING Study 1

### Q1 — Answered 22 Sep 2026
- **Status:** Answered.
- **Fatimah:** “vision score = 4/4. Primary N=50; vision sensitivity subset N=48. Sensitivity analysis only, not a primary exclusion.”
- **Where:** SAP §3.4 vision-screen subset N = 48; Dictionary §7 `vision_subset_flag`; Brief §11 table (48 / 43 / 46).
- **Issue:** The documents give the **size** of the vision-screen subset but not the **rule** that selects those participants. Dictionary says to use “the already-defined vision-screen sensitivity rule” and not to redefine it from the outcome data. That rule is not written in the SAP, Brief, or Dictionary.
- **Options:** (A) include participants with vision_score = 4 (this is how the synthetic README was built: 48/50, 43/50, 46/50). (B) some other prespecified rule (e.g. ≥3/4) that is not in these files.
- **Impact:** Changes who is in the N = 48 sensitivity analysis and whether we may conclude that “conclusions change.”
- **Until answered:** Will compute `vision_score` (0–4) and **will not** freeze `vision_subset_flag` or run sensitivity as a final deliverable.
- **Suggested message:** “The SAP gives vision-screen subset sizes (Study 1 N = 48) but not the inclusion rule. The synthetic files treat score 4/4 as the subset. Please confirm the frozen rule (for example: all four Ishihara-style items correct) so we do not redefine it from the data.”

### Q2 — Answered 22 Sep 2026
- **Status:** Answered (follow-up: Q31 before applying the duplicate rule).
- **Fatimah:** “primary population = all 50 recruited participants, no outcome-based exclusion. Pre-recruitment self-test session is outside the sample. For duplicate discrimination responses: keep the earliest valid response per participant x configured trial, tie-broken by Event Index.”
- **Where:** SAP §1 “predefined primary analysis populations and documented data-cleaning rules”; Study 1 has **no named participant exclusions** (Study 2 names the researcher session). Dictionary §1: do not infer eligibility from raw row counts.
- **Issue:** Study 1 exclusion list and **exact order** of exclusions are not specified.
- **Options:** (A) no Study 1 participant exclusions; analyse all 50 completers. (B) a reconciliation/exclusion SOP exists that was not in this handoff (incomplete tasks, duplicate sessions, failed attention, etc.).
- **Impact:** On real data this can change primary N and every p-value.
- **Until answered:** On synthetic data we will treat the 50 private IDs as the analysis population and will **not** invent extra exclusions. Real-data SOP still required.
- **Suggested message:** “For Study 1, please confirm there are no participant-level exclusions beyond the N = 50 primary population, and the exact order of any session-reconciliation rules we must apply before building the analysis dataset.”

### Q3 — Answered 22 Sep 2026
- **Status:** Answered.
- **Fatimah:** “if a row can't be mapped unambiguously, do NOT guess/exclude/recode automatically. Flag it and stop; report to client before continuing pairwise analysis.”
- **Where:** Brief §4; Dictionary §4.2. Failed pairwise mapping/QA rows: “flag … rather than guessing.”
- **Issue:** Not stated whether a failed trial is dropped from that participant’s Optimized-choice proportion, set to missing, or stops the run.
- **Options:** (A) drop the trial and use remaining trials as the denominator. (B) set `chose_optimized` to NA and still use 12 as denominator. (C) exclude the participant. (D) halt and wait.
- **Impact:** Directly changes H3 (and the vision-sensitivity H3).
- **Until answered:** Will implement QA flags and **will not** silently drop or recode failed rows.
- **Suggested message:** “If a Study 1 pairwise row fails the left/right mapping or the one-Optimized-plus-one-Original check, should we drop that trial from the participant’s proportion, treat it as missing, exclude the participant, or stop the script?”

### Q4 — Answered 22 Sep 2026
- **Status:** Answered.
- **Fatimah:** “expected complete structure is 24 discrimination + 12 pairwise trials/participant. If real data don't meet this, FLAG and stop rather than auto-excluding or computing from incomplete cells.”
- **Where:** SAP §1; Dictionary §9. Missing trials / incomplete Condition × K cells.
- **Issue:** No rule for a participant with fewer than 3 configuration instances in a cell, or fewer than 12 pairwise trials.
- **Options:** (A) drop the participant from analyses that need that cell. (B) average over available trials. (C) flag and stop.
- **Impact:** Changes cell means, ANOVA N, and H3 denominator.
- **Until answered:** Synthetic data are complete (24/12/4). We will add a structural check that **fails loudly** on incomplete cells rather than imputing.
- **Suggested message:** “If a participant is missing one or more Study 1 trials, should we exclude that person from the affected analysis, average over the trials they have, or stop for your review?”

### Q5 — Answered 22 Sep 2026
- **Status:** Answered.
- **Fatimah:** “keep the filter. Populated in real Gorilla files as: Discrimination -> "Response", Pairwise -> "Image Response", Vision -> "Number Entry". Blank was a synthetic-data-only bug, now fixed in v3.”
- **Where:** Dictionary §10 Object Name filters vs earlier synthetic files (`Object Name` was 100% missing). v3 populates the tokens.
- **Issue:** Applying Object Name = `Response` / `Image Response` / `Number Entry` as written would drop **every** synthetic row. We do not know whether real Gorilla exports populate Object Name.
- **Options:** (A) on files where Object Name is empty, select by Task Name + Response Type only. (B) real data will have Object Name and we must filter. (C) different object names than the dictionary.
- **Impact:** Empty analysis dataset vs including extra rows (e.g. confidence responses) if the filter is too loose.
- **Until answered:** Synthetic pipeline will select Task Name + Response Type = `response` and will log that Object Name was empty.
- **Suggested message:** “The dictionary tells us to keep rows with specific Object Name values, but Object Name is entirely blank in the synthetic files. Does the real Study 1 export fill Object Name (`Response`, `Image Response`, `Number Entry`)? If it is also blank, may we select using Task Name and Response Type only?”

### Q6 — Answered 22 Sep 2026
- **Status:** Answered.
- **Fatimah:** “use Participant Public ID as the Study 1 identifier (configurable in code, not hard-coded). Participant Private ID may be kept for internal QA only. NEVER include the real ID in tables/figures/logs/exports meant for reporting - replace with an anonymous sequential ID like S1_P001, S1_P002, ... in any output.”
- **Where:** Dictionary v2 §3 `participant_id` ← Participant Public ID; v3 dummy Public IDs `S1PUB001`–`S1PUB050`.
- **Issue:** The dictionary’s primary ID is unusable on the synthetic Study 1 files and may be blinded on the real export too.
- **Options:** (A) use Private ID whenever Public ID is `BLINDED` or non-unique. (B) Fatimah will unblind locally. (C) a specified reconciliation key (Schedule ID / External Session ID — the latter is empty in Study 1 synthetic).
- **Impact:** Wrong merging of discrimination, pairwise, and vision; incorrect N.
- **Until answered:** Synthetic Study 1 will key on `Participant Private ID` and document it. We need the real-data rule before you run locally.
- **Suggested message:** “Study 1 Public IDs are all `BLINDED` in the synthetic files. Which identifier should the scripts use on your real Study 1 export (Private ID, unblinded Public ID, or another key)?”

### Q7 — Answered 22 Sep 2026
- **Status:** Answered.
- **Fatimah:** “no new numerical cutoff. Generate the SAP-specified diagnostics, then STOP and send them to the client before switching to a fallback test. Do not auto-switch.”
- **Where:** SAP §3.1 fallback “severe deviations from normality”; Brief §9: do not invent a cutoff; flag before switching.
- **Issue:** We cannot both follow the SAP fallback **and** refuse to invent a cutoff without a decision rule from you.
- **Options:** (A) we always produce histograms (and optional numeric skewness **for your eyes only**), you decide fallback **before** we look at Condition p-values, and we code both paths. (B) you later supply a numeric rule to freeze. (C) with N = 50 you want us to stay parametric unless you say otherwise.
- **Impact:** Switches the reported H1/H2/H3 (and RT/AE) tests.
- **Until answered:** We will implement **both** parametric and fallback code, write diagnostics to the analysis log, and **will not** auto-switch on an invented threshold.
- **Suggested message:** “The SAP switches to Wilcoxon/Friedman when accuracy or proportions show ‘severe’ non-normality, but it gives no number. The Brief says we must not invent a cutoff and must ask you. How would you like Study 1 fallbacks decided (you review the histograms before we lock the test, or a rule you want us to program)?”

### Q8 — Answered 22 Sep 2026
- **Status:** Answered.
- **Fatimah:** “histograms for (a) the 8 participant-level Condition x K accuracy vectors, (b) overall Optimized-Original accuracy difference for H1, (c) the four K-specific Optimized-Original difference vectors for H2.”
- **Where:** SAP §3.1 “histograms of the participant-level accuracy data.”
- **Issue:** Unclear which participant-level accuracy values to inspect (8 cells, 2 condition means, residuals, difference scores).
- **Options:** listed above.
- **Impact:** Can change whether you judge the distribution “severe” (Q7).
- **Until answered:** We can produce **all** of those histograms as diagnostics, labelled as such, without using them to auto-switch.
- **Suggested message:** “For the Study 1 normality histograms, which participant-level accuracy values should we plot: each Condition × K cell, the two Condition means, ANOVA residuals, or all of these?”

### Q9 — Answered 22 Sep 2026
- **Status:** Answered.
- **Fatimah:** “RM-ANOVA -> partial eta squared with two-sided 95% CI; paired comparisons -> Cohen's dz with two-sided 95% CI; H3 -> one-sample Cohen's d relative to 0.50; Wilcoxon -> rank-biserial correlation with two-sided 95% CI; Friedman -> Kendall's W with 95% CI. Use the effectsize package consistently; record package/function versions.”
- **Where:** Brief §10; SAP reporting of partial η², Cohen’s d, rank-biserial, and 95% CIs.
- **Issue:** The SAP names the effect sizes but not the computational convention. Brief forbids a silent choice.
- **Options:**  
  - Paired d: mean difference / SD of differences (d_z) vs d_av vs other.  
  - One-sample d: (mean − 0.50) / SD.  
  - Partial η²: SS_effect / (SS_effect + SS_error) with an F-based CI vs bootstrap.  
  - Rank-biserial: several signed formulas; CI via bootstrap vs analytic.
- **Impact:** Different numbers in every primary table even if p-values match.
- **Until answered:** We will **not** freeze ES functions. We can implement a candidate set once you pick.
- **Suggested message:** “Please approve one convention each for: (1) paired Cohen’s d, (2) one-sample Cohen’s d, (3) partial eta-squared and its 95% CI, (4) rank-biserial and its 95% CI. We will not pick among standard alternatives ourselves.”

### Q10 — Answered 22 Sep 2026
- **Status:** Answered.
- **Fatimah:** “omit exact-zero paired differences before ranking, report the effective non-zero N, and use the same non-zero differences for the rank-biserial effect size.”
- **Where:** Brief §9.1 Wilcoxon zero differences.
- **Issue:** Convention not frozen. Brief describes the common convention (omit zeros; report n of non-zero pairs) as an “if”.
- **Options:** (A) standard omit-zeros (`stats::wilcox.test`). (B) Pratt include-zeros. (C) another.
- **Impact:** Changes V, p, effective N, rank-biserial.
- **Until answered:** Will not freeze Wilcoxon code defaults.
- **Suggested message:** “For Wilcoxon tests, may we use the usual convention of dropping zero paired differences and reporting the number of non-zero pairs, consistently across Studies 1–3?”

### Q11 — Answered 22 Sep 2026
- **Status:** Answered.
- **Fatimah:** “Type III sums of squares, sum-to-zero contrasts. Condition levels ordered Original, Optimized. K levels ordered 5, 10, 20, 30. Report paired differences as Optimized minus Original.”
- **Where:** SAP §3.1 2 × 4 RM ANOVA; no software/type/contrast statement.
- **Issue:** ANOVA Type (I/II/III), contrast coding, and sphericity correction details (GG only; no ε threshold) are unspecified.
- **Options:** (A) Type III with sum-to-zero contrasts (common in `afex`). (B) Type I `aov` with default treatment contrasts. (C) other.
- **Impact:** Usually small if fully balanced (synthetic Study 1 is balanced); can matter on real/unbalanced data. Also determines how we extract the Condition and Condition × K lines the SAP wants.
- **Until answered:** Will not freeze the ANOVA engine.
- **Suggested message:** “For the 2 × 4 repeated-measures ANOVA, please confirm the implementation we should freeze (for example Type III sums of squares with sum-to-zero contrasts, Mauchly, and Greenhouse–Geisser when Mauchly is significant). Also confirm the reference level for Condition, if any.”

### Q12 — Answered 22 Sep 2026
- **Status:** Answered.
- **Fatimah:** “e1071::skewness(x, type = 2, na.rm = TRUE), computed on valid Study 1 discrimination trial-level RTs BEFORE participant-level averaging. If skewness > 1, apply the SAP's natural-log transform.”
- **Where:** SAP §3.3.1 “skewness coefficient”; trigger > 1.
- **Issue:** Which skewness formula (e.g. type 1/2/3) is not named. Synthetic Study 1 discrimination RT skew was about 1.18 in Python pandas — near the boundary, so the estimator can change whether we log-transform.
- **Options:** several R functions (`e1071::skewness` types, `moments`, `psych`).
- **Impact:** Changes the RT analysis scale for every participant and all RT p-values/ES.
- **Until answered:** Will compute trial-level skewness but will not freeze the estimator.
- **Suggested message:** “The SAP log-transforms RT when trial-level skewness > 1. Which skewness formula/function should we freeze in R so the decision is reproducible on your machine?”

### Q13 — Answered 22 Sep 2026
- **Status:** Answered (figure **list**). Colours still open: **Q30**.
- **Fatimah:** “Accuracy (Condition x K with 95% CI), Pairwise (Optimized-choice proportion with 95% CI and a 0.50 reference line), RT (descriptive RT by Condition), Absolute Error (Condition x K descriptives), Signed Error (table only), assumption histograms saved separately as diagnostics only.”
- **Where:** SAP §6 “relevant visualizations”; Brief §3 “planned visualizations”; Brief §14 “figures/plots specified by the SAP/reporting plan.”
- **Issue:** No reporting plan was supplied. No figure list, geometry, axes, labels, colours/colormap, or sizes.
- **Options:** (A) you will send a figure list. (B) we may propose thesis-standard plots **for your approval** (not invent as SAP). (C) tables only until you specify plots.
- **Impact:** We cannot truthfully say figures follow the SAP until they are specified.
- **Until answered:** No analysis figures will be invented as if they were SAP-specified. Diagnostic histograms required by the SAP **are** specified and will be produced.
- **Suggested message:** “The SAP asks for relevant visualizations but does not list figure types, axes, labels, colours, or sizes, and we do not have a separate reporting plan. Could you send the Study 1 figure list (or confirm we should only produce the diagnostic histograms plus any plots you name)?”

### Q14 — Answered 22 Sep 2026
- **Status:** Answered.
- **Fatimah:** “tables -> .docx + .csv; figures -> .png at 300dpi + vector .pdf; reusable outputs -> .csv/.rds; R scripts, README, an analysis log, and an renv lockfile. AE x K: descriptive mean/SD/95% CI only, no inferential test.”
- **Where:** Brief §14 “reusable formats”; Brief §8.2 AE × K 95% CI “if this is part of the final reporting template.”
- **Issue:** No table template and no export-format list (CSV, RDS, DOCX, PNG, PDF, …).
- **Options:** (A) CSV + PNG is enough. (B) Word/LaTeX tables to a thesis template you will send.
- **Impact:** Wrong delivery format; optional AE CIs included or omitted.
- **Until answered:** We can export machine-readable CSV of every numbered statistic the SAP names, plus PNG histograms. Thesis styling waits.
- **Suggested message:** “Please confirm the export formats you want (for example CSV + PNG, or Word tables) and whether Absolute Error by Condition × K should include 95% CIs or only mean and SD.”

### Q15 — BLOCKING Study 1
- **Where:** Brief §8.1 geometric-mean ratio for log RT vs SAP §3.3.1 (untransformed ms descriptives + inference on log; no ratio).
- **Issue:** The geometric-mean ratio is in the Brief only. Brief says it does not create new hypotheses, but it is extra reporting.
- **Options:** (A) include as Brief-required reporting. (B) omit unless added to the SAP.
- **Impact:** Extra RT number and labelling (Original/Optimized ratio).
- **Until answered:** Will report untransformed ms descriptives as the SAP requires; will not add the ratio unless you confirm.
- **Suggested message:** “The Brief asks us to exponentiate the paired log-RT difference as an Original/Optimized geometric-mean ratio. That sentence is not in the SAP body. Should Study 1 include it?”

### Q16 — BLOCKING Study 1
- **Where:** Brief §4 `preferred_side = "left"` / `"right"` (lowercase).
- **Issue:** Equality is case-sensitive in R. Study 3 raw responses are `Left`/`Right`. Study 1 derived sides must match `optimized_side` labels.
- **Options:** (A) always store lowercase and compare case-insensitively. (B) follow Brief strings for Study 1 and Dictionary Left/Right for Study 3.
- **Impact:** A case mismatch would zero-out `chose_optimized`.
- **Until answered:** Will normalise sides to a single case internally and document it — please confirm that is acceptable.
- **Suggested message:** “May we treat left/right side labels as case-insensitive when computing chose_optimized, so `"left"` and `"Left"` cannot silently disagree?”

### Q17 — BLOCKING Study 1
- **Where:** Dictionary §3 / §4.1 `Reaction Time` vs also `Absolute Reaction Time` and `Response Duration` (identical on synthetic Study 1).
- **Issue:** Which millisecond field is the analysis RT if they ever differ on real data.
- **Options:** (A) `Reaction Time` only (dictionary). (B) prefer Absolute Reaction Time if Reaction Time is missing.
- **Impact:** Different trial RTs, skewness, log decision, and paired test.
- **Until answered:** Will use `Reaction Time` as the dictionary says and flag if the three columns disagree.
- **Suggested message:** “Please confirm we should use Gorilla’s `Reaction Time` column only, and flag (not silently switch) if `Absolute Reaction Time` disagrees on the real export.”

---

## BLOCKING Studies 2–3 only

### Q18 — BLOCKING Study 2 only
- **Where:** SAP §4.4 “The researcher session should be excluded”; synthetic IDs `S2_RESEARCHER_EXCLUDE` / `S2_PRIV_RESEARCHER`.
- **Issue:** Real-data identifier is not in the SAP.
- **Options:** (A) a known Public/Private ID you will give us. (B) a flag column in the real export.
- **Impact:** Primary N = 50 vs 51; every Study 2 test.
- **Until answered:** Synthetic Study 2 will exclude those two synthetic IDs. Real-data ID still required before you run Study 2.
- **Suggested message:** “For Study 2, what identifier marks the researcher session in the real Gorilla export so we do not hard-code only the synthetic ID?”

### Q19 — BLOCKING Study 3 only
- **Where:** Dictionary §6.1 `condition_order` = `optimized_first` / `original_first`; `block_order` = `black_first` / `white_first`. Synthetic values: `OptimizedFirst` / `OriginalFirst`; `BlackWhite` / `WhiteBlack`.
- **Issue:** Token mismatch. These fields are **not** primary predictors but are used for design documentation/QA.
- **Options:** (A) accept both spellings via an explicit map. (B) real data use dictionary tokens. (C) real data use synthetic tokens.
- **Impact:** QA failures; should not change H4–H7 if we do not enter them in the model.
- **Until answered:** Will recode both forms to canonical labels and log unknown values.
- **Suggested message:** “Study 3 order fields in the synthetic file use `OriginalFirst`/`WhiteBlack` rather than the dictionary’s `original_first`/`white_first`. Which coding will the real export use?”

### Q20 — BLOCKING Study 3 only
- **Where:** Dictionary §10 Study 3 pairwise: retain `Select_Left` / `Select_Right` response events. Synthetic Object Name is blank; Response is already `Left`/`Right`.
- **Issue:** Same class of problem as Q5, Study 3-specific object names.
- **Options:** (A) Task Name + Response ∈ {Left, Right}. (B) real Object Name is populated.
- **Impact:** Wrong pairwise row set for H6/H7.
- **Suggested message:** “For Study 3 pairwise, should we keep rows where Task Name is `Task 2 Pairwise Comparison` and Response is Left/Right if Object Name is blank?”

---

## Non-blocking

### Q21 — non-blocking
- **Where:** Brief cover vs Dictionary §1.
- **Issue:** Brief: SAP governs. Dictionary: Brief governs analysis decisions.
- **Options:** (A) SAP > Brief > Dictionary (our working order). (B) you want Brief to override SAP — that would need an explicit instruction.
- **Impact:** Only where Brief adds or appears to add a method (see Q15).
- **Suggested message:** “Please confirm we should treat the frozen SAP as the methodological source of truth, and the Brief only as implementation detail.”

### Q22 — non-blocking
- **Where:** Study 1 pairwise filenames (`compare_10_easy_optimized.png`, etc.) vs SAP §3.4 “Easy/Medium/Hard was not implemented.”
- **Issue:** Difficulty-like tokens exist in filenames.
- **Options:** (A) ignore tokens; they are leftover names. (B) something else.
- **Impact:** None if we never create a Difficulty factor in Study 1.
- **Suggested message:** “Study 1 pairwise filenames contain easy/medium/hard. We will ignore those tokens as labels only and will not analyse Study 1 Difficulty. Please confirm.”

### Q23 — non-blocking
- **Where:** SAP H1 wording “expected direction favouring Optimized” vs two-sided t / ANOVA main effect.
- **Issue:** Directional scientific expectation vs two-sided tests as written.
- **Options:** Implement the tests as written (two-sided / omnibus); discuss direction in text only.
- **Impact:** Interpretation, not the test, if we follow the SAP test sentences.
- **Suggested message:** “We will implement H1–H3 as the two-sided / ANOVA tests written in the SAP, and will not switch to one-sided tests because of the ‘expected direction’ wording. Please confirm.”

### Q24 — Answered via Q9 (22 Sep 2026)
- **Status:** Answered. Q9 asks for Kendall’s W with 95% CI via `effectsize`.
- **Where:** SAP fallback H2 reporting Kendall’s W without a CI; Brief §10 “CIs where applicable.”
- **Issue:** Whether to add a CI for W.
- **Options:** (A) W only, as SAP. (B) add a CI if you want it later.
- **Impact:** One extra number only if fallback H2 is used.
- **Suggested message:** “If the Friedman fallback is used, should we report Kendall’s W only (as the SAP lists) or also a 95% CI?”

### Q25 — non-blocking
- **Where:** Dictionary §9 Correct mismatch: flag, do not silently overwrite.
- **Issue:** After flagging, do we keep the recalculated accuracy?
- **Options:** (A) always use response == correct_answer; log Gorilla disagreements. (B) stop the run if any mismatch.
- **Impact:** Only if real Gorilla Correct disagrees (0 mismatches in synthetic Study 1).
- **Suggested message:** “If Gorilla’s Correct column disagrees with (response == correct_answer), should we keep the recalculated accuracy, log the mismatch, and continue?”

### Q26 — non-blocking
- **Where:** Synthetic README vs data: blank terminal row documented for Study 3; Study 2 also has one.
- **Issue:** Housekeeping-row rule.
- **Options:** Always drop fully blank rows in all studies.
- **Impact:** One extra NA row if not dropped (would break type parsing more than estimates).
- **Suggested message:** “May we always drop fully blank housekeeping rows in Studies 1–3?”

### Q27 — RESOLVED (local, 22 September 2026)
- **Where:** `.cursor/rules/cursor_rules.md` (user-placed); installed copy `.cursor/rules/r-analysis.mdc`.
- **Issue:** Was missing at Phase 1 start; now present.
- **Options:** n/a
- **Impact:** None on statistical results. Question format and architecture now follow the official rules file. Do not send to Fatimah.

### Q28 — non-blocking
- **Where:** Brief / Dictionary R 4.6.1 (2026-06-24).
- **Issue:** We cannot verify that version here (R is not installed). Client machine must match for `renv`.
- **Impact:** Package install failures at her end.
- **Suggested message:** “We will pin packages for R 4.6.1 as specified. Please confirm that is the version you will use to run the final scripts.”

### Q30 — BLOCKING when Study 1 figures are drawn
- **Where:** Q13 figure list (answered); no palette / colour / linetype specification.
- **Issue:** Fatimah named the plots but not colours, greyscale vs colour, or colourblind-safe tokens. `SAP$figure_colours` stays NA.
- **Options:** (A) she names hex/colours (or a named palette). (B) we use a documented greyscale / colourblind-safe default **after she approves that default**.
- **Impact:** Cannot freeze publication figures without inventing a palette.
- **Until answered:** No analysis figures will pick an unapproved colour scheme. Diagnostic histograms can use default `graphics` greyscale.
- **Suggested message:** “Q13 lists the Study 1 figures. Which colours (or greyscale) should we freeze? If you have no preference we can propose a colourblind-safe default for your approval.”

### Q31 — BLOCKING before Study 1 duplicate-response cleaning (Q2)
- **Where:** Q2: “keep the earliest valid response per participant x configured trial, tie-broken by Event Index.”
- **Issue:** Two parts are still unspecified: (1) the **configured-trial key** (Condition × K × configuration instance? Gorilla Trial Number? stimulus `Spreadsheet: image`?); (2) what **earliest** means as the primary clock if Event Index is only the tie-break (UTC Timestamp vs Local Timestamp vs Event Index as the only sort).
- **Options:** (A) key = Condition × K × `configuration_instance` (variation); earliest = smallest Event Index only. (B) key includes `Spreadsheet: image`; earliest = UTC Timestamp then Event Index. (C) another key she names.
- **Impact:** Changes which row is kept if duplicates exist on the real export. Synthetic v3 is one row per configured trial, so this does not change the current pipeline test.
- **Until answered:** Duplicate-dedup code will not run. Load/QC only counts exact duplicate rows.
- **Suggested message:** “For Study 1 duplicate discrimination rows, please confirm the trial key (for example Condition × K × configuration instance) and whether ‘earliest’ means smallest Event Index only, or UTC Timestamp with Event Index as the tie-break.”

### Q29 — non-blocking (Study 3 design documentation)
- **Where:** Study 3 `participant_group` counts 13/13/12/12, not 12.5-equal.
- **Issue:** SAP says orders were counterbalanced; does not require exact equality in the synthetic file.
- **Impact:** None if orders stay out of the primary model.
- **Suggested message:** “We will document Study 3 group/order counts and will not put them in the primary ANOVA, as the SAP says. No action needed unless you want a balance check against a target table.”

---

## Suggested cover message (you can paste this)

> Dear Fatimah,  
>   
> Thank you for the frozen SAP (21 September 2026), the implementation brief, the data dictionary, and the synthetic files. I have read all three documents in full and profiled the synthetic data only (no inferential results from the synthetic values).  
>   
> Before I freeze the Study 1 R code I need your decisions on the points below. I will not invent cutoffs, effect-size conventions, exclusion rules, or figures that are not in the SAP. The highest-priority items are: the vision-screen inclusion rule; Study 1 exclusions; what to do with failed pairwise-mapping rows; which participant ID to use when Public ID is blinded; how you want ANOVA/effect sizes/Wilcoxon zeros specified; and the figure/table formats.  
>   
> I am happy to implement whichever options you confirm and to record them in the analysis log.  
>   
> Kind regards,  
> Tayyab

---

*End of questions — Phase 1. No analysis was run.*
