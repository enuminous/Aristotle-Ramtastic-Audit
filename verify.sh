#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p verification
python3 scripts/check_project.py | tee verification/integrity.log
lake build | tee verification/build.log
lake env lean -DwarningAsError=true RamtasticAudit/AxiomAudit.lean | tee verification/axioms.log
python3 scripts/test_axiom_audit.py | tee verification/controls.log
git diff --exit-code -- lean-toolchain lakefile.lean lake-manifest.json
python3 scripts/check_project.py
