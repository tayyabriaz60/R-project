**Categorical Colormap Optimization - Studies 1, 2 and 3**

Prepared for R implementation by Tayyab Riaz

| **Governing document** | Final frozen Statistical Analysis Plan (SAP) |
|----|----|
| **SAP version** | Final |
| **SAP freeze date** | 21 September 2026 |
| **R version** | R 4.6.1 (2026-06-24) |
| **Data-access model** | Synthetic-data development/testing; final scripts run locally by Fatimah on the real data |

**Authority of this brief** (re-extracted from original .docx Table 2; pandoc had emitted a broken 1×1 HTML table)

- The frozen SAP is the governing methodological document. This brief clarifies implementation and quality-control details; it does not create new hypotheses or replace the SAP.
- If this brief appears to conflict with the frozen SAP, stop and ask Fatimah before changing the analysis.
- Do not make independent methodological changes. Any methodological concern or proposed deviation must be flagged before implementation.

# 1. Purpose and scope

The purpose of this brief is to make the frozen SAP executable in R
without requiring the analyst to make new methodological decisions. The
primary inferential strategy is participant-level conventional
repeated-measures / paired analysis, not mixed-effects modelling.

- Use participant-level summary measures for the primary inferential
  analyses, as specified in the SAP.

- Use alpha = .05 for each prespecified primary hypothesis; do not add
  an across-hypothesis multiplicity correction.

- Apply Holm correction only to the follow-up comparison families
  specified in the SAP.

- Do not add new primary hypotheses, new inferential factors, post-hoc
  models, or additional trimming rules.

- No participant or trial exclusion may be based on the observed
  outcome. Report all missing/excluded observations and the final N used
  in each analysis.

# 2. Required inputs before coding is frozen

| **Item** | **Status** | **Implementation rule** |
|----|----|----|
| **Final frozen SAP** | Required | Use as the methodological source of truth. |
| **Data dictionary / column structure** | Required | Variable names, coding and derivations must follow this document. |
| **Synthetic dataset** | Required | Build and test the full pipeline using the synthetic structure only. |
| **R version** | Confirmed | Use R 4.6.1 (2026-06-24) for the final local execution; pin package versions with renv. |
| **Exact Study 1 pairwise response-side mapping correction** | Confirmed | Gorilla mapping is fixed: clicking the left image records left_option and clicking the right image records right_option. Reconstruct preferred_side from the recorded response, derive optimized_side from image_left/image_right, then compute chose_optimized = (preferred_side == optimized_side). See Section 4 for the exact QA/derivation rule. |

# 3. Required analysis pipeline order

1.  Confirm analysis populations and apply only predefined exclusions.

2.  Run data-structure and pairwise-mapping quality checks before
    deriving analysis variables.

3.  Calculate the required participant-level summary measures.

4.  Produce descriptive statistics and planned visualizations.

5.  Perform the SAP-specified assumption diagnostics.

6.  Conduct the primary hypothesis tests and any prespecified fallbacks.

7.  Run follow-up comparisons only when the SAP trigger is met; apply
    the specified Holm correction.

8.  Preprocess and analyse secondary outcomes.

9.  Run the prespecified vision-screen sensitivity analyses.

10. Export tables, figures, analysis outputs and the analysis log;
    verify that the full pipeline regenerates all deliverables from
    start to finish.

# 4. Pairwise-choice data QA and derivation

- Before calculating chose_optimized, verify the distribution of
  optimized_side within participants and validate that every analysed
  pairwise trial contains exactly one Optimized image and one
  Original/baseline image.

- Study 1 Gorilla mapping is fixed as follows: clicking the left image
  records the trial-specific value in left_option, and clicking the
  right image records the trial-specific value in right_option. Do not
  interpret the semantic response label (for example, optimized.png or
  baseline.png) directly as the selected stimulus type.

- First reconstruct the selected physical side from the recorded Gorilla
  response: if the response equals left_option, set preferred_side =
  "left"; if it equals right_option, set preferred_side = "right".
  Independently derive optimized_side from the actual stimulus filenames
  in image_left and image_right. Then calculate chose_optimized =
  (preferred_side == optimized_side). If a row fails these mapping
  checks, flag it as a data-structure/QA issue rather than guessing or
  recoding from observed outcomes.

