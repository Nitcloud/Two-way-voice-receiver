module FM_Demodule
(
    input                          clk_in,
    input                          RST,

    input  [INPUT_WIDTH  - 1 : 0]  I_IN,
    input  [INPUT_WIDTH  - 1 : 0]  Q_IN,
    output [OUTPUT_WIDTH - 1 : 0]  Demodule_OUT
);

parameter INPUT_WIDTH  = 12;
parameter OUTPUT_WIDTH = 24;

reg  [INPUT_WIDTH - 1 : 0]  I_data_1;
reg  [INPUT_WIDTH - 1 : 0]  I_data_2;
reg  [INPUT_WIDTH - 1 : 0]  Q_data_1;
reg  [INPUT_WIDTH - 1 : 0]  Q_data_2;
always@(posedge clk_in)
begin
	if (RST) begin
		I_data_1 <= 0;
		Q_data_1 <= 0;
		I_data_2 <= 0;
		Q_data_2 <= 0;
	end
	else begin
		I_data_1 <= I_IN;
		Q_data_1 <= Q_IN;
		I_data_2 <= I_data_1;
		Q_data_2 <= Q_data_1;
	end
end

reg  [2 * INPUT_WIDTH - 1 : 0]  IQ_data;
reg  [2 * INPUT_WIDTH - 1 : 0]  QI_data;
always@(posedge clk_in)
begin
	if (RST) begin
		IQ_data <= 0;
		QI_data <= 0;
	end
	else begin
		IQ_data <= $signed(I_data_1) * $signed(Q_data_2);
		QI_data <= $signed(Q_data_1) * $signed(I_data_2);
	end
end

// reg  [2 * INPUT_WIDTH - 1 : 0]  I_self_data;
// reg  [2 * INPUT_WIDTH - 1 : 0]  Q_self_data;
// always@(posedge clk_in)
// begin
// 	if (RST) begin
// 		I_self_data <= 0;
// 		Q_self_data <= 0;
// 	end
// 	else begin
// 		I_self_data <= $signed(I_data_1) * $signed(I_data_1);
// 		Q_self_data <= $signed(Q_data_1) * $signed(Q_data_1);
// 	end
// end

reg  [2 * INPUT_WIDTH - 1 : 0]  data_diff;
// reg  [2 * INPUT_WIDTH - 1 : 0]  data_add;
always@(posedge clk_in)
begin
	if (RST) begin
		data_diff <= 0;
		// data_add  <= 0;
	end
	else begin
		data_diff <= $signed(QI_data) - $signed(IQ_data);
		// data_add  <= $signed(I_self_data) + $signed(Q_self_data);
	end
end

// reg  [2 * INPUT_WIDTH - 1 : 0]  Demodule_OUT_r;
// always@(posedge clk_in)
// begin
// 	if (RST) begin
// 		Demodule_OUT_r <= 0;
// 	end
// 	else begin
// 		Demodule_OUT_r <= $signed(data_add) / $signed(data_diff);
// 	end
// end
// assign Demodule_OUT = Demodule_OUT_r[2 * INPUT_WIDTH - 1 : 2 * INPUT_WIDTH - OUTPUT_WIDTH - 1];

assign Demodule_OUT = data_diff[2 * INPUT_WIDTH - 1 : 2 * INPUT_WIDTH - OUTPUT_WIDTH];

endmodule