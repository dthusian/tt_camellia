`default_nettype none

module key_reg(
  input  logic clk,
  input  logic rst,

  input  logic shift_en,
  input  logic [7:0] shift_in,

  output logic [127:0] key_out
);
  logic [127:0] key;

  always_ff @(posedge clk) begin
    /*if(rst) begin
      key <= 128'b0;
    end else*/ if(shift_en) begin
      key <= {shift_in, key[127:8]};
    end
  end

  assign key_out = key;
endmodule