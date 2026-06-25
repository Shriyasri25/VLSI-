`timescale 1ns / 1ps

module adder(a,b,cin,sum,cout);
  input a,b;
  input cin;
  output sum;
  output cout;
  
  assign sum = a ^ b ^ cin;
  assign cout = a & b | cin & (a ^ b);
  
  
endmodule
