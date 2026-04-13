#!/usr/bin/env bash
# Run from the project root to register the wiki with qmd and generate embeddings.
# Safe to re-run — always does a clean re-index to pick up any file changes.
#
# By default this keeps qmd's cache and config inside the repo so setup works
# in sandboxed agents and stays self-contained. Override XDG_CACHE_HOME and
# XDG_CONFIG_HOME if you prefer machine-global locations.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WIKI_DIR="$SCRIPT_DIR/wiki"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$SCRIPT_DIR/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$SCRIPT_DIR/.config}"
CACHE_DIR="$XDG_CACHE_HOME/qmd"
CONFIG_DIR="$XDG_CONFIG_HOME/qmd"

if ! command -v qmd &>/dev/null; then
  echo "qmd not found. Install it with: npm install -g @tobilu/qmd"
  exit 1
fi

mkdir -p "$CACHE_DIR"
mkdir -p "$CONFIG_DIR"

# Always remove and re-add to ensure a clean re-index.
# qmd has no persistent file watcher unless running as a daemon, so stale
# index is possible after wiki edits. Re-adding the collection forces a rescan.
if qmd collection list 2>/dev/null | grep -q "^memex "; then
  echo "Re-indexing existing memex collection..."
  qmd collection remove memex
else
  echo "Registering memex collection with qmd..."
fi

qmd collection add "$WIKI_DIR" --name memex
qmd context add qmd://memex "Personal brain wiki: journal entries, goals, habits, health, finance, people, sources, concepts, analyses"

if [[ "${SKIP_EMBED:-0}" == "1" ]]; then
  echo "Skipping embeddings because SKIP_EMBED=1."
else
  echo "Generating embeddings (downloads ~330MB model on first run)..."
  qmd embed
fi

echo ""
echo "Done. qmd is ready."
echo "Cache:  $CACHE_DIR"
echo "Config: $CONFIG_DIR"
echo "Try: XDG_CACHE_HOME=\"$XDG_CACHE_HOME\" XDG_CONFIG_HOME=\"$XDG_CONFIG_HOME\" qmd search 'your query' -c memex"
