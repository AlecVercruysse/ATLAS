module i2s_testbench();
   logic clk, reset, din, bck, lrck, scki;
   logic [23:0] left, right;
   logic [8:0]  i;
   
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


// untested
module twiddlerom_testbench #(parameter width=16, N_2=11)();
   logic clk;
   logic [N_2-2:0] twiddleadr;
   logic [2*width-1:0] twiddle;

   // clk. if ns scale, then we're running @ 11.9 MHz
   initial 
     forever begin
        clk = 1'b0; #5;
        clk = 1'b1; #5;
   end

   initial begin
      twiddleadr = 0;
   end

   always @(posedge clk) begin
      twiddleadr = twiddleadr + 1'b1;

   fft_twiddleROM #(width, N_2) dut(clk, twiddleadr, twiddle);

endmodule // twiddlerom_testbench


// untested
module hannrom_testbench #(parameter width=16, N_2=11)();
   logic clk;
   logic [N_2-1:0] idx;
   logic [width-1:0] out;

   // clk. if ns scale, then we're running @ 11.9 MHz
   initial 
     forever begin
        clk = 1'b0; #5;
        clk = 1'b1; #5;
   end

   initial begin
      idx = 0;
   end

   always @(posedge clk) begin
      idx =idx + 1'b1;


   hann_lut dut(clk, idx, out);

endmodule // twiddlerom_testbench
