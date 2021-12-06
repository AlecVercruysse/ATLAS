
// todo test!!!!!!!!!!!!!!!!
typedef enum logic [3:0] {SPI_IDLE, SPI_LOAD, SPI_WAIT, SPI_SHIFT, SPI_ERROR} spi_state;
module spi_slave(input logic        clk,
                 input logic        reset,
                 input logic        uscki, 
                 input logic        umosi,
                 input logic        uce,
                 input logic [31:0] data, // 32-bit. based on adr.
                 output logic [4:0] adr, // to address data ram
                 output logic       miso);
   
   // cpol = 0 (idle low)
   // cpha = 1 (shift on leading edge (posedge), sample on lagging edge (negedge)
   logic                      scki, mosi, ce;
   sync scki_sync(clk, uscki, scki);
   sync mosi_sync(clk, umosi, mosi);
   sync   ce_sync(clk,   uce,   ce);

   logic                      posedge_scki;
   // , negedge_scki;
   pos_edge pos_edge_scki(clk, scki, posedge_scki);
   // neg_edge neg_edge_scki(clk, scki, negedge_scki);
   
   //////////////////
   logic [31:0]               data_out;
   logic [4:0]                bit_idx;
   spi_state state, nextstate;
   
   assign miso = data_out[31]; // MSB. shifted out

   always_ff @(posedge clk) begin
      if (reset) state <= SPI_IDLE;
      else state <= nextstate;
   end

   always_comb begin
      case (state)
        SPI_IDLE : if (ce) nextstate <= SPI_LOAD;
        else    nextstate <= SPI_IDLE;
        SPI_LOAD : nextstate <= SPI_WAIT;
        SPI_WAIT : if (posedge_scki) begin 
           if (bit_idx != 31) nextstate <= SPI_SHIFT;
           else nextstate <= SPI_LOAD;
        end
        else if (~ce) nextstate <= SPI_IDLE;
        else   nextstate <= SPI_WAIT;
        SPI_SHIFT : nextstate <= SPI_WAIT;
        default : nextstate <= SPI_ERROR;
      endcase // case (state)
      end

   // adr logic
   always_ff @(posedge clk) begin
      if (state == SPI_IDLE)
        adr <= 0;
      else if (state == SPI_LOAD)
        adr <= adr + 1'b1;
   end

   // bit_idx logic
   always_ff @(posedge clk) begin
      if (state == SPI_IDLE || state == SPI_LOAD)
        bit_idx <= 0;
      else if (state == SPI_SHIFT)
        bit_idx <= bit_idx + 1'b1;
   end

   // data_out logic
   always_ff @(posedge clk) begin
      if (state == SPI_LOAD)
        data_out <= data;
      else if (state == SPI_SHIFT)
        data_out <= {data_out[30:0], 1'b0};
   end
endmodule // spi_slave
   
   // always_ff @(posedge clk) begin
   //    if (reset) begin
   //       sample_idx <= 0;
   //       bit_idx <= 0;
   //       data_out <= 0; // throw away the first 4 bytes
   //    end
   //    else if (posedge_scki && ce) begin
   //       // reset from mcu:
   //       if (data_in == 8'hff) begin
   //          sample_idx <= 0;
   //          bit_idx <= 0;
   //          data_out <= 0; 
   //       end else begin
   //          if (bit_idx == 30) begin
   //             sample_idx <= sample_idx + 1;
   //             data_out <= {data_out[30:0], 1'b0};
   //          end else if (bit_idx == 31) begin
   //             data_out <= data;
   //          end else begin
   //             data_out <= {data_out[30:0], 1'b0};
   //          end
   //          bit_idx <= bit_idx + 1'b1;
   //       end
   //    end
// 
//       if (negedge_scki && ce) begin // sample on the negative edge 
//          data_in <= {data_in[6:0], mosi};
//       end
     

module pos_edge(input logic clk,
                input logic  in,
                output logic out);

   logic                     last;
   always_ff @(posedge clk) begin
      last <= in;
   end
   assign out = (last == 0 && in == 1);

endmodule // pos_edge

module neg_edge(input logic clk,
                input logic  in,
                output logic out);

   logic                     last;
   always_ff @(posedge clk) begin
      last <= in;
   end
   assign out = (last == 1 && in == 0);

endmodule // pos_edge

module sync(input logic clk,
            input logic  in,
            output logic out);
   logic                 m1;
   always_ff @(posedge clk) begin
      m1 <= in;
      out <= m1;
   end
endmodule // sync

