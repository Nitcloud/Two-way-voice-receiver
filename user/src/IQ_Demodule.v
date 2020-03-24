module IQ_Demodule
(
    input                       clk_in,
    output                      clk_out,
    
    input                       RST,
    input  [31:0]               LO_fre,
    input  [INPUT_WIDTH - 1:0]  data_in,
    output [OUTPUT_WIDTH - 1:0] I_OUT,
    output [OUTPUT_WIDTH - 1:0] Q_OUT
);

parameter INPUT_WIDTH  = 8;
parameter OUTPUT_WIDTH = 12;
parameter Fiter_width  = 12;

wire [Fiter_width - 1 : 0] filter_out;
IQ_Frontend_Filter #
(
	.INPUT_WIDTH(INPUT_WIDTH),
	.OUTPUT_WIDTH(Fiter_width)
)
IQ_Frontend_Filter_u
(
    .clk_in(clk_in),
    .RST(RST),
    .filter_in(data_in),
    .filter_out(filter_out)
);
//GEN IQ sig
// wire        [31:0] m_axis_data_tdata;
// DDS_Gen sin_cos_Gen(
//     .aclk(clk_in),
//     .m_axis_data_tdata(m_axis_data_tdata)
// );

wire        [11:0] sin_wave;
DDS_Gen #
(
    .OUTPUT_WIDTH(12),
    .PHASE_WIDTH(32)
) 
sin_Gen(
    .clk_in(clk_in),
    .Fre_word(LO_fre),
    .Pha_word(32'd0),  //32'd1073741824
    .wave_out(sin_wave)
);

wire        [11:0] cos_wave;
DDS_Gen #
(
	.OUTPUT_WIDTH(12),
	.PHASE_WIDTH(32)
) 
cos_Gen(
    .clk_in(clk_in),
    .Fre_word(LO_fre),
    .Pha_word(32'd114890375),  //32'd1073741824
    .wave_out(cos_wave)
);

wire signed [11:0] I_SIG;
reg  signed [Fiter_width + 11 : 0] I_SIG_r = 0;
always @(posedge clk_in) begin
	if (RST) begin
		I_SIG_r <= 24'd0;
	end
	else begin
		I_SIG_r <= $signed(filter_out) * $signed(cos_wave);
	end
end
assign I_SIG = I_SIG_r[Fiter_width + 11 : Fiter_width];

wire signed [11:0] Q_SIG;
reg  signed [Fiter_width + 11 : 0] Q_SIG_r = 0;
always @(posedge clk_in) begin
	if (RST) begin
		Q_SIG_r <= 24'd0;
	end
	else begin
		Q_SIG_r <= $signed(filter_out) * $signed(sin_wave);
	end
end
assign Q_SIG = Q_SIG_r[Fiter_width + 11 : Fiter_width];


IQ_Backend_Filter #
(
	.CNT_WIDTH(10),
	.INPUT_WIDTH(12),
	.OUTPUT_WIDTH(OUTPUT_WIDTH)
)
IQ_Backend_Filter_u
(
    .clk_in(clk_in),
    .clk_out(clk_out),
    .RST(RST),

    .N(400),

    .I_IN(I_SIG),
    .Q_IN(Q_SIG),

    .I_OUT(I_OUT),
    .Q_OUT(Q_OUT)
);


endmodule