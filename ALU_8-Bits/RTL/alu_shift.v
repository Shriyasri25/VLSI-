`timescale 1ns / 1ps

module alu_shift(in,op,shift,result,zero,negative,carry,overflow);
  input [7:0]in;
  input [2:0]shift;
  input [1:0]op;
  output reg [7:0]result;
  output zero,negative,carry,overflow;
  
  wire [7:0]in_eff;
  reg mode;
  wire [7:0]in_rev;
  wire [7:0]y_rev;
  wire [7:0]result_out;
  wire [7:0]y_eff;
  wire [2:0]shift_rem;
  
  assign {carry,overflow} = 2'b00;
  
  assign zero = (result == 8'b0);
  assign negative = result[7];
  assign in_rev = {in[0],in[1],in[2],in[3],in[4],in[5],in[6],in[7]};
  assign y_rev = {y_eff[0],y_eff[1],y_eff[2],y_eff[3],y_eff[4],y_eff[5],y_eff[6],y_eff[7]};
  //assign result =  (op[0] == 1'b1)? y_rev : y_eff;
  
  assign in_eff = (op[1:0] == 2'b00)? in : in_rev;
  assign shift_rem = 4'd8 - shift;
  
  shift_core s1(.in(in_eff),.sel(shift),.mode(mode),.y(y_eff));
  
  shift_core s2(.in(in),.sel(shift_rem),.mode(mode),.y(result_out));
  
  always@(*)begin
    case(op[1:0])
      2'b00 : mode = 1'b0; // LSL
      2'b01 : mode = 1'b0; // LSR
      2'b10 : mode = in[7]; // ASR
      2'b11 : mode = 1'b0; // ROR
      default : mode = 1'b0;
    endcase
  end
    
  always@(*)begin
    case(op[1:0])
      2'b00 : result = y_eff;
      2'b01 : result = y_rev;
      2'b10 : result = y_rev;
      2'b11 : result = y_rev | result_out;
      default :result = 0;
    endcase
  end
  
  
endmodule
