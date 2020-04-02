module testbench();

parameter DATA_WIDTH = 12;
parameter ADDR_WIDTH = 32;
parameter MAIN_FRE   = 100; //unit MHz
reg                   clk       = 0;
reg                   sys_rst_n = 0;
reg                   valid_out = 0;
reg [DATA_WIDTH-1:0]  data = 0;
reg [ADDR_WIDTH-1:0]  addr = 0;

always begin
    #(500/MAIN_FRE) clk = ~clk;
end
always begin
    #50 sys_rst_n = 1;
end
always begin
    if (sys_rst_n) begin
        #10 addr = addr + 1;#10;
    end
    else begin     
        #10 addr = 0;#10;
    end
end
always begin
    if (sys_rst_n) begin
        #10 data = data + 1;#10;
    end
    else begin     
        #10 data = 0;#10;
    end
end

wire  [11:0]  wave_out_sin;
wire  [11:0]  wave_out_tri;
wire  [11:0]  wave_out_saw;
parameter Fre_word = (1<<32)*5/MAIN_FRE;
parameter Pha_word = 32'd0;
DDS_Gen #(
    .OUTPUT_WIDTH ( 12 ),
    .PHASE_WIDTH  ( 32 ))
 u_DDS_Gen (
    .clk_in                  ( clk            ),
    .Fre_word                ( Fre_word       ),
    .Pha_word                ( Pha_word       ),

    .wave_out_sin            ( wave_out_sin   ),
    .wave_out_tri            ( wave_out_tri   ),
    .wave_out_saw            ( wave_out_saw   )
);

wire        [14:0] Fiter_wave_1;
CIC_DOWN_2 CIC_DOWN_2(
    .clk(clk),
    .clk_enable(1'd1),
    .reset(~sys_rst_n),
    .filter_in(data),
    .filter_out(Fiter_wave_1),
	.ce_out()
);

wire        [14:0] Fiter_wave_2;
CIC_DOWN_S3 CIC_Down_S3(
    .clk(clk),
    .clk_enable(1'd1),
    .reset(~sys_rst_n),
    .filter_in(data),
    .filter_out(Fiter_wave_2),
	.ce_out()
);


endmodule  //TOP