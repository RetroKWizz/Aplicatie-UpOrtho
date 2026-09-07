#!/usr/bin/env bash
# Ruleaza testele modulului uportho_app pe o baza de test dedicata, in containerul Odoo.
# Prima rulare instaleaza modulul (-i); urmatoarele il actualizeaza (-u).
set -euo pipefail
cd "$(dirname "$0")"
DB=uportho_test
MODE=${1:-u}   # "i" la prima rulare
docker compose run --rm odoo odoo -c /etc/odoo/odoo.conf -d "$DB" "-$MODE" uportho_app \
  --test-enable --test-tags /uportho_app --stop-after-init --log-level=test
