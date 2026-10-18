# Bass rotation and Clifford completion

Original Ramtastic author: **C. Forrester (Adauriel)**. The earlier fork's
rotation extensions and Aristotle's uploaded completion are retained with
[documented provenance](../../PROVENANCE.md). The
[original Bass prose](../../provenance/BASS-README-AS-PUBLISHED.md) is archived.

| File | Formal content |
|---|---|
| [HingeRotation.lean](HingeRotation.lean) | `Hinge`, `rotate`, and six named elementary group/angle theorems |
| [HingeAnalysis.lean](HingeAnalysis.lean) | Commutativity, inverses, periodicity, orbit parameterization, and inner-product/norm preservation with explicit hypotheses |
| [CliffordBridge.lean](CliffordBridge.lean) | Unit Clifford vectors and orthogonal unit pairs act as hinges; the pair action equals the quarter turn |

For a real-linear map with `J² = -I`, the expression
`R(θ) = cos(θ) I + sin(θ) J` gives the angle-addition law. Metric preservation
requires compatibility with the supplied inner product. The orbit formula alone
is a linear image of the coefficient unit circle, and can describe an ellipse.

The Clifford module statements use the negative-definite quadratic form.
They do not construct a preferred spinor metric. The broad architectural claim
that all analysis follows from circles is not a theorem in this package.
Products of two skew-adjoint operators are self-adjoint when the factors
commute; the unrestricted assertion is refuted by the Zoo probe.

Run `bash verify.sh` from the repository root. See
[verification evidence](../../VERIFICATION.md) for exact build scope.
