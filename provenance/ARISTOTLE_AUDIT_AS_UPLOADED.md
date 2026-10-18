# Ramtastic — full audit (2026-10-17)

Toolchain: Lean `v4.30.0-rc1`, Mathlib `8ec19128ad27190c2ec7c872d504be0a2877bd68` (as pinned by
`lean-toolchain` / `lake-manifest.json`). The audit itself left the source tree unchanged;
the build defects it found have since been fixed in the source (see §8). All audit artifacts are in `RamtasticAudit/` (a separate library added to
`lakefile.lean`) and in this file.

## 1. Headline findings

| # | Claim | Finding |
|---|---|---|
| 1 | "run `lake build` and check for yourself" (Bass README, `Materials/description.png`) | **The release build fails.** `Ramtastic.lean` (the only default target) imports `Ramtastic.Bass.HingeAnalysis` and `Ramtastic.Bass.CliffordBridge`, and neither file is in the repository. `lake build` fails right away with `no such file or directory … Ramtastic/Bass/HingeAnalysis.lean`. |
| 2 | Every file compiles | **75 of the 76 `.lean` modules compile; `Ramtastic.Dolbeault.DolbeaultTheorem` does not.** It uses `DelDelBar.del` / `DelDelBar.delbar` without importing `Ramtastic.ComplexStructure.DelDelBar` (12 errors). Adding the import and namespace is not enough: two `simp` calls still fail on `pullbackJ (fun x => extDeriv f x) x m = 0` (the zero-form case). A verified 3-line fix is in `RamtasticAudit/patches/DolbeaultTheorem.patch`. The root file imports only the Bass modules, so even with the root fixed, the default `lake build` would not check the other 73 modules. |
| 3 | "Zero `sorry`, zero custom axioms" | **Confirmed for the 75 modules that compile.** `RamtasticAudit/AxiomAudit.lean` traces every constant in the `Ramtastic` namespace (895 theorems, 1031 definitions, 261 other constants). Together they use only `propext`, `Classical.choice` and `Quot.sound`. There are no `sorryAx`, `axiom` declarations, `native_decide`, `implemented_by` or `extern`. The file fails to build if this ever changes. |
| 4 | Bass Theorem (i), (ii): Clifford action `c(v)² = -id`, `c(v)c(w)` is the quarter turn | **These are not formalized anywhere in the release.** `HingeRotation.lean` only covers an abstract `J` with `J² = -id`, and the Clifford files it would need are the two missing modules. The statements are true, and `RamtasticAudit/BassCompletion.lean` proves them (see §4). |
| 5 | `HingeRotation.lean` header: "Every element of this group preserves any inner product that J preserves. The orbit of any vector under this group is a circle." | **Not proved in the file.** The isometry part is proved in `BassCompletion.rotate_inner`, for skew-adjoint `J`. |
| 6 | "Corollary (Bass, architectural) … every property … follows from the geometry of the circle without additional analytical machinery" | This is not a mathematical statement and cannot be formalized as written. Nothing in the repository supports it formally. |
| 7 | "Hodge conjecture for CP^m" (`cpn_hodge_conjecture_full`) | It compiles, but `CPn m` is **defined to be `Unit`**, and the result depends on hand-chosen data: `Cohom _ := ℚ` and a hand-chosen `HodgeDecomposition`. The same predicate is **false** on the same `CPn 1` model with different admissible data (§3). This is not a statement about complex projective space. (The Hodge conjecture for `ℙⁿ` is a classical, easy fact anyway.) |
| 8 | "`hodgeConjectureViaGAGA` … NOT a placeholder — this IS the real proposition" | `VarietyData` is an arbitrary type with arbitrary "subvariety" types. `HodgeClassData.isHodge` is an arbitrary set that contains the cycle classes. So the predicate's truth value depends on free data (§3). `hodge_from_chain` takes the Hodge conjecture as a hypothesis and returns it unchanged. |
| 9 | BSD statement surface (`WeakRankStatement`, `StrongLeadingCoefficientStatement`) | `MordellWeilHeightComparison` takes the curve as an *unused* parameter (`_C`). The Mordell–Weil group, the L-function and the regulator value are free fields, not computed from the curve. Two packages with identical curve data give opposite verdicts (§3). `Kolyvagin.lean` takes the Kolyvagin and Gross–Zagier results as structure fields, and its "theorems" just restate them. `Regulator.regulator` is never tied to `det gram_matrix`. |
| 10 | de Rham, Hard Lefschetz, Lefschetz decomposition, Poincaré lemma, Kähler identities, Fredholm index 0, GAGA, elliptic regularity | Each of these enters as a **field of a `class`/`structure`** (`DeRhamIsomorphism.integration_bijective`, `HardLefschetzData.hard_lefschetz_inj/surj`, `PoincareLemma.closed_is_exact`, `KahlerLaplacianIdentity`, `FredholmData.index_zero`, `GAGAData.gaga_iso`, `EllipticEstimateAt.estimate`, …). The theorems derived from them are short consequences of what was assumed. `DeRhamIsomorphism` is trivially inhabited: take de Rham cohomology itself as "singular cohomology", with the identity map (§3). All differential forms live on a normed vector space `E`, not on a manifold. |
| 11 | Yang–Mills ℝ⁴ "mass gap" interlocks | The gap-transfer theorem assumes `KatoWeylSpectralTransfer` (every limit spectral point in a window comes from finite-level spectrum in that window) and a uniform gap for every `T_n`. The conclusion is a 3-line consequence. Only bounded operators `E →L[ℂ] E` appear. No Yang–Mills Hamiltonian is constructed, and no mass gap is proved. |
| 12 | Twin primes / Polignac / Tao bounded gaps / Hardy–Littlewood | `TwinPrimeStatement` and `PolignacStatement` are correct *statements* and are not claimed as proved. The implications `Polignac → twin → bounded gaps` are proved correctly. `HardyLittlewoodRow` contains **no asymptotic**: it exists exactly when the row is infinite, and its "singular series" is an unconstrained positive real (§3). |
| 13 | Linting | 23 files switch off 8 linters each (`set_option linter.* false`, 177 lines in total). The 75-module build still prints 53 warnings. This does not affect soundness. |

