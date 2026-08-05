#!/usr/bin/env python3
# Patch every installed kernel spec so each kernel spawn re-sources
# /opt/neurodesktop/environment_variables.sh via kernel_wrapper.sh. This is
# how notebook kernels pick up the correct MODULEPATH (including a CVMFS
# mount that appeared after the Jupyter server started). Covers python3,
# bash, R, etc. - any kernelspec with a kernel.json on disk.
# Idempotent: re-running leaves already-wrapped argv untouched.
# Translated from the upstream Dockerfile (see UPSTREAM_REF).
import json
from pathlib import Path

WRAPPER = "/opt/neurodesktop/kernel_wrapper.sh"
search_roots = [
    Path("/opt/conda/share/jupyter/kernels"),
    Path("/usr/local/share/jupyter/kernels"),
    Path("/usr/share/jupyter/kernels"),
]

for root in search_roots:
    if not root.is_dir():
        continue
    for spec_file in root.glob("*/kernel.json"):
        try:
            spec = json.loads(spec_file.read_text())
        except (json.JSONDecodeError, OSError) as exc:
            print(f"[WARN] Skipping {spec_file}: {exc}")
            continue
        argv = spec.get("argv")
        if not isinstance(argv, list) or not argv:
            continue
        if argv[0] == WRAPPER:
            continue
        spec["argv"] = [WRAPPER] + argv
        spec_file.write_text(json.dumps(spec, indent=1))
        print(f"[INFO] Wrapped kernel spec: {spec_file}")
