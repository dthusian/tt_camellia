`default_nettype none
module ops(
  input  wire        clk,

  // Control path
  input  wire [1:0]  subcycle,
  // 000 =  S1, 001 =  S2, 010 = FL1, 011 = FL2
  // 100 = XOR, 101 = XS1, 110 = XS2, 111 = XS3
  input  wire [2:0]  opcode,

  // Data path
  input  wire [31:0] data_a,
  input  wire [31:0] data_b,
  output var  [31:0] result
);
  // XOR-ing network
  logic [31:0] xored;
  always_comb begin
    case(opcode)
      'b101: xored = data_a ^ {data_b[23:0], data_b[31:24]};
      'b110: xored = data_a ^ {data_b[15:0], data_b[31:16]};
      'b111: xored = data_a ^ {data_b[7:0], data_b[31:8]};
      default: xored = data_a ^ data_b;
    endcase
  end

  // S-boxes
  logic [1:0] sbox_ctl;
  logic [7:0] sbox_in;
  logic [7:0] sbox_shifted_in;
  logic [7:0] sbox_out;
  logic [7:0] sbox_shifted_out;
  logic [31:0] sbox_result;
  always_ff @(posedge clk) begin
    sbox_result[31:8] <= sbox_result[23:0];
  end
  always_comb begin
    sbox_ctl = subcycle + {1'b0, opcode[0]};
    // Input shift
    sbox_in = xored[{subcycle, 3'b000} +: 8];
    if(sbox_ctl == 'b00) begin
      sbox_shifted_in = {sbox_in[6:0], sbox_in[7]};
    end else begin
      sbox_shifted_in = sbox_in;
    end
    // Output shift
    if(sbox_ctl == 'b10) begin
      sbox_shifted_out = {sbox_out[6:0], sbox_out[7]};
    end else if(sbox_ctl == 'b01) begin
      sbox_shifted_out = {sbox_out[0], sbox_out[7:1]};
    end else begin
      sbox_shifted_out = sbox_out;
    end
    sbox_result[7:0] = sbox_shifted_out;
  end
  sbox i_sbox(
    .in(sbox_shifted_in),
    .out(sbox_out)
  );

  // FLA function
  logic [31:0] fla_unrot;
  logic [31:0] fla;
  assign fla_unrot = data_a & data_b;
  assign fla = {fla_unrot[30:0], fla_unrot[31]};

  // FLB function
  logic [31:0] flb;
  assign flb = data_a | data_b;

  // Output muxing
  always_comb begin
    case(opcode)
      'b000: result = sbox_result;
      'b001: result = sbox_result;
      'b010: result = fla;
      'b011: result = flb;
      default: result = xored;
    endcase
  end

endmodule
