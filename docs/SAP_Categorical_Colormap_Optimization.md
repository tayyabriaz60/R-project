Categorical Colormap Optimization: Statistical Analysis Plan

21 September 2026

1 General Analysis Principles

Significance level and confidence intervals. All analyses should use a
significance level of α = .05. Effect estimates should be reported with
95% confidence intervals.

Multiple comparisons. The prespecified primary hypotheses are treated as
distinct, sepa- rately interpreted research questions and are each
tested at α = .05 without adjustment across hypotheses. Holm correction
for multiple comparisons should be applied when several follow-up
comparisons (after finding a statistically significant effect) are
conducted. Holm correction is recommended because it controls the risk
of false-positive findings.

Missing data and exclusions. The predefined primary analysis populations
and documented data-cleaning rules should be used. No participants or
trials should be excluded based on the observed outcomes. Any missing or
excluded observations should be reported together with the final number
of participants included in each analysis.

Analysis level. The primary inferential analyses should use
participant-level summary mea- sures while accounting for repeated
trials within participants.

Fallback analyses. Predefined fallback procedures should be used only
when the assumptions of the corresponding primary analysis are violated.

2 Review of Research Questions and Hypotheses

The research questions and hypotheses were reviewed for alignment with
the final participant- level analyses. Minor wording refinements were
made while preserving the original aims.

RQ1. To what extent does categorical colormap optimization affect
participants’ exact class- count accuracy, and does this effect vary
with the number of classes? Studies 1 and 2 address this question
independently.

H1. Averaged across the class counts tested, participant-level exact
class-count accuracy will differ between Optimized and Original
categorical colormaps, with the expected direction favouring Optimized.
This hypothesis will be tested separately in Study 1 and Study 2.

H2. The effect of optimization on participant-level exact class-count
accuracy will vary across the class counts tested. In Study 1, K = 30 is
retained and interpreted explicitly as a palette- capacity boundary
condition.

RQ2. Are Optimized categorical colormaps perceived as providing clearer
category separation than their Original counterparts?

1

H3. The participant-level proportion of selecting the Optimized colormap
as providing clearer category separation will differ from 0.50, with the
expected direction favouring Optimized. This hypothesis is tested
separately in Study 1 and Study 2.

RQ3. Does categorical colormap optimization using a background-aware
objective affect exact class-count accuracy relative to Original
colormaps, and does this effect depend on display background?

H4. Averaged across White and Black backgrounds, participant-level exact
class-count accuracy will differ between Optimized colormaps generated
using the background-aware objective and Original colormaps, with the
expected direction favouring Optimized.

H5. The effect of optimization on participant-level exact class-count
accuracy will differ be- tween White and Black backgrounds.

RQ4. Are Optimized colormaps generated using the background-aware
objective perceived as providing clearer category separation than
Original colormaps, and does this perception depend on display
background?

H6. In Study 3, the participant-level proportion of selecting the
Optimized colormap as pro- viding clearer category separation will
differ from 0.50, with the expected direction favouring Optimized.

H7. The participant-level proportion of selecting the Optimized colormap
will differ between White and Black backgrounds.

3 Study 1 3.1 Accuracy

Research question. The primary analysis examines whether Optimized
colormaps improve participant-level exact class-count accuracy compared
with Original colormaps (H1), and whether the effect of optimization
differs depending on the number of classes, K (H2).

Recommended analysis. For each participant, calculate exact class-count
accuracy as the proportion of correct responses within each Condition ×
K combination, averaging across the three configuration instances. The
three variations are treated only as configuration sets and are not
analyzed or treated as Difficulty levels.

H1 and H2 should be tested using a 2 × 4 repeated-measures ANOVA, with
Condition (Original vs. Optimized) and K (5, 10, 20, 30) as
within-subject factors. The main effect of Condition tests H1, that is,
whether accuracy differs between Optimized and Original colormaps when
averaged across the tested values of K. The Condition × K interaction
tests H2, that is, whether the difference between Optimized and Original
changes across the four values of K.

If the Condition × K interaction is significant, follow-up
paired-samples t-tests should compare Original and Optimized separately
at K = 5, K = 10, K = 20, and K = 30, with Holm correction across the
four comparisons.

