import Ramtastic.Bass.CliffordBridge
import Ramtastic.Bass.HingeAnalysis

/-! Compatibility names for the uploaded Aristotle completion.
The proofs now live in the two release modules; no proofs are duplicated here. -/
namespace RamtasticAudit.BassCompletion
export Ramtastic.Bass.CliffordBridge
  (actionMap actionMap_apply hingeOfSqNegOne negInnerQ_apply polar_negInnerQ
   embed_sq_unit embed_mul_sq_ortho cliffordHinge cliffordHinge_sq
   cliffordPlaneHinge cliffordPlane_quarter_turn)
export Ramtastic.Bass.HingeAnalysis
  (hinge_J_J hinge_inner_J_J hinge_norm_J rotate_inner)
end RamtasticAudit.BassCompletion
