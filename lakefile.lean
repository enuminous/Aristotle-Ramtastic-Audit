import Lake
open Lake DSL

package «ramtastic» where
  leanOptions := #[⟨`autoImplicit, false⟩]

require mathlib from git
  "https://github.com/leanprover-community/mathlib4" @ "8ec19128ad27190c2ec7c872d504be0a2877bd68"

@[default_target]
lean_lib «Ramtastic»

/-- Independent audit library (added by the audit; not part of the release). -/
@[default_target]
lean_lib «RamtasticAudit»
