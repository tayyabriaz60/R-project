# Thesis figure helpers. Toy objects only. No synthetic load. No hypothesis tests.

test_that("thesis_theme has no in-figure title and a right-hand Condition legend", {
  th <- thesis_theme()
  expect_identical(th$legend.position, "right")
  expect_true(inherits(th$plot.title, "element_blank"))
  expect_true(inherits(th$plot.caption, "element_blank"))
})

test_that("Condition x K plot uses thesis axis labels and no title", {
  pal <- list(Original = "#E69F00", Optimized = "#0072B2", reference = "#000000")
  df <- data.frame(
    condition = rep(c("Original", "Optimized"), each = 2L),
    K = c(5L, 10L, 5L, 10L),
    mean = c(0.90, 0.80, 0.85, 0.75),
    ci_low = c(0.80, 0.70, 0.75, 0.65),
    ci_high = c(1.00, 0.90, 0.95, 0.85),
    stringsAsFactors = FALSE
  )
  p <- plot_condition_by_k(df, "Mean participant-level accuracy", pal, c(5, 10, 20, 30))
  expect_identical(p$labels$x, "Number of classes (K)")
  expect_identical(p$labels$y, "Mean participant-level accuracy")
  expect_identical(p$labels$colour, "Condition")
  expect_true(is.null(p$labels$title) || identical(p$labels$title, ggplot2::waiver()))
})
