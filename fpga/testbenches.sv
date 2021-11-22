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

// verify that agu works. UNSTESTED.
// Requires manually viewing waveforms
// Unsure of exactly what the correct waveforms will look like
module agu_testbench #(parameter width=16, N_2=5)();

  // inputs
	logic clk;
	initial
     forever begin
        clk = 1'b0; #5;
        clk = 1'b1; #5;
   end
   logic  start;

   // outputs
   logic done;
   logic rdsel;
   logic we0;
   logic [N_2-1:0] adr0a;
   logic [N_2-1:0] adr0b;
   logic we1;
   logic [N_2-1:0] adr1a;
   logic [N_2-1:0] adr1b;
   logic [N_2-2:0] twiddleadr;

	fft_agu #(width, N_2) agu(clk, start, done, rdsel, we0, adr0a, adr0b, we1, adr1a, adr1b, twiddleadr);

	initial begin
    // init inputs and outputs to zero/default
		start = 0; done = 0; rdsel = 0; we0 = 0; adr0a = 0; adr0b = 0; we1 = 0; adr1a = 0; adr1b = 0; twiddleadr = 0; #10;

    // init inputs to starting values.
		start = 1; #10;
	end

endmodule // agu_testbench

module slade_fft_testbench();
	logic clk;
	logic start, load, done, reset;
	logic signed [15:0] rd, expected_re, expected_im, wd_re, wd_im;
	logic [31:0] wd;
	logic [31:0] idx, out_idx, expected;
	
	logic [15:0]   input_data [0:31];
	logic [31:0] expected_out [0:31];
	
	fft #(16, 5, 0) dut(clk, reset, start, load, rd, wd, done); // no hann!!
		
	// clk
	always
		begin
			clk = 1; #5; clk=0; #5;
		end
		
	// start of test
	initial
		begin
			$readmemh("rom/slade_test_in.memh", input_data);
			$readmemh("rom/slade_test_out.memh", expected_out);
			idx=0; reset=1; #40; reset=0;
		end	
		
	always @(posedge clk)
		if (~reset) idx <= idx + 1;
		else idx <= idx;
		
	always @(posedge clk)
		if (load) out_idx <= 0;
		else if (done) out_idx <= out_idx + 1;
		
	// load/start logic
	assign load =  idx < 32;
	assign start = idx === 40;
	assign rd = load ? input_data[idx[4:0]] : 0;
	assign expected = expected_out[out_idx[4:0]];
	assign expected_re = expected[31:16];
	assign expected_im = expected[15:0];
	assign wd_re = wd[31:16];
	assign wd_im = wd[15:0];
	
	always @(posedge clk)
		if (done) begin
		   if (out_idx <= 31) begin
				if (wd !== expected) begin
				$display("Error @ out_idx %d: expected %b (got %b)    expected: %d+j%d, got %d+j%d", out_idx, expected, wd, expected_re, expected_im, wd_re, wd_im);
				end
			end else begin 
				$display("Slade FFT test complete.");
				$finish;
			end
		end
endmodule // fft_testbench