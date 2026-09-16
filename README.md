# tornado-severity-analysis

[notebook](./notebook.ipynb): all the code and analysis

[report](./report.md): written report

[slides](./slides.md): concise slides

[notes](./notes.md): rough notes

Notebook setup: run `uv sync --locked`, then `uv run jupyter lab notebook.ipynb`
from this directory and select the project's `.venv` Python kernel. Sections 1–3
download and validate the pinned Kaggle modeling files directly into
`data/source/v8/`, summarize the data, and save audit results in `data/results/audit/`
and styled figures/tables in `assets/`. Sections 4–8 are outlines for later work.
See the notebook's opening cells for execution details.

data stored in `data/`

saved figures and stuff stored in `assets/` (so report.md and slides.md can link them)

sources to cite/reference in `sources/`

report and slides written in markdown so they can share and preview/link all the saved/generated figures and stuff from notebook results/analysis

run `./export.sh` to generate pdf's for report and slides in `outputs/`:
- pandoc and latex stuff to style/format report
- marp for the markdown-based slides
