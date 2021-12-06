module final_fpga(input logic         clk,   // 12MHz MAX1000 clk  H6
                  input logic        nreset, // global reset
                  input logic        din, //  PCM1808 DOUT,        PB6_G12
                  input logic        uscki,
                  input logic        umosi,
                  input logic        uce, 
                  output logic       bck, //  bit clock,       PA7_J2
                  output logic       lrck, // left/right clk,  PA6_J1
                  output logic       scki, // system clock,    PA5_H4
                  output logic       fmt, //  FMT,             PA8_J10
                  output logic [1:0] md, //   MD1 & MD0,       PC7_H13, PA9_H10
                  output logic       miso,
                  output logic [7:0] LEDs // debug LEDs
                  );

   logic                             reset;
   assign reset = ~(nreset);
   assign LEDs[0] = reset;
   // active high reset, active low btns

   assign md  = 2'b00; // see PCM1808 table 2 (slave mode)
   assign fmt = 0;     // see PCM1808 table 3 (i2s mode)

   logic                              newsample;
   logic [23:0]                       left, right;
   i2s pcm_in(clk, reset, din, bck, lrck, scki, left, right, newsample);
   
   logic                              fft_start, fft_done, i2s_load, fft_load, fft_reset, fft_creset, fft_write;
   logic [31:0]                       fft_wd;
   logic signed [15:0]                left_msbs;
   logic signed [15:0]                fft_rd;
   logic [5:0]                        sample_ctr;
                       
   assign fft_reset = reset | fft_creset;

   assign left_msbs = left[23:8];
   assign fft_rd    = left_msbs >>> 5; // arithmetic shift right
   fft fft(clk, fft_reset, fft_start, fft_load, fft_rd, fft_wd, fft_done);
   fft_control i2s_fft_glue(clk, reset, newsample, fft_done, fft_start, fft_load, fft_creset, fft_write, sample_ctr);


   // store result         
   logic [31:0]                       res_count; // result count
   logic                              posedge_fft_done;
   pos_edge pos_edge_fft_done(clk, fft_done, posedge_fft_done);
   always_ff @(posedge clk)
     begin
        if       (reset)    res_count <= 0;
        else if (posedge_fft_done) res_count <= res_count + 1'b1;
     end

   logic [31:0]                       spectrum_result [0:31];
   logic [31:0]                       spectrum_result_fixed [0:31];
   always_ff @(posedge clk) begin
      if (fft_write) 
        begin
           spectrum_result[sample_ctr]       <= fft_wd;
           if (res_count == 9901 || (res_count == 9900 && posedge_fft_done)) spectrum_result_fixed[sample_ctr] <= fft_wd;
        end
   end
   // end store result

   // spi   
   logic [31:0] spi_data;
   logic [4:0] spi_adr;
   assign spi_data = spectrum_result[spi_adr];
   spi_slave spi(clk, reset, uscki, umosi, uce, spi_data, spi_adr, miso);

endmodule // final_fpga

// todo refactor state names: FFT_*
typedef enum logic [3:0] {LOADING, STARTING, WAITING, WRITING, RESETTING, ERROR} statetype;
module fft_control(input logic clk,
               input logic        reset,
               input logic        newsample,
               input logic        fft_done,
               output logic       fft_start,
               output logic       fft_load,
               output logic       fft_reset,
               output logic       fft_write,
               output logic [5:0] sample_ctr);

   statetype                   state, nextstate;
   
   always_ff @(posedge clk) begin
      if      (reset || (state == RESETTING))     sample_ctr <= 0;
      else if ((newsample && (state == LOADING)) || (state == WRITING || nextstate == WRITING)) sample_ctr <= sample_ctr + 1'b1;
      else if (state == WAITING) sample_ctr <= 0; // this case needs to be checked after the previous
                                                  // in case state is waiting but nextstate is writing.
   end

   always_ff @(posedge clk) begin
      if (reset) state <= LOADING;
      else state <= nextstate;
   end

   always_comb begin
      case (state)
        LOADING  : if (sample_ctr == 32)    nextstate = STARTING;
                   else                     nextstate = LOADING;
        STARTING :                          nextstate = WAITING;
        WAITING  : if (fft_done)            nextstate = WRITING;
                   else                     nextstate = WAITING;
        WRITING  : if (sample_ctr == 32)    nextstate = RESETTING;
                   else                     nextstate = WRITING;
        RESETTING : nextstate = LOADING;
        default  : nextstate = ERROR; // debug
      endcase // case (state)
   end

   assign fft_load = (state == LOADING) & newsample;
   assign fft_start = (state == STARTING);
   assign fft_reset = (state == RESETTING);
   assign fft_write = (state == WRITING || nextstate == WRITING);
   
endmodule // control

module i2s(input logic         clk,
           input logic         reset,
           input logic         din, // PCM1808 DOUT,         PB6_G12
           output logic        bck, // bit clock,            PA7_J2
           output logic        lrck, // left/right clk,       PA6_J1
           output logic        scki, // PCM1808 system clock, PA5_H4
           output logic [23:0] left, 
           output logic [23:0] right,
           output logic        newsample_valid);

   /////////////////// clock ////////////////////////////////////
  
   //   Fs = 46.875 KHz
   logic [8:0]                 prescaler; // 9-bit prescaler
   assign scki = clk;          // 256 * Fs = 12 MHz
   assign bck  = prescaler[1]; // 64  * Fs = 3 MHz = 12 MHz / 4
   assign lrck = prescaler[7]; // 1   * Fs = 12 Mhz / 256

   always_ff @(posedge clk)
     begin
        if (reset)
          prescaler <= 0;
        else
          prescaler <= prescaler + 9'd1;
     end   
   /////////////////// end clock ////////////////////////////////

   // left and right shift registers
   logic [23:0]                lsreg, rsreg;

   // samples the prescaler to figure out what bit should currently be sampled.
   // sampling occurs on bit 1 and bit 24, NOT bit 0!
   logic [4:0]                 bit_state;
   assign bit_state = prescaler[6:2];
   
   // shift register enable logic
   logic                       shift_en;
   assign shift_en = ((bit_state >= 1) && (bit_state <= 24) && !reset);
   
   // shift register operation. samples DOUT only when shift_en.
   // this should be the only register that is not clocked directly from clk!!
   always_ff @(posedge bck)
     begin
        if (!lrck && shift_en)     // left
          begin
             lsreg <= {lsreg[22:0], din};
             rsreg <= rsreg;
          end
        else if (lrck && shift_en) // right
          begin
             rsreg <= {rsreg[22:0], din};
             lsreg <= lsreg;
          end
     end // shift register operation 

   // load shift regs into output regs.
   // update both regs at once, once every fs.
   // this way, left and right will always contain a valid sample.
   logic newsample;
   assign newsample = (bit_state == 25 && lrck && prescaler[1:0] == 0); // once every cycle
   assign newsample_valid = (bit_state == 26 && lrck && prescaler[1:0] == 0); // once we can sample it!
   always_ff @(posedge clk)
     begin
        if (reset)
          begin
             left <= 0;
             right <= 0;
          end
        else if (newsample)
          begin
             left <= lsreg;
             right <= rsreg;
          end
        else
          begin
             left <= left;
             right <= right;
          end
     end
   
endmodule // i2s
