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
        data[127:120] <= shift_in;
        data[119:112] <= data[127:120];
        data[111:104] <= data[119:112];
        data[103:96] <= data[111:104];
        data[95:88] <= data[103:96];
        data[87:80] <= data[95:88];
        data[79:72] <= data[87:80];
        data[71:64] <= data[79:72];
        data[63:56] <= data[71:64];
        data[55:48] <= data[63:56];
        data[47:40] <= data[55:48];
        data[39:32] <= data[47:40];
        data[31:24] <= data[39:32];
        data[23:16] <= data[31:24];
        data[15:8] <= data[23:16];
        data[7:0] <= data[15:8];
      end
    end
  end

  assign shift_out = data[7:0];
  assign data_out = address ? data[127:64] : data[63:0];


endmodule