## 2. Results that are genuine and self-contained

These compile with no assumption fields and say what their docstrings say (spot-checked):
`Bass.HingeRotation` (rotate is a one-parameter group, `R(0)=id`, `R(π/2)=J`, `R(π)=-id`,
`R(2π)=id`, `J⁴=id`); `SchurTest.schur_test`; `Sobolev.CartanProof.cartan_identity`
(`ι_ξ(ξ∧ω)+ξ∧ι_ξω = ‖ξ‖²ω`); `Kahler.SL2Weight.L_inj_of_comm_scalar`;
`QuantumYM.WilsonActionConstruction` (non-negativity of an explicit Wilson action);
`QuantumYM.CompactGroupProduct` (product Haar probability measures);
`SeibergWitten.CliffordBundle` (Clifford relations via Mathlib); the elementary BSD lemmas
(`disc_nonzero`, `root_neg_one_forces_vanishing`, `rank_zero_all_torsion`); and
`Polignac.Statement` implications. Most are short wrappers around Mathlib.

## 3. Semantic probes (`RamtasticAudit/SemanticProbes.lean`, all kernel-checked)

* `weakRank_same_curve_opposite_verdicts`: two `BSDArithmeticGAGAComparison` packages
  on the curve `y² = x³ + 1`. Their curve data are equal by `rfl` (`packages_same_curve`). One
  satisfies `WeakRankStatement` and the other refutes it (`L ≡ 1` vs. `L(s) = s − 1`, trivial
  Mordell–Weil group). Corollary `not_forall_weakRank`.
* `hodgeConjectureAt_fails_for_alt_data` / `hodgeConjectureAt_holds_for_release_data`: the
  same `CPn 1` variety, rational-equivalence and intersection data, and the same integer-valued
  cycle class. Putting it in `ℚ × ℚ` with "every class is Hodge" makes `HodgeConjectureAt 0`
  false. The release's own data makes it true.
* `cpn_is_unit`: `CPn n = Unit` by `rfl`.
* `trivialDeRhamIsomorphism`: `DeRhamIsomorphism 𝕜 E n` holds for every `𝕜, E, n` (identity map).
* `hardyLittlewoodRow_nonempty_iff`: `Nonempty (HardyLittlewoodRow k) ↔ (primePairBasePrimes k).Infinite`.

