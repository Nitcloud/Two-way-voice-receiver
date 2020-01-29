`timescale 1ns / 1ps

module Check_tb();

reg         clk_250k;
initial begin
    clk_250k = 0;
end

always begin
    #2000 clk_250k = ~clk_250k;
end

reg         RST;
initial begin
    RST = 1;
end

always begin
    #10000 RST = 0;
end

wire        [11:0] sin_wave;
DDS_Gen #
(
	.OUTPUT_WIDTH(12),
	.PHASE_WIDTH(32)
) 
sin_Gen(
    .clk_in(clk_250k),
    .Fre_word(32'd58411555),  //3.4K
    .Pha_word(32'd0),       //32'd1073741824‬
    .wave_out(sin_wave)
);

wire        [11:0] AM_wave;
AM_Module_V2 #
(
    .INPUT_WIDTH(12),
    .PHASE_WIDTH(32),
    .OUTPUT_WIDTH(12)
)
AM_Module_V2_u(
    .clk_in(clk_250k),
    .RST(RST),
    .wave_in(sin_wave),
    .module_deep(16'd32768),       //(2^16-1)*percent
    .center_fre(32'd171798691),    //(fre*4294967296)/clk_in/1000000
    .AM_wave(AM_wave)
);

reg        [12:0] wave_r = 0;
wire       [12:0] wave;
always @(*) begin
    wave_r <= $signed(AM_wave) + $signed(sin_wave);
end
assign wave = wave_r;

wire        [25:0] Audio_wave_1;
wire        [23:0] Audio_wave_2;
Audio_Handle Audio_Handle_u(
    .clk_in(clk_250k),
    .RST(RST),

    .data_in(wave[12:1]),
    .Audio_wave_1(Audio_wave_1),
    .Audio_wave_2(Audio_wave_2)
);

endmodule
