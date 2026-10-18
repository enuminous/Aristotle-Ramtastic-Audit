import Ramtastic.BSD.Statement
import Ramtastic.CycleClass.ImageInHodge
import Ramtastic.DeRham.DeRhamTheorem
import Ramtastic.HardyLittlewood.PrimePairAsymptotic

/-!
# Semantic probes of Ramtastic statement surfaces

Each probe below is a kernel-checked fact about what a Ramtastic definition
actually says, as opposed to what its docstring says.

* **BSD.** `WeakRankStatement A` is a property of an arbitrary bundle of data,
  not of an elliptic curve: two bundles with *identical* curve data
  (`y² = x³ + 1`, same local data, same conductor) give opposite verdicts,
  because the L-function and the Mordell–Weil group are free fields that are
  not computed from the curve.
* **Hodge.** `HodgeConjectureAt` is a property of chosen `CycleClassData` /
  `HodgeClassData`.  On the release's own `CPn 1` model (same variety data,
  same rational equivalence, same intersection data, same cycle-class
  numbers) a different, equally admissible choice of target cohomology and
  Hodge classes makes it false.
* **de Rham.** `DeRhamIsomorphism` is satisfied by taking "singular
  cohomology" to be de Rham cohomology itself and the identity map.
* **Hardy–Littlewood.** A `HardyLittlewoodRow k` exists exactly when the
  `k`-th prime-pair row is infinite: the structure contains no asymptotic
  information, and the "singular series" field is an unconstrained positive real.
-/

namespace RamtasticAudit.SemanticProbes

noncomputable section

/-! ## BSD -/

section BSD

open Ramtastic.BSD.EllipticCurve Ramtastic.BSD.LFunction Ramtastic.BSD.MordellWeil
open Ramtastic.BSD.HeightPairing Ramtastic.BSD.ArithmeticGAGA Ramtastic.BSD.Statement

/-- The curve `y² = x³ + 1` with good-reduction local data everywhere. -/
def probeCurve : ArithmeticECData where
  a := 0
  b := 1
  disc_ne_zero := by norm_num
  local_data := fun _ => ⟨0, .good, 1, one_pos⟩
  conductor := 1
  conductor_pos := one_pos
  hasse_bound := by intro p _ _; simp

/-- Analytic data on `probeCurve` with an *arbitrary* differentiable `L`
and a matching order of vanishing `r`. -/
def probeAnalytic (L : ℝ → ℝ) (hL : Differentiable ℝ L) (r : ℕ)
    (hv : ∀ k < r, iteratedDeriv k L 1 = 0) (hr : iteratedDeriv r L 1 ≠ 0) :
    AnalyticRank where
  toArithmeticECData := probeCurve
  L := L
  L_continuous := hL.continuous
  L_differentiable := hL
  Lambda := 0
  Lambda_continuous := continuous_const
  root_number := 1
  root_number_sq := by norm_num
  func_eq := by intro s; simp
  analytic_rank := r
  vanishes_below := hv
  leading_nonzero := hr

/-- The comparison of `probeCurve` with any analytic data built on it. -/
def probeComparison (A : AnalyticRank) (h : A.toArithmeticECData = probeCurve) :
    AlgebraicAnalyticCurveComparison where
  arithmetic := probeCurve
  analytic := A
  same_weierstrass_a := by rw [h]
  same_weierstrass_b := by rw [h]
  same_conductor := by rw [h]
  same_local_data := by intro p; rw [h]

def probeNeron (C : AlgebraicAnalyticCurveComparison) (hC : C.arithmetic = probeCurve) :
    NeronModelLocalComparison C where
  componentGroupOrder p := (C.arithmetic.local_data p).tamagawa
  frobeniusTrace p := (C.arithmetic.local_data p).trace_frobenius
  localFactorTrace p := (C.arithmetic.local_data p).trace_frobenius
  component_group_matches_tamagawa _ := rfl
  frobenius_matches_arithmetic _ := rfl
  local_factor_trace_matches_frobenius _ _ := rfl
  good_reduction_component_trivial p _ := by rw [hC]; rfl

