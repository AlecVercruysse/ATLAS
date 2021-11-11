module i2s_testbench();
   logic clk, reset, din, bck, lrck, scki;
   logic [23:0] left, right;
   logic [8:0]  i;
   
   // clk. if ns scale, then we're running @ 11.9 MHz
   initial 
     forever begin
        clk = 1'b0; #5;
        clk = 1'b1; #5;
   end

   initial begin
      reset = 1'b1;
      i = 0;
   end
   
   i2s dut(clk, reset, din, bck, lrck, scki, left, right);

   always @(posedge clk) begin
      if (i == 10)
        reset = 0;
      i = i + 1;
   end
   
endmodule // i2s_testbench

