#!/usr/bin/env bash
# Diagnostic script to verify the Studio environment is set up correctly.
# Run this manually in the Studio terminal after startup:
#   bash /usr/local/bin/check-env.sh

set -euo pipefail

echo "=== nf-core Studio Environment Check ==="
echo ""

# Check Docker socket
if [ -S /var/run/docker.sock ]; then
    echo "[OK] Docker socket found"
    if docker info >/dev/null 2>&1; then
        echo "[OK] Docker CLI can connect to daemon"
    else
        echo "[!!] Docker socket exists but CLI cannot connect"
        echo "     Try: sudo chmod 666 /var/run/docker.sock"
    fi
else
    echo "[!!] No Docker socket at /var/run/docker.sock"
    echo "     Containerized Nextflow processes (-profile docker) will not work"
    echo "     Use Wave containers or Conda instead"
fi

echo ""
echo "Tools:"
command -v nextflow >/dev/null && echo "  nextflow  $(nextflow -version 2>&1 | grep -oP 'version \K[^\s]+')" || echo "  nextflow  NOT FOUND"
command -v nf-test  >/dev/null && echo "  nf-test   $(nf-test version 2>&1 | head -1)" || echo "  nf-test   NOT FOUND"
command -v nf-core  >/dev/null && echo "  nf-core   $(nf-core --version 2>&1)" || echo "  nf-core   NOT FOUND"
command -v docker   >/dev/null && echo "  docker    $(docker --version 2>&1)" || echo "  docker    NOT FOUND"
echo ""
echo "=== Check complete ==="
