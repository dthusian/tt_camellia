`default_nettype none

module data_reg(
  input  logic clk,

  input  logic [1:0]  address,
  input  logic        write_en,

  input  logic [31:0] data_in,
  output logic [31:0] data_out
);

  logic [127:0] data;
  logic [3:0] data_write_en;

`ifdef SYNTHESIS
  generate
    for(genvar i = 0; i < 128; i++) begin
      sky130_fd_sc_hd__edfxtp_1 flop(
        .Q(data[i]),
        .CLK(clk),
        .D(data_in[i & 'b11111]),
        .DE(data_write_en[i[6:5]])
      );
    end
  endgenerate
`else
  always_ff @(posedge clk) begin
    if(data_write_en[0]) data[31:0] <= data_in;
    if(data_write_en[1]) data[63:32] <= data_in;
    if(data_write_en[2]) data[95:64] <= data_in;
    if(data_write_en[3]) data[127:96] <= data_in;
  end
`endif

  always_comb begin
    case({write_en, address})
      'b100: data_write_en = 'b0001;
      'b101: data_write_en = 'b0010;
      'b110: data_write_en = 'b0100;
      'b111: data_write_en = 'b1000;
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