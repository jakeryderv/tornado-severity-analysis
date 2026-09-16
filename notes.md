## Draft title

**Meteorological Indicators, Exposure, and EF Rating in U.S. Tornadoes, 2010–2025**

## Draft abstract

This study extends prior tornado severity classification work by combining official U.S. government data sources describing tornado characteristics, radar-derived storm signatures, damage footprints, warnings, land cover, and population exposure. The primary objective is to examine how meteorological indicators, tornado geometry, and exposure relate to the final Enhanced Fujita (EF) rating, and to identify cases where these indicators diverge from patterns expected from the final damage-based rating. A secondary experiment evaluates whether eventual tornado severity can be estimated using only information available at or before reported tornado onset. The study emphasizes interpretation, source linkage, temporal leakage control, class imbalance, and the distinction between storm characteristics and damage-based severity assessment.

## Main research question

> **How do meteorological indicators, tornado characteristics, and exposure relate to final EF rating, and what factors help explain variation in the damage-based rating?**

## Secondary experiment

> **Can tornado severity be estimated using only information available at or before reported tornado onset?**

## Main objectives

- Quantify relationships between radar indicators, tornado characteristics, exposure, and EF rating.
- Examine whether land cover and exposure help explain variation in final EF ratings.
- Identify tornadoes whose radar, track, or exposure characteristics differ from patterns typically associated with their final rating.
- Compare retrospective EF-rating models with an onset-time severity-classification model.
- Evaluate which feature groups contribute the most information.
- Explore appropriate strategies for handling class imbalance without assuming a fixed EF-class grouping in advance.

## Analysis views

**Retrospective:** Uses full-event information, including radar indicators, tornado track characteristics, damage footprints, land cover, exposure, and warning data, to analyze final EF rating.

**Onset-time:** Uses only information available at or before reported tornado onset to estimate eventual tornado severity.

## Likely feature groups

**Radar:** SWDI/NEXRAD-derived signatures

**Tornado characteristics:** path length, width, location, timing

**Post-event damage:** NOAA Event Footprint Catalog *(retrospective only)*

**Exposure:** NLCD + Census context

**Operational:** NWS warning timing and status

**Environment:** ERA5 atmospheric variables *(if included)*

## Modeling focus

The primary modeling task will classify final EF rating using the retrospective feature set. Controlled deep-neural-network experiments will examine learning rate, gradient descent, L2 regularization, and dropout while keeping preprocessing, train/validation/test splits, and random seeds fixed.

The secondary experiment will apply the selected modeling approach to an onset-time severity-classification task using only features available at or before reported tornado onset.

The final target representation will be selected after examining class distribution and model behavior. Possible approaches include full multiclass EF prediction, ordinal classification, class weighting, resampling, or a simplified severity grouping if needed. The goal is to avoid imposing the previous EF2+ grouping unless the new data and imbalance analysis justify it.