## 4. Bass Theorem: missing statements, now proved (`Ramtastic/Bass/CliffordBridge.lean`, `Ramtastic/Bass/HingeAnalysis.lean`)

These use the release's own negative-definite algebra `CliffordAlgebra (negInnerQ V)`:

* `cliffordHinge` (Bass (i)): for `‖v‖ = 1` and any module `S` over the Clifford algebra,
  `c(v)` is a `Hinge` (`c(v)² = -id`). `embed_sq_unit`: `v·v = -1`.
* `cliffordPlaneHinge`, `cliffordPlane_quarter_turn` (Bass (ii)): for orthonormal `v, w`,
  `c(v)c(w)` is a `Hinge`, and `R_{vw}(π/2) s = v • w • s`. `embed_mul_sq_ortho`: `(vw)² = -1`.
* `rotate_inner`: if `J` is skew-adjoint, every `R(θ)` preserves the inner product.
* `hinge_inner_J_J`, `hinge_norm_J`: the "positivity" row of the README table.

`RamtasticAudit/ProbeAxioms.lean` prints the axioms of every audit result. Each uses only
`propext`, `Classical.choice` and `Quot.sound`.

## 5. Top-level `README.md`

The top-level `README.md` describes a *different* audit bundle (from "eNuminous", 2026-10-16). The files
it references (`REPORT.md`, `VERIFICATION.md`, `ZOO-46.md`, `reproduce.py`, …) are **not in
this upload**, so none of its claims can be checked here. Two of its concrete observations are
consistent with this audit, which reached them independently: the unmodified release build fails, and a
namespace / zero-form defect has to be fixed before a build succeeds (finding 2).

## 6. Recommendations

1. ~~Add the two missing Bass files and fix `DolbeaultTheorem.lean`.~~ **Done** (see §8).
2. ~~Make `Ramtastic.lean` import every module.~~ **Done** (see §8).
3. In docstrings, say clearly which named theorems are *assumed* (as structure or class fields) rather than
   proved. Rename `HodgeConjectureAt` and similar predicates to make clear they are relative to
   supplied data. Remove "CP^m" wording for the `Unit` model.
4. Tie the BSD objects to the curve: compute the L-function, the Mordell–Weil group and the
   regulator from `(a, b)`, or state results as conditional on those identifications.

## 7. Reproduce

```sh
lake build            # whole release tree, all 78 modules (succeeds after the fixes in §8)
lake build RamtasticAudit.AxiomAudit RamtasticAudit.SemanticProbes RamtasticAudit.ProbeAxioms
```

Findings 1, 2 and 4 describe the release *as uploaded*; to reproduce them, check out the
initial commit.

## 8. Fixes applied

* **Finding 1 (missing modules).** Added `Ramtastic/Bass/HingeAnalysis.lean` (skew-adjoint
  hinges: `hinge_inner_J_J`, `hinge_norm_J`, `rotate_inner` — rotations preserve the inner
  product, as claimed in the `HingeRotation.lean` header) and `Ramtastic/Bass/CliffordBridge.lean`
  (Bass (i) and (ii): `cliffordHinge`, `cliffordPlaneHinge`, `cliffordPlane_quarter_turn`, on the
  release's negative-definite Clifford algebra). These are the results formerly in the audit file
  `RamtasticAudit/BassCompletion.lean`, which has been removed.
* **Finding 2 (`DolbeaultTheorem.lean`).** Added the missing import of
  `Ramtastic.ComplexStructure.DelDelBar` and `open Ramtastic.ComplexStructure`, and added
  `pullbackJ_apply` to the two failing `simp` calls (dropping their now-unused arguments).
* **Root file.** `Ramtastic.lean` now imports all 78 modules, so `lake build` checks the whole tree.
  It builds with no errors.
* **Axiom audit.** `RamtasticAudit/AxiomAudit.lean` now imports the root, so it covers all 78
  modules: 920 theorems, 1035 definitions, 261 other constants, using only `propext`,
  `Classical.choice` and `Quot.sound`.
* **Not changed.** The semantic findings in §§2–3 (named theorems assumed as structure/class
  fields, BSD objects not tied to the curve, `CPn m := Unit`, etc.) are about what the
  statements mean. They cannot be repaired by a build fix: doing so would require actually
  proving de Rham, Hard Lefschetz, Kolyvagin/Gross–Zagier, GAGA, a Yang–Mills mass gap, … .
