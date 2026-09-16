# Apply: Regularization, Dropout & Gradient Descent in Deep Neural Networks

## Overview

In the previous assignment, you built and evaluated a neural network and investigated how choices such as activation functions, optimizers, and model capacity affected performance.

In this assignment, you will build a deeper neural network and investigate how:

- Gradient descent
- Learning rate
- L2 regularization
- Dropout

affect:

- Training
- Generalization
- Overfitting

You must use **TensorFlow/Keras (`tf.keras`)**.

You may use the same dataset from the previous assignment.

## Main Question

> How do gradient-descent settings and regularization techniques affect the training, generalization, and overfitting behavior of a deep neural network?

Keep the following consistent across experiments:

- preprocessing
- train/validation/test split
- TensorFlow random seed
- NumPy random seed

---

## Component 1 — Baseline Deep Neural Network

Build a baseline neural network with at least **3 hidden Dense layers**.

Example:

```python
model = keras.Sequential([
    layers.Input(shape=(n_features,)),
    layers.Dense(128, activation="relu"),
    layers.Dense(64, activation="relu"),
    layers.Dense(32, activation="relu"),
    layers.Dense(n_classes, activation="softmax")
])
```

### Requirements

- At least 3 hidden Dense layers
- ReLU activation in hidden layers
- No Dropout
- No L1/L2 regularization
- Appropriate output layer for the classification problem
- Train using validation data
- Keep the `History` object
- Train long enough to observe learning behavior

### Report

Describe:

- number of layers
- number of neurons
- activation functions
- output layer
- loss function
- optimizer
- learning rate
- batch size
- number of epochs

---

## Component 2 — Gradient Descent and Learning Rate

Use the **same architecture** and train with SGD.

```python
keras.optimizers.SGD(learning_rate=...)
```

Run at least:

| Run | Optimizer | Learning Rate |
|---|---|---:|
| GD-1 | SGD | 0.1 |
| GD-2 | SGD | 0.01 |
| GD-3 | SGD | 0.001 |

Keep everything else fixed.

### Record

For each run:

- final training accuracy
- final validation accuracy
- final training loss
- final validation loss

### Discuss

- Which learning rate learned fastest?
- Was any learning rate too large?
- Was any learning rate too small?
- Which produced the best validation performance?
- What is gradient descent doing to the weights during training?

---

## Component 3 — L2 Regularization

Return to the baseline model and add L2 regularization to the hidden Dense layers.

Example:

```python
layers.Dense(
    128,
    activation="relu",
    kernel_regularizer=keras.regularizers.l2(0.001)
)
```

Compare:

- **Run A:** No regularization
- **Run B:** L2 regularization

Suggested starting value:

```python
keras.regularizers.l2(0.001)
```

Keep everything else fixed.

### Compare

- training accuracy
- validation accuracy
- training loss
- validation loss
- train-validation performance gap

### Discuss

> What is L2 regularization trying to prevent, and what happened after adding it?

---

## Component 4 — Dropout Regularization

Investigate Dropout.

Example:

```python
model = keras.Sequential([
    layers.Input(shape=(n_features,)),

    layers.Dense(128, activation="relu"),
    layers.Dropout(0.3),

    layers.Dense(64, activation="relu"),
    layers.Dropout(0.3),

    layers.Dense(32, activation="relu"),

    layers.Dense(n_classes, activation="softmax")
])
```

Run at least:

| Run | Dropout Rate |
|---|---:|
| Dropout-0 | 0.0 |
| Dropout-1 | 0.2 |
| Dropout-2 | 0.5 |

Keep everything else fixed.

### Discuss

- What happened to training accuracy as dropout increased?
- What happened to validation accuracy?
- Did dropout reduce the train-validation gap?
- Was 0.5 useful or too aggressive?
- Which dropout rate generalized best?

---

## Component 5 — Final Model

Create one final model using the settings that worked best.

The final model may combine:

- preferred optimizer
- best learning rate
- L2 regularization
- Dropout
- deep-network architecture

