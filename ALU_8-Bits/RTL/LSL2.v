`timescale 1ns / 1ps


module LSL2(in,sel,mode,y);
  input [7:0]in;
  input sel;
  input mode;
  output [7:0]y;
  
     mux_2_1 m2_0(.in({mode,in[0]}),.sel(sel),.y(y[0]));
     mux_2_1 m2_1(.in({mode,in[1]}),.sel(sel),.y(y[1]));
     mux_2_1 m2_2(.in({in[0],in[2]}),.sel(sel),.y(y[2]));
     mux_2_1 m2_3(.in({in[1],in[3]}),.sel(sel),.y(y[3]));
     mux_2_1 m2_4(.in({in[2],in[4]}),.sel(sel),.y(y[4]));
     mux_2_1 m2_5(.in({in[3],in[5]}),.sel(sel),.y(y[5]));
     mux_2_1 m2_6(.in({in[4],in[6]}),.sel(sel),.y(y[6]));
     mux_2_1 m2_7(.in({in[5],in[7]}),.sel(sel),.y(y[7]));
endmodule
