**Categorical Colormap Optimization --- Studies 1--3**

*For the synthetic-data R implementation workflow*

  -----------------------------------------------------------------------
  **Document control**                **Value**
  ----------------------------------- -----------------------------------
  SAP version                         Final

  SAP freeze date                     21 September 2026

  R version                           4.6.1 (2026-06-24)

  Purpose                             Define the raw Gorilla source
                                      columns, canonical analysis
                                      variables, and synthetic-data
                                      column structure for Studies 1--3.
  -----------------------------------------------------------------------

# 1. Scope and use

This dictionary is based on the three Gorilla exports supplied for Study
1, Study 2, and Study 3. It defines the variables needed to implement
the frozen SAP. The Final Analysis Implementation Brief remains the
governing source for analysis decisions, diagnostics, fallbacks, effect
sizes, multiplicity, and reporting.

- Tayyab should build and test the R workflow using synthetic data that
  follow the canonical structures below.

- When Fatimah runs the scripts locally on real data, the
  import/preprocessing code should map the raw Gorilla columns to these
  canonical variables.

- Do not use questionnaire fields as inferential predictors unless
  separately requested. They are not part of the frozen primary
  hypothesis tests.

- Do not infer eligibility from raw export row counts. Apply the
  predefined participant exclusions/reconciliation rules before creating
  the final analysis datasets.

# 2. Raw files supplied

  -----------------------------------------------------------------------
  **Study**               **Raw export file(s)**  **Core task names**
  ----------------------- ----------------------- -----------------------
  Study 1                 data_exp_229051-v38 --- Vision Check;
                          local unblinded export  Discrimination Task G1;
                          (kept on Fatimah's      Discrimination Task G2;
                          device; not shared with Pairwise Comparison
                          Tayyab)                 Task2

  Study 2                 data_exp_263105-vall    Vision Check;
                          (3).zip                 Discrimination Task G1
                                                  (Clone); Discrimination
                                                  Task G2 (Clone);
                                                  Pairwise Comparison
                                                  Task2 (Clone)

  Study 3                 data_exp_275904-vall    Vision Check (Clone);
                          (1).zip                 Discrimination Task;
                                                  Task 2 Pairwise
                                                  Comparison
  -----------------------------------------------------------------------

# 3. Common identifiers and event fields

  -----------------------------------------------------------------------------------
  **Raw Gorilla     **Canonical name**       **Type**          **Use / rule**
  column**                                                     
  ----------------- ------------------------ ----------------- ----------------------
  Participant       participant_id           string            Study 1: primary
  Public ID                                                    participant key for
                                                               the local unblinded
                                                               Gorilla run. Synthetic
                                                               Study 1 data use
                                                               unique dummy Public
                                                               IDs only. Do not
                                                               expose real Gorilla
                                                               IDs in shareable
                                                               outputs. For other
                                                               studies, use the
                                                               study-specific
                                                               validated ID mapping.

  Participant       participant_private_id   string            Study 1: retain only
  Private ID                                                   for internal
                                                               QA/reconciliation if
                                                               useful; do not use as
                                                               the primary
                                                               participant key when
                                                               unblinded Participant
                                                               Public ID is
                                                               available. Synthetic
                                                               values are dummy and
                                                               real values must not
                                                               appear in shared
                                                               outputs.

  Participant       external_session_id      string            Session identifier
  External Session                                             used for
  ID                                                           reconciliation where
                                                               applicable. It is
                                                               blank in the supplied
                                                               Study 1 unblinded
                                                               export and must not be
                                                               used as the Study 1
                                                               participant key.

  Task Name         task_name                string            Used to select the
                                                               relevant task rows.

  Response Type     response_type            string            Used to isolate
                                                               response events.

  Object Name       object_name              string            Used with Task Name to
                                                               isolate the intended
                                                               response object when a
                                                               task contains multiple
                                                               response components.

  Response          response_raw             string/numeric    Raw participant
                                                               response. Convert to
                                                               numeric only for
                                                               class-count responses.

  Reaction Time     reaction_time_ms         numeric           Raw Gorilla response
                                                               time in milliseconds
                                                               on the relevant
                                                               response event. Apply
                                                               the frozen SAP RT
                                                               rules later; do not
                                                               trim here beyond
                                                               documented invalid
                                                               values.

  Correct           correct_raw              0/1               Gorilla correctness
                                                               indicator where
                                                               available.
                                                               Recalculate/validate
                                                               against response and
                                                               correct_answer in the
                                                               canonical dataset.

  Trial Number      gorilla_trial_number     integer           Event/trial counter
                                                               from Gorilla; retain
                                                               for traceability where
                                                               useful.
  -----------------------------------------------------------------------------------

