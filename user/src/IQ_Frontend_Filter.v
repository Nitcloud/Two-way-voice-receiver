module IQ_Frontend_Filter #(
	parameter INPUT_WIDTH = 8,
	parameter OUTPUT_WIDTH = 12
)(
    input                         clk_in,
    input                         RST,
    input  [INPUT_WIDTH - 1 : 0]  filter_in,
    output [OUTPUT_WIDTH - 1 : 0] filter_out
);



wire        [22:0] Fiter_wave;
FIR_100M_10_7M_BPF FIR_100M_10_7M_BPF_u0(
    .clk(clk_in),
    .clk_enable(~RST),
    .reset(RST),
    .filter_in(filter_in),
    .filter_out(Fiter_wave)
);
assign filter_out = Fiter_wave[22 : 23 - OUTPUT_WIDTH];

endmodule