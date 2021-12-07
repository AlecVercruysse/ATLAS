
typedef enum logic [1:0] {BEAT_LOAD, BEAT_EVAL, BEAT_RESET, BEAT_ERROR} beat_load_state;
module beat_track
  #(parameter wait_samples=30)
   (input logic        clk,
    input logic        reset,
    input logic [5:0]  sample_ctr,
    input logic [31:0] data,
    input logic        fft_write,
    input logic        fft_done,
    input logic [7:0]  thresh,
    output logic       beat_out,
    output logic [7:0] debug);

   ///////////////////////////////// load control
   beat_load_state             state, nextstate;
   always_ff @(posedge clk) begin
      if (reset) state <= BEAT_RESET;
      else       state <= nextstate;
   end

   always_comb
     case (state)
       BEAT_LOAD  : 
         if (~fft_write)  nextstate = BEAT_EVAL;
         else             nextstate = BEAT_LOAD;
       BEAT_EVAL  :       nextstate = BEAT_RESET;
       BEAT_RESET :       
         if (fft_write)   nextstate = BEAT_LOAD;
         else             nextstate = BEAT_RESET;
       BEAT_ERROR :       nextstate = BEAT_ERROR;
       default    :       nextstate = BEAT_ERROR;
     endcase // case (state)
   ///////////////////////////////// end load control

   ///////////////////////////////// accumulator
   logic [31:0]                data_mag;
   logic signed [31:0]         accum, accum_stable;
   logic signed [15:0]         mag_real;

   assign debug = accum_stable[7:0];
   
   assign mag_real = data_mag[31:16];
   complex_mag magnitude(data, data_mag);
   
   // todo: potential error if we were to try to accumulate
   //       the first fft output sample (since we need
   //       the state to be out of BEAT_RESET to accum.)
   always_ff @(posedge clk) begin
      if (reset || (state == BEAT_RESET))
        begin
           accum <= 0;
           // accum_stable <= 0; // debug, easier not to reset
        end
      // choose bins 10..16 (see sim .ipynb)
      else if ((sample_ctr >= 10) && (sample_ctr <= 16) && fft_write) 
        begin
           accum <= accum + mag_real;
        end
      if (state == BEAT_EVAL)
        accum_stable <= accum;
   end
   ///////////////////////////////// end accumulator

   ///////////////////////////////// beat filter
   logic [31:0]                wait_ctr;
   logic                       over;

   // translate python code. TODO should this be a state machine?
   // it's kind of gross!
   always_ff @(posedge clk) begin
      if (reset) begin
         wait_ctr <= wait_samples + 1'b1;
         over <= 0;
      end
      else if (state == BEAT_EVAL) begin
         if (accum > thresh) begin // threshold met
            wait_ctr <= 0;
            over <= 1;
         end else begin            // threshold not met
            if (wait_ctr > wait_samples) begin
               over <= 0;
               wait_ctr <= wait_ctr;
            end else begin
               wait_ctr <= wait_ctr + 1'b1;
               over <= over;
            end
         end
      end // if (state == BEAT_EVAL)
   end // always_ff @ (posedge clk)

   always_ff @(posedge clk) begin
      if (state == BEAT_EVAL) begin
         if ((accum > thresh) && ~over && (wait_ctr > wait_samples))
           beat_out <= 1;
         else
           beat_out <= 0;
      end
   end
   ///////////////////////////////// end beat filter
   
   
endmodule // beat_track