# 4. Study 1

Primary design fields: Condition = Original vs Optimized; K = 5, 10, 20,
30. The three discrimination variations are configuration instances only
and must not be analysed or interpreted as Difficulty levels. Study 1
identifier rule: Fatimah will run the final scripts locally on an
unblinded Gorilla export. Map \`Participant Public ID\` to canonical
\`participant_id\`; the synthetic Study 1 files use unique dummy Public
IDs. Keep the identifier field configurable in code and never include
original Gorilla IDs in shareable tables, figures, or reports.

## 4.1 Discrimination task

  --------------------------------------------------------------------------------
  **Raw column**    **Canonical variable**   **Values /          **Analysis role**
                                             derivation**        
  ----------------- ------------------------ ------------------- -----------------
  Spreadsheet:      condition                baseline →          Within-subject
  condition                                  Original; sa →      Condition factor
                                             Optimized           

  Spreadsheet:      colormap_raw             tab20; tab20sa      Traceability
  colormap                                                       only; Condition
                                                                 is the canonical
                                                                 factor

  Spreadsheet:      K                        5, 10, 20, 30       Within-subject K
  num_classes                                                    factor

  Spreadsheet:      configuration_instance   1, 2, 3             Repeated
  variation                                                      configuration
                                                                 instance only;
                                                                 not Difficulty

  Spreadsheet:      image                    stimulus filename   Traceability / QA
  image                                                          

  Spreadsheet:      correct_answer           numeric class count Ground truth
  correct_answer                                                 

  Response          response_count           numeric class-count Participant
                                             response            response

  Correct +         accuracy                 1 if response_count Exact class-count
  validation                                 = correct_answer,   accuracy
                                             else 0              

  Reaction Time     reaction_time_ms         numeric             Secondary RT
                                             milliseconds        outcome

  Derived           signed_error             response_count −    Descriptive
                                             correct_answer      secondary outcome

  Derived           absolute_error           abs(signed_error)   Secondary error
                                                                 outcome
  --------------------------------------------------------------------------------

## 4.2 Pairwise task

Important Study 1 mapping correction: the semantic text stored in
left_option/right_option does not reliably identify the condition shown
on that side. Reconstruct the physical side selected first, then compare
it with the actual side containing the Optimized image.

  -----------------------------------------------------------------------
  **Raw column**          **Canonical variable**  **Derivation / rule**
  ----------------------- ----------------------- -----------------------
  Spreadsheet:            trial_number            Pairwise trial index.
  trial_number                                    Analyse the 12 task
                                                  trials; non-task
                                                  screens are excluded.

  Spreadsheet: image_left image_left              Left stimulus filename.

  Spreadsheet:            image_right             Right stimulus
  image_right                                     filename.

  Spreadsheet:            left_option             Value Gorilla records
  left_option                                     when the left image is
                                                  clicked.

  Spreadsheet:            right_option            Value Gorilla records
  right_option                                    when the right image is
                                                  clicked.

  Response                response_raw            Recorded click-response
                                                  value.

  Derived                 preferred_side          Left if response_raw =
                                                  left_option; Right if
                                                  response_raw =
                                                  right_option.

  Derived from filenames  optimized_side          Left if image_left is
                                                  the \*\_optimized\*
                                                  stimulus; Right if
                                                  image_right is the
                                                  \*\_optimized\*
                                                  stimulus.

  Derived                 chose_optimized         1 if preferred_side =
                                                  optimized_side;
                                                  otherwise 0.

  Reaction Time           reaction_time_ms        Pairwise RT retained
                                                  for descriptive
                                                  reporting only under
                                                  the frozen SAP.
  -----------------------------------------------------------------------

QA requirement: each analysed pairwise trial must contain exactly one
Optimized image and one baseline/Original image. Do not code
chose_optimized directly from the words "optimized.png" or
"baseline.png" in Response.

# 5. Study 2

Primary design fields: Condition = Original vs Optimized; K = 5, 10, 20,
30. The study implemented three Difficulty levels. Difficulty is not a
standalone primary factor in the frozen SAP; the primary Condition × K
accuracy analysis averages across the three levels.

## 5.1 Discrimination task

  --------------------------------------------------------------------------
  **Raw column**    **Canonical        **Values /          **Analysis role**
                    variable**         derivation**        
  ----------------- ------------------ ------------------- -----------------
  Spreadsheet:      condition          baseline →          Within-subject
  condition                            Original; sa →      Condition factor
                                       Optimized           

  Spreadsheet:      colormap_raw       distinctipy;        Traceability
  colormap                             distinctipysa       only; Condition
                                                           is the canonical
                                                           factor

  Spreadsheet:      K                  5, 10, 20, 30       Within-subject K
  num_classes                                              factor

  Spreadsheet:      difficulty_index   1, 2, 3             Three implemented
  variation                                                Difficulty
                                                           instances;
                                                           primary accuracy
                                                           is averaged
                                                           across them
                                                           within Condition
                                                           × K

  Spreadsheet:      image              stimulus filename   Traceability / QA
  image                                                    

  Spreadsheet:      correct_answer     numeric class count Ground truth
  correct_answer                                           

  Response          response_count     numeric class-count Participant
                                       response            response

  Correct +         accuracy           1 if response_count Exact class-count
  validation                           = correct_answer,   accuracy
                                       else 0              

  Reaction Time     reaction_time_ms   numeric             Secondary RT
                                       milliseconds        outcome

  Derived           signed_error       response_count −    Descriptive
                                       correct_answer      secondary outcome

  Derived           absolute_error     abs(signed_error)   Secondary error
                                                           outcome
  --------------------------------------------------------------------------

Difficulty label note: the raw discrimination export stores 1/2/3 rather
than the text labels. The synthetic/canonical file may use
difficulty_index as the authoritative field. If text labels are added,
they must follow the established study coding and must not be inferred
from outcomes.

## 5.2 Pairwise task

  --------------------------------------------------------------------------
  **Raw column**    **Canonical        **Derivation /     **Analysis role**
                    variable**         rule**             
  ----------------- ------------------ ------------------ ------------------
  Spreadsheet:      trial_number       Pairwise trial     Structure/QA
  trial_number                         index; 12 analysed 
                                       task trials.       

  Spreadsheet:      image_left         Left stimulus      Stimulus/QA
  image_left                           filename;          
                                       filenames contain  
                                       K and              
                                       Easy/Medium/Hard   
                                       labels.            

  Spreadsheet:      image_right        Right stimulus     Stimulus/QA
  image_right                          filename.          

  Spreadsheet:      optimized_side     Raw Left/Right     Pairwise
  optimized_side                       field; validate    recoding/QA
                                       against actual     
                                       filenames before   
                                       use.               

  Spreadsheet:      left_option        Value Gorilla      Side
  left_option                          records when the   reconstruction
                                       left image is      
                                       clicked.           

  Spreadsheet:      right_option       Value Gorilla      Side
  right_option                         records when the   reconstruction
                                       right image is     
                                       clicked.           

  Response          response_raw       Recorded           Side
                                       click-response     reconstruction
                                       value.             

  Derived           preferred_side     Left if            Pairwise outcome
                                       response_raw =     construction
                                       left_option; Right 
                                       if response_raw =  
                                       right_option.      

  Derived           chose_optimized    1 if               Primary pairwise
                                       preferred_side =   outcome
                                       validated          
                                       optimized_side;    
                                       otherwise 0.       

  Derived from      K                  5, 10, 20, 30      Useful for
  filename                                                QA/descriptives;
                                                          H3 uses overall
                                                          participant
                                                          proportion.

  Derived from      difficulty_label   Easy, Medium, Hard Retain for
  filename                                                structure/QA; no
                                                          standalone primary
                                                          pairwise
                                                          Difficulty
                                                          hypothesis.

  Reaction Time     reaction_time_ms   Pairwise RT        Descriptive
                                       retained for       pairwise RT
                                       descriptive        
                                       reporting only     
                                       under the frozen   
                                       SAP.               
  --------------------------------------------------------------------------

QA requirement: do not determine chose_optimized directly from Response
= "optimized"/"baseline". In the supplied export,
left_option/right_option are not a reliable proxy for the actual
condition shown on that physical side. Reconstruct preferred_side and
compare it with validated optimized_side.

# 6. Study 3

Primary design fields: Condition = Original vs background-aware
Optimized; Background = White vs Black; K = 10, 20, 30; Difficulty =
Easy, Medium, Hard. For primary accuracy, participant-level values are
averaged across both K and Difficulty within each Condition × Background
cell.

## 6.1 Discrimination task

  ---------------------------------------------------------------------------------------------
  **Raw column**      **Canonical         **Values / derivation**         **Analysis role**
                      variable**                                          
  ------------------- ------------------- ------------------------------- ---------------------
  Spreadsheet:        participant_group   G_BW_OptFirst; G_WB_OptFirst;   Design/QA; not a
  participant_group                       G_BW_OrigFirst; G_WB_OrigFirst  primary predictor

  Spreadsheet:        condition_order     optimized_first; original_first Design documentation;
  condition_order                                                         not a primary
                                                                          predictor

  Spreadsheet:        block_order         black_first; white_first        Design documentation;
  block_order                                                             not a primary
                                                                          predictor

  Spreadsheet:        background          white; black                    Within-subject
  background                                                              Background factor

  Spreadsheet:        condition           C1_original_distinctipy →       Within-subject
  condition                               Original;                       Condition factor
                                          C2_background_aware_optimized → 
                                          Optimized                       

  Spreadsheet:        K                   10, 20, 30                      Averaged across for
  num_classes                                                             H4/H5
                                                                          participant-level
                                                                          cells

  Spreadsheet:        difficulty_index    1, 2, 3                         Difficulty index
  difficulty_num                                                          

  Spreadsheet:        difficulty_label    easy; medium; hard              Implemented
  difficulty_label                                                        Difficulty label

  Spreadsheet:        scale_factor        0.8; 1.0; 1.3                   Stimulus-generation
  scale_factor                                                            metadata / QA

  Spreadsheet:        layout_id           e.g., K10_D1                    Stimulus/layout
  layout_id                                                               traceability

  Spreadsheet: image  image               stimulus filename               Traceability / QA

  Spreadsheet:        correct_answer      10, 20, 30                      Ground truth
  correct_answer                                                          

  Response            response_count      numeric class-count response    Participant response

  Correct +           accuracy            1 if response_count =           Exact class-count
  validation                              correct_answer, else 0          accuracy

  Reaction Time       reaction_time_ms    numeric milliseconds            Secondary RT outcome

  Derived             signed_error        response_count − correct_answer Descriptive secondary
                                                                          outcome

  Derived             absolute_error      abs(signed_error)               Secondary error
                                                                          outcome
  ---------------------------------------------------------------------------------------------

## 6.2 Pairwise task

  -----------------------------------------------------------------------
  **Raw column**          **Canonical variable**  **Values / derivation**
  ----------------------- ----------------------- -----------------------
  Spreadsheet:            trial_number            Pairwise trial index;
  trial_number                                    18 analysed task
                                                  trials.

  Spreadsheet: trial_id   trial_id                Study-defined pairwise
                                                  trial identifier.

  Spreadsheet: background background              white; black.

  Spreadsheet:            K                       10, 20, 30.
  num_classes                                     

  Spreadsheet:            difficulty_index        1, 2, 3.
  difficulty_num                                  

  Spreadsheet:            difficulty_label        easy; medium; hard.
  difficulty_label                                

  Spreadsheet: image_left image_left              Left stimulus filename.

  Spreadsheet:            image_right             Right stimulus
  image_right                                     filename.

  Spreadsheet:            optimized_side          Left or Right; validate
  optimized_side                                  against \*\_opt\_\*
                                                  versus \*\_orig\_\*
                                                  filenames.

  Response                preferred_side          For the supplied task,
                                                  the response is
                                                  directly recorded as
                                                  Left or Right.

  Derived                 chose_optimized         1 if preferred_side =
                                                  validated
                                                  optimized_side;
                                                  otherwise 0.

  Reaction Time           reaction_time_ms        Pairwise RT retained
                                                  for descriptive
                                                  reporting unless
                                                  otherwise specified in
                                                  the frozen SAP.
  -----------------------------------------------------------------------

# 7. Vision-screen structure

All three exports contain a four-item Vision Check with the same answer
keys (12, 16, 29, 26). The vision-screen outcome is used only for the
prespecified sensitivity analyses.

  ------------------------------------------------------------------------
  **Raw column**          **Canonical variable**  **Rule**
  ----------------------- ----------------------- ------------------------
  Spreadsheet: tag        vision_item             Q1_answer, Q2_answer,
                                                  Q3_answer, Q4_answer

  Spreadsheet:            vision_correct_answer   12, 16, 29, 26
  correct_answer                                  

  Response                vision_response         Participant numeric
                                                  response

  Correct + validation    vision_item_correct     1 if vision_response =
                                                  vision_correct_answer,
                                                  else 0

  Derived summary         vision_score            Sum of
                                                  vision_item_correct
                                                  across the four items
                                                  (0--4)

  Derived / prespecified  vision_subset_flag      Use the already-defined
  rule                                            vision-screen
                                                  sensitivity rule
                                                  associated with the
                                                  frozen SAP; do not
                                                  redefine the threshold
                                                  from the outcome data.
  ------------------------------------------------------------------------

# 8. Canonical synthetic-data file structures

The recommended synthetic package should contain one discrimination
table, one pairwise table, and one vision table per study. These
canonical tables contain only variables required for analysis/QA and can
be mapped from the raw Gorilla exports using the rules above. For Study
1, the synthetic raw-structure files use unique dummy \`Participant
Public ID\` values so the import code can be developed against the same
unblinded-ID structure used in the local real-data run.

  -----------------------------------------------------------------------
  **File**                            **Required columns**
  ----------------------------------- -----------------------------------
  study1_discrimination.csv           participant_id, condition, K,
                                      configuration_instance, image,
                                      response_count, correct_answer,
                                      accuracy, reaction_time_ms,
                                      signed_error, absolute_error

  study1_pairwise.csv                 participant_id, trial_number,
                                      image_left, image_right,
                                      left_option, right_option,
                                      response_raw, preferred_side,
                                      optimized_side, chose_optimized,
                                      reaction_time_ms

  study1_vision.csv                   participant_id, vision_item,
                                      vision_response,
                                      vision_correct_answer,
                                      vision_item_correct, vision_score,
                                      vision_subset_flag

  study2_discrimination.csv           participant_id, condition, K,
                                      difficulty_index, image,
                                      response_count, correct_answer,
                                      accuracy, reaction_time_ms,
                                      signed_error, absolute_error

  study2_pairwise.csv                 participant_id, trial_number, K,
                                      difficulty_label, image_left,
                                      image_right, left_option,
                                      right_option, response_raw,
                                      preferred_side, optimized_side,
                                      chose_optimized, reaction_time_ms

  study2_vision.csv                   participant_id, vision_item,
                                      vision_response,
                                      vision_correct_answer,
                                      vision_item_correct, vision_score,
                                      vision_subset_flag

  study3_discrimination.csv           participant_id, participant_group,
                                      condition_order, block_order,
                                      condition, background, K,
                                      difficulty_index, difficulty_label,
                                      scale_factor, layout_id, image,
                                      response_count, correct_answer,
                                      accuracy, reaction_time_ms,
                                      signed_error, absolute_error

  study3_pairwise.csv                 participant_id, trial_number,
                                      trial_id, background, K,
                                      difficulty_index, difficulty_label,
                                      image_left, image_right,
                                      preferred_side, optimized_side,
                                      chose_optimized, reaction_time_ms

  study3_vision.csv                   participant_id, vision_item,
                                      vision_response,
                                      vision_correct_answer,
                                      vision_item_correct, vision_score,
                                      vision_subset_flag
  -----------------------------------------------------------------------

# 9. Structural validation checks

  -----------------------------------------------------------------------
  **Check**                           **Expected rule**
  ----------------------------------- -----------------------------------
  Study 1 discrimination              24 analysed trials per included
                                      participant = 2 Condition × 4 K × 3
                                      configuration instances.

  Study 1 pairwise                    12 analysed pairwise trials per
                                      included participant.

  Study 2 discrimination              24 analysed trials per included
                                      participant = 2 Condition × 4 K × 3
                                      implemented Difficulty instances.

  Study 2 pairwise                    12 analysed pairwise trials per
                                      included participant.

  Study 3 discrimination              36 analysed trials per included
                                      participant = 2 Condition × 2
                                      Background × 3 K × 3 Difficulty.

  Study 3 pairwise                    18 analysed pairwise trials per
                                      included participant.

  Vision check                        4 vision items per participant
                                      before participant-level vision
                                      summary.

  Discrimination correctness          accuracy must equal (response_count
                                      == correct_answer). Any mismatch
                                      with Gorilla Correct must be
                                      flagged, not silently overwritten.

  Pairwise condition identity         Each pairwise trial must contain
                                      exactly one Original/baseline image
                                      and one Optimized image.

  Pairwise side reconstruction        Study 1 and Study 2: reconstruct
                                      preferred_side from Response versus
                                      left_option/right_option before
                                      calculating chose_optimized.

  Study 3 side coding                 Response must be Left or Right and
                                      must agree with the response
                                      object/side coding.

  No outcome-based exclusions         Never drop participants/trials
                                      because their results are unusual.
                                      Use only predefined exclusions and
                                      documented technical/data-quality
                                      rules.
  -----------------------------------------------------------------------

# 10. Raw-event row selection guidance

  -----------------------------------------------------------------------
  **Study/task**                      **Rows to retain for trial-level
                                      analysis**
  ----------------------------------- -----------------------------------
  Study 1 discrimination              Task Name = Discrimination Task G1
                                      or Discrimination Task G2; Response
                                      Type = response; Object Name =
                                      Response.

  Study 1 pairwise                    Task Name = Pairwise Comparison
                                      Task2; Response Type = response;
                                      Object Name = Image Response.
                                      Exclude confidence/comment
                                      responses.

  Study 1 vision                      Task Name = Vision Check; Response
                                      Type = response; Object Name =
                                      Number Entry.

  Study 2 discrimination              Task Name = Discrimination Task G1
                                      (Clone) or Discrimination Task G2
                                      (Clone); Response Type = response;
                                      Object Name = Response.

  Study 2 pairwise                    Task Name = Pairwise Comparison
                                      Task2 (Clone); Response Type =
                                      response; Object Name = Image
                                      Response. Exclude
                                      confidence/comment responses.

  Study 2 vision                      Task Name = Vision Check; Response
                                      Type = response; Object Name =
                                      Number Entry.

  Study 3 discrimination              Task Name = Discrimination Task;
                                      retain only answer-response events
                                      that carry the discrimination
                                      spreadsheet fields and participant
                                      response.

  Study 3 pairwise                    Task Name = Task 2 Pairwise
                                      Comparison; retain Select_Left /
                                      Select_Right response events only.

  Study 3 vision                      Task Name = Vision Check (Clone);
                                      Response Type = response; Object
                                      Name = Number Entry.
  -----------------------------------------------------------------------

# 11. Fields not required for the frozen primary analyses

The raw exports contain many Gorilla metadata fields (timestamps,
device/browser information, screen IDs, internal object IDs) and Study 3
stimulus provenance fields (source paths, commit hashes, palette
metrics, rendering metadata). These should be preserved in the raw
archive but do not need to appear in the canonical synthetic analysis
tables unless Tayyab uses them for traceability or QA. They must not be
introduced as additional predictors without a separate methodological
decision.

# 12. Handoff rule

If a raw field is ambiguous, absent, or inconsistent with this
dictionary, Tayyab should stop at the mapping/QA stage and flag the
issue to Fatimah. He should not resolve an ambiguity by changing an
analysis, inventing a factor, or recoding a condition from outcome
values. The real unblinded Study 1 export remains local to Fatimah and
must not be sent to Tayyab; only synthetic/dummy identifiers should be
used in shared development files.
