
// the width is the bit width (e.g. if width=16, 16 real and 16 im bits).
// the input should be width-5 to account for bit growth.
module fft
  #(parameter width = 16)
   (input logic  clk,
    input logic  start,
    output logic done);
   
   
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
    output logic twiddleadr);
   // TODO: twiddle adr size? 

endmodule // fft_agu

module fft_twiddleROM(input logic clk,
                      input logic  twiddleadr,
                      output logic twiddle_re
                      output logic twiddle_im);


endmodule // fft_twiddleROM

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
