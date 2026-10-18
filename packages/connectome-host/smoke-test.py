#!/usr/bin/env python3
"""Exercise the installed host and its native store without provider credentials."""

import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

package = Path(sys.argv[1])
with tempfile.TemporaryDirectory() as directory:
    work = Path(directory)
    recipe = json.loads(
        (package / "share/connectome-host/recipes/mock-test.json").read_text()
    )
    recipe["modules"]["webui"] = False
    recipe["agent"]["mock"] = {
        "echoMode": False,
        "defaultResponse": "CONNECTOME_NIX_SMOKE_OK",
    }
    recipe_path = work / "mock.json"
    recipe_path.write_text(json.dumps(recipe))
    result = subprocess.run(
        [str(package / "bin/connectome-host"), str(recipe_path), "--no-tui"],
        input="Hello from the Nix smoke test\n",
        text=True,
        capture_output=True,
        cwd=work,
        env={**os.environ, "HOME": directory, "DATA_DIR": str(work / "data")},
        timeout=60,
        check=True,
    )
    print(result.stdout)
    print(result.stderr, file=sys.stderr)
    if "CONNECTOME_NIX_SMOKE_OK" not in result.stdout:
        sys.exit("The mock provider did not return its expected response")
    if not (package / "share/connectome-host/dist/web/index.html").is_file():
        sys.exit("The web UI bundle is missing")
