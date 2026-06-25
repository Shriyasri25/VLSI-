`timescale 1ns / 1ps


module adder_8_bit(a,b,cin,sum,cout);
  input [7:0]a,b;
  input cin;
  output [7:0]sum;
  output cout;
  
  wire w1;
  
  adder_4_bit m1(.a(a[3:0]),.b(b[3:0]),.cin(cin),.sum(sum[3:0]),.cout(w1));
  adder_4_bit m2(.a(a[7:4]),.b(b[7:4]),.cin(w1),.sum(sum[7:4]),.cout(cout));
  
endmodule
