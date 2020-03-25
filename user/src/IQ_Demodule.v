module IQ_Demodule #(
	parameter LO_WIDTH     = 12,
	parameter Fiter_width  = 12,
	parameter INPUT_WIDTH  = 8,
	parameter OUTPUT_WIDTH = 12
)(
    input                       clk_in,
    output                      clk_out,
    
    input                       RST,
    input  [31:0]               LO_fre,
    input  [INPUT_WIDTH - 1:0]  data_in,
    output [OUTPUT_WIDTH - 1:0] I_OUT,
    output [OUTPUT_WIDTH - 1:0] Q_OUT
);



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

wire  [31:0]         pha_diff;
wire  [LO_WIDTH-1:0] cos_wave;
wire  [LO_WIDTH-1:0] sin_wave;
Cordic # (
    .XY_BITS(LO_WIDTH),               
    .PH_BITS(32),               //1~32     
    .ITERATIONS(16),            //1~32
    .CORDIC_STYLE("ROTATE"),    //ROTATE  //VECTOR
    .PHASE_ACC("ON")            //ON      //OFF
)
IQ_Gen_u 
(
    .clk_in(clk_100m),
    .RST(RST),
    .x_i(0), 
    .y_i(0),
    .phase_in(LO_fre), //Fre_word = （(2^PH_BITS)/fc）* f   fc：时钟频率   f输出频率
        
    .x_o(cos_wave),
    .y_o(sin_wave),
    .phase_out(pha_diff)
);

wire signed [11:0] I_SIG;
reg  signed [Fiter_width + LO_WIDTH - 1 : 0] I_SIG_r = 0;
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