- Keep a QA record showing the response-to-side reconstruction,
  optimized_side derivation, validation results, and the final
  chose_optimized derivation used for Study 1.

# 5. Study 1 implementation

## 5.1 Accuracy - H1 and H2

- Calculate exact class-count accuracy for each participant within each
  Condition x K cell.

- Average across the three configuration instances within each Condition
  x K cell.

- Treat the three variations only as configuration instances.
  Easy/Medium/Hard Difficulty was not implemented in Study 1 and must
  not be analysed or interpreted as Difficulty.

- Primary test: 2 x 4 repeated-measures ANOVA with within-subject
  factors Condition (Original, Optimized) and K (5, 10, 20, 30).

- H1 = Condition main effect. H2 = Condition x K interaction.

- If the Condition x K interaction is significant, run paired Original
  vs Optimized comparisons separately at K = 5, 10, 20 and 30, with Holm
  correction across the four comparisons.

- Zero-variance rule: if the within-participant Optimized - Original
  difference at a given K has exactly zero variance, do not compute the
  inferential follow-up or standardized paired effect size for that K.
  Report descriptives for that K and apply Holm correction across the
  remaining estimable K-specific comparisons.

- Keep K = 30 in the analysis and retain its SAP interpretation as a
  palette-capacity boundary condition.

## 5.2 Pairwise choice - H3

- For each participant, calculate the proportion of pairwise trials on
  which Optimized was selected, after the QA/mapping checks in Section
  4.

- Primary test: two-sided one-sample t-test against 0.50, with the
  SAP-specified Wilcoxon fallback if required.

- The fixed pairwise trial order requires no analytical adjustment;
  retain it as a reporting limitation only.

# 6. Study 2 implementation

## 6.1 Analysis population

- Exclude the predefined researcher session from all analyses; the SAP
  primary analysis population is N = 50.

## 6.2 Accuracy - H1 and H2

- Use the same participant-level 2 x 4 repeated-measures ANOVA
  framework, assumptions, fallbacks, follow-ups and reporting rules as
  Study 1.

- In Study 2, Easy, Medium and Hard Difficulty levels were implemented.
  Difficulty is not a standalone primary factor in the frozen SAP.

- For the primary Condition x K analysis, average participant-level
  accuracy across the three Difficulty levels within each Condition x K
  cell.

- Do not add a standalone Difficulty hypothesis or Condition x
  Difficulty / higher-order inferential model unless the frozen SAP is
  formally amended before analysis.

## 6.3 Pairwise choice - H3

- Use the same participant-level pairwise-choice procedure, assumptions,
  fallback and reporting rules as Study 1, following the pairwise QA
  rules in Section 4.

# 7. Study 3 implementation

## 7.1 Accuracy - H4 and H5

- For each participant, calculate exact class-count accuracy within each
  Condition x Background cell, averaging across both K and Difficulty.

- Primary test: 2 x 2 repeated-measures ANOVA with within-subject
  factors Condition (Original, Optimized) and Background (White, Black).

- H4 = Condition main effect. H5 = Condition x Background interaction.

- If the Condition x Background interaction is significant, compare
  Original vs Optimized separately within White and Black backgrounds,
  with Holm correction across the two comparisons.

- Condition order and Background order were counterbalanced; do not
  include them as predictors in the primary analysis. Document them as
  design features.

## 7.2 Pairwise choice - H6 and H7

- H6: calculate each participant's overall Optimized-choice proportion
  across the 18 pairwise trials and use the SAP-specified two-sided
  one-sample test against 0.50.

- H7: calculate each participant's Optimized-choice proportion
  separately for White and Black backgrounds and use the SAP-specified
  paired comparison.

# 8. Secondary outcomes

## 8.1 Response time (RT)

- Include all valid trials regardless of response accuracy.

- Exclude only missing or non-positive RT values and RT values affected
  by a documented recording/technical error. Apply no other trimming.

