module fir_lowpass #(
    parameter DATA_WIDTH = 16
) (
    input signed [DATA_WIDTH-1:0] i2s_data_in,
    output reg signed [(DATA_WIDTH+16)-1:0] i2s_data_out,
    input clk,
    input resetn
);

  //  Delay buffers
  reg signed [15:0] buffer0, buffer1, buffer2, buffer3, buffer4, buffer5, buffer6, buffer7, buffer8, buffer9, buffer10, buffer11, buffer12, buffer13, buffer14, buffer15;

  //  Multiplication buffers
  reg signed [(DATA_WIDTH+16)-1:0] mul0, mul1, mul2, mul3, mul4, mul5, mul6, mul7, mul8, mul9, mul10, mul11, mul12, mul13, mul14, mul15;

  // 16-bit filter coefficients
  wire signed [15:0] coef0, coef1, coef2, coef3, coef4, coef5, coef6, coef7, coef8, coef9, coef10, coef11, coef12, coef13, coef14, coef15;
  assign coef0  = 16'hF70E;
  assign coef1  = 16'hFF78;
  assign coef2  = 16'h01A8;
  assign coef3  = 16'h052E;
  assign coef4  = 16'h09A2;
  assign coef5  = 16'h0E54;
  assign coef6  = 16'h1277;
  assign coef7  = 16'h1550;
  assign coef8  = 16'h1655;
  assign coef9  = 16'h1550;
  assign coef10 = 16'h1277;
  assign coef11 = 16'h0E54;
  assign coef12 = 16'h09A2;
  assign coef13 = 16'h052E;
  assign coef14 = 16'h01A8;
  assign coef15 = 16'hFF78;

  // Delay stage
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

  // Multiplication stage
  always @(posedge clk) begin
    if (!resetn) begin
      mul0  <= 'h00;
      mul1  <= 'h00;
      mul2  <= 'h00;
      mul3  <= 'h00;
      mul4  <= 'h00;
      mul5  <= 'h00;
      mul6  <= 'h00;
      mul7  <= 'h00;
      mul8  <= 'h00;
      mul9  <= 'h00;
      mul10 <= 'h00;
      mul11 <= 'h00;
      mul12 <= 'h00;
      mul13 <= 'h00;
      mul14 <= 'h00;
      mul15 <= 'h00;
    end else begin
      mul0  <= coef0 * buffer0;
      mul1  <= coef1 * buffer1;
      mul2  <= coef2 * buffer2;
      mul3  <= coef3 * buffer3;
      mul4  <= coef4 * buffer4;
      mul5  <= coef5 * buffer5;
      mul6  <= coef6 * buffer6;
      mul7  <= coef7 * buffer7;
      mul8  <= coef8 * buffer8;
      mul9  <= coef9 * buffer9;
      mul10 <= coef10 * buffer10;
      mul11 <= coef11 * buffer11;
      mul12 <= coef12 * buffer12;
      mul13 <= coef13 * buffer13;
      mul14 <= coef14 * buffer14;
      mul15 <= coef15 * buffer15;
    end
  end

  // Accumulation stage
  always @(posedge clk) begin
    if (!resetn) begin
      i2s_data_out <= 'h00;
    end else begin
      i2s_data_out <= mul0 + mul1 + mul2 + mul3 + mul4 + mul5 + mul6 + mul7 + mul8 + mul9 + mul10 + mul11 + mul12 + mul13 + mul14 + mul15;
    end
  end

  initial begin
    $dumpvars(0, fir_lowpass);
    $dumpfile("fir_lowpass.vcd");
  end

endmodule
