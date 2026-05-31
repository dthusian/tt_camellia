`default_nettype none

module key_reg(
  input  logic [63:0] latch_in,
  input  logic [5:0] latch_ena,

  input  logic [1:0] key_sel,
  output logic [127:0] key_out
);

logic [383:0] keys;

always_latch begin
  if(latch_ena[0]) keys[63:0] <= latch_in;
  if(latch_ena[1]) keys[127:64] <= latch_in;
  if(latch_ena[2]) keys[191:128] <= latch_in;
  if(latch_ena[3]) keys[255:192] <= latch_in;
  if(latch_ena[4]) keys[319:256] <= latch_in;
  if(latch_ena[5]) keys[383:320] <= latch_in;
end

always_comb begin
  case (key_sel)
    'b00: key_out = keys[127:0];
    'b01: key_out = keys[255:128];
    'b10: key_out = keys[383:256];
    default: key_out = 128'bx;
  endcase
end

endmodule