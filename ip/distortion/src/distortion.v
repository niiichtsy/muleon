module distortion #(
    parameter DATA_WIDTH = 24
) (
    input [DATA_WIDTH-1:0] i2s_data_in,
    output reg [DATA_WIDTH-1:0] i2s_data_out,
    input clk,
    input resetn
);

  always @(posedge clk) begin
    if (!resetn) begin
      i2s_data_out <= 'h00;
    end


  end

endmodule
