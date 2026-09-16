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
with preparation summaries in `data/results/preparation/`. The notebook displays three main figures (class balance, contiguous-U.S. frequency
and EF locations, and training relationships), two consolidated tables, and a supporting
Oklahoma footprint. Only the predictor missingness and split summaries are saved separately; each export is linked
below its corresponding notebook result. Temporal splitting is a planned robustness check.
Sections 5–8 remain outlines for later work.

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
