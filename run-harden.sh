#!/bin/bash -e

if [[ ! -d tt ]] ; then
  git clone https://github.com/TinyTapeout/tt-support-tools tt
fi

mkdir -p ttsetup
if [[ ! -d ttsetup/venv/ ]] ; then
  python3.12 -m venv ttsetup/venv
fi
source ttsetup/venv/bin/activate
pip install -r tt/requirements.txt

export PDK_ROOT=ttsetup/pdk
export PDK=sky130A
export LIBRELANE_TAG=3.0.3
pip install librelane==$LIBRELANE_TAG

python3 tt/tt_tool.py --create-user-config
python3 gen_manual_placements.py
python3 tt/tt_tool.py --harden
python3 tt/tt_tool.py --print-warnings