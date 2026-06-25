
`timescale 1ns / 1ps

module ALU(a,b,op,result,zero,negative,overflow,carry);
  input [7:0]a;
  input [7:0]b;
  input [3:0]op;
  output reg [7:0]result;
  output reg zero,overflow,negative,carry;
  
  wire [7:0]arith_result;
  wire arith_zero,arith_overflow,arith_carry,arith_negative;
  
  wire [7:0]logic_result;
  wire logic_zero,logic_overflow,logic_carry,logic_negative;
  
  wire [7:0]shift_result;
  wire shift_zero,shift_overflow,shift_carry,shift_negative;
  
  wire [7:0]compare_result;
  wire compare_zero,compare_overflow,compare_carry,compare_negative;
  
  alu_addsub u1(.a(a),.b(b),.op(op[1:0]),.result(arith_result),.overflow(arith_overflow),.negative(arith_negative),.carry(arith_carry),.zero(arith_zero));
  
  alu_logic u2(.a(a),.b(b),.op(op[1:0]),.result(logic_result),.overflow(logic_overflow),.negative(logic_negative),.carry(logic_carry),.zero(logic_zero));
  
  alu_shift u3(.in(a),.op(op[1:0]),.shift(b[2:0]),.result(shift_result),.overflow(shift_overflow),.negative(shift_negative),.carry(shift_carry),.zero(shift_zero));
  
  alu_compare u4(.a(a),.b(b),.op(op[1:0]),.result(compare_result),.overflow(compare_overflow),.negative(compare_negative),.carry(compare_carry),.zero(compare_zero));
  
  always@(*)begin
    case(op[3:2])
          2'b00: begin
              result   = arith_result;
              zero     = arith_zero;
              negative = arith_negative;
              carry    = arith_carry;
              overflow = arith_overflow;
          end
          2'b01: begin
              result   = logic_result;
              zero     = logic_zero;
              negative = logic_negative;
              carry    = logic_carry;
              overflow = logic_overflow;
          end
          2'b10: begin
              result   = shift_result;
              zero     = shift_zero;
              negative = shift_negative;
              carry    = shift_carry;
              overflow = shift_overflow;
          end
          2'b11: begin
              result   = compare_result;
              zero     = compare_zero;
              negative = compare_negative;
              carry    = compare_carry;
              overflow = compare_overflow;
          end
          default: begin
              result   = 8'h00;
              zero     = 1'b0;
              negative = 1'b0;
              carry    = 1'b0;
              overflow = 1'b0;
          end
      endcase
  end
endmodule
