"""
Layout (prototype 1):
- Latches are arranged in a 32R8C layout
    0  32   1  33   2  34   3  35
   64  96  65  97  66  98  67  99
  128 160 ...
  192 224
  ...
   28  60  29  61  30  62  31  63
   92 124  93 125  94 126  95 127
  156 188 ...
  220 252
- Every 4 rows of latches has 2 row of bus1/2 muxes
- Every 16 rows of latches has 2 rows of bus3 muxes
- Shift-in can just go between a 2x4 region
- Tap cells inserted every 4 latches or every 2 muxes

Layout (prototype 2):
- Latches are arranged in a 32R8C layout
    0  32  64  96  128 160 192 224
    1  33  65  97  129 161 193 225
  ...
- Every 4 columns of latches has 1 column of bus1/2 muxes
- On the side, rows 0, 1, 2, 3, 16, 17, 18, 19 has bus4 muxes
- Shift-in goes horizontally
- Tap cells inserted every 4 latches or every 2 muxes
"""

import json
from decimal import Decimal

placements = {}

ROW_H = Decimal("2.76")
LATCH_W = Decimal("5.52")
MUX4_W = Decimal("9.66")
TAP_W = Decimal("0.46")

PLACE_X = ROW_H * 5
PLACE_Y = ROW_H * 5

# prototype 2
for y in range(32):
  context = {
    "cx": PLACE_X
  }
  def place_thing(inst: str, w: Decimal):
    placements[inst] = {
      "location": (str(context["cx"] + w / 2), str(PLACE_Y + y * ROW_H)),
      "orientation": "R0"
    }
    context["cx"] += w + TAP_W
  for x in range(8):
    i = x * 32 + y
    place_thing(f"mpgen1[{i}].mplatch", LATCH_W)
    if x == 3:
      if y < 16:
        place_thing(f"mpgen2[{y}].mpmux1a", MUX4_W)
      else:
        place_thing(f"mpgen2[{y-16}].mpmux2a", MUX4_W)
    if x == 7:
      if y < 16:
        place_thing(f"mpgen2[{y}].mpmux1b", MUX4_W)
        place_thing(f"mpgen2[{y}].mpmux1c", MUX4_W)
      else:
        place_thing(f"mpgen2[{y-16}].mpmux2b", MUX4_W)
        place_thing(f"mpgen2[{y-16}].mpmux2c", MUX4_W)

with open("config.json", "r") as fin:
  with open("config_placed.json", "w") as fout:
    j = json.load(fin)
    j.update({ "MANUAL_GLOBAL_PLACEMENTS": placements })
    json.dump(j, fout, indent=2)