If the within-participant Optimized − Original difference at a given K
has zero variance, the inferential follow-up comparison and standardized
paired effect size for that K will not be computed. Descriptive values
will be reported instead, and Holm correction will be applied across the
remaining estimable K-specific comparisons.

2

Assumptions and diagnostics. Inspect histograms of the participant-level
accuracy data for normality, focusing on severe skewness and extreme
outliers. With N = 50, moderate deviations from normality are unlikely
to be problematic. Sphericity should be assessed using Mauchly’s test.
If the assumption is violated, the Greenhouse–Geisser correction should
be applied.

Fallback analysis. If the participant-level accuracy data show severe
deviations from nor- mality, non-parametric alternatives should be used.
There is no single simple non-parametric equivalent of the 2 × 4
repeated-measures ANOVA that tests both the overall Condition effect and
the Condition × K interaction in the same model. Therefore, H1 and H2
should be tested separately. For H1, use a paired Wilcoxon signed-rank
test comparing overall Original and Op- timized accuracy. For H2,
calculate the Optimized–Original accuracy difference at each value of K
and use a Friedman test to assess whether these differences vary across
K.

Reporting. Report the mean and standard deviation of participant-level
accuracy for Original and Optimized colormaps.

For H1, report the Condition main effect with F, degrees of freedom,
p-value, partial η2, and 95% confidence interval.

For H2, report the Condition × K interaction with F, degrees of freedom,
p-value, partial η2, and 95% confidence interval. If the interaction is
significant, report the paired Original vs. Optimized comparison at each
value of K, including the mean difference, 95% confidence interval, t
statistic, degrees of freedom, Cohen’s d for effect size, and
Holm-adjusted p-value.

Reporting of fallback analyses. If the non-parametric test is used,
report the corresponding non-parametric test statistics and effect
sizes.

For H1, report the Wilcoxon signed-rank statistic (V ), p-value, a
rank-biserial correlation as the effect size, and its 95% confidence
interval.

For H2, report the Friedman test statistic, degrees of freedom, p-value,
and Kendall’s W as the effect size. If the Friedman test is significant,
conduct pairwise Wilcoxon signed-rank tests comparing the
Optimized–Original difference scores between the four values of K, with
Holm correction across the six pairwise comparisons.

3.2 Pairwise Choice

Research question. Whether the participant-level proportion of Optimized
choices differs from 0.50, with the expected direction favoring
Optimized (H3).

Recommended analysis. For each participant, calculate the proportion of
the 12 pairwise trials in which the Optimized colormap was selected. H3
should be tested using a one-sample t-test, comparing the mean
Optimized-choice proportion with 0.50.

A two-sided test should be used because H3 formally tests whether the
proportion differs from 0.50, although the expected direction is in
favor of Optimized.

Assumptions and diagnostics. Check whether the participant-level
proportions are approx- imately normally distributed, without severe
skewness. With N = 50, the one-sample t-test is reasonably robust to
moderate deviations from normality, so a visual inspection using a his-
togram is sufficient.

3

Fallback analysis. If the participant-level proportions are very skewed,
a one-sample Wilcoxon signed-rank test against 0.50 should be used
instead. If the Wilcoxon test is used, the inter- pretation changes
slightly: instead of testing whether the mean proportion differs from
0.50, it tests whether participant proportions generally tend to be
above or below 0.50.

Reporting. Report the mean Optimized-choice proportion, standard
deviation, 95% confi- dence interval, t statistic, degrees of freedom,
p-value, and Cohen’s d as the effect size.

Reporting of fallback analysis. If a Wilcoxon signed-rank fallback is
used, report the Wilcoxon signed-rank statistic (V ), p-value,
rank-biserial correlation, and its 95% confidence interval.

3.3 Secondary Outcomes

3.3.1 Response Time

Valid trials and preprocessing. Include all valid trials, regardless of
whether the response was correct or incorrect. Trials with missing or
non-positive response time values, or values affected by a documented
recording or technical error, should be excluded. No other trimming
should be applied.

Recommended analysis. Calculate the skewness coefficient of the
trial-level response time distribution. If the skewness coefficient is
greater than 1, indicating substantial right skew, log-transform
response time before calculating participant-level means.

For each participant, calculate the mean response time separately for
Original and Optimized trials, averaging across K, using either the raw
or log-transformed response times as determined above. Compare the two
conditions using a paired-samples t-test.

