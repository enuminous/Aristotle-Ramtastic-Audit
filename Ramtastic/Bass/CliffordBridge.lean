import Ramtastic.Bass.HingeRotation
import Ramtastic.SeibergWitten.CliffordBundle
import Mathlib.Analysis.InnerProductSpace.Basic

/-!
# Clifford actions as hinges

Restored from Aristotle's uploaded `RamtasticAudit/BassCompletion.lean`
(run 6b97b551-c689-4d49-9ea2-282f6f81a993). These are algebraic statements
on a supplied Clifford module. Metric preservation requires the separate
skew-adjointness hypothesis in `HingeAnalysis.lean`.
-/
namespace Ramtastic.Bass.CliffordBridge
open Ramtastic.Bass.HingeRotation
open Ramtastic.SeibergWitten.CliffordBundle

noncomputable section

/-! ## Any square root of `-1` in an algebra acting on a module is a hinge -/

section Algebra

variable {A : Type*} [Ring A] [Algebra ℝ A]
variable {S : Type*} [AddCommGroup S] [Module ℝ S] [Module A S] [IsScalarTower ℝ A S]

/-- The real-linear map `s ↦ x • s` given by an algebra element `x`. -/
def actionMap (x : A) : S →ₗ[ℝ] S where
  toFun s := x • s
  map_add' a b := smul_add x a b
  map_smul' r s := by
    simp only [RingHom.id_apply]
    rw [← algebraMap_smul A r s, ← mul_smul, ← Algebra.commutes, mul_smul, algebraMap_smul]

@[simp] theorem actionMap_apply (x : A) (s : S) : actionMap (S := S) x s = x • s := rfl

/-- If `x * x = -1` in `A`, then the action of `x` on `S` is a `Hinge`. -/
def hingeOfSqNegOne (x : A) (hx : x * x = -1) : Hinge S where
  J := actionMap x
  sq_neg := by
    ext s
    simp [← mul_smul, hx]

end Algebra

/-! ## Clifford algebra facts, negative-definite convention -/

section Clifford

variable {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]

theorem negInnerQ_apply (v : V) : negInnerQ V v = -(@inner ℝ V _ v v) := by
  simp [negInnerQ, innerQ_apply]

/-- The polar form of `-⟪·,·⟫` is `-2⟪v,w⟫`. -/
theorem polar_negInnerQ (v w : V) :
    QuadraticMap.polar (negInnerQ V) v w = -(2 * @inner ℝ V _ v w) := by
  simp only [QuadraticMap.polar, negInnerQ_apply, inner_add_left, inner_add_right,
    real_inner_comm w v]
  ring

/-- A unit vector squares to `-1` in `Cl(V, -⟪·,·⟫)`. -/
theorem embed_sq_unit (v : V) (hv : ‖v‖ = 1) : embed V v * embed V v = -1 := by
  rw [embed_sq, negInnerQ_apply, real_inner_self_eq_norm_sq, hv]
  simp

/-- For orthogonal unit vectors, `(v w)² = -1` in `Cl(V, -⟪·,·⟫)`. -/
theorem embed_mul_sq_ortho (v w : V) (hv : ‖v‖ = 1) (hw : ‖w‖ = 1)
    (hvw : @inner ℝ V _ v w = 0) :
    (embed V v * embed V w) * (embed V v * embed V w) = -1 := by
  have hanti : embed V w * embed V v = -(embed V v * embed V w) := by
    have h := embed_ortho_anticomm (V := V) w v
      (by rw [polar_negInnerQ, real_inner_comm, hvw]; ring)
    exact h
  calc (embed V v * embed V w) * (embed V v * embed V w)
      = embed V v * (embed V w * embed V v) * embed V w := by noncomm_ring
    _ = -(embed V v * embed V v) * (embed V w * embed V w) := by
        rw [hanti]; noncomm_ring
    _ = -1 := by rw [embed_sq_unit v hv, embed_sq_unit w hw]; noncomm_ring

variable {S : Type*} [AddCommGroup S] [Module ℝ S] [Module (CliffordAlgebra (negInnerQ V)) S]
  [IsScalarTower ℝ (CliffordAlgebra (negInnerQ V)) S]

/-- **Bass (i).** For a unit vector `v` and any module `S` over the
negative-definite Clifford algebra, `c(v)` is a hinge: `c(v)² = -id`. -/
def cliffordHinge (v : V) (hv : ‖v‖ = 1) : Hinge S :=
  hingeOfSqNegOne (embed V v) (embed_sq_unit v hv)

theorem cliffordHinge_sq (v : V) (hv : ‖v‖ = 1) (s : S) :
    (embed V v) • (embed V v) • s = -s := by
  have := LinearMap.ext_iff.mp (cliffordHinge (S := S) v hv).sq_neg s
  simpa [cliffordHinge, hingeOfSqNegOne] using this

/-- **Bass (ii), first half.** For orthogonal unit vectors `v, w`, the degree-2
action `c(v) c(w)` is a hinge. -/
def cliffordPlaneHinge (v w : V) (hv : ‖v‖ = 1) (hw : ‖w‖ = 1)
    (hvw : @inner ℝ V _ v w = 0) : Hinge S :=
  hingeOfSqNegOne (embed V v * embed V w) (embed_mul_sq_ortho v w hv hw hvw)

/-- **Bass (ii), second half.** The quarter turn of the `(v,w)`-plane rotation
is the action of `c(v) c(w)`, i.e. `s ↦ v • (w • s)`. -/
theorem cliffordPlane_quarter_turn (v w : V) (hv : ‖v‖ = 1) (hw : ‖w‖ = 1)
    (hvw : @inner ℝ V _ v w = 0) (s : S) :
    rotate (cliffordPlaneHinge (S := S) v w hv hw hvw) (Real.pi / 2) s =
      embed V v • embed V w • s := by
  rw [rotate_halfPi]
  simp [cliffordPlaneHinge, hingeOfSqNegOne, mul_smul]

end Clifford

end

end Ramtastic.Bass.CliffordBridge
