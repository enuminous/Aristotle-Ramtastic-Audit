import Ramtastic.Bass.HingeRotation
import Mathlib

/-!
# The Hinge: the claims stated in the header of `HingeRotation.lean`

The header of `HingeRotation.lean` claims, beyond the eight declarations in the file:

* every element of the rotation group preserves any inner product that `J` preserves;
* under the same inner-product hypothesis, the orbit is a metric circle
  (degenerating to a point at the zero vector).

The parameterized orbit formula holds without that hypothesis; its image
need not be a Euclidean circle without metric compatibility. Periodicity,
inverses, and commutativity are also proved here.
-/

namespace Ramtastic.Bass.HingeRotation

open Real
open scoped RealInnerProductSpace

noncomputable section

section Module

variable {E : Type*} [AddCommGroup E] [Module ℝ E]

theorem Hinge.J_J_apply (h : Hinge E) (v : E) : h.J (h.J v) = -v := by
  have := LinearMap.ext_iff.mp h.sq_neg v
  simpa using this

theorem rotate_apply (h : Hinge E) (θ : ℝ) (v : E) :
    rotate h θ v = Real.cos θ • v + Real.sin θ • h.J v := by
  simp [rotate]

/-- Rotations commute. -/
theorem rotate_comm (h : Hinge E) (a b : ℝ) :
    (rotate h a).comp (rotate h b) = (rotate h b).comp (rotate h a) := by
  rw [← rotate_add, ← rotate_add, add_comm]

/-- `R(-θ)` inverts `R(θ)`. -/
theorem rotate_neg_comp (h : Hinge E) (θ : ℝ) :
    (rotate h (-θ)).comp (rotate h θ) = LinearMap.id := by
  rw [← rotate_add, neg_add_cancel, rotate_zero]

/-- The rotation group is `2π`-periodic: the circle closes. -/
theorem rotate_periodic (h : Hinge E) (θ : ℝ) : rotate h (θ + 2 * π) = rotate h θ := by
  rw [rotate_add, rotate_twoPi, LinearMap.comp_id]

/-- `J` commutes with every rotation. -/
theorem J_comp_rotate (h : Hinge E) (θ : ℝ) :
    h.J.comp (rotate h θ) = (rotate h θ).comp h.J := by
  rw [← rotate_halfPi h, ← rotate_add, ← rotate_add, add_comm]

end Module

section Inner

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-- If `J` preserves the inner product, then (because `J² = -id`) `J` is skew-adjoint. -/
theorem skew_of_isometry (h : Hinge E) (hJ : ∀ x y : E, ⟪h.J x, h.J y⟫ = ⟪x, y⟫)
    (x y : E) : ⟪h.J x, y⟫ = -⟪x, h.J y⟫ := by
  have := hJ (h.J x) y
  rw [h.J_J_apply, inner_neg_left] at this
  linarith

/-- Conversely, a skew-adjoint Hinge preserves the inner product. -/
theorem isometry_of_skew (h : Hinge E) (hs : ∀ x y : E, ⟪h.J x, y⟫ = -⟪x, h.J y⟫)
    (x y : E) : ⟪h.J x, h.J y⟫ = ⟪x, y⟫ := by
  rw [hs, h.J_J_apply, inner_neg_right, neg_neg]

/-- **Header claim 1.** Every rotation `R(θ)` preserves any inner product that `J` preserves. -/
theorem rotate_inner (h : Hinge E) (hJ : ∀ x y : E, ⟪h.J x, h.J y⟫ = ⟪x, y⟫)
    (θ : ℝ) (x y : E) : ⟪rotate h θ x, rotate h θ y⟫ = ⟪x, y⟫ := by
  have hs := skew_of_isometry h hJ
  have hc : ⟪h.J x, y⟫ + ⟪x, h.J y⟫ = 0 := by rw [hs]; ring
  simp only [rotate_apply, inner_add_left, inner_add_right, inner_smul_left,
    inner_smul_right, hJ, RCLike.conj_to_real]
  linear_combination ⟪x, y⟫ * Real.cos_sq_add_sin_sq θ + Real.cos θ * Real.sin θ * hc

/-- Rotations preserve the norm. -/
theorem norm_rotate (h : Hinge E) (hJ : ∀ x y : E, ⟪h.J x, h.J y⟫ = ⟪x, y⟫)
    (θ : ℝ) (x : E) : ‖rotate h θ x‖ = ‖x‖ := by
  have := rotate_inner h hJ θ x x
  rw [real_inner_self_eq_norm_sq, real_inner_self_eq_norm_sq] at this
  exact (sq_eq_sq₀ (norm_nonneg _) (norm_nonneg _)).mp this

