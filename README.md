# Aristotle Ramtastic audit

[![Complete Lean audit](https://github.com/enuminous/Aristotle-Ramtastic-Audit/actions/workflows/verify.yml/badge.svg)](https://github.com/enuminous/Aristotle-Ramtastic-Audit/actions/workflows/verify.yml)

A reproducible Lean project containing the restored Ramtastic source, Aristotle's
Clifford completion and semantic probes, and the earlier Monolithic Zoo
counterexamples. The uploaded repository was incomplete: its root imported an
absent `Ramtastic/` tree, and its README described a different archive.

[Audit findings](AUDIT.md) · [Verification](VERIFICATION.md) ·
[Source provenance](PROVENANCE.md) · [Aristotle's original summary](ARISTOTLE_SUMMARY.md)

## Interactive field guide

[Open the Ramtastic Audit website](https://enuminous.github.io/Aristotle-Ramtastic-Audit/).

The [website source](index.html) provides a findings dashboard, an interactive
rotation lab, a six-step tutorial, a searchable index of all 83 source/audit
modules, and links to Chris Forrester's original Ramtastic and the related papers.
It distinguishes a recorded passing run from the latest live workflow status.
See [website publication and maintenance](WEBSITE.md) for deployment and upkeep.

## What this checks

- **78 Ramtastic source modules**, all imported by [Ramtastic.lean](Ramtastic.lean).
- **Five audit modules**, all imported by [RamtasticAudit.lean](RamtasticAudit.lean).
- Clifford unit-vector and orthogonal-pair hinges, quarter turns, and metric
  preservation under explicit inner-product hypotheses.
- Semantic counterexamples for the BSD, Hodge, de Rham, and Hardy–Littlewood
  interfaces, plus the earlier Zoo counterexamples.
- A compiled dependency audit covering private declarations and declarations
  outside the public namespaces. Only `propext`, `Classical.choice`, and
  `Quot.sound` are allowed; unsafe declarations are rejected.
- Failure controls for public/private axioms, `sorry`, native proof certificates,
  and unsafe definitions; source digests and import coverage.

Both libraries are default Lake targets. A plain `lake build` checks the release
and audit modules. `bash verify.sh` additionally reruns the dependency audit and
its rejection controls. See the workflow for the result at a particular commit;
Aristotle's written summary is retained separately from that execution evidence.

## Reproduce

Install [elan](https://github.com/leanprover/elan), Python 3.10+, and Git, then:

```sh
git clone https://github.com/enuminous/Aristotle-Ramtastic-Audit.git
cd Aristotle-Ramtastic-Audit
lake exe cache get
bash verify.sh
```

Lean is pinned to `v4.30.0-rc1`; Mathlib is pinned in both Lake configuration
and manifest to `8ec19128ad27190c2ec7c872d504be0a2877bd68`. Do not run `lake update`
as part of verification. GitHub Actions uploads the build, integrity, axiom,
and rejection-control logs as an artifact named for the checked commit.

## Mathematical scope

Compilation verifies the stated propositions under their hypotheses. Several
named geometric and arithmetic results remain supplied assumptions or properties
of abstract data. This project does not supply unconditional proofs of BSD,
Hodge, twin primes, or a Yang–Mills mass gap. The probes make these boundaries
inspectable rather than changing the definitions to hide them.

The [52-theorem finite BSD follow-on package](https://github.com/enuminous/papers/tree/main/formal/bsd-parity)
is a separate Lean 4.28 project with its own verification. It is linked here,
not silently counted in this Lean 4.30 build. The earlier
[full Zoo audit](https://github.com/enuminous/Ramtastic/blob/main/audit/REPORT.md)
retains its own operation ledger, inputs, and execution record.

## Attribution and navigation

Ramtastic's original author is C. Forrester (Adauriel); per-file formalization
credits remain in the restored source. Aristotle run
`6b97b551-c689-4d49-9ea2-282f6f81a993` supplied the uploaded completion and semantic
probes. Matthew Chenoweth Wright / Monolithic directed the restoration and Zoo
work, prepared with OpenAI Codex assistance. Restoration is not a claim of
ownership of upstream mathematics. The original
[usage statement](provenance/UPSTREAM-README.md#license) is preserved verbatim.

[Ramtastic fork](https://github.com/enuminous/Ramtastic) ·
[Original Ramtastic](https://github.com/CasimirKnights/Ramtastic) ·
[Monolithic Zoo](https://github.com/enuminous/Monolithic-Zoo-Lean4) ·
[Papers](https://github.com/enuminous/papers) ·
[eNuminous network](https://enuminous.github.io/EFMW/repositories.html)
