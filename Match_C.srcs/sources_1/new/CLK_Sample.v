//==================================================================================================
//  Filename      : CLK_Sample.v
//  Created On    : 2019-05-13 00:14:41
//  Last Modified : 2019-05-13 00:14:41
//  Author 		  : DUAN
//  Revision      : By sublime_3   
//					module version is 1.0
//  Description   : 下抽样模块
//					相关计算公式 : sample_fre = (Fs*2^32)/Fc  (Fc = clk_AD)
//                  
//         			端口定义    ： clk_AD          ：AD最大采样时钟
//                  			  sample_fre      ：采样率控制字
//         			         	  clk_sample      ：对应采样率下的时钟输出	
//	Note          : 本代码遵循BSD开源协议			
//==================================================================================================

/*******************************************************************************/
// wire             clk_sample;
// CLK_Sample CLK_Sample_u(
//     .clk_in(clk_sys),
//     .RST(1'b0),
//     .sample_fre(32'd85899345),
//     .clk_sample(clk_sample)
// );
/*******************************************************************************/

module CLK_Sample
(
    input         clk_in,
    input         RST,
    input  [31:0] sample_fre,
    output		  clk_sample
);

reg  [31:0] addr_r = 0;
always @(posedge clk_in) begin
	if (RST) begin
		addr_r <= 32'd0;
	end
	else begin
		addr_r <= addr_r + sample_fre;
	end
end

assign clk_sample = addr_r[31];

endmodule
