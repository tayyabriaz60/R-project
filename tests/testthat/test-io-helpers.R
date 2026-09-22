# I/O and validation helpers. Hand-checkable toy objects only.

test_that("drop_blank_rows drops all-missing rows and keeps mixed rows", {
  df <- data.frame(
    a = c(1, NA, 2),
    b = c("x", NA, NA),
    stringsAsFactors = FALSE
  )
  out <- drop_blank_rows(df)
  expect_equal(nrow(out), 2L)
  expect_equal(out$a, c(1, 2))
})

test_that("read_gorilla_csv strips a UTF-8 BOM from the first header", {
  path <- tempfile(fileext = ".csv")
  payload <- c(as.raw(c(0xef, 0xbb, 0xbf)), charToRaw("col_a,col_b\n1,2\n"))
  writeBin(payload, path)
  df <- read_gorilla_csv(path)
  expect_identical(names(df)[1], "col_a")
  expect_equal(nrow(df), 1L)
})

test_that("require_columns names the missing fields", {
  expect_error(
    require_columns(data.frame(a = 1), c("a", "b"), "toy"),
    "Missing required columns in toy: b"
  )
})

test_that("assert_expected_n fails only for synthetic mismatches", {
  expect_error(
    assert_expected_n(3L, 2L, "toy", "synthetic"),
    "Synthetic structure mismatch"
  )
  expect_false(assert_expected_n(3L, 2L, "toy", "real"))
})

test_that("require_param returns filled SAP values and stops on pending NA", {
  expect_equal(require_param("alpha"), 0.05)
  pal <- require_param("figure_colours")
  expect_identical(pal$Original, "#E69F00")
  expect_identical(pal$Optimized, "#0072B2")
  expect_identical(
    require_param("duplicate_trial_key"),
    "participant_id|condition|K|configuration_instance"
  )
  expect_error(require_param("geometric_mean_rt_ratio"), "PENDING a client answer")
})

test_that("parse_utc_timestamp accepts numeric epoch and rejects date strings", {
  expect_equal(parse_utc_timestamp(c("1789992007000", "100"), "toy"), c(1789992007000, 100))
  expect_error(parse_utc_timestamp("21/09/2026 12:00:07", "toy"), "not numeric")
})

test_that("resolve_study1_file finds a real CSV by task id", {
  old_src <- DATA_SOURCE
  old_dir <- DATA_DIR
  on.exit({
    DATA_SOURCE <<- old_src
    DATA_DIR <<- old_dir
  }, add = TRUE)
  tmp <- tempfile("realdata")
  dir.create(file.path(tmp, "Study1"), recursive = TRUE)
  dest <- file.path(tmp, "Study1", "data_exp_1_task-y3n9.csv")
  write.csv(data.frame(a = 1), dest, row.names = FALSE)
  DATA_SOURCE <<- "real"
  DATA_DIR <<- tmp
  found <- resolve_study1_file("study1_disc_g1")
  expect_identical(normalizePath(found, winslash = "/", mustWork = TRUE),
                   normalizePath(dest, winslash = "/", mustWork = TRUE))
})

test_that("fmt_p uses < .001 under 0.001", {
  expect_identical(fmt_p(0.0004), "< .001")
  expect_identical(fmt_p(0.042), "0.042")
  expect_true(is.na(fmt_p(NA_real_)))
})