def probeHasseWeil (C : AlgebraicAnalyticCurveComparison) (N : NeronModelLocalComparison C) :
    HasseWeilReadoutComparison C N where
  eulerCoefficient := N.frobeniusTrace
  completedCentralCoefficient n := iteratedDeriv n C.analytic.L 1 / (Nat.factorial n : ℝ)
  euler_coefficients_are_frobenius _ _ := rfl
  analytic_rank_is_first_nonzero_completed_coefficient := by
    refine ⟨fun n hn => ?_, ?_⟩
    · simp [C.analytic.vanishes_below n hn]
    · exact div_ne_zero C.analytic.leading_nonzero (by positivity)
  completed_coefficients_match_lfunction _ := rfl

/-- The trivial group as a "Mordell–Weil group" of rank 0. -/
def trivialMW : MordellWeilGroup where
  Point := Unit
  rank := 0
  torsion_order := 1
  torsion_order_pos := one_pos
  free_generators := fun i => i.elim0
  free_independent := fun _ _ i => i.elim0
  spans := fun p => ⟨fun i => i.elim0, p, ⟨1, one_pos, Subsingleton.elim _ _⟩,
    Subsingleton.elim _ _⟩

def trivialRegulator : Regulator trivialMW where
  height := fun _ => 0
  height_nonneg := fun _ => le_rfl
  height_zero_iff := fun _ => ⟨fun _ => ⟨1, one_pos, Subsingleton.elim (α := Unit) _ _⟩, fun _ => rfl⟩
  height_quadratic := fun _ _ => by simp
  gram_matrix := fun i => i.elim0
  gram_is_pairing := fun i => i.elim0
  regulator := 1
  regulator_pos := fun h => absurd h (lt_irrefl 0)
  regulator_zero_rank := fun _ => rfl

def probeMW (C : AlgebraicAnalyticCurveComparison) : MordellWeilHeightComparison C where
  mw := trivialMW
  regulator := trivialRegulator
  basisRank := 0
  basis_rank_matches_mw := rfl
  free_generators_independent := trivialMW.free_independent
  free_generators_span := trivialMW.spans
  height_detects_torsion := trivialRegulator.height_zero_iff
  regulator_positive_for_positive_rank := trivialRegulator.regulator_pos

/-- Assemble a full `BSDArithmeticGAGAComparison` on `probeCurve`. -/
def probePackage (A : AnalyticRank) (h : A.toArithmeticECData = probeCurve) :
    BSDArithmeticGAGAComparison :=
  let C := probeComparison A h
  let N := probeNeron C rfl
  { curve := C, neron := N, hasseWeil := probeHasseWeil C N, mordellWeil := probeMW C }

/-- Analytic data with `L ≡ 1`, so analytic rank `0`. -/
def analyticRankZero : AnalyticRank :=
  probeAnalytic (fun _ => 1) (differentiable_const 1) 0 (fun k hk => absurd hk (by omega))
    (by simp)

/-- Analytic data with `L(s) = s - 1`, so analytic rank `1`. -/
def analyticRankOne : AnalyticRank :=
  probeAnalytic (fun s => s - 1) (differentiable_id.sub_const 1) 1
    (fun k hk => by
      obtain rfl : k = 0 := by omega
      simp)
    (by
      rw [iteratedDeriv_one]
      simp)

def packageGood : BSDArithmeticGAGAComparison := probePackage analyticRankZero rfl
def packageBad : BSDArithmeticGAGAComparison := probePackage analyticRankOne rfl

/-- The two packages describe literally the same curve data. -/
theorem packages_same_curve :
    packageGood.curve.arithmetic = packageBad.curve.arithmetic := rfl

/-- **BSD probe.** Same curve, opposite verdicts of the "weak BSD" statement surface. -/
theorem weakRank_same_curve_opposite_verdicts :
    WeakRankStatement packageGood ∧ ¬ WeakRankStatement packageBad := by
  refine ⟨rfl, ?_⟩
  intro h
  exact Nat.zero_ne_one (h : (0 : ℕ) = 1)

/-- Consequently the weak BSD statement surface cannot be asserted for all packages. -/
theorem not_forall_weakRank : ¬ ∀ A : BSDArithmeticGAGAComparison, WeakRankStatement A :=
  fun h => weakRank_same_curve_opposite_verdicts.2 (h packageBad)

end BSD

/-! ## Hodge -/

section Hodge

open Ramtastic.ChowGroups.AlgebraicCycle Ramtastic.ChowGroups.RationalEquivalence
open Ramtastic.ChowGroups.ChowGroup Ramtastic.ChowGroups.IntersectionProduct
open Ramtastic.ChowGroups.ChowRing Ramtastic.ChowGroups.ProjectiveSpace
open Ramtastic.CycleClass.ImageInHodge

