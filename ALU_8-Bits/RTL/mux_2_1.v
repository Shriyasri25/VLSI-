`timescale 1ns / 1ps


module mux_2_1(in,sel,y);
   input [1:0]in;
   input sel;
   output y;
   
   assign y = (sel == 1'b1)? in[1] : in[0]; 
endmodule

/*
module mux_2_1(in,sel,y);
  input [1:0]in;
  input sel;
  output reg y;
  
  always@(*)begin 
    if(sel)
      y = in[1];
    else
      y = in[0];
  end
endmodule
*/