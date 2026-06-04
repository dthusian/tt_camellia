`default_nettype none

module data_reg(
  input  logic clk,

  input  logic [1:0]  address,
  input  logic        write_en,

  input  logic [31:0] data_in,
  output logic [31:0] data_out
);

  logic [127:0] data;
  logic [127:0] data_write;
  logic [3:0] data_write_en;

  generate
    for(genvar i = 0; i < 128; i++) begin
      sky130_fd_sc_hd__edfxtp_1 flop(
        .Q(data[i]),
        .CLK(clk),
        .D(data_write[i]),
        .DE(data_write_en[i[6:5]])
      );
    end
  endgenerate

  always_comb begin
    data_write = {data_in, data_in, data_in, data_in};
    case({write_en, address})
      'b100: data_write_en = 'b0001;
      'h101: data_write_en = 'b0010;
      'h110: data_write_en = 'b0100;
      'h111: data_write_en = 'b1000;
      default: data_write_en = 'b0000;
    endcase
  end

  always_comb begin
    case(address)
      'h0: data_out = data[31:0];
      'h1: data_out = data[63:32];
      'h2: data_out = data[95:64];
      'h3: data_out = data[127:96];
    endcase
  end
endmodule