/-- `CPn n` in the release is the one-point type `Unit`. -/
theorem cpn_is_unit (n : ℕ) : CPn n = Unit := rfl

instance : Fact (0 < 1) := ⟨one_pos⟩

/-- With the release's own choice of data, `HodgeConjectureAt` holds on `CPn 1`. -/
theorem hodgeConjectureAt_holds_for_release_data :
    HodgeConjectureAt (X := CPn 1) 0 :=
  cpn_hodge_conjecture 1 0

/-- Alternative cycle-class data on the release's `CPn 1` model: the same
integer-valued cycle class, placed in the first coordinate of `ℚ × ℚ`. -/
@[reducible] def altCycleClassData : CycleClassData (CPn 1) where
  Cohom _ := ℚ × ℚ
  cohom_addCommGroup _ := inferInstance
  cohom_module _ := inferInstance
  cycleClass p := (AddMonoidHom.inl ℚ ℚ).comp (cpnCycleClass 1 p)
  cl_nontrivial := by
    obtain ⟨p, a, h⟩ := (cpnCycleClassData 1).cl_nontrivial
    refine ⟨p, a, ?_⟩
    intro h'
    apply h
    have := congrArg Prod.fst h'
    simpa using this

/-- Alternative Hodge-class data: every class is declared Hodge. -/
@[reducible] def altHodgeClassData : @HodgeClassData (CPn 1) _ _ _ altCycleClassData := by
  letI := altCycleClassData
  exact
  { isHodge := fun _ => Set.univ
    cl_is_hodge := fun _ _ => Set.mem_univ _ }

attribute [-instance] cpnCycleClassData cpnHodgeClassData
attribute [local instance] altCycleClassData altHodgeClassData

/-- **Hodge probe.** On the release's own `CPn 1` model, the release predicate
`HodgeConjectureAt` is false for an admissible choice of cycle-class and
Hodge-class data. -/
theorem hodgeConjectureAt_fails_for_alt_data :
    ¬ HodgeConjectureAt (X := CPn 1) 0 := by
  intro h
  have hmem := h ((0 : ℚ), (1 : ℚ)) (Set.mem_univ _)
  have hle : Submodule.span ℚ
      (Set.range (CycleClassData.cycleClass (X := CPn 1) 0)) ≤
      LinearMap.ker (LinearMap.snd ℚ ℚ ℚ) := by
    rw [Submodule.span_le]
    rintro _ ⟨a, rfl⟩
    show ((AddMonoidHom.inl ℚ ℚ).comp (cpnCycleClass 1 0) a).2 = 0
    simp
  have h1 : (1 : ℚ) = 0 := hle hmem
  exact one_ne_zero h1

end Hodge

/-! ## de Rham -/

section DeRham

open Ramtastic.DeRham.Quotient Ramtastic.DeRham.DeRhamTheorem

/-- **de Rham probe.** `DeRhamIsomorphism` is inhabited for every normed space
and degree by choosing de Rham cohomology itself as "singular cohomology". -/
@[reducible] def trivialDeRhamIsomorphism (𝕜 : Type*) [NontriviallyNormedField 𝕜]
    (E : Type*) [NormedAddCommGroup E] [NormedSpace 𝕜 E] (n : ℕ) :
    DeRhamIsomorphism 𝕜 E n where
  SingularCohom := @DeRhamCohomology 𝕜 _ E _ _ 𝕜 _ _ n
  integrationMap := LinearMap.id
  integration_bijective := Function.bijective_id

end DeRham

/-! ## Hardy–Littlewood -/

section HardyLittlewood

open Ramtastic.HardyLittlewood.PrimePairAsymptotic

/-- **Hardy–Littlewood probe.** A "Hardy–Littlewood row" exists iff the
prime-pair row is infinite; no asymptotic content is involved. -/
theorem hardyLittlewoodRow_nonempty_iff (k : ℕ) (hk : 1 ≤ k) :
    Nonempty (HardyLittlewoodRow k) ↔ Set.Infinite (primePairBasePrimes k) := by
  constructor
  · rintro ⟨R⟩
    exact infinite_row_of_hardy_littlewood R
  · intro hinf
    refine ⟨⟨hk, 1, one_pos, fun n => ?_⟩⟩
    obtain ⟨p, hp, hnp⟩ := hinf.exists_gt n
    exact ⟨p, hnp, hp⟩

end HardyLittlewood

end

end RamtasticAudit.SemanticProbes
