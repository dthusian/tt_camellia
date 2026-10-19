# TinyTapeout Camellia-128

This project implements the Camellia-128 block cipher in hardware. See https://www.rfc-editor.org/info/rfc3713/ for a 
specification of the algorithm.

This project is currently being validated, and as such has not been submitted to any TinyTapeout shuttle.

## Pinout
- `clk`: Clock input
- `rst_n`: Active-low reset input
- `din[7:0]`: Data/key input
- `dout[7:0]`: Data output
- `test_mode`: HIGH enables test mode
- `cmd_key`: Begin key input
- `cmd_data`: Begin data input/output
- `cmd_encrypt`: Begin encryption
- `cmd_decrypt`: Begin decryption
- `ready`: Ready to accept commands

## Functional Description

All inputs (including `rst_n`) are synchronized to the `clk` signal. Commands can be initiated
whenever `ready` is high, by pulling one of the `cmd_*` pins high for 1 cycle. If the command involves
data transfer, the first cycle of data transfer occurs on the cycle after `cmd_*` is high.
Another command may not be issued until `ready` goes from low to high.

### `cmd_key`

Inputs a key into the key register and perform key scheduling.

Input each byte of the 128-bit key into `din[7:0]` on each following cycle, with
a 2 cycle wait after 8 bytes. During this command, values on `dout[7:0]` should be ignored.

This command takes 80 cycles to complete, including the cycles when data is transferred.

TODO: insert a waveform here

### `cmd_data`

Inputs data into the data register.

Input each byte of the data block into `din[7:0]` on each following cycle, with
a 2 cycle wait after 8 bytes. Simultaneously, each cycle outputs on `dout[7:0]` a byte from
the result of encryption or decryption from the last command. If the last command
is not `cmd_encrypt` or `cmd_decrypt`, the values on `dout[7:0]` should be ignored.

This command takes 20 cycles to complete, including the cycles when data is transferred.

TODO: insert a waveform here

### `cmd_encrypt`

Encrypts the data inside the data register, with the key inside the key register.

No data is transferred during this command.

This command takes 242 cycles to complete.

### `cmd_decrypt`

Decrypts the data inside the data register, with the key inside the key register.

No data is transferred during this command.

This command takes 242 cycles to complete.