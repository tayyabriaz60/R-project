# Toy checks for Q2 audit, Q3/Q4 gates, and accuracy / pairwise summaries.

tiny_disc <- function(n_extra = 0L) {
  n <- 24L + n_extra
  data.frame(
    participant_id = rep("A", n),
    participant_anon_id = rep("S1_P001", n),
    condition = rep(rep(c("Original", "Optimized"), each = 12L), length.out = n),
    K = rep(rep(c(5L, 10L, 20L, 30L), each = 3L), length.out = n),
    configuration_instance = rep(c(1L, 2L, 3L), length.out = n),
    event_index = seq_len(n),
    utc_timestamp = as.numeric(seq_len(n)),
    accuracy = as.integer(rep(c(1, 0, 1), length.out = n)),
    absolute_error = rep(0, n),
    signed_error = rep(0, n),
    reaction_time_ms = rep(400, n),
    stringsAsFactors = FALSE
  )
}

tiny_pw <- function(n_fail = 0L, n = 12L) {
  data.frame(
    participant_id = rep("A", n),
    participant_anon_id = rep("S1_P001", n),
    mapping_fail = c(rep(1L, n_fail), rep(0L, n - n_fail)),
    chose_optimized = c(rep(NA_integer_, n_fail), rep(c(1L, 0L), length.out = n - n_fail)),
    stringsAsFactors = FALSE
  )
}

test_that("duplicate audit counts extras and does not drop rows", {
  d <- tiny_disc(n_extra = 2L)
  d$condition[25:26] <- d$condition[1:2]
  d$K[25:26] <- d$K[1:2]
  d$configuration_instance[25:26] <- d$configuration_instance[1:2]
  aud <- audit_disc_duplicates_guess(d)
  expect_true(aud$n_dup_keys >= 1L)
  expect_true(aud$n_rows_would_drop >= 1L)
  expect_false(aud$applied)
  expect_equal(nrow(d), 26L)
})

test_that("Q31 keeps the earliest UTC Timestamp, then Event Index", {
  d <- tiny_disc()
  extra <- d[1, , drop = FALSE]
  extra$utc_timestamp <- d$utc_timestamp[1] + 50
  extra$event_index <- 99L
  extra$accuracy <- 0L
  later <- rbind(d, extra)
  out <- apply_study1_discrimination_dedup(later)
  expect_equal(nrow(out), 24L)
  kept <- out[out$condition == later$condition[1] &
                out$K == later$K[1] &
                out$configuration_instance == later$configuration_instance[1], ]
  expect_equal(nrow(kept), 1L)
  expect_equal(kept$utc_timestamp, d$utc_timestamp[1])
  expect_equal(kept$accuracy, d$accuracy[1])
})

test_that("Q31 uses Event Index when UTC Timestamp ties", {
  d <- tiny_disc()
  extra <- d[1, , drop = FALSE]
  extra$utc_timestamp <- d$utc_timestamp[1]
  extra$event_index <- d$event_index[1] + 10L
  extra$accuracy <- 0L
  earlier_event <- d[1, , drop = FALSE]
  earlier_event$event_index <- d$event_index[1] - 1L
  earlier_event$accuracy <- 1L
  later <- rbind(d[-1, ], extra, earlier_event)
  out <- apply_study1_discrimination_dedup(later)
  kept <- out[out$condition == d$condition[1] &
                out$K == d$K[1] &
                out$configuration_instance == d$configuration_instance[1], ]
  expect_equal(nrow(kept), 1L)
  expect_equal(kept$event_index, d$event_index[1] - 1L)
})

test_that("Q31 stops if a duplicate-key row has no UTC Timestamp", {
  d <- tiny_disc(n_extra = 1L)
  d$condition[25] <- d$condition[1]
  d$K[25] <- d$K[1]
  d$configuration_instance[25] <- d$configuration_instance[1]
  d$utc_timestamp[25] <- NA_real_
  expect_error(apply_study1_discrimination_dedup(d), "UTC Timestamp")
})

test_that("Q31 apply drops extras and continues when there are no duplicates", {
  tmp <- tempfile()
  writeLines("tmp", tmp)
  clean <- apply_study1_q31_dedup(list(discrimination = tiny_disc()), tmp)
  expect_true(clean$duplicate_audit$applied)
  expect_equal(clean$duplicate_audit$n_dup_keys, 0L)
  expect_equal(nrow(clean$discrimination), 24L)
})

test_that("Q3 gate stops when mapping_fail > 0 and passes when 0", {
  tmp <- tempfile()
  writeLines("tmp", tmp)
  expect_error(gate_pairwise_mapping_q3(tiny_pw(n_fail = 1L), tmp), "Q3 GATE")
  expect_true(gate_pairwise_mapping_q3(tiny_pw(n_fail = 0L), tmp))
})

test_that("Q4 gate stops when a participant has fewer than 24 disc rows", {
  tmp <- tempfile()
  writeLines("tmp", tmp)
  d <- tiny_disc()[1:20, ]
  pw <- tiny_pw()
  expect_error(gate_incomplete_cells_q4(d, pw, tmp), "Q4 GATE")
})

test_that("Q4 gate passes a complete 24 disc + 12 pairwise participant", {
  tmp <- tempfile()
  writeLines("tmp", tmp)
  expect_true(gate_incomplete_cells_q4(tiny_disc(), tiny_pw(), tmp))
})

test_that("accuracy cell mean and pairwise proportion are hand-checkable", {
  d <- data.frame(
    participant_id = "A",
    participant_anon_id = "S1_P001",
    condition = "Original",
    K = 5L,
    accuracy = c(1, 0, 1),
    stringsAsFactors = FALSE
  )
  cells <- accuracy_cells_long(d)
  expect_equal(cells$accuracy, 2 / 3)
  pw <- data.frame(
    participant_id = "A",
    participant_anon_id = "S1_P001",
    chose_optimized = c(1L, 1L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  pr <- pairwise_proportion(pw)
  expect_equal(pr$chose_optimized, 0.75)
})
