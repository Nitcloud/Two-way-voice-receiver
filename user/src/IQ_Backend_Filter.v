module IQ_Backend_Filter #(
	parameter CNT_WIDTH = 8,
	parameter INPUT_WIDTH = 12,
	parameter OUTPUT_WIDTH = 12
)
(
    input                         clk_in,
    output                        clk_out,  
    input                         RST,

    input  [CNT_WIDTH - 1 : 0]    N,

    input  [INPUT_WIDTH - 1 : 0]  I_IN,
    input  [INPUT_WIDTH - 1 : 0]  Q_IN,

    output [OUTPUT_WIDTH - 1 : 0] I_OUT,
    output [OUTPUT_WIDTH - 1 : 0] Q_OUT
);

wire        [37:0] Fiter_wave_I;
CIC_Down Fiter_I(
    .clk(clk_in),
    .clk_enable(1'd1),
    .reset(RST),
    .filter_in(I_IN),
    .filter_out(Fiter_wave_I)
);
assign I_OUT = Fiter_wave_I[37 : 38 - OUTPUT_WIDTH];

wire        [37:0] Fiter_wave_Q;
CIC_Down Fiter_Q(
    .clk(clk_in),
    .clk_enable(1'd1),
    .reset(RST),
    .filter_in(Q_IN),
    .filter_out(Fiter_wave_Q)
);
assign Q_OUT = Fiter_wave_Q[37 : 38 - OUTPUT_WIDTH];

endmodule