# Final notebook scope

The notebook follows the Unit 2 [Apply assignment](sources/apply_assignment.md). Its main
modeling question is how learning rate, SGD, L2, and dropout affect learning and generalization.
A validation-only feature-group analysis provides a bounded extension of the previous report's
proposals to evaluate across time and investigate land-use information.

## Data and evaluation

- Pinned data: US Tornado Data 2010-2025, v2.2.1 / Kaggle version 8; retrospective table and
  explicit predictor list from `ml/feature_dictionary.json`.
- 20,164 records; 18,639 known EF0-EF5 labels modeled; 1,525 unknown labels retained in coverage
  summaries but excluded from supervised learning.
- Train 2010-2019 (11,771); validate 2020-2022 (3,117); test 2023-2025 (3,751). The notebook
  checks that source/radar/warning linkage groups do not cross these partitions.
- Median imputation, missingness indicators, scaling, and selection of log transforms use only
  training data. Time is encoded cyclically. All 32 permitted raw predictors yield 49 inputs.
- Six-class softmax; inverse training-frequency weights normalized to mean sample weight one.
  EF5 support is 7 / 0 / 1, so EF5 performance cannot be estimated reliably.
- Select by final-epoch validation macro F1 over present classes, with weighted validation loss
  as the tie-breaker. Keep full six-class test macro F1 primary; any EF0-EF4 score is supplementary.
- Test accuracy, unweighted cross-entropy, per-class precision/recall/F1, confusion matrix,
  EF-category MAE, and within-one accuracy describe the selected model.

## Controlled experiments

Use TensorFlow/Keras with three ReLU hidden layers (128, 64, 32), seed 42, batch size 64,
and a fixed 50-epoch budget. The original Keras History object is retained for every run.

1. Adam 0.001 baseline, no regularization; also the Dropout-0 reference.
2. Same architecture with SGD at 0.1, 0.01, and 0.001.
3. Baseline plus L2 0.001 on hidden-layer kernels.
4. Baseline plus dropout 0.2 or 0.5 after the first two hidden layers.
5. Reuse the validation-selected model as the final model; duplicate its results in the final
   table row without retraining it. Evaluate it once per complete notebook execution.

Keras loss curves contain class weighting and any L2 penalty on both training and validation.
Dropout applies only during training. The comparison table's accuracy and accuracy gap use
inference mode after training, distinct from accuracy measured during fitting. Small single-seed
ranking differences do not establish statistical significance. Fixed-epoch selection preserves
late overfitting behavior; it is not best-checkpoint selection.

## Feature groups and interpretation

Retrain the selected configuration without radar, final track, land cover, or both track and land
cover, keeping the same cohort and split. These comparisons use validation only. Removing track
and land cover still retains full-window radar; it is not an onset-only experiment. Feature
removal measures predictive contribution under this training procedure, not causation or proof
of rural under-rating. Post-event track and land-cover sampling information limit forecasting
claims. Radar matches are proximity associations rather than confirmed parent-storm identities.

The previous report's 0.613 test accuracy is not directly comparable with current results because
class definitions, years, predictors, and the split changed. The final notebook does not include
an onset task, random split, ordinal model, ensemble, extra weather enrichment, or tuning grid.

## Execution and submission

Run `notebook.ipynb` in place with the project `.venv`. Saved figures and CSV tables are regenerated
by the notebook. `data/results/training_history.csv` holds the per-epoch curves, and
`data/results/run_summary.json` records the runtime, configuration, final metrics, split audit,
and existing test results for verification without another test prediction call.

The report follows the previous report's seven-page format: one title page, five write-up
pages with selected saved figures/tables, and one references page. `report.md` contains the
draft, and `slides.md` contains seven GitHub-dark Marp slides with notes for a 4–5 minute talk.
Run `./export.sh` to rebuild both PDFs in `outputs/`. Keep the notebook a concise
walkthrough with reasoning, executed results, and short readouts; put citations and extended
discussion in the report. Package the finished report and executed notebook together.

## Development history and holdout limitation

Earlier exploratory work included test comparisons, documented below and retained at the
`severity-modeling` tag. The current notebook scores one selected model once per execution;
the test period is not a newly collected or never-inspected external holdout. The archived
results below describe those earlier experiments, not outputs to reproduce in the final workflow.

## Explored and dropped: severity modeling (tag `severity-modeling`)

Tried on the temporal split, building on the assignment's final model (SGD 0.01 softmax,
validation macro F1 0.465 over the classes present in 2020-2022):

- Cumulative ordinal head (one latent score minus five ordered cutpoints): 0.315. Lost EF0/EF1
  accuracy; forcing every class boundary onto one severity direction hurt.
- Threshold ladder (five free "is EF > k" logits, running-minimum monotonicity): 0.445.
  Recovered most of the loss, so the ordering was not the problem, the shared score was.
- Focal threshold loss (gamma 2) on the ordinal head: 0.151. Harmful.
- Balanced-subset ensemble (3 members, EF0/EF1 capped at the EF2 count, sqrt weights):
  0.456 on softmax, 0.265 on the ordinal head, 0.482 on the ladder. Only the ladder
  combination beat softmax, by 0.017 on one seed; on the test years it traded three points
  of accuracy (0.508 vs 0.540) for slightly better EF2/EF3 recall (macro F1 0.352 vs 0.345).
- Feature-group conclusions were the same under both models: final track dominates, radar
  and land cover add a little.

Dropped from the submitted notebook as complexity without a robust gain. The full notebook
and outputs are at git tag `severity-modeling`. Pairwise ranking losses and a withheld-EF4
extrapolation check remain untried.