Pairwise-task response time should remain descriptive, as specified in
the current study plan, unless a specific inferential question is
included.

Assumptions and fallback. Calculate each participant’s
Original–Optimized difference in mean response time using the same
response time scale used for the analysis, and inspect a histogram of
these difference scores. If the differences are severely non-normal, use
a paired Wilcoxon signed-rank test instead of the paired-samples t-test.

Reporting. Report the mean and standard deviation of participant-level
response time for Original and Optimized trials. Report the paired mean
difference with its 95% confidence interval, together with the t
statistic, degrees of freedom, p-value, and Cohen’s d. If response time
is log-transformed, state that the inferential analysis was conducted on
the log-transformed values while still reporting descriptive mean
response times in milliseconds for interpretability (the non-transformed
values).

Reporting of fallback analysis. If the paired Wilcoxon signed-rank test
is used, report the Wilcoxon signed-rank statistic (V ), p-value,
rank-biserial correlation as the effect size, and its 95% confidence
interval.

3.3.2 Absolute Error

Recommended treatment. Absolute error examines whether the size of
participants’ errors differs between Original and Optimized colormaps.
For each participant, calculate the mean absolute error separately for
Original and Optimized trials, averaging across all values of K.

4

Compare the two conditions using a paired-samples t-test. This provides
a simple test of whether the magnitude of participants’ errors differs
between Original and Optimized colormaps.

Assumptions and diagnostics. Inspect the distribution of the
within-participant differences in mean absolute error for substantial
skewness, using a histogram. With N = 50, the paired t-test is robust to
moderate deviations from normality. If the within-participant
differences are extremely skewed, a paired Wilcoxon signed-rank test
should be used instead.

Reporting. Report the mean and standard deviation of absolute error for
each condition, the mean paired difference, 95% confidence interval, t
statistic, degrees of freedom, p-value, and paired-samples Cohen’s d for
effect size.

Reporting of fallback analysis. If the paired Wilcoxon signed-rank test
is used, report the Wilcoxon signed-rank statistic (V ), p-value,
rank-biserial correlation as the effect size, and its 95% confidence
interval.

3.3.3 Signed Error

Recommended treatment. Signed error shows the direction of participants’
errors. Negative values indicate underestimation, meaning that
participants perceived fewer categories than were actually present.
Positive values indicate overestimation, meaning that participants
perceived more categories than were actually present.

Signed error should be treated as a descriptive secondary outcome
because no separate inferential hypothesis was prespecified for
directional error. It will be used to describe whether errors tend
toward underestimation or overestimation in each condition.

Reporting. Report the mean signed error and standard deviation
separately for the Original and Optimized conditions. Values below zero
indicate a tendency toward underestimation and values above zero
indicate overestimation.

3.4 Design and Sensitivity Considerations

Condition order. Condition order was counterbalanced equally across
participants. It there- fore does not need to be included as a predictor
in the primary analysis and should simply be documented as part of the
study design.

Configuration variations. The three variations within each K level
should be treated only as repeated configuration instances. The
Easy/Medium/Hard manipulation was not implemented in Study 1, so no
Difficulty effect should be analyzed or interpreted.

Fixed pairwise order. The pairwise trial order was fixed across
participants. No analytical adjustment is recommended, but this should
be reported as a limitation.

Vision-screen sensitivity analysis. The primary analyses should use all
N = 50 partici- pants. Repeat the primary accuracy and pairwise-choice
analyses using the vision-screen subset (N = 48) as a sensitivity check
and report whether the conclusions change.

K=30 condition. K = 30 should remain in the analysis. Because Tab20
contains 20 base colors, results for this condition should be
interpreted cautiously.

5

Stimulus generalization. Results are specific to the tested stimulus
layouts and should be generalized to other layouts cautiously.

4 Study 2

Study 2 follows the same analytical approach as Study 1 unless otherwise
stated.

4.1 Accuracy

Research question. Whether Optimized colormaps improve participant-level
exact class- count accuracy compared with Original colormaps (H1), and
whether the effect of optimization differs depending on K (H2).

Recommended analysis. Use the same participant-level 2 × 4
repeated-measures ANOVA as in Study 1. The same assumptions,
diagnostics, fallback procedure, follow-up comparisons, and reporting
recommendations as in Study 1 apply.

