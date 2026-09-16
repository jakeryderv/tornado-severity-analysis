## Draft title

**Meteorological Indicators, Exposure, and EF Rating in U.S. Tornadoes, 2010–2025**

## Draft abstract

This study extends prior tornado severity classification work using a linked compilation of U.S. tornado records, nearby radar-derived indicators, archived NWS warnings, and land-cover summaries for 2010–2025. The primary question examines how meteorological indicators, tornado characteristics, and exposure proxies relate to final Enhanced Fujita (EF) rating. The secondary question asks how well final EF rating can be estimated using features eligible under the dataset's reported-onset cutoff, conditional on a recorded tornado's cataloged onset and location. The modeling question uses controlled deep-neural-network experiments to investigate how learning rate, stochastic gradient descent (SGD), L2 regularization, and dropout affect training, generalization, and overfitting. The study emphasizes source linkage, temporal leakage control, class imbalance, missingness, and the distinction between recorded damage ratings and physical storm intensity.

## Primary question

> **How do meteorological indicators, tornado characteristics, and exposure relate to final EF rating, and what factors help explain variation in the damage-based rating?**

Uses the **retrospective ML table**. Exposure initially means land-cover and impervious-surface proxies; county population and housing context would require a separate, documented join.

## Secondary question

> **Among recorded tornadoes, how well can final EF rating be estimated using features eligible under the dataset's reported-onset cutoff?**

Uses the **onset ML table**. This is a conditional onset analysis: reported onset and start location come from the final catalog, and radar availability assumes a five-minute latency. Actual real-time receipt is unverified, so the experiment does not establish operational forecasting performance.

## Modeling question

> **How do learning rate, SGD, L2 regularization, and dropout affect the training, generalization, and overfitting behavior of a deep neural network?**

This is the assignment-specific methodology applied to the tornado research. Run the required controlled experiments on the retrospective task, then apply the selected approach to the onset task without repeating the entire experiment grid.

- **Primary and secondary questions:** what the tornado analyses investigate.
- **ML-ready tables:** which features each task may use.
- **Modeling question:** how neural-network training and regularization affect results, assessed through controlled experiments.

## Main objectives

- Quantify relationships between radar indicators, tornado characteristics, exposure, and EF rating.
- Examine whether land cover and exposure proxies help explain variation in final EF ratings, without treating predictive associations as causal effects.
- Identify tornadoes whose radar, track, or exposure characteristics differ from patterns typically associated with their final rating.
- Compare retrospective and conditional onset EF-rating models using the same target definition and event splits.
- Evaluate which feature groups contribute the most information.
- Explore appropriate strategies for handling class imbalance without assuming a fixed EF-class grouping in advance.

## Dataset and analysis views

