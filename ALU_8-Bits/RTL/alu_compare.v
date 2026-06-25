`timescale 1ns / 1ps

module alu_compare(a,b,op,result,zero,negative,carry,overflow);
   input [7:0]a,b;
   input [1:0]op;
   output reg [7:0]result;
   output zero,overflow,negative,carry;
   
   wire [7:0] sub_result;
   wire sub_carry, sub_zero, sub_negative, sub_overflow;
   
   // comparison results
   wire eq, lt_u, lt_s, gt_u;
   alu_addsub s1(.a(a),.b(b),.op(2'b01),.result(sub_result),.zero(sub_zero),.negative(sub_negative),.carry(sub_carry),.overflow(sub_overflow));
   
   assign eq = (sub_zero);
   assign lt_u = ~sub_carry;
   assign lt_s = sub_overflow ^ sub_negative;
   assign gt_u = sub_carry & ~sub_zero;
   
   always@(*)begin
     case(op[1:0])
       2'b00 : result = (eq == 1'b1)? 8'h01: 8'h00;
       2'b01 : result = (lt_u == 1'b1)? 8'h01: 8'h00;
       2'b10 : result = (lt_s == 1'b1)? 8'h01: 8'h00;
       2'b11 : result = (gt_u == 1'b1)? 8'h01: 8'h00;
       default : result = 8'h00;
     endcase
   end
   
   assign zero     = (result == 8'h00);
   assign negative = 1'b0;
   assign carry    = 1'b0;
   assign overflow = 1'b0;
   
endmodule
