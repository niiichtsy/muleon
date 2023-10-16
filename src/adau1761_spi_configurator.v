module adau1761_spi_configurator (
    output wire sclk,
    output reg sdo,
    output reg cs,
    input sdi,
    input clk,
    input resetn
);

  // States
  localparam IDLE = 0;
  localparam INIT = 1;
  localparam REPEAT = 2;
  localparam READ = 3;
  localparam WRITE = 4;

  //Regs
  reg [23:0] sdo_reg;
  reg [ 7:0] spi_counter;
  reg [ 1:0] init_counter;
  reg [ 3:0] state;

  // Wire assignments
  assign sclk = clk;


  always @(posedge clk) begin
    if (!resetn) begin
      sdo <= 'h00;
      cs <= 'b1;
      init_counter <= 'h00;
      spi_counter <= 'h00;
      state <= INIT;
    end else begin

      case (state)

        IDLE: begin
        end

        // In order to put the ADAU1761 in SPI mode, make 3 dummy writes
        INIT: begin
          cs <= 1'b0;
          spi_counter <= spi_counter + 1'b1;
        end

        REPEAT: begin
          if (init_counter == 2'b10) begin
            state <= WRITE;
            init_counter <= 2'b00;
          end else begin
            state <= INIT;
            init_counter <= init_counter + 1;
          end
        end

        // Enable core clock
        WRITE: begin
          cs <= 1'b0;
          spi_counter <= spi_counter + 1'b1;
          if (spi_counter == 8'h00) begin
            sdo_reg <= {8'h00, 8'h40, 8'h00, 8'h01};  // Write a 0x1 to register 0x4000 to enable core clock
            sdo <= 1'b0;  // NOTE: This bit is ignored - sdo coincidental with the cs falling edge is not read
          end else begin
            sdo_reg <= sdo_reg << 1;
            sdo <= sdo_reg[23];  // MSB first
          end
        end

        // Read check
        READ: begin
          cs <= 1'b0;
          spi_counter <= spi_counter + 1'b1;
          if (spi_counter == 8'h00) begin
            sdo_reg <= {8'h01, 8'h40, 8'h02};
            sdo <= 1'b0;  // NOTE: This bit is ignored - sdo coincidental with the cs falling edge is not read
          end else begin
            sdo_reg <= sdo_reg << 1;
            sdo <= sdo_reg[23];  // MSB first
          end
        end

      endcase

      if (spi_counter == 8'h20) begin
        cs <= 1'b1;
        spi_counter <= 8'h00;
        case (state)
          INIT:  state <= REPEAT;
          READ:  state <= IDLE;
          WRITE: state <= IDLE;
        endcase
      end

    end
  end

  initial begin
    $dumpvars(0, adau1761_spi_configurator);
    $dumpfile("dump.vcd");
  end

endmodule
