module PFD
(
	input	      clk_in,	
	input	      SIG_IN,
	output [31:0] LO_fre
);

//	相关计算公式   : fre  = clk_in*SQU/CLK
reg		SIG_IN_r0 = 1'b0;
reg		SIG_IN_r1 = 1'b0;
reg		SIG_IN_r2 = 1'b0;
reg		SIG_IN_r3 = 1'b0;

wire	SIG_IN_pose;
always @ (posedge clk_in) begin
	SIG_IN_r0 <= SIG_IN;
	SIG_IN_r1 <= SIG_IN_r0;//将外部输入的方波打两拍
	SIG_IN_r2 <= SIG_IN_r1;
	SIG_IN_r3 <= SIG_IN_r2;
end
assign SIG_IN_pose = SIG_IN_r2 & ~SIG_IN_r3;

reg [31:0] cnt1 = 32'd0;   
reg	[31:0] cnt2 = 32'd0;
reg	[31:0] CNT  = 32'd0;
reg [31:0] Fre_LO = 32'd324699527;
always @ (posedge clk_in) begin
	if(cnt1 == 32'd249_999)begin
		cnt1 <= 32'd0;
		if ((cnt2 <= 32'd10800) && (cnt2 >= 32'd10600)) begin
			CNT <= cnt2;
			Fre_LO <= $signed($signed(CNT-10700) * $signed(16'd8590)) + $signed({1'b0,Fre_LO});
		end
		else begin
			Fre_LO <= 32'd324699527;
		end
	end
	else begin
		cnt1 <= cnt1 + 1'b1; 
	end
end

always @ (posedge clk_in) begin
	if(cnt1 == 32'd249_999)begin
		cnt2 <= 32'd0;
	end
	else if(SIG_IN_pose)begin
		cnt2 <= cnt2 + 1'b1;
	end
	else begin
		cnt2 <= cnt2; 
	end
end
assign LO_fre = Fre_LO;

endmodule