Difficulty levels. In Study 2, the three Difficulty levels (Easy,
Medium, and Hard) were implemented as intended. Difficulty is not tested
as a standalone primary factor in the present SAP; for the primary
Condition × K analysis, participant-level accuracy is averaged across
the three Difficulty levels.

4.2 Pairwise Choice

Research question. Whether the participant-level proportion of Optimized
choices differs from 50%, with the expected direction favoring Optimized
(H3).

Recommended analysis. Use the same participant-level analysis as in
Study 1. The same assumptions, fallback procedure, and reporting
recommendations as in Study 1 apply.

4.3 Secondary Outcomes

4.3.1 Response Time

Use the same response time approach as in Study 1.

4.3.2 Absolute Error

Use the same secondary analysis as in Study 1.

4.3.3 Signed Error

Use the same descriptive approach as in Study 1.

4.4 Design and Sensitivity Considerations

Primary analysis population. The researcher session should be excluded
from all analyses, giving a sample of N = 50.

Condition order. Use the same rules as in Study 1.

Vision-screen sensitivity analysis. The primary analyses should use N =
50. Repeat the primary accuracy and pairwise-choice analyses using the
vision-screen subset (N = 43) as a sensitivity check and report whether
the conclusions change.

Stimulus generalization. As in Study 1, results are specific to the
tested stimulus layouts and should be generalized to other layouts
cautiously.

6

5 Study 3 5.1 Accuracy

Research question. Whether Optimized colormaps improve participant-level
exact class- count accuracy compared with Original colormaps, averaged
across White and Black back- grounds (H4), and whether the effect of
optimization differs between White and Black back- grounds (H5).

Recommended analysis. For each participant, calculate exact class-count
accuracy as the proportion of correct responses within each Condition ×
Background combination, averaging across both K and Difficulty.

H4 and H5 should be tested using a 2 × 2 repeated-measures ANOVA, with
Condition (Original vs. Optimized) and Background (White vs. Black) as
within-subject factors. The main effect of Condition tests H4, that is,
whether accuracy differs between Optimized and Original colormaps when
averaged across backgrounds. The Condition × Background interaction
tests H5, that is, whether the difference between Optimized and Original
differs between White and Black backgrounds.

If the Condition × Background interaction is significant, follow-up
paired-samples t-tests should compare Original and Optimized separately
within White and Black backgrounds, with Holm correction across the two
comparisons.

Assumptions and diagnostics. Inspect histograms of the participant-level
accuracy data for severe skewness and extreme outliers. With N = 50,
moderate deviations from normality are unlikely to be problematic. No
sphericity correction is required because both within-subject factors
have only two levels.

Fallback analysis. If the participant-level accuracy data show severe
deviations from nor- mality, H4 and H5 should be tested separately using
non-parametric alternatives. For H4, use a paired Wilcoxon signed-rank
test comparing overall Original and Optimized accuracy. For H5,
calculate the Optimized–Original accuracy difference separately for
White and Black back- grounds and compare these two difference scores
using a paired Wilcoxon signed-rank test.

Reporting. Report the mean and standard deviation of participant-level
accuracy for each Condition × Background combination.

For H4, report the Condition main effect with F, degrees of freedom,
p-value, partial η2, and 95% confidence interval.

For H5, report the Condition × Background interaction with F, degrees of
freedom, p-value, partial η2, and 95% confidence interval. If the
interaction is significant, report the paired Original vs. Optimized
comparison within each background, including the mean difference, 95%
confidence interval, t statistic, degrees of freedom, Cohen’s d for
effect size, and Holm-adjusted p-value.

Reporting of fallback analyses. For H4, report the Wilcoxon signed-rank
statistic (V ), p-value, rank-biserial correlation as the effect size,
and its 95% confidence interval.

For H5, report the Wilcoxon signed-rank statistic (V ), p-value,
rank-biserial correlation as the effect size, and its 95% confidence
interval. If the test is significant, compare Original and Optimized
separately within White and Black backgrounds using paired Wilcoxon
signed-rank tests with Holm correction across the two comparisons.

7

5.2 Pairwise Choice

Research questions. Whether the participant-level proportion of
Optimized choices differs from 50%, with the expected direction favoring
Optimized (H6), and whether the participant- level proportion of
Optimized choices differs between White and Black backgrounds (H7).

