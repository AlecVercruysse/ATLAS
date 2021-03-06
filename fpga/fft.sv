

// the width is the bit width (e.g. if width=16, 16 real and 16 im bits).
// the input should be width-5 to account for bit growth.
module fft
  #(parameter width=16, N_2=5, hann=0) // N_2 is log base 2 of N (points)
   (input logic                clk,
    input logic                reset,
    input logic                start,
    input logic                load,
    input logic [width-1:0]    rd, // real    read data in
    output logic [2*width-1:0] wd, // complex write data out
    output logic               done);

   logic                       enable;  // for AGU operation
   logic                       rdsel;   // read from RAM0 or RAM1
   logic                       we0_agu, we0, we1; // RAMx write enable
   logic [N_2 - 1:0]           adr0a_agu, adr0b_agu, adr0a, adr0b, adr0a_load, adr0b_load, adr0a_load_agu, adr1a, adr1b, adr1a_agu;
   logic [N_2 - 2:0]           twiddleadr; // twiddle ROM adr
   logic [2*width-1:0]         twiddle, a, b, writea, writeb, aout, bout, rd0a, rd0b, rd1a, rd1b, val_in;

   // LOAD LOGIC
   fft_load #(width, N_2, hann) loader(clk, reset, load, rd, adr0a_load, adr0b_load, val_in);
   assign adr0a_load_agu = load ? adr0a_load : adr0a_agu;
   assign adr0b = load ? adr0b_load : adr0b_agu;
   assign writea = load ? val_in : aout;
   assign writeb = load ? val_in : bout;
   assign we0    = load ?   1'b1 : we0_agu;

   // AGU ENABLE LOGIC
   always_ff @(posedge clk)
     begin
	if      (start) enable <= 1;
	else if (done || reset)  enable <= 0;
     end

   // OUTPUT LOGIC
   logic [N_2-1:0] out_idx;
   assign wd    = N_2[0] ? rd1a : rd1b; // ram holding results depends on even-ness of log2(N-points)s?
   assign adr0a = done ? out_idx : adr0a_load_agu;
   assign adr1a = done ? out_idx : adr1a_agu;

   always_ff @(posedge clk)
     begin
	if      (reset) out_idx <= 0;
	else if (done)  out_idx <= out_idx + 1'b1;
     end

   fft_agu #(width, N_2) agu(clk, enable, reset, done, rdsel, we0_agu, adr0a_agu, adr0b_agu, we1, adr1a_agu, adr1b, twiddleadr);
   fft_twiddleROM #(width, N_2) twiddlerom(twiddleadr, twiddle);

   twoport_RAM #(width, N_2) ram0(clk, we0, adr0a, adr0b, writea, writeb, rd0a, rd0b);
   twoport_RAM #(width, N_2) ram1(clk, we1, adr1a, adr1b,   aout,   bout, rd1a, rd1b);
   assign a = rdsel ? rd1a : rd0a;
   assign b = rdsel ? rd1b : rd0b;

   fft_butterfly #(width) bgu(twiddle, a, b, aout, bout);

endmodule // fft

