`timescale 1ns / 1ps

module alu_addsub(a,b,op,result,carry,zero,overflow,negative);
  input [7:0]a,b;
  input [1:0]op;
  output [7:0]result;
  output carry,zero,negative,overflow;
  
  reg cin;
  reg [7:0]b_eff;
  
  assign zero = (result == 0);
  assign negative = (result[7] == 1'b1);
  assign overflow = (a[7] == b_eff[7]) && (result[7] != a[7]);
  
  always@(*)begin
    case(op[1:0])
      2'b00 : begin
               b_eff = b;
               cin = 1'b0;
            end
      2'b01 : begin
               b_eff = ~b;
               cin = 1'b1;
             end
      2'b10 : begin
                b_eff = 0;
                cin = 1'b1;
             end
      2'b11 : begin
                b_eff = 8'hFF;
                cin = 0;
             end
      default :begin b_eff = 0; cin = 0; end
      endcase
  end
  
  adder_8_bit addsub(.a(a),.b(b_eff),.cin(cin),.sum(result),.cout(carry));
  
  
endmodule
