`timescale 1ns / 1ps

module TOP(
    input          sys_clk,

    input          FM_IN,
    output         LO_OUT,
    output         DAC_CH1,
    output         DAC_CH2
);

//----------System Level Signals----------//
wire 	clk_500m;
wire 	clk_250m;
wire 	clk_100m;
wire 	clk_50m;
wire    locked;
CLK_Global #(
	.CLKIN_PERIOD(20),
    .Mult(20),
    .DIVCLK_DIV(1),

    .CLKOUT0_DIV(2),
    .CLK0_PHASE(0.0),

    .CLKOUT1_DIV(4),
    .CLK1_PHASE(0.0),

    .CLKOUT2_DIV(10),
    .CLK2_PHASE(0.0),

    .CLKOUT3_DIV(20),
    .CLK3_PHASE(0.0)
) CLK_Global_u (
    .clk_in(sys_clk),
    .rst_n(1'b1),

    .clk_out1(clk_500m),
    .clk_out2(clk_250m),
    .clk_out3(clk_100m),
    .clk_out4(clk_50m),

    .locked(locked)
); 

wire        [31:0] LO_fre;
PFD PFD_u(
    .clk_in(clk_250m),   
    .SIG_IN(FM_IN),
    .LO_fre(LO_fre)
);

CLK_Sample CLK_Sample_u(
    .clk_in(clk_500m),
    .RST(1'b0),
    .sample_fre(32'd324699527),//32'd324699527
    .clk_sample(LO_OUT)
);

wire               clk_250k;
wire        [23:0] Demodule_OUT;
Demodule Demodule_u(
    .clk_in(clk_100m),
    .clk_out(clk_250k),
    .RST(0),

    .data_in({~FM_IN,{7{FM_IN}}}),
    .Demodule_OUT(Demodule_OUT)
);

wire        [25:0] Audio_wave_1;
wire        [31:0] Audio_wave_2;
Audio_Handle Audio_Handle_u(
    .clk_in(clk_250k),
    .RST(0),

    .data_in(Demodule_OUT[14:3]),
    .Audio_wave_1(Audio_wave_1),
    .Audio_wave_2(Audio_wave_2)
);

DAC_PWM DAC_PWM_CH2(
    .clk_in(clk_500m),
    .RST(0),
    .data_in({Audio_wave_1[23:0],8'd0}),
    .DAC_PWM(DAC_CH2)
);

DAC_PWM DAC_PWM_CH1(
    .clk_in(clk_500m),
    .RST(0),
    .data_in(Audio_wave_2),
    .DAC_PWM(DAC_CH1)
);

endmodule

