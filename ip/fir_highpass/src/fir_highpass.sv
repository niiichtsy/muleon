module fir_highpass #(
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
  assign coef[0]  = 16'hFBF9;
  assign coef[1]  = 16'h0899;
  assign coef[2]  = 16'h07F2;
  assign coef[3]  = 16'h0608;
  assign coef[4]  = 16'h003D;
  assign coef[5]  = 16'hF6B5;
  assign coef[6]  = 16'hEBDC;
  assign coef[7]  = 16'hE340;
  assign coef[8]  = 16'h5FF8;
  assign coef[9]  = 16'hE340;
  assign coef[10] = 16'hEBDC;
  assign coef[11] = 16'hF6B5;
  assign coef[12] = 16'h003D;
  assign coef[13] = 16'h0608;
  assign coef[14] = 16'h07F2;
  assign coef[15] = 16'h0899;

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

  initial begin
    $dumpvars(0, fir_highpass);
    $dumpfile("fir_highpass.vcd");
  end

endmodule
