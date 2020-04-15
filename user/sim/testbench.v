module testbench();

parameter MAIN_FRE   = 100; //unit MHz
reg                   clk       = 0;
reg                   sys_rst_n = 0;

always begin
    #(500/MAIN_FRE) clk = ~clk;
end
always begin
    #50 sys_rst_n = 1;
end

wire  [11:0]  wave_out_sin;
wire  [11:0]  wave_out_tri;
wire  [11:0]  wave_out_saw;

DDS_Gen #(
    .OUTPUT_WIDTH ( 12 ),
    .PHASE_WIDTH  ( 32 ))
 u_DDS_Gen (
    .clk_in                  ( clk            ),
    .Fre_word                ( 32'd42950      ),
    .Pha_word                ( 32'd0          ),

    .wave_out_sin            ( wave_out_sin   ),
    .wave_out_tri            ( wave_out_tri   ),
    .wave_out_saw            ( wave_out_saw   )
);

wire  [7:0]  FM_wave;
FM_Modulate #(
    .INPUT_WIDTH  ( 12 ),
    .PHASE_WIDTH  ( 32 ),
    .OUTPUT_WIDTH ( 8  ))
 u_FM_Modulate (
    .clk_in                  ( clk           ),
    .RST                     ( ~sys_rst_n    ),
    .wave_in                 ( wave_out_sin  ),
    .move_fre                ( 20'd262       ),  //25k
    .center_fre              ( 32'd459561501 ),  //10.7M

    .FM_wave                 ( FM_wave      )
);

wire  [7:0]  AM_wave;
AM_Modulate #(
    .INPUT_WIDTH  ( 12 ),
    .PHASE_WIDTH  ( 32 ),
	.DEEP_WIDTH   ( 12 ),
    .OUTPUT_WIDTH ( 8  ))
 u_AM_Modulate (
    .clk_in                  ( clk           ),
    .RST                     ( ~sys_rst_n    ),
    .wave_in                 ( wave_out_sin  ),
    .modulate_deep           ( 12'd4090      ),  //100%
    .center_fre              ( 32'd459561501 ),  //10.7M

    .AM_wave                 ( AM_wave      )
);

wire  [11:0]  FM_Demodule_OUT;
wire  [11:0]  AM_Demodule_OUT;
Demodulate #(
    .PHASE_WIDTH  ( 32  ),
	.Fiter_WIDTH  ( 38  ),
    .INPUT_WIDTH  ( 8   ),
    .OUTPUT_WIDTH ( 12  ))
 u_Demodulate (
    .clk_in                  ( clk               ),
    .RST                     ( ~sys_rst_n        ),

    .FACTOR       			 ( 16'd400           ),
    .Fre_word                ( 32'd459561501     ),
    .wave_in                 ( FM_wave           ),

    .FM_Demodule_OUT         ( FM_Demodule_OUT   ),
    .AM_Demodule_OUT         ( AM_Demodule_OUT   )
);

endmodule  //TOP