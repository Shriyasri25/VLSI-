`timescale 1ns / 1ps

module shift_core(in,sel,mode,y);
  input [7:0]in;
  input [2:0]sel;
  input mode;
  output [7:0]y;
  
  wire [7:0]w1;
  wire [7:0]w2;
  
  LSL1 l1(.in(in),.sel(sel[0]),.mode(mode),.y(w1));
  LSL2 l2(.in(w1),.sel(sel[1]),.mode(mode),.y(w2));
  LSL3 l3(.in(w2),.sel(sel[2]),.mode(mode),.y(y));
 
  
endmodule