- Calculate the skewness coefficient of the trial-level RT distribution.
  If skewness \> 1, apply the natural-log transformation using log() in
  R before calculating participant-level means, exactly as specified by
  the SAP transformation rule.

- For Studies 1 and 2, calculate participant-level mean RT separately
  for Original and Optimized trials, averaging across K, using the raw
  or transformed scale selected by the SAP rule.

- For Study 3, calculate participant-level mean RT within each Condition
  x Background cell and use the SAP-specified 2 x 2 repeated-measures
  ANOVA and follow-ups.

- Pairwise-task RT remains descriptive unless a separate inferential
  question is explicitly added to the frozen SAP.

- If inference is conducted on natural-log-transformed RT, continue to
  report untransformed descriptive RT values in milliseconds. In
  addition, exponentiate the estimated paired log difference and its
  95% CI. Where the analysed contrast is Original - Optimized, label the
  back-transformed estimate explicitly as the Original/Optimized
  geometric-mean ratio.

## 8.2 Absolute Error

- Retain the SAP-specified inferential analysis of mean Absolute Error;
  do not replace it with a K-specific inferential model.

- Additionally produce descriptive Absolute Error summaries by Condition
  x K (mean and SD; include a 95% CI if this is part of the final
  reporting template). These summaries are descriptive only and do not
  create additional hypothesis tests.

- For Study 3, descriptive Absolute Error may also be reported
  separately for White and Black backgrounds, as allowed by the SAP.

## 8.3 Signed Error

- Treat Signed Error as a descriptive secondary outcome only. No
  inferential test should be added.

- Use negative values to describe underestimation and positive values to
  describe overestimation. Report mean and SD by the SAP-specified
  conditions.

# 9. Assumptions, fallbacks and non-parametric implementation

- Use only the diagnostics and fallbacks prespecified in the SAP.

- Do not create a new universal numerical fallback threshold (for
  example, \|skewness\| \> 1) for ANOVA/t-test decisions. The SAP
  threshold skewness \> 1 applies to the RT transformation rule only.

- Where the SAP uses qualitative wording such as severe deviations,
  severely non-normal, very skewed or extremely skewed without a
  numerical cutoff, do not invent a cutoff. Produce the specified
  diagnostic, flag it to Fatimah before switching analysis, and record
  the agreed decision in the analysis log.

- Fallback decisions must be documented before examining the statistical
  significance or direction of the Condition effect.

- For H2 non-parametric fallback, preserve the SAP logic: calculate
  Optimized - Original accuracy differences at each K, use Friedman to
  test whether those difference scores vary across K, and if significant
  compare the difference scores between K levels with pairwise Wilcoxon
  signed-rank tests and Holm correction across the six comparisons. Do
  not replace this with Original vs Optimized tests at each K as the
  Friedman follow-up.

## 9.1 Wilcoxon zero differences

- Use one prespecified and consistent convention for zero paired
  differences.

- If the standard Wilcoxon convention is used, omit zero differences
  from the signed-rank calculation and report the effective number of
  non-zero pairs.

- Document the exact R function/package used for the Wilcoxon test,
  rank-biserial correlation and its 95% CI.

# 10. Effect sizes, confidence intervals and reporting conventions

- Report effect sizes and 95% confidence intervals exactly where
  required by the SAP.

- Document the exact package, function and convention used for partial
  eta-squared, paired-samples Cohen's d, one-sample Cohen's d,
  rank-biserial correlation, Kendall's W and their confidence intervals
  where applicable.

- If the SAP wording permits more than one standard computational
  convention (for example, alternative definitions of paired Cohen's d
  or alternative CI methods), do not choose silently. Flag the proposed
  convention to Fatimah before the final code is frozen, then use the
  approved convention consistently across all studies.

- Do not substitute a different effect-size family for the effect size
  named in the SAP.

# 11. Vision-screen sensitivity analyses

| **Study** | **Primary N** | **Vision-screen subset** |
|:---------:|:-------------:|:------------------------:|
|  Study 1  |      50       |            48            |
|  Study 2  |      50       |            43            |
|  Study 3  |      50       |            46            |