Recommended analysis. For H6, calculate each participant’s overall
Optimized choice pro- portion across the 18 pairwise trials and compare
the mean proportion with 0.50 using a two- sided one-sample t-test.

For H7, calculate each participant’s Optimized choice proportion
separately for White and Black backgrounds and compare the two
proportions using a paired-samples t-test.

H6 uses a one-sample t-test because each participant contributes one
overall proportion, while H7 uses a paired-samples t-test because each
participant contributes two related proportions (repeated measures); one
for White and one for Black backgrounds.

Assumptions and diagnostics. As in Study 1, inspect the
participant-level proportions and paired differences using histograms
for severe skewness.

Fallback analysis. If the distributions are very skewed, use a
one-sample Wilcoxon signed- rank test against 0.50 for H6 and a paired
Wilcoxon signed-rank test for H7.

Reporting. For H6, report the mean Optimized-choice proportion, standard
deviation, 95% confidence interval, t statistic, degrees of freedom,
p-value, and Cohen’s d. For H7, report the mean and standard deviation
for each background, the mean paired difference (White − Black), 95%
confidence interval, t statistic, degrees of freedom, p-value, and
paired-samples Cohen’s d.

Reporting of fallback analyses. For H6, if the one-sample Wilcoxon
signed-rank test is used, report the Wilcoxon signed-rank statistic (V
), p-value, rank-biserial correlation, and its 95% confidence interval.

For H7, if the paired Wilcoxon signed-rank test is used, report the
Wilcoxon signed-rank statistic (V ), p-value, rank-biserial correlation,
and its 95% confidence interval.

5.3 Secondary Outcomes

5.3.1 Response Time

Use the same preprocessing and, if needed, transformation as in Study 1.
For each participant, calculate mean response time within each Condition
× Background combination and analyze these using a 2 × 2
repeated-measures ANOVA. Apply the same assumption checks and fallback
principles as for the Study 3 accuracy analysis. If the Condition ×
Background interaction is significant, compare Original and Optimized
separately within White and Black backgrounds using paired-samples
t-tests with Holm correction across the two comparisons.

Report the Condition, Background, and Condition × Background effects
with F, degrees of freedom, p-value, partial η2, and 95% confidence
intervals. If response time is log-transformed, state that inference was
conducted on the log-transformed values while reporting untransformed
response times in milliseconds.

5.3.2 Absolute Error

Use the same approach as in Study 1. Descriptive values can additionally
be reported separately for White and Black backgrounds.

8

5.3.3 Signed Error

Use the same approach as in Study 1.

5.4 Design and Sensitivity Considerations

Condition and background order. Condition order and Background order
were counter- balanced across participants. They do not need to be
included in the primary analysis and should be documented as part of the
study design.

Vision-screen sensitivity analysis. The primary analyses should use N =
50. Repeat the primary accuracy and pairwise-choice analyses using the
vision-screen subset (N = 46) as a sensitivity check and report whether
the conclusions change.

Stimulus generalization. As in Studies 1 and 2, results are specific to
the tested stimulus layouts and should be generalized to other layouts
cautiously.

6 Recommended Analysis and Reporting Order

The analyses should be conducted in the following order:

1.  Confirm the analysis populations and apply all predefined
    exclusions.

2.  Calculate the required participant-level summary measures.

3.  Produce descriptive statistics and relevant visualizations.

4.  Perform the specified assumption checks for the primary analyses.

5.  Conduct the primary hypothesis tests, applying any required
    corrections or predefined fallback analyses.

6.  If an interaction is significant, conduct the planned follow-up
    comparisons with the speci- fied Holm correction.

7.  Report the primary results, including effect sizes and 95%
    confidence intervals, and produce relevant visualizations.

8.  Preprocess the secondary outcomes, including the specified
    response-time checks and any required log transformation.

9.  Calculate the required participant-level summaries for the secondary
    outcomes.

10. Perform the specified assumption checks and conduct the secondary
    analyses, using pre- defined fallback analyses where required.

11. Report the secondary outcomes, including effect sizes and 95%
    confidence intervals where applicable, and produce relevant
    visualizations.

12. Conduct the predefined vision-screen sensitivity analyses for the
    primary outcomes.

13. Report whether the sensitivity analyses change the conclusions of
    the primary analyses.

9
