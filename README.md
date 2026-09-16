# tornado-severity-analysis

[notebook](./notebook.ipynb): all the code and analysis

[report](./report.md): written report

[slides](./slides.md): concise slides

[notes](./notes.md): rough notes

The notebook can also run on its own: copy it into a folder, install the dependencies
listed in its first code cell, and run it with Python 3.12 or newer. Start the kernel
in that folder; `data/` and `assets/` are created automatically.

For this repository, run `uv sync --locked`, then `uv run jupyter lab notebook.ipynb`
and select the `.venv` Python kernel. Sections 1–3
download and validate the pinned Kaggle modeling and map files directly into
`data/source/v8/`, summarize the data, and save audit results in `data/results/audit/`
and styled figures/tables in `assets/`. Section 4 preserves EF0–EF5, defines a shared
group-aware stratified split targeting 70/15/15, explores the training data,
and saves labels and prepared inputs in `data/derived/`,
with preparation summaries in `data/results/preparation/`. Sections 1–4 display three main figures (class balance, contiguous-U.S. frequency
and EF locations, and training relationships), two consolidated tables, and a supporting
Oklahoma footprint. Only the predictor missingness and split summaries are saved separately; each export is linked
below its corresponding notebook result. Temporal splitting is a planned robustness check.
Section 5 combines strategy selection and the three questions. It compares weighted
softmax, single ordinal, full-data ordinal ensemble, subset ordinal ensemble, and
weighted subset ordinal models; then runs controlled SGD/L2/dropout experiments,
retrospective feature exclusions, and the onset counterpart. Figures 5–6 and Tables
3–6 show the comparisons. `data/results/experiments/` contains histories, final
summaries, training-member assignments, and settings, with visible links in the notebook.
Selected retrospective and onset probability models and input definitions are saved
in `data/models/`. Their ordinal helper definitions must be executed before reloading.
Selection uses validation macro F1. Sections 6–7 remain outlines for final test
evaluation and findings; the test set has not been scored.

For an NVIDIA GPU on Linux or WSL2 with a working NVIDIA driver:

```sh
uv sync --locked --extra gpu
TORNADO_CUDA_LIBS=$(find "$PWD/.venv/lib" -type d -path '*/nvidia/*/lib' -printf '%p:')
export LD_LIBRARY_PATH="${TORNADO_CUDA_LIBS}${LD_LIBRARY_PATH:-}"
uv run --locked --extra gpu jupyter lab notebook.ipynb
```

The library path lets TensorFlow find all CUDA libraries installed in `.venv`.
Run these commands in the same terminal, select the `.venv` Python kernel, and
restart any already-running kernel. Keep `--extra gpu` on subsequent `uv sync` /
`uv run` commands so the optional libraries stay installed. Other notebook editors
must also inherit this library path; restarting only their kernel may not suffice.
Verify detection from the same terminal with:

```sh
uv run --locked --extra gpu python -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"
```

TensorFlow automatically uses a detected GPU for supported operations. A standalone
notebook can install `tensorflow[and-cuda]>=2.21.0` in its kernel instead; if libraries
are not found, follow the [TensorFlow GPU setup guide](https://www.tensorflow.org/install/pip#linux).
RTX 50-series GPUs may require kernel compilation on first use with this TensorFlow
build. CPU and GPU runs may produce different numerical results even with matched seeds.

Development checks (installed by `uv sync --locked`):

```sh
uv run --locked ruff check notebook.ipynb
uv run --locked ruff format --check notebook.ipynb
uv run --locked ty check
```

Use `uv run --locked ruff format notebook.ipynb` to apply formatting, and
`uv run --locked ruff check notebook.ipynb --fix` for safe lint fixes. Both tools
check the notebook directly, including references across cells. Shared helpers
stay inside the notebook so a standalone copy needs only its analysis dependencies.
Type checks cover helper interfaces and supported library types; runtime assertions
and fresh-kernel execution still check data shapes, split isolation, and results.

data stored in `data/`

saved figures and stuff stored in `assets/` (so report.md and slides.md can link them)

sources to cite/reference in `sources/`

report and slides written in markdown so they can share and preview/link all the saved/generated figures and stuff from notebook results/analysis

run `./export.sh` to generate pdf's for report and slides in `outputs/`:
- pandoc and latex stuff to style/format report
- marp for the markdown-based slides
