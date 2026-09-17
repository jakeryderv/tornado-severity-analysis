#!/usr/bin/env bash
# Export the Markdown sources. Requires Pandoc, XeLaTeX, Node/npm, and Chrome/Chromium.
set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$project_dir"
for dependency in pandoc xelatex node pdfinfo; do
  command -v "$dependency" >/dev/null || { echo "Missing dependency: $dependency" >&2; exit 1; }
done

if [[ -n "${MARP_CLI:-}" ]]; then
  # Optional path to an existing marp-cli.js installation.
  marp_cmd=(node "$MARP_CLI")
elif command -v marp >/dev/null; then
  marp_cmd=(marp)
else
  command -v npx >/dev/null || { echo 'Install Node/npm or Marp CLI.' >&2; exit 1; }
  marp_cmd=(npx --yes --prefer-offline @marp-team/marp-cli@4.5.0)
fi

build_dir="$(mktemp -d "${TMPDIR:-/tmp}/tornado-export.XXXXXX")"
trap 'rm -rf -- "$build_dir"' EXIT
mkdir -p outputs

pandoc report.md --from=markdown --standalone --pdf-engine=xelatex \
  --resource-path="$project_dir" --lua-filter=scripts/report-tables.lua --output="$build_dir/report.pdf"
"${marp_cmd[@]}" slides.md --theme assets/themes/github-dark.css \
  --html --pdf --allow-local-files --output "$build_dir/slides.pdf"

# Publish both complete exports together after both tools succeed.
mv -- "$build_dir/report.pdf" outputs/report.pdf
mv -- "$build_dir/slides.pdf" outputs/slides.pdf
for name in report slides; do
  pages="$(pdfinfo "outputs/$name.pdf" | awk '/^Pages:/ {print $2}')"
  printf 'Exported outputs/%s.pdf (%s pages)\n' "$name" "$pages"
  if [[ "$name" == report && "$pages" != 7 ]]; then
    echo 'Warning: report should contain one title page, five write-up pages, and one references page.' >&2
  fi
done
