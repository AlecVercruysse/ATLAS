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


// requires manually checking! compare to values in file.
// need to copy the rom/ dir into the simulation/modelsim/ dir
module hannrom_testbench #(parameter width=16, N_2=5)();
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
      idx =idx+1'b1;
   end

   hann_lut dut(clk, idx, out);

endmodule // twiddlerom_testbench

// untested!! (new bgu implementation)
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
     
      twiddle = {16'h7FFF, 16'b0}; #10; assert(aout===0 && bout===0) else $error("case 2 failed.");
      b = {16'h7FFF, 16'b0}; #10; assert(aout==={16'h7FFE,16'b0} && bout==={16'h8002, 16'b0}) else $error("case 3 failed.");
      
      // real test case:
      // real b*w out: 0xEE59 (-4520). im b*w out: 0x58C2 (22722).
      // aout: 141 + j27382. bout:  9179 - j18062.
      twiddle = {16'h471C, 16'h6A6C}; a={16'h1234, 16'h1234}; b={16'h3FFF, 16'h3FFF}; #10;
      assert(aout==={16'h008C, 16'h6AF6} && bout==={16'h23DC, 16'hB972}) else $error("case 4 failed!");
      
      $display("BGU tests complete.");
   end

   fft_butterfly dut(twiddle, a, b, aout, bout);

endmodule // twiddlerom_testbench

// verify that RAM works, and is fully two-port.
// tested.
module ram_testbench #(parameter width=16, N_2=5)();
   logic clk;
   initial 
     forever begin
        clk = 1'b0; #5;
        clk = 1'b1; #5;
     end
   
   logic               we;
   logic [N_2-1:0]     adra;
   logic [N_2-1:0]     adrb;
   logic [2*width-1:0] wda;
   logic [2*width-1:0] wdb;
   logic [2*width-1:0] rda;
   logic [2*width-1:0] rdb;
   
   twoport_RAM #(width, N_2) dut(clk, we, adra, adrb, wda, wdb, rda, rdb);
   
   initial begin
      we = 0; adra = 0; adrb = 0; wda = 0; wdb = 0; rda = 0; rdb = 0; #10
	adra = 10; adrb = 12; wda = 10; wdb = 12; we = 1; #10;
      we = 0; #20; adra = 12; adrb = 10; #10; assert(rda === 12 && rdb === 10) else $error("ram test failed.");
   end

endmodule // ram_testbench
