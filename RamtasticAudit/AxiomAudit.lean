import Lean
import Ramtastic
import RamtasticAudit.BassCompletion
import RamtasticAudit.SemanticProbes
import RamtasticAudit.ZooProbes
import RamtasticAudit.ProbeAxioms

/-!
# Compiled declaration audit

Scan every declaration from an imported `Ramtastic` or `RamtasticAudit`
module, including private names and declarations in other namespaces.
Reject unsafe declarations, admissions, and dependencies beyond Lean's
three allowed foundational axioms. `AuditProbe` is reserved for the
failure controls inserted by `scripts/test_axiom_audit.py`.
-/
open Lean in
run_cmd do
  let env ← getEnv
  let allowed : Array Name := #[``propext, ``Classical.choice, ``Quot.sound]
  let mut count := 0
  let mut theoremCount := 0
  let mut used : Std.HashSet Name := {}
  for (name, info) in env.constants.toList do
    let isProject := match env.getModuleIdxFor? name with
      | some idx =>
          let modName := env.header.moduleNames[idx.toNat]!
          (`Ramtastic).isPrefixOf modName || (`RamtasticAudit).isPrefixOf modName
      | none => (`AuditProbe).isPrefixOf (privateToUserName name)
    if isProject then
      if info.isUnsafe then
        throwError "Unsafe project declaration {name}"
      count := count + 1
      if info matches .thmInfo _ then
        theoremCount := theoremCount + 1
      let axioms ← collectAxioms name
      for ax in axioms do
        used := used.insert ax
        unless allowed.contains ax do
          throwError "Unapproved axiom {ax} used by {name}"
  if count == 0 then
    throwError "Audit matched no project declarations"
  logInfo m!"AXIOM_AUDIT_PASS declarations={count} theorems={theoremCount} unsafe=0"
  logInfo m!"AXIOMS_USED {used.toList}"
