// the input clock is 12MHz.

module final_fpga(input logic clk,
                  input logic         reset,
                  input logic         din, // PCM1808 DOUT,         PB6_G12
                  output logic        bck, // bit clock,            PA7_J2
                  output logic        lrck, // left/right clk,       PA6_J1
                  output logic        scki, // PCM1808 system clock, PA5_H4
                  output logic [23:0] left, 
                  output logic [23:0] right
                  );

   i2s pcm_in(clk, reset, din, bck, lrck, scki, left, right);
   
endmodule // final_fpga

module i2s(input logic         clk,
           input logic         reset,
           input logic         din, // PCM1808 DOUT,         PB6_G12
           output logic        bck, // bit clock,            PA7_J2
           output logic        lrck, // left/right clk,       PA6_J1
           output logic        scki, // PCM1808 system clock, PA5_H4
           output logic [23:0] left, 
           output logic [23:0] right);

   /////////////////// clock ////////////////////////////////////
  // we sample at Fs = 46.875 KHz
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
   logic [4:0]                 bit_state;

   // logic to decide if lrck changed
   logic                       lrck_old, lrck_edge;
   assign lrck_edge = (lrck_old != lrck);
   always_ff @(negedge bck)
     lrck_old <= lrck;

   // bit counting state machine. counts from 0 to 25
   // under normal operation, resetting when lrck is
   // toggled. When it goes to 25 (disable), it holds
   // there until reset.
   // 
   // Examining i2s protocol, no data is read on the first
   // bck pulse (bit_state = 0). data is read on 1-24.
   always_ff @(negedge bck) // bit count state machine
     begin
        if (reset || lrck_edge)
          bit_state <= 0;
        else if (bit_state == 25) // disable count
          bit_state <= 25;
        else
          bit_state <= bit_state + 1;
     end

   // shift register enable logic
   logic                       shift_en;
   assign shift_en = ((bit_state >= 1) && (bit_state <= 24) && !reset);

   // shift register operation. samples DOUT only when shift_en.
   always_ff @(posedge bck)
     begin
        if (reset) 
          begin // make it nice to debug
             lsreg <= 0;
             rsreg <= 0;
          end
        else begin
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
        end
     end // shift register operation 

   // load shift regs into output regs.
   always_ff @(negedge bck)
     begin
        if (reset)
          begin
             left  <= 0;
             right <= 0;
             
          end
        else 
          begin
             left  <= lsreg;
             right <= rsreg;
          end
     end
endmodule // i2s
