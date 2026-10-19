# Study 1 Q7 recommendation (Oct 2026, N = 48)

**Locked mixed path (aligned with Study 2 Q32):**

| Analysis | Test |
|----------|------|
| H1 | Paired Wilcoxon on Optimized − Original accuracy |
| H2 | Friedman on Opt−Orig difference scores across K; Holm pairwise Wilcoxon follow-ups only if Friedman *p* < .05 |
| H3 | Two-sided one-sample **t** vs 0.50 |
| RT | Paired **t** on Q12 analysis scale |
| AE | Paired **t** |

**Rationale:** Based on participant-level difference-score diagnostics (`study1_diag_h1_opt_minus_orig`, `study1_diag_h2_opt_minus_orig_by_k`) and SAP §3.1 fallback rules—not on raw accuracy cell histograms alone. H1/H2 difference distributions show discrete spikes and heavy mass near zero; rank-based tests are appropriate. H3/RT/AE follow the Study 2 mixed parametric choice. Rank-based inputs use difference scores rounded to 10 decimals before Wilcoxon/Friedman.

**Config:** `q7_path_locked = TRUE`, `study1_q7_hold_inferential = FALSE`.

After updating to the final zip, rerun on real data to produce inferential tables and figures.
