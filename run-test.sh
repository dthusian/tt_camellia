#!/bin/bash -e

cd test/

if [[ ! -d venv ]] ; then
  python3.12 -m venv venv
fi

source venv/bin/activate
pip install -r requirements.txt
make