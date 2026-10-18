"""Check source completeness, frozen digests, dependency pins, and README links."""
from pathlib import Path
import argparse
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "provenance/source-manifest.json"
MATHLIB = "8ec19128ad27190c2ec7c872d504be0a2877bd68"
TOOLCHAIN = "leanprover/lean4:v4.30.0-rc1"


def imports(path):
    return set(re.findall(r"^import\s+([\w.]+)", path.read_text(), re.M))


def source_paths():
    return sorted(
        [*ROOT.glob("Ramtastic/**/*.lean"), *ROOT.glob("RamtasticAudit/**/*.lean")]
        + [ROOT / name for name in
           ("Ramtastic.lean", "RamtasticAudit.lean", "lakefile.lean", "lake-manifest.json", "lean-toolchain")]
    )


def digests():
    return {p.relative_to(ROOT).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
            for p in source_paths()}


def check():
    for namespace in ("Ramtastic", "RamtasticAudit"):
        paths = list((ROOT / namespace).rglob("*.lean"))
        expected = {p.relative_to(ROOT).with_suffix("").as_posix().replace("/", ".") for p in paths}
        actual = imports(ROOT / f"{namespace}.lean")
        if actual != expected:
            raise SystemExit(f"{namespace} root mismatch: missing={expected-actual}, extra={actual-expected}")
        print(f"MODULE_COVERAGE_PASS {namespace}: {len(paths)} modules")
    for path in source_paths():
        if path.suffix != ".lean":
            continue
        for module in imports(path):
            if module.split(".")[0] in {"Ramtastic", "RamtasticAudit"}:
                target = ROOT / (module.replace(".", "/") + ".lean")
                if not target.is_file():
                    raise SystemExit(f"Missing import {module} in {path.relative_to(ROOT)}")
    if (ROOT / "lean-toolchain").read_text().strip() != TOOLCHAIN:
        raise SystemExit("Unexpected Lean toolchain")
    lakefile = (ROOT / "lakefile.lean").read_text()
    if f'@ "{MATHLIB}"' not in lakefile:
        raise SystemExit("Mathlib must be pinned in lakefile.lean")
    if lakefile.count("@[default_target]") != 2:
        raise SystemExit("Both release and audit libraries must be default targets")
    manifest = json.loads((ROOT / "lake-manifest.json").read_text())
    package = next(p for p in manifest["packages"] if p["name"] == "mathlib")
    if package["rev"] != MATHLIB or package["inputRev"] != MATHLIB:
        raise SystemExit("Mathlib manifest and lakefile disagree")
    for filename in ("README.md", "AUDIT.md", "VERIFICATION.md", "PROVENANCE.md", "Ramtastic/Bass/README.md"):
        doc = ROOT / filename
        for link in re.findall(r"\]\(([^)]+)\)", doc.read_text()):
            if "://" not in link and not link.startswith("#"):
                target = doc.parent / link.split("#")[0]
                if not target.exists():
                    raise SystemExit(f"Broken link in {filename}: {link}")
    expected = json.loads(MANIFEST.read_text())["sha256"]
    actual = digests()
    if expected != actual:
        changed = sorted(k for k in expected.keys() | actual.keys() if expected.get(k) != actual.get(k))
        raise SystemExit(f"Source manifest differs: {changed}. Review edits, then regenerate it.")
    print(f"SOURCE_INTEGRITY_PASS {len(actual)} files; dependency pins and documentation links checked")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--update-manifest", action="store_true", help="Record reviewed source changes")
    args = parser.parse_args()
    if args.update_manifest:
        MANIFEST.parent.mkdir(exist_ok=True)
        data = {
            "schema_version": 1,
            "uploaded_audit_commit": "abe3c3c36b44c3469cd3d4d789231cbc157a1c61",
            "restored_source_repository": "https://github.com/enuminous/Ramtastic",
            "restored_source_commit": "2a5d4a718333213e395f16df630cf332d0e16f4c",
            "aristotle_run": "6b97b551-c689-4d49-9ea2-282f6f81a993",
            "sha256": digests(),
        }
        MANIFEST.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")
    check()
