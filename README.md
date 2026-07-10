# Warp Hiring Challenge — Space Mission Log Analysis

Find the security code of the **longest successful Mars mission** in `space_missions.log`
(105,032 records, `|`-delimited, mixed with comments and noise lines).

See the full brief in [mission_challenge.md](mission_challenge.md).

## Answer

```
XRT-421-ZQP
```

Mission `WGU-0200`, launched 2065-06-05, duration **1,629 days** — the longest
`Mars` mission with `Completed` status.

## Solution

A single `awk` command solves it:

```bash
awk -F'[[:space:]]*[|][[:space:]]*' \
  '$3=="Mars" && $4=="Completed" && ($6+0)>max {max=$6+0; code=$8}
   END{gsub(/[[:space:]]/,"",code); print code}' space_missions.log
```

### How it handles the traps in the data

- **Inconsistent spacing around `|`** — the field separator `[[:space:]]*[|][[:space:]]*`
  is a regex that absorbs any surrounding whitespace, so fields come out clean.
- **Comment / noise lines** (`#`, `SYSTEM:`, `CONFIG:`, `CHECKPOINT:`, blanks) —
  they never match `$3=="Mars"` and `$4=="Completed"`, so they're ignored without
  needing explicit skip rules.
- **Duration is text that must be compared numerically** — `$6+0` forces a numeric
  comparison so `1629 > 476` instead of a string comparison.
- **Trailing whitespace on the security code** — `gsub(/[[:space:]]/,"",code)` strips
  it so the output is exactly `XRT-421-ZQP`.

## Repository layout

- `space_missions.log` — the dataset
- `mission_challenge.md` — the original challenge brief
- `README.md` — this file
