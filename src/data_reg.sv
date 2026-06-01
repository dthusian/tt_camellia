`default_nettype none

module data_reg(
  input  logic clk,
  input  logic rst,

  input  logic        address,
  input  logic        write_en,
  input  logic        shift_en,

  input  logic [63:0] data_in,
  output logic [63:0] data_out,

  input  logic [7:0] shift_in,
  output logic [7:0] shift_out
);

  logic [127:0] data;

  always_ff @(posedge clk) begin
    if(rst) begin
      data <= 'b0;
    end else begin
      if(write_en) begin
        if(address) begin
          data[127:64] <= data_in;
        end else begin
          data[63:0] <= data_in;
        end
      end else if(shift_en) begin
        data <= {shift_in, data[127:8]};
      end
    end
  end

  assign shift_out = data[7:0];
  assign data_out = address ? data[127:64] : data[63:0];


endmodule