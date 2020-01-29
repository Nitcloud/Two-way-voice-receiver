`timescale 1ns / 1ps
module AGC
(
    input          clk_in,
    input          RST,

    input  [11:0]  data_in,
    output [11:0]  data_out
);


wire signed  [11:0] max;
Max_meas Max_meas_u(
    .clk_in(clk_in),
    .rst_n(~RST),
    .range(32'd250000),
    .data_in(data_in),
    .data_out(max)
);

wire        [11:0] Audio_wave_a;
wire        [31:0] m_axis_dout_tdata;
AGC_div AGC_u(
    .aclk(clk_in),

    .s_axis_dividend_tdata({data_in,12'd0}),
    .s_axis_dividend_tvalid(1'b1),

    .s_axis_divisor_tdata({{4{max[11]}},max}),
    .s_axis_divisor_tvalid(1'b1),

    .m_axis_dout_tdata(m_axis_dout_tdata),
    .m_axis_dout_tvalid()
);
assign data_out = m_axis_dout_tdata[21:10];

endmodule

