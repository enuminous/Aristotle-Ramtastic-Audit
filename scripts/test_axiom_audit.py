"""Verify that the compiled axiom audit fails for each prohibited construction."""
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
source = (ROOT / "RamtasticAudit/AxiomAudit.lean").read_text()
marker = "open Lean in\nrun_cmd do"
assert source.count(marker) == 1
cases = [
    ("public axiom", "axiom AuditProbe.probe : False", "Unapproved axiom", "AuditProbe.probe"),
    ("private axiom", "namespace AuditProbe\nprivate axiom probe : False\nend AuditProbe", "Unapproved axiom", "probe"),
    ("admitted proof", "theorem AuditProbe.probe : False := by sorry", "Unapproved axiom", "sorryAx"),
    ("native proof", "theorem AuditProbe.probe : (1 : Nat) = 1 := by native_decide", "Unapproved axiom", "native_decide"),
    ("unsafe definition", "unsafe def AuditProbe.probe : Nat := 0", "Unsafe project declaration", "AuditProbe.probe"),
]
with tempfile.TemporaryDirectory(prefix="audit-controls-", dir=ROOT) as directory:
    probe = Path(directory) / "Probe.lean"
    for label, declaration, reason, name in cases:
        probe.write_text(source.replace(marker, declaration + "\n\n" + marker))
        result = subprocess.run(
            ["lake", "env", "lean", str(probe.relative_to(ROOT))],
            cwd=ROOT, text=True, capture_output=True, timeout=180,
        )
        output = result.stdout + result.stderr
        if result.returncode == 0 or reason not in output or name not in output:
            raise SystemExit(f"Failed to reject {label} for the expected reason:\n{output}")
        print(f"CONTROL_PASS {label}: {reason}")
