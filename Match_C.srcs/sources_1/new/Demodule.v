module Demodule
(
    input                       clk_in,
    output                      clk_out,  
    input                       RST,

    input  [INPUT_WIDTH - 1:0]  data_in,
    output [OUTPUT_WIDTH - 1:0] Demodule_OUT
);

parameter INPUT_WIDTH  = 8;
parameter OUTPUT_WIDTH = 24;

wire signed [11:0] I_SIG;
wire signed [11:0] Q_SIG;
IQ_Demodule #
(
	.INPUT_WIDTH(INPUT_WIDTH),
	.OUTPUT_WIDTH(12)
)
IQ_Demodule_u(
    .clk_in(clk_in),
    .clk_out(clk_out),
    .RST(RST),
    .LO_fre(32'd459561501),
    .data_in(data_in),
    .I_OUT(I_SIG),
    .Q_OUT(Q_SIG)
);

FM_Demodule #
(
	.INPUT_WIDTH(12),
	.OUTPUT_WIDTH(OUTPUT_WIDTH)
)
FM_Demodule_u(
    .clk_in(clk_out),
    .RST(RST),

    .I_IN(I_SIG),
    .Q_IN(Q_SIG),
    .Demodule_OUT(Demodule_OUT)
);

endmodule