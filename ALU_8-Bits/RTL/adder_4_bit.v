`timescale 1ns / 1ps


module adder_4_bit(a,b,cin,sum,cout);
    input [3:0]a,b;
    input cin;
    output [3:0]sum;
    output cout;
    
    wire [2:0]w;
    
    adder a1 (.a(a[0]),.b(b[0]),.cin(cin),.sum(sum[0]),.cout(w[0]));
    adder a2 (.a(a[1]),.b(b[1]),.cin(w[0]),.sum(sum[1]),.cout(w[1]));
    adder a3 (.a(a[2]),.b(b[2]),.cin(w[1]),.sum(sum[2]),.cout(w[2]));
    adder a4 (.a(a[3]),.b(b[3]),.cin(w[2]),.sum(sum[3]),.cout(cout));
    
endmodule
