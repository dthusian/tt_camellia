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
- Shift-in goes left to right
- Tap cells inserted every 4 latches or every 2 muxes
"""

from decimal import Decimal

ROW_H = Decimal("2.76")
LATCH_W = Decimal("5.52")
MUX4_W = Decimal("9.66")
TAP_W = Decimal("0.46")