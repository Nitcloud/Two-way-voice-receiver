module IQ_Backend_Filter
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

parameter CNT_WIDTH = 8;
parameter INPUT_WIDTH = 12;
parameter OUTPUT_WIDTH = 12;

reg [CNT_WIDTH-1:0] cnt_p = 0;// 上升沿计数单位
reg [CNT_WIDTH-1:0] cnt_n = 0;// 下降沿计数单位
reg                 clk_in_p = 0;// 上升沿时钟
reg                 clk_in_n = 0;// 下降沿时钟
        
always@(posedge clk_in) begin
    if (RST)
        cnt_p <= 0;
    else if (cnt_p == (N-1))
        cnt_p <= 0;
    else
        cnt_p <= cnt_p + 1;
end

always@(posedge clk_in) begin
    if (RST) 
        clk_in_p <= 1;//此处设置为0也是可以的，这个没有硬性的要求，不管是取0还是取1结果都是正确的。
    else if (cnt_p < (N>>1))/*N整体向右移动一位，最高位补零，其实就是N/2，不过在计算奇数的时候有很明显的优越性*/
        clk_in_p <= 1;
    else
        clk_in_p <= 0;    
end

always@(negedge clk_in) begin
    if (RST)
        cnt_n <= 0;
    else if (cnt_n == (N-1))
        cnt_n <= 0;
    else
        cnt_n <= cnt_n + 1;
end

always@(negedge clk_in) begin
    if (RST)
        clk_in_n <= 1;
    else if (cnt_n < (N>>1))
        clk_in_n <= 1;
    else
        clk_in_n <= 0;
end

//其中N==1是判断不分频，N[0]是判断是奇数还是偶数，若为1则是奇数分频，若是偶数则是偶数分频。
assign clk_out = (N == 1) ? clk_in : (N[0])   ? (clk_in_p | clk_in_n) : (clk_in_p);

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