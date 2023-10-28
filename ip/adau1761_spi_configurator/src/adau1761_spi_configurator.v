module adau1761_spi_configurator (
    output wire sclk,
    output reg sdo,
    output reg cs,
    output reg [39:0] read_value,
    input [15:0] address,
    input [15:0] write_value,
    input write,
    input read,
    input init,
    input sdi,
    input clk,
    input resetn
);

  // States
  localparam IDLE = 0;
  localparam INIT = 1;
  localparam READ = 2;
  localparam WRITE = 3;

  //Regs
  reg [39:0] sdo_reg;
  reg sdi_reg;
  reg [7:0] spi_counter;
  reg [1:0] init_counter;
  reg [3:0] state;
  reg transaction_done;

  // Wire assignments
  assign sclk = clk;


  always @(posedge clk) begin
    if (!resetn) begin
      sdo <= 'h00;
      cs <= 'b1;
      init_counter <= 'h00;
      spi_counter <= 'h00;
      transaction_done <= 1'b0;
      state <= INIT;  // By default, go straight to init stage
    end else begin

      case (state)

        IDLE: begin
          if (write) state <= WRITE;
          if (read) state <= READ;
          if (init) state <= INIT;
          transaction_done <= 1'b0;
        end

        // In order to put the ADAU1761 in SPI mode, make 3 dummy writes
        INIT: begin
          if (transaction_done) begin
            transaction_done <= 1'b0;
            if (init_counter == 2'b10) begin
              state <= IDLE;
              init_counter <= 2'b00;
              cs <= 1'b1;
            end else begin
              state <= INIT;
              init_counter <= init_counter + 1;
              cs <= 1'b0;
            end
          end else begin
            state <= INIT;
            spi_counter <= spi_counter + 1'b1;
            cs <= 1'b0;
          end
        end

        // Write operation
        WRITE: begin
          cs <= 1'b0;
          spi_counter <= spi_counter + 1'b1;
          if (spi_counter == 8'h00) begin
            sdo_reg <= {8'h00, address, write_value};  // Write a 0x1 to register 0x4000 to enable core clock
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
            sdo_reg <= {8'h01, address, 16'h00};
            sdo <= 1'b0;  // NOTE: This bit is ignored - sdo coincidental with the cs falling edge is not read
          end else begin
            sdo_reg <= sdo_reg << 1;
            sdo <= sdo_reg[23];  // MSB first
            if (spi_counter >= 'd24) begin
              read_value[0] <= sdi;
              read_value <= read_value << 1;
            end
          end
        end

      endcase

      if (spi_counter == 8'h28) begin
        cs <= 1'b1;
        spi_counter <= 8'h00;
        transaction_done <= 1'b1;
        case (state)
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
