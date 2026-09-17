# tornado-severity-analysis

Unit 2 deep-learning assignment: controlled learning-rate, SGD, L2, and dropout experiments on
U.S. tornado EF ratings, 2010-2025, then a feature-group analysis built on the assignment's final
model. Models are trained on 2010-2019, selected on 2020-2022, and tested once on 2023-2025.

| File | Purpose |
|---|---|
| [notebook.ipynb](./notebook.ipynb) | all code, results, figures, and tables |
| [report.md](./report.md) | written report (APA 7, 3-5 pages) |
| [slides.md](./slides.md) | presentation slides (Marp) |
| [notes.md](./notes.md) | working notes on the dataset, questions, and design |
| `sources/` | assignment descriptions, previous report, and references |
| `assets/figures/`, `assets/tables/` | PNG figures and tables written by the notebook, linked from the report and slides |
| `data/results/` | CSV versions of every table plus per-epoch training history |
| `data/source/` | pinned Kaggle download (ignored by git) |

## Notebook layout

| Section | Produces |
|---|---|
| 3. Data | download, class balance (Fig. 1), map (Fig. 2) |
| 4. Preparation | year-based split (Table 1), feature groups and missingness (Table 2) |
| 5. Assignment experiments | baseline architecture and curves (Table 3, Fig. 3), learning curves for every run (Fig. 4), all runs (Table 4), single test evaluation of the final model (Fig. 5, Table 5) |
| 6. Feature groups | final model retrained without each feature group (Table 6) |
| 7. Findings | interpretation and limitations |

Each experiment is followed by a short readout that the report and slides draw from.

## Running

```sh
uv sync --locked
uv run --locked jupyter lab notebook.ipynb
```

Select the `.venv` kernel and run all cells. The notebook downloads the pinned dataset into
`data/source/` on first run and reuses it afterwards. The notebook also runs standalone: copy it
to a folder, uncomment the `%pip install` line in its first code cell, and run it with Python
3.12 or newer.

For an NVIDIA GPU on Linux or WSL2:

```sh
uv sync --locked --extra gpu
export LD_LIBRARY_PATH="$(find "$PWD/.venv/lib" -type d -path '*/nvidia/*/lib' -printf '%p:')${LD_LIBRARY_PATH:-}"
uv run --locked --extra gpu jupyter lab notebook.ipynb
```

The library path lets TensorFlow find the CUDA libraries installed in `.venv`; run both commands
in the same terminal. CPU and GPU runs can differ numerically even with matched seeds.

Checks:

```sh
uv run --locked ruff check notebook.ipynb
uv run --locked ruff format --check notebook.ipynb
uv run --locked ty check
```

## Report and slides

The report and slides are Markdown so they can link the notebook's saved figures and tables
directly. `./export.sh` renders `outputs/report.pdf` with pandoc and `outputs/slides.pdf` with
Marp.