Choices should be based on experimental evidence.

Evaluate the final model **once** on the held-out test set.

### Report

- test accuracy
- test loss

If the dataset is imbalanced, also report:

- precision
- recall
- F1 score
- confusion matrix

> Do not use the test set for model selection or hyperparameter tuning.

---

## Results Table

Include one table containing all experiments.

| Run | Optimizer / Learning Rate | L2 | Dropout | Train Accuracy | Validation Accuracy | Train Loss | Validation Loss |
|---|---|---|---:|---:|---:|---:|---:|
| Baseline | Adam / 0.001 | No | 0.0 | | | | |
| GD-1 | SGD / 0.1 | No | 0.0 | | | | |
| GD-2 | SGD / 0.01 | No | 0.0 | | | | |
| GD-3 | SGD / 0.001 | No | 0.0 | | | | |
| L2 | Selected | 0.001 | 0.0 | | | | |
| Dropout-1 | Selected | No | 0.2 | | | | |
| Dropout-2 | Selected | No | 0.5 | | | | |
| Final Model | Best settings | Selected | Selected | | | | |

---

## Required Learning Curves

Include at least two learning-curve figures:

1. One for an **unregularized** model
2. One for a **regularized** model

Plot either:

- training vs validation accuracy across epochs
- training vs validation loss across epochs

All figures must include:

- clear titles
- labeled axes
- legends
- figure captions

---

## Questions to Answer in the Report

1. **Gradient Descent:** How did changing the learning rate affect how quickly and successfully the network learned?
2. **Overfitting:** Did the baseline network overfit? Use the training and validation curves as evidence.
3. **L2 Regularization:** What changed after adding L2 regularization?
4. **Dropout:** What changed after introducing dropout? Why might training accuracy decrease even if validation performance improves?
5. **Best Model:** Which model generalized best, and what evidence supports that conclusion?
6. **Too Much Regularization:** Can too much regularization hurt performance? Use your results as evidence.
7. **Test Performance:** How well did the final model perform on unseen test data?

---

## Report Organization

The report should be approximately **3–5 pages** and follow **APA 7th Edition** formatting.

Suggested sections:

1. **Baseline Deep Neural Network**
   - architecture
   - initial performance

2. **Gradient Descent Experiments**
   - learning-rate experiments
   - interpretation

3. **Regularization Experiments**
   - L2
   - Dropout

4. **Results and Evaluation**
   - experiment comparison table
   - learning curves
   - final test results

5. **Analysis and Conclusion**
   - overall interpretation
   - final model

---

## Code Quality and Reproducibility

The notebook must:

- use TensorFlow/Keras
- set NumPy and TensorFlow random seeds
- run from top to bottom without errors
- use the same train/validation/test split across experiments
- include clear Markdown section headings
- display all outputs and plots
- avoid unused/debugging cells
- keep the test set untouched until final model selection

---

## Submission

Submit a compressed folder containing:

1. `report.pdf`
   - standalone written report
   - approximately 3–5 pages
   - includes figures and tables

2. `.ipynb`
   - fully executed notebook
   - all cells run
   - outputs and plots visible

Do not paste large blocks of code into the report. The notebook provides the technical evidence; the report explains and interprets the results.

---

## Grading — 20 Points

| Component | Points |
|---|---:|
| Baseline Deep Neural Network | 3 |
| Gradient Descent Experiments | 4 |
| L2 Regularization | 3 |
| Dropout Experiments | 4 |
| Final Model and Evaluation | 3 |
| Analysis, Code Quality, and Reproducibility | 3 |
| **Total** | **20** |

---

## Important

> Change one thing at a time whenever possible.

If architecture, optimizer, learning rate, dropout, and L2 are changed simultaneously, it becomes difficult to determine which change caused the result.

The goal is **not simply to obtain the highest accuracy**.

The goal is to experimentally understand how:

- gradient descent
- learning rate
- L2 regularization
- dropout

affect the behavior of a deep neural network.