Repeat only the SAP-defined primary accuracy and pairwise-choice
analyses in the relevant vision-screen subset and report whether the
substantive conclusions change. Do not redefine the primary analysis
population.

# 12. Reproducibility, version control and analysis log

- Frozen SAP version: Final. SAP freeze date: 21 September 2026.

- Final local execution R version: R 4.6.1 (2026-06-24).

- Pin package versions with renv and include setup/run instructions in a
  README.

- The analysis log must record: analysis population/exclusions, missing
  observations, QA/mapping checks, assumption diagnostics, any fallback
  invoked and why, zero-difference handling, zero-variance follow-ups,
  package/functions used for effect sizes/CIs, and any technical issue
  encountered.

- The final pipeline must regenerate all analyses, tables and figures
  from start to finish without manual editing of numerical results.

# 13. Synthetic-data-only development and troubleshooting workflow

- Build and test the full R workflow using the synthetic dataset with
  the same column structure as the real data.

- Fatimah will run the final scripts locally on the real data.

- Do not require access to the real participant-level dataset for
  development or final delivery.

- Troubleshooting on the real run may use error messages and
  non-sensitive outputs supplied by Fatimah, provided the work remains
  within the frozen SAP.

- Avoid dataset-specific hard-coding that would prevent the scripts from
  running on the real dataset with the documented structure.

# 14. Required deliverables

- Participant-level summary measures used by the analyses.

- All primary hypothesis tests (H1-H7 as applicable by study).

- All SAP-specified assumption checks and predefined fallback analyses.

- All triggered follow-up comparisons with the specified multiplicity
  correction.

- Effect sizes and 95% confidence intervals as specified in the SAP.

- Response-time, Absolute Error and Signed Error analyses/descriptives
  specified in the SAP and this brief.

- Vision-screen sensitivity analyses.

- Publication-ready summary tables for primary and secondary analyses.

- Figures/plots specified by the SAP/reporting plan, with clear labels
  and thesis/publication-suitable formatting.

- Exported analysis outputs, tables and figures in reusable formats.

- One clean, reproducible R pipeline that regenerates the complete
  analysis from start to finish.

- renv lockfile/environment and a README with setup and run
  instructions.

- Analysis log documenting the implementation decisions and diagnostics
  listed above.

# 15. Implementation guardrails - do not do the following

**Do not:** (re-extracted from original .docx Table 5; pandoc had emitted a broken 1×1 HTML table)

- Use mixed-effects models as the primary analysis strategy.
- Treat Study 1 configuration variations as Difficulty.
- Add Difficulty as a standalone primary factor in Study 2.
- Change H2 Friedman follow-ups to a different question.
- Introduce new outlier trimming or RT trimming beyond the SAP.
- Invent numerical fallback thresholds that are not in the frozen SAP.
- Add inferential tests for Signed Error or the additional Absolute Error by-K descriptives.
- Interpret the Study 1 recorded response label directly as Optimized/Original, or recode the mapping from observed outcome patterns.
- Change a methodological decision without first flagging it to Fatimah.

# 16. Pre-delivery acceptance checklist

> ☐ SAP version = Final, freeze date = 21 September 2026, and R version
> = 4.6.1 (2026-06-24) are recorded in the README / analysis log.
>
> ☐ Study 1 pairwise mapping QA has passed: response -\> preferred_side
> is reconstructed using left_option/right_option; optimized_side is
> derived from image_left/image_right; chose_optimized is then computed
> from side agreement.
>
> ☐ Synthetic dataset runs from raw input to all outputs without manual
> intervention.
>
> ☐ All participant-level summaries match the SAP aggregation rules for
> each study.
>
> ☐ All fallback decisions, if any, are documented before interpretation
> of hypothesis results.
>
> ☐ Holm correction is applied only to the prespecified follow-up
> families.
>
> ☐ All requested effect sizes and 95% CIs are present and their
> computational conventions are documented.
>
> ☐ RT reporting preserves untransformed millisecond descriptives even
> if inference uses log RT.
>
> ☐ Vision-screen sensitivity analyses are complete for Studies 1-3.
>
> ☐ Tables, figures, reusable exports, README, renv files and analysis
> log are included.

*End of implementation brief*
