`default_nettype none

module data_reg(
  input  logic clk,
  input  logic rst,

  input  logic        address,
  input  logic        write_en,
  input  logic        xor_en,
  input  logic [7:0]  byte_en,

  input  logic [63:0] in_data,
  output logic [63:0] out_data
);

  logic [127:0] data;
  logic [63:0] write_val;

  always_comb begin
    if(write_en) begin
      write_val = in_data;
    end else if(xor_en) begin
      write_val = in_data ^ (address ? data[127:64] : data[63:0]);
    end else begin
      write_val = 64'bx;
    end
  end

  always_ff @(posedge clk) begin
    if(rst) begin
      data <= 'b0;
    end else begin
      if(write_en | xor_en) begin
        if(address) begin
          if(byte_en[7]) data[127:120] <= write_val[63:56];
          if(byte_en[6]) data[119:112] <= write_val[55:48];
          if(byte_en[5]) data[111:104] <= write_val[47:40];
          if(byte_en[4]) data[103:96] <= write_val[39:32];
          if(byte_en[3]) data[95:88] <= write_val[31:24];
          if(byte_en[2]) data[87:80] <= write_val[23:16];
          if(byte_en[1]) data[79:72] <= write_val[15:8];
          if(byte_en[0]) data[71:64] <= write_val[7:0];
        end else begin
          if(byte_en[7]) data[63:56] <= write_val[63:56];
          if(byte_en[6]) data[55:48] <= write_val[55:48];
          if(byte_en[5]) data[47:40] <= write_val[47:40];
          if(byte_en[4]) data[39:32] <= write_val[39:32];
          if(byte_en[3]) data[31:24] <= write_val[31:24];
          if(byte_en[2]) data[23:16] <= write_val[23:16];
          if(byte_en[1]) data[15:8] <= write_val[15:8];
          if(byte_en[0]) data[7:0] <= write_val[7:0];
        end
      end
    end
  end

  assign out_data = address ? data[127:64] : data[63:0];

endmodule