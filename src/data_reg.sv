`default_nettype none

module data_reg(
  input  wire clk,

  input  wire [2:0]  read_addr,
  input  wire [2:0]  write_addr,
  input  wire        write_en,

  input  wire [31:0] data_in,
  output wire [31:0] data_out
);

  logic [191:0] data;
  logic [5:0] data_write_en;

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
  generate
    for(genvar i = 0; i < 6; i++) begin : g
      always_ff @(posedge clk) begin
        if(data_write_en[i]) data[i * 32 +: 32] <= data_in;
      end
    end
  endgenerate
`endif

  generate
    for(genvar i = 0; i < 6; i++) begin : h
      assign data_write_en[i] = i == write_addr && write_en;
    end
  endgenerate

  assign data_out = read_addr < 6 ? data[{read_addr, 5'b0} +: 32] : 32'b0;
endmodule
