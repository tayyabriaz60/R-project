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
  expect_error(require_param("figure_colours"), "PENDING a client answer")
  expect_error(require_param("duplicate_trial_key"), "PENDING a client answer")
})

test_that("fmt_p uses < .001 under 0.001", {
  expect_identical(fmt_p(0.0004), "< .001")
  expect_identical(fmt_p(0.042), "0.042")
  expect_true(is.na(fmt_p(NA_real_)))
})
