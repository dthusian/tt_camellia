`default_nettype none

module data_reg(
  input  wire clk,

  input  wire [2:0]  read_addr1,
  output wire [31:0] read_data1,
  input  wire [2:0]  read_addr2,
  output wire [31:0] read_data2,

  input  wire [2:0]  write_addr,
  input  wire        write_en,
  input  wire [31:0] write_data
);

  logic [191:0] data;
  logic [5:0] data_write_en;

`ifdef SYNTHESIS
  generate
    for(genvar i = 0; i < 192; i++) begin
      sky130_fd_sc_hd__edfxtp_1 flop(
        .Q(data[i]),
        .CLK(clk),
        .D(write_data[i & 'b11111]),
        .DE(data_write_en[i[7:5]])
      );
    end
  endgenerate
`else
  generate
    for(genvar i = 0; i < 6; i++) begin : g
      always_ff @(posedge clk) begin
        if(data_write_en[i]) data[i * 32 +: 32] <= write_data;
      end
    end
  endgenerate
`endif

  generate
    for(genvar i = 0; i < 6; i++) begin : h
      assign data_write_en[i] = i == write_addr && write_en;
    end
  endgenerate

  assign read_data1 = read_addr1 < 6 ? data[{read_addr1, 5'b0} +: 32] : 32'b0;
  assign read_data2 = read_addr2 < 6 ? data[{read_addr2, 5'b0} +: 32] : 32'b0;
endmodule
