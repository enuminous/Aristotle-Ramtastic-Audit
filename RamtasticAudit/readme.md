# Audit modules

The [audit root](../RamtasticAudit.lean) imports every module in this directory.
`SemanticProbes.lean` contains Aristotle's BSD/Hodge/de Rham/prime-row witnesses;
`ZooProbes.lean` preserves the earlier five Zoo witness theorems.
`BassCompletion.lean` provides compatibility exports, `ProbeAxioms.lean` prints
selected dependency footprints, and `AxiomAudit.lean` enforces the whole imported
project closure. See [verification](../VERIFICATION.md).
