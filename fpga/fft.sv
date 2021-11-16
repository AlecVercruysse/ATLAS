// the width is the bit width (e.g. if width=16, 16 real and 16 im bits).
// the input should be width-5 to account for bit growth.
module fft
  #(parameter width = 16)
   (input logic  clk,
    input logic  start,
    input logic  [2*width-1] rd, // read data
    output logic [2*width-1] wd, // write data
    output logic done);

   logic         rdsel;   // read from RAM0 or RAM1
   logic         we0 we1; // RAMx write enable
   logic [10:0]  adr0a, ard0b, adr1a, adr1b;
   logic [9:0]   twiddleadr; // twiddle ROM adr
   
   agu fft_agu(clk, start, done,

endmodule // fft

// 11-bit addressing for 2048 unique values (2048-point fft).
module fft_agu
   (input logic  clk,
    input logic  start,
    output logic done,
    output logic rdsel,
    output logic we0
    output logic [10:0] adr0a,
    output logic [10:0] ard0b,
    output logic we1,
    output logic [10:0] adr1a,
    output logic [10:0] adr1b,
    output logic [9:0] twiddleadr);

endmodule // fft_agu

module fft_twiddleROM 
  #(parameter width=16)
   (input logic clk,
    input logic  [9:0] twiddleadr, // 0 - 1023 = 10 bits
    output logic [2*width-1:0] twiddle);

   // twiddle table pseudocode: w[k] = w[k-1] * w, 
   // where w[0] = 1 and w = exp(-j 2pi/N) 
   // for k=0... N/2-1

   logic [2*width-1:0]         vectors [0:1023];
   initial $readmemb("rom/twiddle.vectors", vectors);

   always @(posedge clk)
     out <= vectors[idx];
   
endmodule // fft_twiddleROM


// make sure the script rom/hann.py has been run with
// the desired width! the `width` param should be equal to `q` in the script.
module hann_lut
  #(parameter width = 16)
   (input logic              clk,
    input logic  [10:0]      idx,
    output logic [wdith-1:0] out);

   logic [width-1:0]         vectors [0:2047];
   initial $readmemb("rom/hann.vectors", vectors);

   always @(posedge clk)
     out <= vectors[idx];
   
endmodule // hann_lut

module fft_butterfly
  #(paramter width = 16)
   (input logic [2*width-1:0] twiddle,
    input logic [2*width-1:0]  a,
    input logic [2*width-1:0]  b,
    output logic [2*width-1:0] aout,
    output logic [2*width-1:0] bout);

   logic [width-1:0]           twiddle_re, twiddle_im, a_re, a_im, b_re, b_im, aout_re, aout_im, bout_re, bout_im;
   logic [width-1:0]           b_re_mult, b_im_mult;

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
   assign b_re_mult = twiddle_re * b_re;
   assign b_im_mult = twiddle_im * b_im;

   assign aout_re = a_re + b_re_mult;
   assign aout_im = a_im + b_im_mult;

   assign bout_re = a_re - b_re_mult;
   assign bout_im = a_im - b_im_mult;
   
endmodule // fft_butterfly

// adapted from HDL example 5.7 in Harris TB
module twoport_RAM
  #(parameter width = 16, size = 11)
   (input logic                clk,
    input logic                we,
    input logic [size-1:0]     adra,
    input logic [size-1:0]     adrb,
    input logic [2*width-1:0]  wda,
    input logic [2*width-1:0]  wdb,
    output logic [2*width-1:0] rda,
    output logic [2*width-1:0] rdb);

   reg [size-1:0]              mem [2*width-1:0];

   always @(posedge clk)
     if (we) 
       begin
          mem[adra] <= wda;
          mem[adrb] <= wdb;
       end

   assign rda = mem[adra];
   assign rdb = mem[adrb];
   
endmodule // twoport_RAM