Use [US Tornado Data, 2010–2025, v2.2.1 / Kaggle version 8](https://www.kaggle.com/datasets/jakevanslyke/us-tornado-data-2010-2025/versions/8). Pin the version and retain `ml/feature_dictionary.json` with the modeling files. This is an independent compilation of government-source records and supporting archives, not an official government product.

Both tables contain **20,164 tornado records**, one row per `tornado_id`, with the same final `target_ef_rating`.

| View | File | Allowed default predictors |
|---|---|---|
| Retrospective | `ml/events_retrospective.parquet` | 32 candidates: onset predictors plus final track characteristics, radar aggregates through onset +60 minutes, and land-cover/impervious summaries |
| Conditional onset | `ml/events_onset.parquet` | 15 candidates: reported start coordinates, month/hour, pre-cutoff radar aggregates, and warning counts/lead time |

Select features using the dictionary's explicit predictor lists. Targets, identifiers, split groups, source statuses, quality fields, injuries, and fatalities are not default predictors. The retrospective radar window is not necessarily the tornado's entire lifetime.

## Feature groups and scope

- **Radar:** nearby SWDI/NEXRAD-derived detection counts and indicator maxima. These are proximity associations, not verified parent-storm identities or raw radar scans.
- **Tornado characteristics:** reported start location and calendar features in both views; final endpoint, path length, width, and duration in the retrospective view only.
- **Warnings:** archived NWS tornado/severe-thunderstorm warning counts and tornado-warning lead time at the onset cutoff. The archive omits standalone cancellation rows, so active-warning counts can be overstated.
- **Exposure proxies:** prior-year NLCD land-cover fractions and impervious-surface percentage sampled within the final event area. These remain retrospective because the sampling area is derived after the event.
- **Damage footprints:** NOAA Event Footprint Catalog regions support retrospective land-cover sampling. Where accepted footprints are unavailable, the dataset uses a documented 500 m buffered track/point approximation. Footprints are not independent measurements of physical intensity.
- **Optional county context:** Census population and housing estimates are available in supporting tables but require a separate join. Whole-county totals do not measure people or buildings struck.
- **Deferred environment data:** ERA5 and ACS/TIGER tract enrichment are not included in this release and are outside the initial analysis.

## Target, missingness, and evaluation

The release contains **18,639 known EF labels** and **1,525 unknown labels**. Known classes are EF0: 9,197; EF1: 7,149; EF2: 1,776; EF3: 426; EF4: 83; EF5: 8. Preserve unknown-label records in coverage summaries, but exclude them from supervised training and scoring; never interpret them as EF0.

Keep **EF0–EF5 as six separate classes** for the primary setup, using a six-output softmax and class-weighted cross-entropy. Compute balanced class weights from training labels and keep them fixed across the controlled experiments. Class collapsing, resampling, focal loss, and an ordinal formulation are optional later experiments, not defaults. Eight EF5 examples in only four linkage groups cannot support stable class-specific estimates on their own; weighting does not create additional evidence.

Inspect missingness by year and EF class rather than dropping every incomplete row. For example, onset shear is missing for 13,260 records and warning lead time for 8,819. Missing radar maxima may reflect no qualifying detection; missing warning lead time may reflect no active warning. Neither automatically means a failed collection job.

- Target a **70/15/15 group-aware stratified random split**, keeping `ml_split_group` values intact. These groups link shared source groups, radar detections, and warnings; they are not confirmed storm-system identities. Choose among reproducible random group allocations using only class balance and split sizes, never features or model performance. Report achieved proportions and class support rather than forcing exact quotas.
- Use the same eligible events, target definition, and split assignments when comparing the two views.
- Fit imputers and scalers only on training data. Use training-guided `log1p` transforms, cyclic month/hour encoding, and missingness indicators; preserve meaningful observed zeros. One-hot encoding applies only if approved categorical predictors are added later. Source-status and quality metadata do not automatically become predictors. Keep preprocessing rules and imbalance handling fixed within the assignment's controlled experiments, with each feature view fitted on the same training events.
- Use validation data for model selection. Keep the test set untouched until all choices are fixed, then evaluate each final task model once.
- Report accuracy, cross-entropy, macro-F1, per-class precision/recall/F1, support, and a six-class confusion matrix. Keep the full label order EF0–EF5; explicitly identify absent or very rare classes and use a documented undefined-metric convention. Also report mean absolute EF-category error and within-one-category accuracy from the predicted class. Validation/test metrics are unweighted; report predictive cross-entropy separately from the training objective when class weighting or L2 changes that objective.
- Compare feature groups on the same cohort, including models with and without final track/damage-derived features. Predictive importance or unusual cases do not establish causation, true wind intensity, or an incorrect official rating.

The current primary allocation retains all 18,639 known-label events: **13,133 training, 2,629 validation, and 2,877 test** (70.46% / 14.10% / 15.44%). EF5 support is **6 / 1 / 1**. The fixed seed and 512-candidate balance search are recorded in the notebook and saved split summary; holdout labels are counted only to audit the split, not to tune models.

Keep the **2010–2019 / 2020–2022 / 2023–2025 temporal split** as a planned forward-in-time robustness check. Keep linkage groups intact, excluding and reporting boundary-crossing groups, and refit all preprocessing on its own training partition. Assess the same modeling approach under this split before separately considering focal loss or an ordinal formulation. Do not change split strategy and loss together or use any held-out test result to select a new configuration.

## Modeling focus

Follow [the assignment requirements](sources/apply_assignment.md) using **TensorFlow/Keras (`tf.keras`)**. Keep preprocessing, train/validation/test splits, NumPy and TensorFlow seeds, and unrelated training settings fixed across controlled comparisons. Reset seeds consistently before each run.

| Experiment | Required comparison |
|---|---|
| Baseline | At least three hidden Dense layers with ReLU, an appropriate classification output/loss, no dropout or L1/L2 regularization; retain training history |
| SGD / learning rate | Same architecture with SGD at 0.1, 0.01, and 0.001; keep everything else fixed |
| L2 | Baseline versus the same model with L2 on hidden Dense layers; start at 0.001 and hold optimizer/learning rate fixed within the pair |
| Dropout | Rates 0.0, 0.2, and 0.5 at consistent positions; hold optimizer/learning rate fixed and omit L2 to isolate dropout |
| Final model | Combine settings justified by validation evidence, then evaluate once on the held-out test set |

Record architecture, optimizer, learning rate, batch size, epochs, and final training/validation accuracy and loss for every run. Include one experiment comparison table and at least two labeled, captioned learning-curve figures covering unregularized and regularized models. Discuss learning speed, instability, overfitting, the train-validation gap, and excessive regularization—not just the highest accuracy.

Apply the selected modeling approach to the onset predictors, retraining with the corresponding input dimensions. The assignment's controlled comparisons address the modeling question; feature-group analysis addresses the primary question, and the onset analysis addresses the secondary question.

The assignment submission is a fully executed notebook and a standalone **3–5-page APA 7 report**, packaged together in a compressed folder. Keep detailed diagnostics in the notebook so the report can prioritize the required experimental evidence.

## Dataset references for implementation

- [Feature dictionary](https://huggingface.co/datasets/jakeryderv/us-tornado-data-2010-2025/blob/v2.2.1/ml/feature_dictionary.json): predictor lists, column roles, units, and timing rules.
- [Feature construction](https://huggingface.co/datasets/jakeryderv/us-tornado-data-2010-2025/blob/v2.2.1/ENRICHMENT.md): radar/warning windows, land-cover sampling, and deferred sources.
- [Research limitations](https://huggingface.co/datasets/jakeryderv/us-tornado-data-2010-2025/blob/v2.2.1/RESEARCH_READINESS.md): coverage, missingness, grouping, and interpretation limits.
