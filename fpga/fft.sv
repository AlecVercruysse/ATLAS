// the width is the bit width (e.g. if width=16, 16 real and 16 im bits).
// the input should be width-5 to account for bit growth.
module fft
  #(parameter width=16, N_2=11) // N_2 is log base 2 of N (points)
   (input logic  clk,
    input logic  start,
    input logic  [2*width-1:0] rd, // read data
    output logic [2*width-1:0] wd, // write data
    output logic done);

   logic              rdsel;   // read from RAM0 or RAM1
   logic              we0, we1; // RAMx write enable
   logic [N_2 - 1:0]  adr0a, adr0b, adr1a, adr1b;
   logic [N_2 - 2:0]  twiddleadr; // twiddle ROM adr
   logic [2*width-1:0] twiddle, a, b, aout, bout, rd0a, rd0b, rd1a, rd1b;

   // TODO LOAD LOGIC!!

   fft_agu #(width, N_2) agu(clk, start, done, rdsel, we0, adr0a, adr0b, we1, adr1a, adr1b, twiddleadr);
   fft_twiddleROM #(width, N_2) twiddlerom(clk, twiddleadr, twiddle);

   twoport_RAM #(width, N_2) ram0(clk, we0, adr0a, adr0b, aout, bout, rd0a, rd0b);
   twoport_RAM #(width, N_2) ram1(clk, we1, adr1a, adr1b, aout, bout, rd1a, rd1b);
   assign a = rdsel ? rd1a : rd0a;
   assign b = rdsel ? rd1b : rd0b;

   fft_butterfly #(width) bgu(twiddle, a, b, aout, bout);

endmodule // fft

module fft_agu
  #(parameter width=16, N_2=11)
   (input logic  clk,
    input logic  start,
    output logic done,
    output logic rdsel,
    output logic we0,
    output logic [N_2-1:0] adr0a,
    output logic [N_2-1:0] ard0b,
    output logic we1,
    output logic [N_2-1:0] adr1a,
    output logic [N_2-1:0] adr1b,
    output logic [N_2-2:0] twiddleadr);

endmodule // fft_agu

module fft_twiddleROM 
  #(parameter width=16, N_2=11)
   (input logic  clk,
    input logic  [N_2-2:0] twiddleadr, // 0 - 1023 = 10 bits
    output logic [2*width-1:0] twiddle);

   // twiddle table pseudocode: w[k] = w[k-1] * w, 
   // where w[0] = 1 and w = exp(-j 2pi/N) 
   // for k=0... N/2-1

   logic [2*width-1:0]         vectors [0:2**(N_2-1)-1];
   initial $readmemb("rom/twiddle.vectors", vectors);

   always @(posedge clk)
     twiddle <= vectors[twiddleadr];
   
endmodule // fft_twiddleROM


// make sure the script rom/hann.py has been run with
// the desired width! the `width` param should be equal to `q` in the script.
module hann_lut
  #(parameter width=16, N_2=11, N=2048)
   (input logic              clk,
    input logic [N_2-1:0]    idx,
    output logic [width-1:0] out);

   logic [width-1:0]         vectors [0:N-1];
   initial $readmemb("rom/hann.vectors", vectors);

   always @(posedge clk)
     out <= vectors[idx];
   
endmodule // hann_lut

module complex_mult 
  #(parameter width=16)
  (input logic [2*width-1:0] a,
	input logic [2*width-1:0] b,
	output logic [2*width-1:0] out);
	
	logic signed [width-1:0] a_re, a_im, b_re, b_im, out_re, out_im;
	assign a_re = a[31:16]; assign a_im = a[15:0];
	assign b_re = b[31:16]; assign b_im = b[15:0];
	
	assign out_re = (a_re * b_re) - (a_im * b_im);
	assign out_im = (a_re * b_im) + (a_im * b_re);
	assign out = {out_re, out_im};
endmodule // complex_mult
	
module fft_butterfly
  #(parameter width=16)
   (input logic [2*width-1:0] twiddle,
    input logic [2*width-1:0]  a,
    input logic [2*width-1:0]  b,
    output logic [2*width-1:0] aout,
    output logic [2*width-1:0] bout);

   logic signed [width-1:0]           twiddle_re, twiddle_im, a_re, a_im, b_re, b_im, aout_re, aout_im, bout_re, bout_im;
   logic signed [width-1:0]           b_re_mult, b_im_mult;
	logic        [2*width-1:0]         b_mult;


   // expand to re and im components 
   assign twiddle_re = twiddle[2*width-1:width];
   assign twiddle_im = twiddle[width-1:0];
   assign a_re = a[2*width-1:width];
   assign a_im = a[width-1:0];
   assign b_re = b[2*width-1:width];
   assign b_im = b[width-1:0];
   assign aout = {aout_re, aout_im};
   assign bout = {bout_re, bout_im};

   // perform computation
	complex_mult #(width) twiddle_mult(b, twiddle, b_mult);
   assign b_re_mult = b_mult[31:16];
   assign b_im_mult = b_mult[15:0];

   assign aout_re = a_re + b_re_mult;
   assign aout_im = a_im + b_im_mult;

   assign bout_re = a_re - b_re_mult;
   assign bout_im = a_im - b_im_mult;
   
endmodule // fft_butterfly


// adapted from HDL example 5.7 in Harris TB
module twoport_RAM
  #(parameter width = 16, N_2 = 11)
   (input logic                clk,
    input logic                we,
    input logic [N_2-1:0]     adra,
    input logic [N_2-1:0]     adrb,
    input logic [2*width-1:0]  wda,
    input logic [2*width-1:0]  wdb,
    output logic [2*width-1:0] rda,
    output logic [2*width-1:0] rdb);

   reg [2*width-1:0]              mem [2**N_2-1:0];

   always @(posedge clk)
     if (we) 
       begin
          mem[adra] <= wda;
          mem[adrb] <= wdb;
       end

   assign rda = mem[adra];
   assign rdb = mem[adrb];
   
endmodule // twoport_RAM
