module distortion #(
    parameter DATA_WIDTH = 16
) (
    input [DATA_WIDTH-1:0] i2s_data_in,
    output reg [DATA_WIDTH-1:0] i2s_data_out,
    input clk,
    input resetn
);

  always @(posedge clk) begin
    if (!resetn) begin
      i2s_data_out <= 'h00;
    end else begin
      // This is for distorting the signal in the data format that is
      // acquired from the codec

      // if ((i2s_data_in[23:20] <= 4'hE) && (i2s_data_in[23:20] >= 4'h8)) begin
      //   i2s_data_out <= 24'hE00000;
      // end else if ((i2s_data_in[23:20] >= 4'h2) && (i2s_data_in[23:20] <= 4'h7)) begin
      //   i2s_data_out <= 24'h200000;
      // end

      // This is for testing

      if (i2s_data_in < 'd6554) begin
        i2s_data_out <= 'd6554;
      end else if (i2s_data_in > 'd26214) begin
        i2s_data_out <= 'd26214;
      end else begin
        i2s_data_out <= i2s_data_in;
      end

    end

  end


  initial begin
    $dumpvars(0, distortion);
    $dumpfile("dump.vcd");
  end


endmodule
