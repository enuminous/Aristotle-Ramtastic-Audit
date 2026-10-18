# Verification

The [Complete Lean audit workflow](https://github.com/enuminous/Aristotle-Ramtastic-Audit/actions/workflows/verify.yml)
is the execution record for this repository. Select a run whose commit matches
the source being reviewed. A badge or an older successful run does not certify
later edits.

## Pipeline

1. Check that both roots import every source module and that all local imports
   resolve; verify source digests, documentation links, and dependency pins.
2. Install the pinned Lean toolchain and fetch the matching Mathlib cache.
3. Run `lake build` for both default libraries: 78 release modules, five audit
   modules, and their two root files.
4. Run the compiled declaration audit afresh with warnings treated as errors.
   Module ownership, rather than the spelling of a public name, determines
   coverage. Unexpected axioms and unsafe declarations fail the run.
5. Require failure for five deliberately invalid controls: unused public axiom,
   unused private axiom, admitted theorem, native proof certificate, unsafe
   definition. A failed control must have the expected diagnostic.
6. Confirm dependency pins and source digests remain unchanged, then retain logs
   in the workflow artifact `lean-audit-<commit>`.

The full build permits inherited linter warnings; proof admissions are rejected
by the axiom audit. Compiled theorem counts include generated declarations and
must not be reported as counts of novel mathematical results. The audit prints
its actual counts in `verification/axioms.log`.

## Historical evidence

The uploaded [Aristotle summary](ARISTOTLE_SUMMARY.md) reports successful checks
in its working environment. GitHub upload `abe3c3c` omitted the entire source
tree, so that report alone could not reproduce a build here. The source
restoration and subsequent CI are separately identified in [PROVENANCE.md](PROVENANCE.md).

The earlier [Zoo verification record](https://github.com/enuminous/Ramtastic/blob/main/audit/VERIFICATION.md)
checks a different frozen release and a disclosed diagnostic checkout. It is
background evidence, not a substitute for this repository's own workflow.
