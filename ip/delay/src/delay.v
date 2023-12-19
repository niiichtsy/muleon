module delay #(
    parameter DATA_WIDTH = 16
) (
    input [DATA_WIDTH-1:0] i2s_data_in,
    output reg [DATA_WIDTH-1:0] i2s_data_out,
    input clk,
    input resetn
);

  //  Delay buffers
  reg signed [15:0] buffer0, buffer1, buffer2, buffer3, buffer4, buffer5, buffer6, buffer7, buffer8, buffer9, buffer10, buffer11, buffer12, buffer13, buffer14, buffer15;

  // Buffer stage
  always @(posedge clk) begin
    if (!resetn) begin
      buffer0  <= 'h00;
      buffer1  <= 'h00;
      buffer2  <= 'h00;
      buffer3  <= 'h00;
      buffer4  <= 'h00;
      buffer5  <= 'h00;
      buffer6  <= 'h00;
      buffer7  <= 'h00;
      buffer8  <= 'h00;
      buffer9  <= 'h00;
      buffer10 <= 'h00;
      buffer11 <= 'h00;
      buffer12 <= 'h00;
      buffer13 <= 'h00;
      buffer14 <= 'h00;
      buffer15 <= 'h00;
    end else begin
      buffer0  <= i2s_data_in;
      buffer1  <= buffer0;
      buffer2  <= buffer1;
      buffer3  <= buffer2;
      buffer4  <= buffer3;
      buffer5  <= buffer4;
      buffer6  <= buffer5;
      buffer7  <= buffer6;
      buffer8  <= buffer7;
      buffer9  <= buffer8;
      buffer10 <= buffer9;
      buffer11 <= buffer10;
      buffer12 <= buffer11;
      buffer13 <= buffer12;
      buffer14 <= buffer13;
      buffer15 <= buffer14;
    end
  end

  // Delay stage
  // At 100 MHz, a delay of 16 clock cycles is ~160 ns. to increase this time,
  // we can decrease the clock frequency or increase the number of buffers. To make the delay audible to humans,
  // it should be about 500 ms, so, with 16 buffers, the module should run @ 32
  // MHz.
  always @(posedge clk) begin
    if (!resetn) begin
      i2s_data_out <= 'h00;
    end else begin
      i2s_data_out <= buffer15 + i2s_data_in;
    end
  end

  // Waves for simulation
  initial begin
    $dumpvars(0, delay);
    $dumpfile("delay.vcd");
  end


endmodule