module fft_load
  #(parameter width=16, N_2=5, hann=0) // hann: bool, whether or not to window.
   (input logic clk,
    input logic                reset,
    input logic                load,
    input logic [width-1:0]    rd,
    output logic [N_2-1:0]     adr0a_load,
    output logic [N_2-1:0]     adr0b_load,
    output logic [2*width-1:0] val_in);

   logic [N_2-1:0]             idx;
   logic [width-1:0]           val_in_re;

   bit_reverse #(N_2) reverseaddr(idx, adr0a_load);
   assign adr0b_load = adr0a_load;

   always_ff @(posedge clk)
     begin
	if (reset) begin
	   idx <= 0;
	end else if (load) begin
	   idx <= idx + 1'b1;
	end
     end

   logic        [2*width-1:0] untruncated_mult;
   logic signed [width-1:0]   hann_coeff;
   hann_lut #(width, N_2) hann_rom(clk, idx, hann_coeff);
   assign untruncated_mult = hann_coeff * rd;
   assign val_in_re = hann ? untruncated_mult[2*width-2:width-1] : rd;
   assign val_in    = {val_in_re, 16'b0}; // imaginary is all zeros!

endmodule // fft_load

module bit_reverse
  #(parameter N_2=5)
   (input logic [N_2-1:0] in,
    output logic [N_2-1:0] out);

   genvar                  i;
   generate
      for(i=0; i<N_2; i=i+1) begin : BIT_REVERSE
	 assign out[i] = in[N_2-i-1];
      end
   endgenerate

endmodule // bit_reverse

// 32-point FFT address generation unit
module fft_agu
  #(parameter width=16, N_2=5)
   (input logic            clk,
    input logic            enable,
    input logic            reset,
    output logic           done,
    output logic           rdsel,
    output logic           we0,
    output logic [N_2-1:0] adr0a,
    output logic [N_2-1:0] adr0b,
    output logic           we1,
    output logic [N_2-1:0] adr1a,
    output logic [N_2-1:0] adr1b,
    output logic [N_2-2:0] twiddleadr);

   logic [N_2-1:0]         fftLevel = 0;
   logic [N_2-1:0]         flyInd = 0;

   logic [N_2-1:0]         adrA;
   logic [N_2-1:0]         adrB;

   always_ff @(posedge clk) begin
      if (reset) begin
         fftLevel <= 0;
         flyInd <= 0;
      end
      // Increment fftLevel and flyInd
      else if(enable === 1 & ~done) begin
         if(flyInd < 2**(N_2 - 1) - 1) begin
            flyInd <= flyInd + 1'd1;
         end else begin
            flyInd <= 0;
            fftLevel <= fftLevel + 1'd1;
         end
      end
   end

   // sets done when we are finished with the fft
   assign done = (fftLevel == (N_2));
   calcAddr #(width, N_2) adrCalc(fftLevel, flyInd, adrA, adrB, twiddleadr);

   assign adr0a = adrA;
   assign adr1a = adrA;

   assign adr0b = adrB;
   assign adr1b = adrB;

   // flips every cycle
   assign we0 = fftLevel[0] & enable;
   assign we1 = ~fftLevel[0] & enable;

   // flips every cycle
   assign rdsel = fftLevel[0];

endmodule // fft_agu

// todo: parameterize for more than 32-point FFT.
module calcAddr
  #(parameter width=16, N_2=5)
   (input logic  [N_2-1:0]    fftLevel,
    input logic [N_2-1:0]  flyInd,
    output logic [N_2-1:0] adrA,
    output logic [N_2-1:0] adrB,
    output logic [N_2-2:0] twiddleadr);

   logic [N_2-1:0]         tempA;
   logic [N_2-1:0]         tempB;

   always_comb begin
      tempA = flyInd << 1'd1;
      tempB = tempA +  1'd1;
      adrA = ((tempA << fftLevel) | (tempA >> (N_2 - fftLevel))) & 5'h1f;

      adrB = ((tempB << fftLevel) | (tempB >> (N_2 - fftLevel))) & 5'h1f;
      twiddleadr = ((32'hffff_fff0 >> fftLevel) & 32'hf) & flyInd;
   end
endmodule // calcAddr

module fft_twiddleROM
  #(parameter width=16, N_2=5)
   (input logic  [N_2-2:0] twiddleadr, // 0 - 1023 = 10 bits
    output logic [2*width-1:0] twiddle);

   // twiddle table pseudocode: w[k] = w[k-1] * w,
   // where w[0] = 1 and w = exp(-j 2pi/N)
   // for k=0... N/2-1

   logic [2*width-1:0]         vectors [0:2**(N_2-1)-1];
   initial $readmemb("rom/twiddle.vectors", vectors);
   assign twiddle = vectors[twiddleadr];

endmodule // fft_twiddleROM


// make sure the script rom/hann.py has been run with
// the desired width! the `width` param should be equal to `q` in the script.
// todo: test hann windowing (does the read need to be clocked)?
module hann_lut
  #(parameter width=16, N_2=5)
   (input logic              clk,
    input logic [N_2-1:0]    idx,
    output logic [width-1:0] out);

   logic [width-1:0]         vectors[2**N_2-1:0];
   initial $readmemb("rom/hann.vectors", vectors);

   always @(posedge clk)
     out <= vectors[idx];

endmodule // hann_lut


// explicit so that it is inferred, and we control
// the truncation of the output.
module mult
  #(parameter width=16)
   (input logic signed [width-1:0]  a,
    input logic signed [width-1:0]  b,
    output logic signed [width-1:0] out);

   logic [2*width-1:0]              untruncated_out;

   assign untruncated_out = a * b;
   assign out = untruncated_out[30:15];
   // see slade paper. this works as long as we're not
   // multiplying two maximum mag. negative numbers.

endmodule // mult


module complex_mult
  #(parameter width=16)
   (input logic [2*width-1:0]  a,
    input logic [2*width-1:0]  b,
    output logic [2*width-1:0] out);

   logic signed [width-1:0]    a_re, a_im, b_re, b_im, out_re, out_im;
   assign a_re = a[31:16]; assign a_im = a[15:0];
   assign b_re = b[31:16]; assign b_im = b[15:0];

   logic signed [width-1:0]    a_re_be_re, a_im_b_im, a_re_b_im, a_im_b_re;
   mult #(width) m1 (a_re, b_re, a_re_be_re);
   mult #(width) m2 (a_im, b_im, a_im_b_im);
   mult #(width) m3 (a_re, b_im, a_re_b_im);
   mult #(width) m4 (a_im, b_re, a_im_b_re);

   assign out_re = (a_re_be_re) - (a_im_b_im);
   assign out_im = (a_re_b_im) + (a_im_b_re);
   assign out = {out_re, out_im};
endmodule // complex_mult

module fft_butterfly
  #(parameter width=16)
   (input logic [2*width-1:0] twiddle,
    input logic [2*width-1:0]  a,
    input logic [2*width-1:0]  b,
    output logic [2*width-1:0] aout,
    output logic [2*width-1:0] bout);

   logic signed [width-1:0]    a_re, a_im, aout_re, aout_im, bout_re, bout_im;
   logic signed [width-1:0]    b_re_mult, b_im_mult;
   logic [2*width-1:0]         b_mult;


   // expand to re and im components
   assign a_re = a[2*width-1:width];
   assign a_im = a[width-1:0];
   
   // perform computation
   complex_mult #(width) twiddle_mult(b, twiddle, b_mult);
   assign b_re_mult = b_mult[31:16];
   assign b_im_mult = b_mult[15:0];

   assign aout_re = a_re + b_re_mult;
   assign aout_im = a_im + b_im_mult;

   assign bout_re = a_re - b_re_mult;
   assign bout_im = a_im - b_im_mult;

   // pack re and im outputs
   assign aout = {aout_re, aout_im};
   assign bout = {bout_re, bout_im};
   
endmodule // fft_butterfly


// adapted from HDL example 5.7 in Harris TB
module twoport_RAM
  #(parameter width=16, N_2=5)
   (input logic                clk,
    input logic                we,
    input logic [N_2-1:0]      adra,
    input logic [N_2-1:0]      adrb,
    input logic [2*width-1:0]  wda,
    input logic [2*width-1:0]  wdb,
    output logic [2*width-1:0] rda,
    output logic [2*width-1:0] rdb);

   reg [2*width-1:0]           mem [2**N_2-1:0];

   always @(posedge clk)
     if (we)
       begin
          mem[adra] <= wda;
          mem[adrb] <= wdb;
       end

   assign rda = mem[adra];
   assign rdb = mem[adrb];

endmodule // twoport_RAM

module complex_mag
  #(parameter width=16)
   (input logic [2*width-1:0]  a,
    output logic [2*width-1:0] out);
   
   logic [2*width-1:0]         b;
   logic signed [width-1:0]    b_re, b_im;
   
   assign b_re = a[31:16]; 
   assign b_im = -a[15:0];
   assign b = {b_re, b_im};

   complex_mult mag_mult(a, b, out);
   
endmodule // magnitude
