import Ramtastic.Bass.HingeRotation
import Ramtastic.SeibergWitten.CliffordBundle
import Mathlib.Analysis.InnerProductSpace.Basic

/-!
# The Bass Theorem: statements from `Ramtastic/Bass/README.md` that the release does not prove

`Ramtastic/Bass/HingeRotation.lean` only proves facts about an abstract `Hinge`
(a real-linear `J` with `J ∘ J = -id`).  The Bass README additionally states:

* (i)  for a unit vector `v`, the Clifford action `c(v)` on a spinor module
  satisfies `c(v)² = -id`, i.e. it is a `Hinge`;
* (ii) for orthogonal unit vectors `v, w`, `c(v) c(w)` is a `Hinge`, and it is
  the quarter turn `R_{vw}(π/2)`;
* the HingeRotation header: every rotation preserves any inner product that `J`
  preserves (here: for which `J` is skew-adjoint);
* the "positivity" line of the README table, `⟪c(v)ψ, c(v)ψ⟫ = ⟪v,v⟫⟪ψ,ψ⟫`
  for a skew-adjoint action.

None of these is formalized in the release (the root file imports two modules,
`Ramtastic.Bass.HingeAnalysis` and `Ramtastic.Bass.CliffordBridge`, that are not
in the repository).  This file proves them, using the release's own
negative-definite Clifford algebra `CliffordAlgebra (negInnerQ V)` from
`Ramtastic/SeibergWitten/CliffordBundle.lean`.
-/

namespace RamtasticAudit.BassCompletion

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

/-! ## Rotations generated by a skew-adjoint hinge are isometries -/

section Inner

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

theorem hinge_J_J (h : Hinge E) (x : E) : h.J (h.J x) = -x := by
  have := LinearMap.ext_iff.mp h.sq_neg x
  simpa using this

/-- If `J` is skew-adjoint, `J` preserves the inner product. -/
theorem hinge_inner_J_J (h : Hinge E)
    (skew : ∀ x y, @inner ℝ E _ (h.J x) y = -@inner ℝ E _ x (h.J y)) (x y : E) :
    @inner ℝ E _ (h.J x) (h.J y) = @inner ℝ E _ x y := by
  rw [skew, hinge_J_J, inner_neg_right, neg_neg]

/-- README "positivity" row: `⟪Jψ, Jψ⟫ = ⟪ψ, ψ⟫` for a skew-adjoint hinge,
so `‖Jψ‖ = ‖ψ‖`. -/
theorem hinge_norm_J (h : Hinge E)
    (skew : ∀ x y, @inner ℝ E _ (h.J x) y = -@inner ℝ E _ x (h.J y)) (x : E) :
    ‖h.J x‖ = ‖x‖ := by
  have h1 := hinge_inner_J_J h skew x x
  rw [real_inner_self_eq_norm_sq, real_inner_self_eq_norm_sq] at h1
  have := (sq_eq_sq₀ (norm_nonneg _) (norm_nonneg _)).mp h1
  exact this

/-- **Rotation preserves the inner product.** If the hinge generator `J` is
skew-adjoint, then every rotation `R(θ) = cos θ · id + sin θ · J` preserves the
inner product.  (Claimed in the `HingeRotation.lean` header, not proved there.) -/
theorem rotate_inner (h : Hinge E)
    (skew : ∀ x y, @inner ℝ E _ (h.J x) y = -@inner ℝ E _ x (h.J y))
    (θ : ℝ) (x y : E) :
    @inner ℝ E _ (rotate h θ x) (rotate h θ y) = @inner ℝ E _ x y := by
  simp only [rotate, LinearMap.add_apply, LinearMap.smul_apply, LinearMap.id_apply]
  simp only [inner_add_left, inner_add_right, real_inner_smul_left, real_inner_smul_right,
    hinge_inner_J_J h skew, skew x y]
  have hc := Real.cos_sq_add_sin_sq θ
  linear_combination (@inner ℝ E _ x y) * hc

end Inner

end

end RamtasticAudit.BassCompletion
