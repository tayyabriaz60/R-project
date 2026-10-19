Study 1–3 pipeline — output folder
==================================

This folder is created automatically when you run the analysis scripts.
It is empty in the delivery zip on purpose (no pre-computed results).

After a successful run of run_study3.R (or run_study1.R / run_study2.R), you
should see:

  output/
    figures/   — thesis PNG (300 dpi) + PDF report figures
    tables/    — CSV + DOCX result tables
    logs/      — QC and analysis logs (aggregates only; no Gorilla IDs)
    models/    — reserved for saved model objects if used

Study 3 thesis figures (real or synthetic run), examples:

  output/figures/study3_fig_accuracy_condition_background.png  (H4/H5 two-panel)
  output/figures/study3_fig_accuracy_by_k_descriptive.png
  output/figures/study3_fig_pairwise_prop.png  (H6/H7 primary)
  output/figures/study3_fig_pairwise_by_background_descriptive.png
  output/figures/study3_fig_rt_condition_background.png
  output/figures/study3_fig_ae_condition_background.png

Diagnostic histograms (not thesis figures):

  output/figures/study3_diag_h4_opt_minus_orig.png
  output/figures/study3_diag_h5_white_minus_black_diff.png
  output/figures/study3_diag_h6_prop.png

Figure captions:

  output/logs/study3_figure_captions.txt   (real data: no _SYNTHETIC suffix)
  output/logs/study3_figure_captions_SYNTHETIC.txt   (synthetic test runs)

Location: always PROJECT_ROOT/output/, where PROJECT_ROOT is the folder that
contains config/ and run_study3.R. Set PROJECT_ROOT explicitly if needed:

  PROJECT_ROOT <- "C:/path/to/unzipped/Study3_Tayyab_v2.2"
  source(file.path(PROJECT_ROOT, "run_study3.R"))

The console prints the resolved output path at the end of each run.
