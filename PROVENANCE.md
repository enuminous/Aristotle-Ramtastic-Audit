# Source provenance

## Pinned inputs

| Input | Identifier |
|---|---|
| Incomplete Aristotle audit upload | [abe3c3c36b44c3469cd3d4d789231cbc157a1c61](https://github.com/enuminous/Aristotle-Ramtastic-Audit/tree/abe3c3c36b44c3469cd3d4d789231cbc157a1c61) |
| Restored eNuminous Ramtastic fork | [2a5d4a718333213e395f16df630cf332d0e16f4c](https://github.com/enuminous/Ramtastic/tree/2a5d4a718333213e395f16df630cf332d0e16f4c) |
| Original Zoo release baseline | `916ab476012852778edd9ca63aecf200a8e90ed1` |
| Aristotle run | `6b97b551-c689-4d49-9ea2-282f6f81a993` |
| Lean | `leanprover/lean4:v4.30.0-rc1` |
| Mathlib | `8ec19128ad27190c2ec7c872d504be0a2877bd68` |

## Restoration procedure

The source tree under `Ramtastic/` was copied from the pinned fork. The supplied
`RamtasticAudit/patches/DolbeaultTheorem.patch` was applied to its target.
`CliffordBridge.lean` was reconstructed from the algebra and Clifford sections
of the uploaded `BassCompletion.lean`, with their namespace moved to the release
module. This is a documented reconstruction, not a claim to have recovered an
unavailable byte-identical Aristotle export.

The fork's existing `HingeAnalysis.lean` was retained. Four compatibility theorems
provide the names expected by Aristotle's `ProbeAxioms`, using the existing
metric results. Its orbit documentation was qualified without weakening any
theorem statement. `BassCompletion.lean` now exports the release declarations
under the earlier audit names instead of duplicating proofs.

`RamtasticAudit/SemanticProbes.lean` is retained from the upload.
`RamtasticAudit/ZooProbes.lean` is byte-identical to the pinned fork's
`audit/SemanticProbes.lean`. The axiom harness and repository verification were
strengthened as documented in [AUDIT.md](AUDIT.md).

The original [Aristotle audit](provenance/ARISTOTLE_AUDIT_AS_UPLOADED.md),
[upstream README and usage statement](provenance/UPSTREAM-README.md), and
[Bass prose](provenance/BASS-README-AS-PUBLISHED.md) are archived as historical
inputs. Their claims and relative links describe their original context.
The original `ARISTOTLE_SUMMARY.md` remains unchanged. The patch directory is
historical evidence; do not reapply its patch to the repaired tree.

## Integrity and changes

[Source manifest](provenance/source-manifest.json) records SHA-256 digests for
all release and audit Lean files, both roots, and the Lake configuration,
manifest, and toolchain. CI checks exact agreement. After intentional source
changes, review the diff and run:

```sh
python3 scripts/check_project.py --update-manifest
bash verify.sh
```

The manifest is an integrity record, not a signature or a substitute for proof
checking. Current compiled declaration counts can differ from Aristotle's
historical counts because this restoration also retains earlier fork extensions,
Zoo probes, compatibility aliases, and private declarations.

The separate Lean 4.28 finite-BSD package in
[enuminous/papers](https://github.com/enuminous/papers/tree/main/formal/bsd-parity)
is not included in these digests or build counts.