/-- An isometric Hinge moves every vector to an orthogonal vector of the same length. -/
theorem inner_self_J (h : Hinge E) (hJ : ∀ x y : E, ⟪h.J x, h.J y⟫ = ⟪x, y⟫) (x : E) :
    ⟪x, h.J x⟫ = 0 := by
  have := skew_of_isometry h hJ x x
  rw [real_inner_comm] at this
  linarith

theorem norm_J (h : Hinge E) (hJ : ∀ x y : E, ⟪h.J x, h.J y⟫ = ⟪x, y⟫) (x : E) :
    ‖h.J x‖ = ‖x‖ := by
  simpa [rotate_halfPi] using norm_rotate h hJ (π / 2) x

/-- The orbit is the linear image of the unit circle in coefficient space.
Without metric compatibility this image can be an ellipse. Together with
`inner_self_J`, `norm_J`, and a nonzero vector, it is a metric circle. -/
theorem orbit_eq_circle (h : Hinge E) (x : E) :
    Set.range (fun θ : ℝ => rotate h θ x) =
      {y | ∃ a b : ℝ, a ^ 2 + b ^ 2 = 1 ∧ y = a • x + b • h.J x} := by
  ext y
  constructor
  · rintro ⟨θ, rfl⟩
    exact ⟨Real.cos θ, Real.sin θ, Real.cos_sq_add_sin_sq θ, rotate_apply h θ x⟩
  · rintro ⟨a, b, hab, rfl⟩
    have hz : ‖(⟨a, b⟩ : ℂ)‖ = 1 := by
      rw [Complex.norm_def, Complex.normSq_mk, Real.sqrt_eq_one]; nlinarith
    obtain ⟨θ, hθ⟩ : ∃ θ : ℝ, Real.cos θ = a ∧ Real.sin θ = b := by
      refine ⟨Complex.arg ⟨a, b⟩, ?_, ?_⟩
      · have := Complex.cos_arg (x := ⟨a, b⟩) (by intro h0; simp [h0] at hz)
        rw [this, hz]; simp
      · have := Complex.sin_arg (x := ⟨a, b⟩)
        rw [this, hz]; simp
    exact ⟨θ, by simp only [rotate_apply, hθ.1, hθ.2]⟩

/-- Every point of the orbit has the same distance `‖x‖` from the origin. -/
theorem orbit_on_sphere (h : Hinge E) (hJ : ∀ x y : E, ⟪h.J x, h.J y⟫ = ⟪x, y⟫)
    (x : E) : Set.range (fun θ : ℝ => rotate h θ x) ⊆ Metric.sphere 0 ‖x‖ := by
  rintro _ ⟨θ, rfl⟩
  simp [norm_rotate h hJ]

end Inner

end

end Ramtastic.Bass.HingeRotation

/-! Aristotle-compatible names for the metric completion. The earlier fork's
results above are preserved; these wrappers use their explicit hypotheses. -/
namespace Ramtastic.Bass.HingeAnalysis
open Ramtastic.Bass.HingeRotation
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

theorem hinge_J_J (h : Hinge E) (x : E) : h.J (h.J x) = -x := h.J_J_apply x

theorem hinge_inner_J_J (h : Hinge E)
    (skew : ∀ x y, @inner ℝ E _ (h.J x) y = -@inner ℝ E _ x (h.J y)) (x y : E) :
    @inner ℝ E _ (h.J x) (h.J y) = @inner ℝ E _ x y :=
  isometry_of_skew h skew x y

theorem hinge_norm_J (h : Hinge E)
    (skew : ∀ x y, @inner ℝ E _ (h.J x) y = -@inner ℝ E _ x (h.J y)) (x : E) :
    ‖h.J x‖ = ‖x‖ := norm_J h (isometry_of_skew h skew) x

theorem rotate_inner (h : Hinge E)
    (skew : ∀ x y, @inner ℝ E _ (h.J x) y = -@inner ℝ E _ x (h.J y))
    (θ : ℝ) (x y : E) :
    @inner ℝ E _ (rotate h θ x) (rotate h θ y) = @inner ℝ E _ x y :=
  HingeRotation.rotate_inner h (isometry_of_skew h skew) θ x y
end Ramtastic.Bass.HingeAnalysis
