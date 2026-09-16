## Draft title

**Meteorological Indicators, Exposure, and EF Rating in U.S. Tornadoes, 2010–2025**

## Draft abstract

This study extends prior tornado severity classification work using a linked compilation of U.S. tornado records, nearby radar-derived indicators, archived NWS warnings, and land-cover summaries for 2010–2025. The primary objective is to examine how meteorological indicators, tornado characteristics, and exposure proxies relate to final Enhanced Fujita (EF) rating. A secondary experiment estimates final EF rating using features eligible under the dataset's reported-onset cutoff, conditional on a recorded tornado's cataloged onset and location. Controlled deep-neural-network experiments investigate how learning rate, stochastic gradient descent (SGD), L2 regularization, and dropout affect training, generalization, and overfitting. The study emphasizes source linkage, temporal leakage control, class imbalance, missingness, and the distinction between recorded damage ratings and physical storm intensity.

## Main research question

> **How do meteorological indicators, tornado characteristics, and exposure relate to final EF rating, and what factors help explain variation in the damage-based rating?**

Uses the **retrospective ML table**. Exposure initially means land-cover and impervious-surface proxies; county population and housing context would require a separate, documented join.

## Secondary experiment

> **Among recorded tornadoes, how well can final EF rating be estimated using features eligible under the dataset's reported-onset cutoff?**

Uses the **onset ML table**. This is a conditional onset analysis: reported onset and start location come from the final catalog, and radar availability assumes a five-minute latency. Actual real-time receipt is unverified, so the experiment does not establish operational forecasting performance.

## Modeling methodology question

> **How do learning rate, SGD, L2 regularization, and dropout affect the training, generalization, and overfitting behavior of a deep neural network?**

This is the assignment-specific methodology applied to the tornado research. Run the required controlled experiments on the retrospective task, then apply the selected approach to the onset task without repeating the entire experiment grid.

- **Research questions:** what the study investigates.
- **ML-ready tables:** which features each task may use.
- **Modeling experiments:** how neural-network training and regularization are evaluated.

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

Select the **target representation** using training-data class support and validation evidence: full EF classes, ordinal classification, or a justified severity grouping. Separately assess **imbalance handling**, such as class weighting or training-only resampling. Do not assume the previous EF2+ grouping or choose a grouping to improve test results. Eight EF5 examples cannot support stable class-specific estimates on their own.

Inspect missingness by year and EF class rather than dropping every incomplete row. For example, onset shear is missing for 13,260 records and warning lead time for 8,819. Missing radar maxima may reflect no qualifying detection; missing warning lead time may reflect no active warning. Neither automatically means a failed collection job.

- Define a temporal train/validation/test split while keeping `ml_split_group` values intact; exclude and report groups crossing temporal boundaries.
- Use the same eligible events, target definition, and split assignments when comparing the two views.
- Fit imputers, scalers, and any resampling only on training data. Keep preprocessing and imbalance handling fixed within the assignment's controlled experiments.
- Use validation data for model selection. Keep the test set untouched until all choices are fixed, then evaluate each final task model once.
- Report accuracy and loss, plus precision, recall, F1, class support, and confusion matrices; include macro-F1 and per-class results so common classes do not dominate interpretation.
- Compare feature groups on the same cohort, including models with and without final track/damage-derived features. Predictive importance or unusual cases do not establish causation, true wind intensity, or an incorrect official rating.

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

Apply the selected modeling approach to the onset predictors, retraining with the corresponding input dimensions. The assignment's controlled comparisons remain the methodological core; feature-group analysis and the onset experiment address the research questions.

The assignment submission is a fully executed notebook and a standalone **3–5-page APA 7 report**, packaged together in a compressed folder. Keep detailed diagnostics in the notebook so the report can prioritize the required experimental evidence.

## Dataset references for implementation

- [Feature dictionary](https://huggingface.co/datasets/jakeryderv/us-tornado-data-2010-2025/blob/v2.2.1/ml/feature_dictionary.json): predictor lists, column roles, units, and timing rules.
- [Feature construction](https://huggingface.co/datasets/jakeryderv/us-tornado-data-2010-2025/blob/v2.2.1/ENRICHMENT.md): radar/warning windows, land-cover sampling, and deferred sources.
- [Research limitations](https://huggingface.co/datasets/jakeryderv/us-tornado-data-2010-2025/blob/v2.2.1/RESEARCH_READINESS.md): coverage, missingness, grouping, and interpretation limits.
