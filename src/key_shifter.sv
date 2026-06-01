`default_nettype none

module key_shifter(
  input  logic [127:0] key_l,
  input  logic [127:0] key_a,
  input  logic [1:0] word_sel,
  input  logic [2:0] shift,
  output logic [63:0] key_out
);
  logic [127:0] selected_key;
  logic [3:0] barrel_ctl;
  logic [127:0] barrel0;
  logic [127:0] barrel1;
  logic [127:0] barrel2;
  logic [127:0] barrel3;

  always_comb begin
    case(shift)
      'b000: barrel_ctl = 'b0000;
      'b001: barrel_ctl = 'b1011;
      'b010: barrel_ctl = 'b1001;
      'b011: barrel_ctl = 'b0111;
      'b100: barrel_ctl = 'b0101;
      'b101: barrel_ctl = 'b1111;
      'b110: barrel_ctl = 'b1100;
      'b111: barrel_ctl = 'b0011;
    endcase

    if(word_sel[1]) begin
      selected_key = key_a;
    end else begin
      selected_key = key_l;
    end

    barrel0 = barrel_ctl[0] ? {selected_key[1:0], selected_key[127:2]} : selected_key;
    barrel1 = barrel_ctl[1] ? {selected_key[14:0], selected_key[127:15]} : selected_key;
    barrel2 = barrel_ctl[2] ? {selected_key[95:0], selected_key[127:96]} : selected_key;
    barrel3 = barrel_ctl[3] ? {selected_key[65:0], selected_key[127:66]} : selected_key;

    if(word_sel[0]) begin
      key_out = barrel3[127:64];
    end else begin
      key_out = barrel3[63:0];
    end
  end

endmodule