-- SQLite FTS5 Rule Index Schema
-- Used by build-index.sh and query-rules.sh
-- https://www.sqlite.org/fts5.html

DROP TABLE IF EXISTS rules;

CREATE VIRTUAL TABLE rules USING fts5(
  source,   -- file path relative to project root (e.g. docs/security.md)
  section,  -- heading text (e.g. ## SQL & Query Safety)
  content,  -- rule body text (the lines under the heading)
  tags,     -- space-separated boost keywords (optional, set by build-index.sh)
  tokenize='porter unicode61'
);
