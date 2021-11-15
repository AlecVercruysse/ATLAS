module final_fpga(input logic         clk,   // 12MHz MAX1000 clk    H6
                  input logic         reset, // global reset         PB10_K12
                  input logic         din, //  PCM1808 DOUT,         PB6_G12
                  output logic        bck, //  bit clock,            PA7_J2
                  output logic        lrck, // left/right clk,       PA6_J1
                  output logic        scki, // system clock,         PA5_H4
                  output logic        fmt, //  FMT,                  PA8_J10
                  output logic [1:0]  md, //   MD1 & MD0,            PC7_H13, PA9_H10
                  output logic [23:0] left, 
                  output logic [23:0] right
                  );

   assign md  = 2'b00; // see PCM1808 table 2 (slave mode)
   assign fmt = 0;     // see PCM1808 table 3 (i2s mode)

   logic                              newsample;
   i2s pcm_in(clk, reset, din, bck, lrck, scki, left, right, newsample);
   
endmodule // final_fpga

module i2s(input logic         clk,
           input logic         reset,
           input logic         din, // PCM1808 DOUT,         PB6_G12
           output logic        bck, // bit clock,            PA7_J2
           output logic        lrck, // left/right clk,       PA6_J1
           output logic        scki, // PCM1808 system clock, PA5_H4
           output logic [23:0] left, 
           output logic [23:0] right,
           output logic        newsample);

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
          prescaler <= prescaler + 1;
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
   assign newsample = (bit_state == 25 && lrck && prescaler[1:0] == 0); // once every cycle
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
