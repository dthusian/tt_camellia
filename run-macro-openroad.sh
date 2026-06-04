#!/bin/bash -e

export RUNDIR=runs/macro_key_reg
export PDK_ROOT=ttsetup/pdk
export PDK=sky130A
export LIBRELANE_TAG=3.0.3
source ttsetup/venv/bin/activate
pip install librelane==$LIBRELANE_TAG
python3 -m librelane --docker-no-tty --dockerized \
  --flow "OpenInOpenROAD" \
  --pdk-root "$PDK_ROOT" \
  --run-tag macro_key_reg --force-run-dir "$RUNDIR" \
  macros/camellia_key_reg/config.json

python3 -m librelane --docker-no-tty --dockerized \
  --flow "OpenInOpenROAD" \
  --pdk-root "$PDK_ROOT" \
  --run-tag dffram --force-run-dir "runs/dffram"