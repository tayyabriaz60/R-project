# Thesis report figure helpers. Toy data only; checks layout labels, not saved files.

test_that("plot_condition_by_k uses thesis axis labels and no in-figure title", {
  pal <- require_param("figure_colours")
  df_mean <- c(0.5, 0.6, 0.7, 0.8, 0.55, 0.65, 0.75, 0.85)
  df <- data.frame(
    condition = rep(c("Original", "Optimized"), each = 4L),
    K = rep(c(5L, 10L, 20L, 30L), 2L),
    mean = df_mean,
    ci_low = df_mean - 0.05,
    ci_high = df_mean + 0.05,
    stringsAsFactors = FALSE
  )
  p <- plot_condition_by_k(df, "Mean participant-level accuracy", pal, c(5L, 10L, 20L, 30L))
  expect_null(p$labels$title)
  expect_null(p$labels$caption)
  expect_equal(p$labels$x, "Number of classes (K)")
  expect_equal(p$labels$y, "Mean participant-level accuracy")
  expect_equal(p$labels$colour, "Condition")
  built <- ggplot2::ggplot_build(p)
  expect_identical(built$plot$theme$legend.position, "right")
})

test_that("Study 2 figure writer uses revised Study 2 presentation helpers", {
  src <- readLines(file.path(PROJECT_ROOT, "R", "study2_export.R"), warn = FALSE)
  body <- paste(src, collapse = "\n")
  expect_match(body, "plot_study2_accuracy_panels")
  expect_match(body, "plot_study2_h3_stacked_dots")
  expect_match(body, "plot_study2_rt_by_condition")
  expect_false(grepl("plot_condition_by_k\\(", body))
})
