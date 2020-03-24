//==================================================================================================
//  Filename      : Max_meas.v
//  Created On    : 2019-05-10 12:04:34
//  Last Modified : 2019-05-10 12:04:34
//  Author 		  : DUAN
//  Revision      : By sublime_3   
//					module version is 1.0
//  Description   : 最大值检测模块
//					相关计算公式 : 
//                  
//         			端口定义    ： range：比较的数据的个数 （输入为0则一直比较，1以上则为周期比较）
//                                data_width：数据宽度
//         			         	  data_in&data_out：数据的输入输出	
//	Note          : 本代码遵循BSD开源协议			
//==================================================================================================
module Max_meas//最大值检测
(
	input				  clk_in,
	input 				  rst_n,
	input          [31:0] range,
	input  signed  [11:0] data_in,
	output signed  [11:0] data_out
);

parameter 		  state_initial = 3'b000;
parameter 		  state_detection = 3'b001;
parameter 		  state_output = 3'b010;

reg signed [11:0] data_out_buf  = 0;
reg signed [11:0] data_out_buf1 = 0;

reg [2:0] 		  state = 3'b000;
reg 			  test_sig = 1'b0;
reg 			  test_sig_buf = 1'b0;

wire 			  test_done_sig = ~test_sig & test_sig_buf;
wire 			  test_start_sig = test_sig & ~test_sig_buf;

/***************************************************/
//define the time counter
reg [31:0] cnt0 = 1;

always@(posedge clk_in)
begin
	if (cnt0 == range)      
    begin
        cnt0 <= 10'd0;                   
        test_sig <= 1'd0;
    end
    else begin
    	test_sig <= 1'd1;                 
        cnt0 <= cnt0 + 1'b1; 
    end
end
/***************************************************/

always@(posedge clk_in)
begin
		test_sig_buf <= test_sig;
end

always@(posedge clk_in or negedge rst_n)
begin
	if(!rst_n) begin
		data_out_buf <= 0;
		data_out_buf1 <= 0;
	end
	else begin
		case(state)
		state_initial:begin 
			if(test_start_sig) begin 
				state <= state_detection; 
				data_out_buf <= 0;
			end 
			end
		state_detection:begin 
			if(test_done_sig)
				state <= state_output;
			else
				if(data_in > data_out_buf) begin
					data_out_buf <= data_in;
				end
				else begin
					data_out_buf <= data_out_buf;
				end
			end
		state_output:begin 
			data_out_buf1 <= data_out_buf;
			state <= state_initial; 
			end
		endcase
	end
end

assign data_out=data_out_buf1;

endmodule 