module fir_lowpass #(
    parameter DATA_WIDTH = 16
) (
    input signed [DATA_WIDTH-1:0] i2s_data_in,
    output reg signed [(DATA_WIDTH+16)-1:0] i2s_data_out,
    input clk,
    input resetn
);

  //  Delay buffers
  reg signed [15:0] buffer[DATA_WIDTH-1:0];

  //  Multiplication buffers
  reg signed [(DATA_WIDTH+16)-1:0] mul[DATA_WIDTH-1:0];

  // 16-bit filter coefficients
  wire signed [15:0] coef[15:0];
  assign coef[0]  = 16'hF70E;
  assign coef[1]  = 16'hFF78;
  assign coef[2]  = 16'h01A8;
  assign coef[3]  = 16'h052E;
  assign coef[4]  = 16'h09A2;
  assign coef[5]  = 16'h0E54;
  assign coef[6]  = 16'h1277;
  assign coef[7]  = 16'h1550;
  assign coef[8]  = 16'h1655;
  assign coef[9]  = 16'h1550;
  assign coef[10] = 16'h1277;
  assign coef[11] = 16'h0E54;
  assign coef[12] = 16'h09A2;
  assign coef[13] = 16'h052E;
  assign coef[14] = 16'h01A8;
  assign coef[15] = 16'hFF78;

  // Loop variable
  integer i;

  // Delay stage
  always @(posedge clk) begin
    if (!resetn) begin
      foreach (buffer[i]) begin
        buffer[i] <= 'h00;
      end
    end else begin
      buffer[0] <= i2s_data_in;
      for (i = 1; i < 15; i = i + 1) begin
        buffer[i] <= buffer[i-1];
      end
    end
  end

  // Multiplication stage
  always @(posedge clk) begin
    if (!resetn) begin
      foreach (buffer[i]) begin
        mul[i] <= 'h00;
      end
    end else begin
      for (i = 0; i < 15; i = i + 1) begin
        mul[i] <= coef[i] * buffer[i];
      end
    end
  end

  // Accumulation stage
  always @(posedge clk) begin
    if (!resetn) begin
      i2s_data_out <= 'h00;
    end else begin
      for (i = 0; i < 15; i = i + 1) begin
        i2s_data_out <= i2s_data_out + mul[i];
      end
    end
  end

endmodule
