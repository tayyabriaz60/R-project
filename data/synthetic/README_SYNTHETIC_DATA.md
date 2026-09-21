# Synthetic Data for R Implementation — Studies 1–3

## Purpose
These files are entirely synthetic and contain no real participant responses. They are intended only for building and testing the R analysis pipeline against the same column structure and analytical trial structure as the Gorilla exports.

**Do not interpret or report any statistical result from these synthetic values.**

## Scope
The synthetic package includes the task data required by the frozen SAP:
- discrimination / exact class-count task;
- pairwise-choice task;
- four-item vision screen.

Questionnaire/demographic rows are intentionally omitted because they are not required for the prespecified SAP analyses.

Only analysis-relevant `Response Type = response` rows are generated. Gorilla information/continue rows are intentionally omitted. The real-export column headers are retained.

## Study 1
- 50 synthetic primary participants.
- `Participant Public ID` is intentionally set to `BLINDED`, matching the real export behavior.
- Use the unique synthetic `Participant Private ID` to identify participants in this Study 1 test data.
- Discrimination: 24 rows/participant = 2 Condition × 4 K × 3 configuration instances.
- Pairwise: 12 rows/participant.
- Vision: 4 rows/participant; exactly 48/50 synthetic participants score 4/4.

### Study 1 pairwise mapping test
The synthetic pairwise file deliberately reproduces the mapping issue:
`left_option` / `right_option` are response labels attached to the physical image objects and do not necessarily describe the actual condition shown on that side.

Reconstruct the selected physical side first:
- if `Response == Spreadsheet: left_option`, `preferred_side = left`;
- if `Response == Spreadsheet: right_option`, `preferred_side = right`.

Derive `optimized_side` independently from `Spreadsheet: image_left` and `Spreadsheet: image_right`, then:
`chose_optimized = (preferred_side == optimized_side)`.

## Study 2
- Raw synthetic file contains 51 synthetic sessions.
- `S2_RESEARCHER_EXCLUDE` represents the predefined researcher-run session and must be excluded before primary analyses.
- Primary N after exclusion = 50.
- G1 = 25 primary participants; G2 = 25 primary participants + the synthetic researcher session.
- Discrimination: 24 rows/participant.
- Pairwise: 12 rows/participant.
- Vision: 4 rows/participant; among the 50 primary participants, exactly 43 score 4/4.
- The raw Study 2 export does not contain a separate Difficulty-label column for discrimination. The three levels remain represented by `Spreadsheet: variation` (1, 2, 3), consistent with the supplied column structure.

## Study 3
- 50 synthetic primary participants.
- Discrimination: 36 rows/participant = 2 Condition × 2 Background × 3 K × 3 Difficulty.
- Pairwise: 18 rows/participant = 2 Background × 3 K × 3 Difficulty.
- Vision: 4 rows/participant; exactly 46/50 score 4/4.
- One fully blank terminal row is included to test the documented housekeeping-row removal.

## Expected primary analysis counts after preprocessing
- Study 1 discrimination: 50 × 24 = 1,200 rows.
- Study 1 pairwise: 50 × 12 = 600 rows.
- Study 1 vision: 50 × 4 = 200 rows.
- Study 2 after excluding `S2_RESEARCHER_EXCLUDE`:
  - discrimination = 50 × 24 = 1,200 rows;
  - pairwise = 50 × 12 = 600 rows;
  - vision = 50 × 4 = 200 rows.
- Study 3:
  - discrimination = 50 × 36 = 1,800 rows;
  - pairwise = 50 × 18 = 900 rows;
  - vision = 50 × 4 = 200 rows.

## Synthetic-generation notes
- Responses, correctness, choice, and RT values are simulated using a fixed random seed for reproducibility.
- All participant identifiers, session identifiers, timestamps, device information, and outcomes are synthetic.
- Real stimulus/file naming patterns are retained only to exercise parsing and QA logic.
- Synthetic RTs are positive and right-skewed so the prespecified RT diagnostics can be exercised.
- No synthetic result should be used to infer the actual study findings.
