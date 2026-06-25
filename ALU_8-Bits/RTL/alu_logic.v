`timescale 1ns / 1ps


module alu_logic(a,b,op,result,zero,negative,carry,overflow);
  input [7:0]a,b;
  input [1:0]op;
  output reg [7:0]result;
  output zero,negative,carry,overflow;
  
  wire [7:0]b_eff;
  
  assign b_eff = (op[1:0] == 2'b11)?8'h00: b; 
  assign carry = 0;
  assign overflow = 0;
  assign zero = (result == 0);
  assign negative = result[7];
  
  always@(*)begin
    case(op[1:0])
      2'b00 : result = a & b_eff;
      2'b01 : result = a | b_eff;
      2'b10 : result = a ^ b_eff;
      2'b11 : result = ~a;
      default : result = 0;
    endcase
  end
endmodule
