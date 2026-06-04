import json
from decimal import Decimal

placements = {}

ROW_H = Decimal("2.72")

INIT_X = Decimal("6.90")
INIT_Y = Decimal("8.16")

SPACING = Decimal("2.00")
MUX4_1_W = Decimal("9.66")
DLXTP_1_W = Decimal("5.52")

for x in range(32):
  for y in range(8):
    idx = x + y * 32
    pos_x = INIT_X + x * (DLXTP_1_W + SPACING)
    pos_y = INIT_Y + y * ROW_H + (y // 4) * ROW_H * 3
    latch = f"engine/key_r/mpgen1[{idx}].mplatch"
    placements[latch] = {
      "location": (str(pos_x), str(pos_y)),
      "orientation": "R0"
    }

j = None
with open("src/config.json", "r") as fp:
  j = json.load(fp)
j["MANUAL_GLOBAL_PLACEMENTS"] = placements
with open("src/config.json", "w") as fp:
  json.dump(j, fp, indent=2)