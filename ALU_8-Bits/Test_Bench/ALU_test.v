
`timescale 1ns / 1ps

module ALU_test;
    reg [7:0] a, b;
    reg [3:0] op;
    wire [7:0] result;
    wire carry, zero, overflow, negative;

 
    integer pass_count = 0;
    integer fail_count = 0;
    integer test_num   = 0;

    ALU m1(.a(a),.b(b),.op(op),.result(result),
           .zero(zero),.overflow(overflow),
           .negative(negative),.carry(carry));

    
    task check;
        input [7:0] exp_result;
        input       exp_carry;
        input       exp_zero;
        input       exp_neg;
        input       exp_ovf;
        begin
            test_num = test_num + 1;
            if(result   === exp_result &&
               carry    === exp_carry  &&
               zero     === exp_zero   &&
               negative === exp_neg    &&
               overflow === exp_ovf)
            begin
                pass_count = pass_count + 1;
                $display("PASS [Test %0d] op=%b a=%0d b=%0d | result=%0d",
                          test_num, op, a, b, result);
            end
            else begin
                fail_count = fail_count + 1;
                $display("FAIL [Test %0d] op=%b a=%0d b=%0d | got=%0d exp=%0d | C=%b/%b Z=%b/%b N=%b/%b V=%b/%b",
                          test_num, op, a, b,
                          result,   exp_result,
                          carry,    exp_carry,
                          zero,     exp_zero,
                          negative, exp_neg,
                          overflow, exp_ovf);
            end
        end
    endtask

    task ADD;
        begin
            op = 4'b0000;
            a = 8'd5;   b = 8'd3;   #10; check(8'd8,   0,0,0,0);
            a = 8'd100; b = 8'd200; #10; check(8'd44,  1,0,0,0);
            a = 8'd255; b = 8'd1;   #10; check(8'd0,   1,1,0,0);
            a = 8'd127; b = 8'd1;   #10; check(8'd128, 0,0,1,1);
            a = 8'd0;   b = 8'd0;   #10; check(8'd0,   0,1,0,0);
        end
    endtask

    task SUB;
        begin
            op = 4'b0001;
            a = 8'd10;  b = 8'd3;   #10; check(8'd7,   1,0,0,0);
            a = 8'd5;   b = 8'd5;   #10; check(8'd0,   1,1,0,0);
            a = 8'd3;   b = 8'd10;  #10; check(8'd249, 0,0,1,0);
            a = 8'd127; b = 8'd255; #10; check(8'd128, 0,0,1,1);
        end
    endtask

    task INC;
        begin
            op = 4'b0010;
            b = 8'd0;
            a = 8'd5;   #10; check(8'd6,   0,0,0,0);
            a = 8'd255; #10; check(8'd0,   1,1,0,0);
            a = 8'd127; #10; check(8'd128, 0,0,1,1);
        end
    endtask

    task DEC;
        begin
            op = 4'b0011;
            b = 8'd0;
            a = 8'd5;   #10; check(8'd4,   1,0,0,0);
            a = 8'd0;   #10; check(8'd255, 0,0,1,0);
            a = 8'd128; #10; check(8'd127, 1,0,0,1);
        end
    endtask

    task AND;
        begin
            op = 4'b0100;
            a = 8'h00; b = 8'h36; #10; check(8'h00, 0,1,0,0);
            a = 8'h44; b = 8'hDD; #10; check(8'h44, 0,0,0,0);
            a = 8'hD1; b = 8'h8B; #10; check(8'h81, 0,0,1,0);
            a = 8'hB9; b = 8'h8D; #10; check(8'h89, 0,0,1,0);
            a = 8'h13; b = 8'hD6; #10; check(8'h12, 0,0,0,0);
            a = 8'h6E; b = 8'hE2; #10; check(8'h62, 0,0,0,0);
        end
    endtask

    task OR;
        begin
            op = 4'b0101;
            a = 8'hFF; b = 8'h00; #10; check(8'hFF, 0,0,1,0);
            a = 8'hAA; b = 8'h55; #10; check(8'hFF, 0,0,1,0);
            a = 8'h0A; b = 8'hF0; #10; check(8'hFA, 0,0,1,0);
            a = 8'h00; b = 8'h00; #10; check(8'h00, 0,1,0,0);
            a = 8'hAA; b = 8'hAA; #10; check(8'hAA, 0,0,1,0);
        end
    endtask

    task XOR;
        begin
            op = 4'b0110;
            a = 8'hFF; b = 8'hFF; #10; check(8'h00, 0,1,0,0);
            a = 8'hFF; b = 8'h00; #10; check(8'hFF, 0,0,1,0);
            a = 8'hAA; b = 8'h55; #10; check(8'hFF, 0,0,1,0);
            a = 8'hAA; b = 8'hAA; #10; check(8'h00, 0,1,0,0);
            a = 8'h0F; b = 8'hF0; #10; check(8'hFF, 0,0,1,0);
        end
    endtask

    task NOT;
        begin
            op = 4'b0111;
            a = 8'hFF; b = 8'h00; #10; check(8'h00, 0,1,0,0);
            a = 8'h00; b = 8'hFF; #10; check(8'hFF, 0,0,1,0);
            a = 8'hAA; b = 8'h00; #10; check(8'h55, 0,0,0,0);
            a = 8'h55; b = 8'h00; #10; check(8'hAA, 0,0,1,0);
            a = 8'hF0; b = 8'h00; #10; check(8'h0F, 0,0,0,0);
        end
    endtask

    task LSL;
        begin
            op = 4'b1000;
            a = 8'b0000_0001; b = 3'd1; #10; check(8'd2,   0,0,0,0);
            a = 8'b0000_0001; b = 3'd7; #10; check(8'd128, 0,0,1,0);
            a = 8'b1111_1111; b = 3'd1; #10; check(8'd254, 0,0,1,0);
            a = 8'b1111_1111; b = 3'd4; #10; check(8'd240, 0,0,1,0);
            a = 8'b1010_1010; b = 3'd3; #10; check(8'd80,  0,0,0,0);
            a = 8'b0000_0001; b = 3'd0; #10; check(8'd1,   0,0,0,0);
            a = 8'b1111_1111; b = 3'd7; #10; check(8'd128, 0,0,1,0);
            a = 8'b1000_0000; b = 3'd1; #10; check(8'd0,   0,1,0,0);
        end
    endtask

    task LSR;
        begin
            op = 4'b1001;
            a = 8'b1000_0000; b = 3'd1; #10; check(8'd64,  0,0,0,0);
            a = 8'b1111_1111; b = 3'd4; #10; check(8'd15,  0,0,0,0);
            a = 8'b1010_1010; b = 3'd2; #10; check(8'd42,  0,0,0,0);
            a = 8'b1000_0000; b = 3'd7; #10; check(8'd1,   0,0,0,0);
            a = 8'b1111_1111; b = 3'd7; #10; check(8'd1,   0,0,0,0);
            a = 8'b0000_0001; b = 3'd1; #10; check(8'd0,   0,1,0,0);
        end
    endtask

    task ASR;
        begin
            op = 4'b1010;
            a = 8'd128; b = 3'd1; #10; check(8'd192, 0,0,1,0);
            a = 8'd255; b = 3'd4; #10; check(8'd255, 0,0,1,0);
            a = 8'd64;  b = 3'd1; #10; check(8'd32,  0,0,0,0);
            a = 8'd127; b = 3'd7; #10; check(8'd0,   0,1,0,0);
            a = 8'd170; b = 3'd2; #10; check(8'd234, 0,0,1,0);
            a = 8'd128; b = 3'd7; #10; check(8'd255, 0,0,1,0);
            a = 8'd255; b = 3'd7; #10; check(8'd255, 0,0,1,0);
        end
    endtask

    task ROR;
        begin
            op = 4'b1011;
            a = 8'b0000_0001; b = 3'd1; #10; check(8'd128, 0,0,1,0);
            a = 8'b1000_0000; b = 3'd1; #10; check(8'd64,  0,0,0,0);
            a = 8'b1111_1111; b = 3'd4; #10; check(8'd255, 0,0,1,0);
            a = 8'b1010_1010; b = 3'd2; #10; check(8'd170, 0,0,1,0);
            a = 8'b0000_0001; b = 3'd0; #10; check(8'd1,   0,0,0,0);
            a = 8'b1001_0110; b = 3'd3; #10; check(8'd210, 0,0,1,0);
            a = 8'b0000_0000; b = 3'd4; #10; check(8'd0,   0,1,0,0);
        end
    endtask

    task EQ;
        begin
            op = 4'b1100;
            a = 8'd5;   b = 8'd5;   #10; check(8'h01, 0,0,0,0);
            a = 8'd0;   b = 8'd0;   #10; check(8'h01, 0,0,0,0);
            a = 8'd255; b = 8'd255; #10; check(8'h01, 0,0,0,0);
            a = 8'd5;   b = 8'd3;   #10; check(8'h00, 0,1,0,0);
            a = 8'd0;   b = 8'd255; #10; check(8'h00, 0,1,0,0);
        end
    endtask

    task LT_U;
        begin
            op = 4'b1101;
            a = 8'd3;   b = 8'd10;  #10; check(8'h01, 0,0,0,0);
            a = 8'd10;  b = 8'd3;   #10; check(8'h00, 0,1,0,0);
            a = 8'd5;   b = 8'd5;   #10; check(8'h00, 0,1,0,0);
            a = 8'd0;   b = 8'd255; #10; check(8'h01, 0,0,0,0);
            a = 8'd200; b = 8'd100; #10; check(8'h00, 0,1,0,0); 
        end
    endtask

    task LT_S;
        begin
            op = 4'b1110;
            a = 8'd255; b = 8'd1;   #10; check(8'h01, 0,0,0,0); // -1 < +1
            a = 8'd1;   b = 8'd255; #10; check(8'h00, 0,1,0,0); // +1 > -1
            a = 8'd128; b = 8'd1;   #10; check(8'h01, 0,0,0,0); // -128 < +1
            a = 8'd127; b = 8'd1;   #10; check(8'h00, 0,1,0,0); // +127 > +1
            a = 8'd200; b = 8'd100; #10; check(8'h01, 0,0,0,0); 
        end
    endtask

    task GT_U;
        begin
            op = 4'b1111;
            a = 8'd10;  b = 8'd3;   #10; check(8'h01, 0,0,0,0);
            a = 8'd3;   b = 8'd10;  #10; check(8'h00, 0,1,0,0);
            a = 8'd5;   b = 8'd5;   #10; check(8'h00, 0,1,0,0);
            a = 8'd255; b = 8'd0;   #10; check(8'h01, 0,0,0,0);
            a = 8'd200; b = 8'd100; #10; check(8'h01, 0,0,0,0); 
        end
    endtask
  
    initial begin
        
      $display("   ALU TESTBENCH - 16 OPERATIONS     ");
      $display("   8-bit ALU Verification             ");
      
      // Arithmetic Operations - ADD, SUB, INC, DEC
      ADD();
      SUB();
      INC();
      DEC();

      // Logic Operations - AND, OR, XOR, NOT
      AND();
      OR();
      XOR();
      NOT();

      // Shift Operations - LSL, LSR, ASR, ROR
      LSL();
      LSR();
      ASR();
      ROR();

      // Compare Operations - EQ, LT_U, LT_S, GT_U
      EQ();
      LT_U();
      LT_S();
      GT_U();

      $display("TOTAL : %0d tests", test_num);
      $display("PASSED: %0d", pass_count);
      $display("FAILED: %0d", fail_count);

      $finish;
    end
endmodule
