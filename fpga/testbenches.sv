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

/**
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

**/
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

// tested
module bgu_testbench #(parameter width=16)();
   logic clk;
   logic [2*width-1:0] twiddle;
   logic [2*width-1:0] a;
   logic [2*width-1:0] b;
   logic [2*width-1:0] aout;
   logic [2*width-1:0] bout;

   initial 
     forever begin
        clk = 1'b0; #5;
        clk = 1'b1; #5;
   end

   initial begin
		twiddle = 0;
		a = 0;
		b = 0;
		aout = 0;
		bout = 0; #10;
		assert (aout===0 && bout===0) else $error("case 1 failed.");
		
		twiddle = {16'b1, 16'b0}; #10; assert(aout===0 && bout===0) else $error("case 2 failed.");
		b = {16'b1, 16'b0}; #10; assert(aout==={16'b1,16'b0} && bout==={16'hFFFF, 16'b0}) else $error("case 3 failed.");
		
		// real test case: (truncated imag bout!)
		twiddle = {16'h0012, 16'h0012}; a={16'hF00F, 16'hF00F}; b={16'h0101, 16'h0101}; #10;
		assert(aout==={16'hF00F, 16'h1433} && bout==={16'hF00F, 16'hCBEB}) else $error("case 4 failed!");
   end

   fft_butterfly dut(twiddle, a, b, aout, bout);

endmodule // twiddlerom_testbench

