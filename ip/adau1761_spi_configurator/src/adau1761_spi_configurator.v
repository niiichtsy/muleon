module adau1761_spi_configurator (
    output wire sclk,
    output reg sdo,
    output reg cs,
    output reg [39:0] read_value,
    input [15:0] address,
    input [7:0] write_value,
    input write,
    input read,
    input init,
    input sdi,
    input clk,
    input resetn
);

  // States
  localparam IDLE = 0;
  localparam INIT_SPI = 1;
  localparam INIT_REG = 2;
  localparam WRITE = 3;
  localparam READ = 4;

  //Regs
  reg [31:0] sdo_reg;
  reg [7:0] spi_transaction_counter;
  reg [7:0] reg_sequence;
  reg [3:0] state;
  reg [1:0] spi_init_counter;
  reg transaction_done;
  reg reg_init_done;

  assign sclk = clk;

  always @(posedge clk) begin
    if (!resetn) begin
      sdo <= 'h00;
      sdo_reg <= 32'h00;
      cs <= 'b1;
      spi_init_counter <= 'h00;
      spi_transaction_counter <= 'h00;
      transaction_done <= 1'b0;
      state <= IDLE;  // By default, go straight to init stage
      reg_sequence <= 'h00;
      reg_init_done <= 1'b0;
    end else begin

      case (state)

        IDLE: begin
          if (write) begin
            state   <= WRITE;
            sdo_reg <= {8'h00, address, write_value};
          end
          if (read) begin
            state   <= READ;
            sdo_reg <= {8'h01, address, 8'h00};
          end
          if (init) state <= INIT_SPI;
          transaction_done <= 1'b0;
        end

        // In order to put the ADAU1761 in SPI mode, make 3 dummy writes. Once
        // done with the SPI init, move to register init
        INIT_SPI: begin
          if (transaction_done) begin
            transaction_done <= 1'b0;
            if (spi_init_counter == 2'b10) begin
              state <= INIT_REG;
              spi_init_counter <= 2'b00;
              cs <= 1'b1;
            end else begin
              state <= INIT_SPI;
              spi_init_counter <= spi_init_counter + 1;
              cs <= 1'b0;
            end
          end else begin
            state <= INIT_SPI;
            spi_transaction_counter <= spi_transaction_counter + 1'b1;
            cs <= 1'b0;
          end
        end

        // ADAU1761 register init sequence. Make writes to each of the
        // necessary registers to allow audio passthrough.
        INIT_REG: begin
          if (!reg_init_done) begin
            case (reg_sequence)
              0:  sdo_reg <= {8'h00, 16'h4000, 8'h01};  // R0: Clock Control, enable core clock
              1:  sdo_reg <= {8'h00, 16'h400A, 8'h5B};  // R4: Record Mixer Left Control 0, enable @ 0dB
              2:  sdo_reg <= {8'h00, 16'h400B, 8'h0D};  // R5: Record Mixer Left Control 1, enable @ 0dB
              3:  sdo_reg <= {8'h00, 16'h400C, 8'h5B};  // R6: Record Mixer Left Control 0, enable @ 0dB
              4:  sdo_reg <= {8'h00, 16'h400D, 8'h0D};  // R7: Record Mixer Left Control 1, enable @ 0dB
              5:  sdo_reg <= {8'h00, 16'h401C, 8'h2D};  // R22: Playback Mixer Left Control 0, enable @ 0dB
              6:  sdo_reg <= {8'h00, 16'h401E, 8'h2D};  // R22: Playback Mixer Right Control 0, enable @ 0dB
              7:  sdo_reg <= {8'h00, 16'h4023, 8'hF7};  // R29: Playback Headphone Left Volume Control @ +6dB
              8:  sdo_reg <= {8'h00, 16'h4024, 8'hF7};  // R30: Playback Headphone Right Volume Control @ +6dB
              9:  sdo_reg <= {8'h00, 16'h4025, 8'hF7};  // R31: Playback Line Output Left Volume Control @ +6dB
              10: sdo_reg <= {8'h00, 16'h4026, 8'hF7};  // R32: Playback Line Output Right Volume Control @ +6dB
              11: sdo_reg <= {8'h00, 16'h4019, 8'h03};  // R19: ADC Control
              12: sdo_reg <= {8'h00, 16'h4029, 8'h03};  // R35: Playback Power Management
              13: sdo_reg <= {8'h00, 16'h402A, 8'h03};  // R2A: DAC Control 0
              14: sdo_reg <= {8'h00, 16'h40F2, 8'h01};  // R58: Serial Input Route Controlm, rout to ADC
              15: sdo_reg <= {8'h00, 16'h40F3, 8'h01};  // R59: Serial Output Route Control, route to DAC
              16: sdo_reg <= {8'h00, 16'h40F9, 8'h7F};  // R65: Clock Enable 0
              17: begin
                sdo_reg <= {8'h00, 16'h40FA, 8'h03};  // R66: Clock Enable 1
                reg_init_done <= 1'b1;
              end
            endcase
            reg_sequence <= reg_sequence + 1'b1;
            state <= WRITE;
          end else state <= IDLE;
        end

        // Write operation
        WRITE: begin
          cs <= 1'b0;
          spi_transaction_counter <= spi_transaction_counter + 1'b1;
          sdo <= sdo_reg[31];  // MSB first
          sdo_reg <= sdo_reg << 1;
        end

        // Read check
        READ: begin
          cs <= 1'b0;
          spi_transaction_counter <= spi_transaction_counter + 1'b1;
          sdo <= sdo_reg[31];  // MSB first
          sdo_reg <= sdo_reg << 1;
          if (spi_transaction_counter >= 'h18) begin
            read_value[0] <= sdi;
            read_value <= read_value << 1;
          end
        end

      endcase

      if (spi_transaction_counter == 8'h20) begin
        cs <= 1'b1;
        spi_transaction_counter <= 8'h00;
        transaction_done <= 1'b1;
        case (state)
          READ:  state <= IDLE;
          WRITE: state <= INIT_REG;
        endcase
      end

    end
  end

  initial begin
    $dumpvars(0, adau1761_spi_configurator);
    $dumpfile("dump.vcd");
  end

endmodule
