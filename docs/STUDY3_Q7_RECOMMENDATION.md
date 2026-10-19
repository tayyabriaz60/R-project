# Study 3 inferential path recommendation (Oct 2026, N = 46)

**Locked parametric path (real-data diagnostics reviewed):**

| Analysis | Test |
|----------|------|
| H4 | Condition main effect from **2 × 2 RM-ANOVA** (Condition × Background accuracy cells) |
| H5 | Condition × Background interaction from same RM-ANOVA; if interaction *p* < .05, paired **t** Orig vs Opt within each background with **Holm × 2** |
| H6 | Two-sided one-sample **t** on overall Optimized-choice proportion vs 0.50 (18 trials) |
| H7 | Paired **t** on White vs Black Optimized-choice proportions |
| RT | **2 × 2 RM-ANOVA** on participant mean RT per Condition × Background (trial-level skew 6.40 → **log** analysis scale) |
| AE | Paired **t** on Optimized − Original mean absolute error |

**Rationale:** Fatimah’s real primary sample (N = 46) diagnostic skewness on analysis-scale difference scores / proportions:

- H4 (overall Opt − Orig accuracy): **0.35**
- H5 (White − Black Opt − Orig diff): **−0.62**
- H6 (pairwise Optimized proportion): **−0.19**
- H7 (White − Black proportion diff): **0.47**

None meet the pipeline’s **severe non-normality** flag (|skewness| > 2) or SAP wording for switching accuracy/pairwise tests to Wilcoxon. Histograms are unimodal with modest tails—appropriate for the prespecified RM-ANOVA / *t* path. RT log transform is already driven by trial-level skew > 1 (6.40), separate from H4–H7.

**Config:** `study3_inferential_path_locked = TRUE`, `study3_q_hold_inferential = FALSE`, `study3_accuracy_pairwise_use_fallback = FALSE`.

**Real loader (preserve in package):** `REAL_STUDY3_COMBINED_FILE` and `REAL_STUDY3_FILES$study3_questionnaire` as in `config/config.R`.
