import Mathlib.Tactic
import Ramtastic.Bass.HingeRotation
import Ramtastic.GAGA.AnalyticSheaves

/-! Counterexamples to unrestricted prose/specifications, not to proved theorems. -/
namespace RamtasticAudit

noncomputable def anisotropicJ : (ℝ × ℝ) →ₗ[ℝ] (ℝ × ℝ) where
  toFun v := (-2 * v.2, v.1 / 2)
  map_add' := by intro x y; ext <;> simp <;> ring
  map_smul' := by intro a v; ext <;> simp <;> ring

noncomputable def anisotropicHinge : Ramtastic.Bass.HingeRotation.Hinge (ℝ × ℝ) where
  J := anisotropicJ
  sq_neg := by ext <;> simp [anisotropicJ]

def euclideanSquare (v : ℝ × ℝ) : ℝ := v.1 ^ 2 + v.2 ^ 2

theorem squareMinusIdentity_does_not_force_euclidean_isometry :
    euclideanSquare (anisotropicHinge.J (1, 0)) ≠ euclideanSquare (1, 0) := by
  norm_num [euclideanSquare, anisotropicHinge, anisotropicJ]

theorem actual_quarter_turn_changes_euclidean_length :
    euclideanSquare
      (Ramtastic.Bass.HingeRotation.rotate anisotropicHinge (Real.pi / 2) (1, 0)) = 1 / 4 := by
  rw [Ramtastic.Bass.HingeRotation.rotate_halfPi]
  norm_num [euclideanSquare, anisotropicHinge, anisotropicJ]

open Ramtastic.GAGA.AnalyticSheaves

def unconstrainedSheaf : StructureSheafWithHodge 1 where
  rank := 1
  cohomDim := fun q => if q.val = 0 then 1 else 7
  rank_one := rfl
  hodge_symmetry_0q := fun _ => Or.inr True.intro

theorem hodge_named_field_allows_unequal_dimensions :
    unconstrainedSheaf.cohomDim ⟨1, by omega⟩ ≠
    unconstrainedSheaf.cohomDim ⟨0, by omega⟩ := by
  norm_num [unconstrainedSheaf]

/-- Symmetric K3-shaped Hodge-number fixture; no construction of a K3 surface claimed. -/
def hodgeFixture (p q : ℕ) : ℕ :=
  if (p = 0 ∧ q = 0) ∨ (p = 2 ∧ q = 2) ∨
     (p = 0 ∧ q = 2) ∨ (p = 2 ∧ q = 0) then 1
  else if p = 1 ∧ q = 1 then 20 else 0

theorem clamped_hodge_sum_adds_out_of_range_terms :
    (∑ p ∈ Finset.range 4, hodgeFixture (min p 2) (min (3 - p) 2)) = 2 ∧
    (∑ p ∈ Finset.range 4,
      if p ≤ 2 ∧ 3 - p ≤ 2 then hodgeFixture p (3 - p) else 0) = 0 := by
  decide

def quaternionI : Matrix (Fin 4) (Fin 4) ℚ :=
  !![0, -1, 0, 0; 1, 0, 0, 0; 0, 0, 0, -1; 0, 0, 1, 0]

def quaternionJ : Matrix (Fin 4) (Fin 4) ℚ :=
  !![0, 0, -1, 0; 0, 0, 0, 1; 1, 0, 0, 0; 0, -1, 0, 0]

theorem two_skew_factors_need_not_have_selfadjoint_product :
    quaternionI.transpose = -quaternionI ∧
    quaternionJ.transpose = -quaternionJ ∧
    quaternionI * quaternionI = -1 ∧
    quaternionJ * quaternionJ = -1 ∧
    (quaternionI * quaternionJ).transpose ≠ quaternionI * quaternionJ := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · ext i j
    fin_cases i <;> fin_cases j <;> norm_num [quaternionI]
  · ext i j
    fin_cases i <;> fin_cases j <;> norm_num [quaternionJ]
  · ext i j
    fin_cases i <;> fin_cases j <;>
      norm_num [quaternionI, Matrix.mul_apply, Fin.sum_univ_succ]
  · ext i j
    fin_cases i <;> fin_cases j <;>
      norm_num [quaternionJ, Matrix.mul_apply, Fin.sum_univ_succ]
  · intro h
    have entry := congrArg (fun m : Matrix (Fin 4) (Fin 4) ℚ => m 0 3) h
    norm_num [quaternionI, quaternionJ, Matrix.mul_apply, Fin.sum_univ_succ] at entry
    change (1 : ℚ) = -1 at entry
    norm_num at entry

#print axioms squareMinusIdentity_does_not_force_euclidean_isometry
#print axioms actual_quarter_turn_changes_euclidean_length
#print axioms hodge_named_field_allows_unequal_dimensions
#print axioms clamped_hodge_sum_adds_out_of_range_terms
#print axioms two_skew_factors_need_not_have_selfadjoint_product

end RamtasticAudit
