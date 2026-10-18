import Lean
import Ramtastic

/-!
# Axiom audit of the compiled Ramtastic modules

Every declaration in the `Ramtastic` namespace, in all 78 modules imported by
the root file `Ramtastic.lean`, is traced with `Lean.collectAxioms`.  The command
below fails (and hence this file fails to build) if any declaration depends
on an axiom other than `propext`, `Classical.choice` and `Quot.sound`
(this includes `sorryAx`, which is what `sorry` elaborates to).
-/

open Lean Elab Command

def RamtasticAudit.allowedAxioms : List Name :=
  [``propext, ``Classical.choice, ``Quot.sound]

elab "#ramtastic_axiom_audit" : command => do
  let env ← getEnv
  let mut nThm := 0
  let mut nDef := 0
  let mut nOther := 0
  let mut bad : Array (Name × Array Name) := #[]
  let mut used : Std.HashSet Name := {}
  for (n, ci) in env.constants.toList do
    unless (`Ramtastic).isPrefixOf n do continue
    match ci with
    | .thmInfo _ => nThm := nThm + 1
    | .defnInfo _ => nDef := nDef + 1
    | .axiomInfo _ => bad := bad.push (n, #[n])
    | _ => nOther := nOther + 1
    let axs ← liftCoreM <| collectAxioms n
    for a in axs do used := used.insert a
    let nonstd := axs.filter (fun a => !RamtasticAudit.allowedAxioms.contains a)
    unless nonstd.isEmpty do bad := bad.push (n, nonstd)
  logInfo m!"theorems: {nThm}, definitions: {nDef}, other constants: {nOther}; \
    axioms used anywhere: {used.toList}"
  unless bad.isEmpty do
    throwError m!"non-standard axioms found: {bad.toList}"

#ramtastic_axiom_audit
