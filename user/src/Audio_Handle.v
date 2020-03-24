`timescale 1ns / 1ps
module Audio_Handle
(
    input         clk_in,
    input         RST,

    input  [11:0] data_in,
    output [25:0] Audio_wave_1,
    output [31:0] Audio_wave_2
);

wire             clk_50k;
wire      [14:0] cic_wave_L;
CIC_DOWN_5 CIC_LPF(
    .clk(clk_in),
    .clk_enable(1'd1),
    .reset(RST),
    .filter_in(data_in),
    .filter_out(cic_wave_L),
    .ce_out(clk_50k)
);

FIR_50K_5K_LPF Fiter_LPF(
    .clk(clk_50k),
    .clk_enable(1'd1),
    .reset(RST),
    .filter_in(data_in),
    .filter_out(Audio_wave_1)
);

wire             clk_125k;
wire      [14:0] cic_wave_H;
CIC_DOWN_2 CIC_HPF(
    .clk(clk_in),
    .clk_enable(1'd1),
    .reset(RST),
    .filter_in(data_in),
    .filter_out(cic_wave_H),
    .ce_out(clk_125k)
);

wire        [28:0] Fiter_wave_H;
FIR_125K_6K_HPF Fiter_HPF(
    .clk(clk_125k),
    .clk_enable(1'd1),
    .reset(RST),
    .filter_in(cic_wave_H[14:3]),
    .filter_out(Fiter_wave_H)
);

wire        [11:0] sin_wave;
DDS_Gen #
(
    .OUTPUT_WIDTH(12),
    .PHASE_WIDTH(32)
) 
sin_Gen(
    .clk_in(clk_125k),
    .Fre_word(32'd343597383),  //10k
    .Pha_word(32'd0),          //32'd1073741824
    .wave_out(sin_wave)
);

wire        [11:0] cos_wave;
DDS_Gen #
(
    .OUTPUT_WIDTH(12),
    .PHASE_WIDTH(32)
) 
cos_Gen(
    .clk_in(clk_125k),
    .Fre_word(32'd343597383), //10k
    .Pha_word(32'd1073741824),  //32'd1073741824
    .wave_out(cos_wave)
);

wire signed [11:0] I_SIG;
wire signed [11:0] Q_SIG;
reg  signed [23:0] I_SIG_r = 0;
reg  signed [23:0] Q_SIG_r = 0;
always @(posedge clk_125k) begin
    if (RST) begin
        I_SIG_r <= 24'd0;
        Q_SIG_r <= 24'd0;
    end
    else begin
        I_SIG_r <= $signed(Fiter_wave_H[28:17]) * $signed(cos_wave);
        Q_SIG_r <= $signed(Fiter_wave_H[28:17]) * $signed(sin_wave);
    end
end
assign I_SIG = I_SIG_r[23:12];
assign Q_SIG = Q_SIG_r[23:12];

wire        [26:0] Fiter_wave_I;
FIR_125K_10K_LPF AM_HPF_I(
    .clk(clk_125k),
    .clk_enable(1'd1),
    .reset(RST),
    .filter_in(I_SIG),
    .filter_out(Fiter_wave_I)
);

wire        [26:0] Fiter_wave_Q;
FIR_125K_10K_LPF AM_HPF_Q(
    .clk(clk_125k),
    .clk_enable(1'd1),
    .reset(RST),
    .filter_in(Q_SIG),
    .filter_out(Fiter_wave_Q)
);

reg [47:0] AM_SIG_I = 0;
reg [47:0] AM_SIG_Q = 0;
reg [47:0] AM_SIG_r = 0;
always @(posedge clk_125k) begin
    if (RST) begin
        AM_SIG_I <= 0;
        AM_SIG_Q <= 0;
        AM_SIG_r <= 0;
    end
    else begin
        AM_SIG_I <= $signed(Fiter_wave_I[26:3]) * $signed(Fiter_wave_I[26:3]);
        AM_SIG_Q <= $signed(Fiter_wave_Q[26:3]) * $signed(Fiter_wave_Q[26:3]);
        AM_SIG_r <= AM_SIG_I + AM_SIG_Q;
    end
end

wire      [23:0] Demodule_wave;
wire             m_axis_dout_tvalid;
Square Square_Root(
    .aclk(clk_125k),
    .s_axis_cartesian_tvalid(1),
    .s_axis_cartesian_tdata(AM_SIG_r),
    .m_axis_dout_tvalid(m_axis_dout_tvalid),
    .m_axis_dout_tdata(Demodule_wave)
);

reg signed [31:0] Audio_wave_2_r;
always @(posedge clk_125k) begin
	Audio_wave_2_r <= $signed({Demodule_wave[17:0],14'd0}) - $signed(32'd2147483648);
end
assign Audio_wave_2 = Audio_wave_2_r;

endmodule
