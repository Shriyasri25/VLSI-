`timescale 1ns / 1ps


module LSL1(in,sel,mode,y);
  input [7:0]in;
  input sel;
  input mode;
  output [7:0]y;
  
   mux_2_1 m1_0(.in({mode,in[0]}),.sel(sel),.y(y[0]));
   mux_2_1 m1_1(.in({in[0],in[1]}),.sel(sel),.y(y[1]));
   mux_2_1 m1_2(.in({in[1],in[2]}),.sel(sel),.y(y[2]));
   mux_2_1 m1_3(.in({in[2],in[3]}),.sel(sel),.y(y[3]));
   mux_2_1 m1_4(.in({in[3],in[4]}),.sel(sel),.y(y[4]));
   mux_2_1 m1_5(.in({in[4],in[5]}),.sel(sel),.y(y[5]));
   mux_2_1 m1_6(.in({in[5],in[6]}),.sel(sel),.y(y[6]));
   mux_2_1 m1_7(.in({in[6],in[7]}),.sel(sel),.y(y[7]));
   
endmodule
