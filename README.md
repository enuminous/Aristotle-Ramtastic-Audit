# Ramtastic Monolithic Zoo audit — 2026-10-16



This is a **flat audit bundle**: every ZIP member is at the archive root. It
contains the audit, not a rearranged copy of the Lean project. The reproducer
fetches the original repositories at exact commits, preserving their imports.

| Artifact | Purpose |
|---|---|
| `REPORT.md`, `SOURCE-REVIEW.md` | Findings, known-result comparison, semantic scope and remaining obligations |
| `PLAN.md`, `operation-criteria.json` | Frozen criteria and retrospective/exploratory disclosure |
| `zoo-46-ledger.json`, `.csv`, `ZOO-46.md` | All 46 animal dispositions |
| `operation-catalogue.json` | Exact input schemas, current formal scopes and both source hashes |
| `conformance-inputs.json`, `conformance-results.json` | Published fixtures, 46 adapter outputs and 90 comparisons |
| `target-operation-*.json`, `extension-*.json` | Actual target inputs/outputs and five extension dispositions |
| `source-manifest.json`, `source-inventory.json`, `structure-fields.json` | 84 file hashes, 77 modules, declarations, imports and assumptions |
| `counterexamples.json`, `SemanticProbes.lean` | Four exact witnesses and Lean checks |
| `StrictAudit.lean`, `ReleasedSubsetAudit.lean`, `test_axiom_audit.py` | Compiled declaration audit and rejection controls |
| `diagnostic_namespace.py` | Explicit namespace/zero-form experiment for the release build defect |
| `run_audit.py`, `reproduce.py` | Reproducible Python checks and repository retrieval |
| `execution-evidence.json`, `*.log` | Hosted run identifiers, outcomes and captured evidence |
| `SHA256SUMS.txt` | Integrity of every other archive member |

## Reproduce

Python 3.10+ and Git are required. The mathematical checks also require the
[Lean toolchain manager](https://github.com/leanprover/elan). The original
`lean-toolchain` and `lake-manifest.json` must remain unchanged.

```sh
python3 reproduce.py --verify-only
python3 reproduce.py --work-dir /tmp/ramtastic-zoo-reproduction
python3 reproduce.py --work-dir /tmp/ramtastic-zoo-with-lean --lean
```

Choose a new work directory for each reproduction. The first command works
offline. The other commands fetch three pinned repositories. The `--lean` run
first records the **unmodified release failure**, then applies the disclosed
namespace/zero-form diagnostic in that disposable checkout and runs the build, axiom
audit, rejection controls and semantic probes. Success of the reproducer means
the expected observations were reproduced; it does not turn the release failure
into a passing release build.

To run just the Python audit against existing clones:

```sh
python3 run_audit.py --source /path/to/Ramtastic \
  --zoo /path/to/Monolithic-Zoo-Lean4 \
  --engine /path/to/EFMW_Post156_Zoo_Audit --out /tmp/ramtastic-results
```

The engine and Zoo clones must be at the pinned commits with no tracked edits.
The Ramtastic inventory is read directly from its frozen Git object, not from
mutable working-tree text.

## Attribution and interpretation

Original Ramtastic author: C. Forrester (Adauriel); per-file formalization credits
remain authoritative. [UPSTREAM-README.md](UPSTREAM-README.md) retains the original
description and license statement verbatim, including its unqualified build
claim; the current audit qualifies that claim. No ownership of upstream proofs
is asserted. The Zoo registry, adapters and specifications retain their original
attribution and pinned repository licenses. This package primarily references
them rather than copying their complete implementations.

Generated audit prose and scripts were prepared with AI assistance for Matthew
Chenoweth Wright / eNuminous. Tests do not establish physical EFMW hypotheses,
Hypernym product claims, or the unpublished halting theorem. No third-party
message or upstream contribution is implied by publishing in the enuminous fork.

[Ramtastic](https://github.com/enuminous/Ramtastic) ·
[Canonical Zoo](https://github.com/enuminous/Monolithic-Zoo-Lean4) ·
[eNuminous network](https://enuminous.github.io/EFMW/repositories.html)
