`timescale 1 ns / 1 ns

module CIC_Down #
(
	parameter SECTIONS     = 3,
	parameter FACTOR       = 3,
	parameter INPUT_WIDTH  = 12,
	parameter OUTPUT_WIDTH = 38
)
(
	input   clk,
	input   clk_enable,
	input   reset,
	input   signed [INPUT_WIDTH-1:0]  filter_in,
	output  signed [OUTPUT_WIDTH-1:0] filter_out,
	output  ce_out
);

	reg  [15:0] cur_count; // ufix9
	wire phase_1; // boolean
	reg  ce_out_reg; // boolean

	reg  signed [INPUT_WIDTH-1:0]  input_register; 

	wire signed [INPUT_WIDTH-1:0]  section_in[1:6]; 
	reg  signed [OUTPUT_WIDTH-1:0] section_out[1:6];

	wire signed [OUTPUT_WIDTH-1:0] sum[1:3];      
	wire signed [OUTPUT_WIDTH-1:0] add_cast[0:5]; 
	wire signed [OUTPUT_WIDTH:0]   add_temp[0:2]; 

	reg  signed [OUTPUT_WIDTH-1:0] diff[1:3]; 
	wire signed [OUTPUT_WIDTH-1:0] sub_cast[0:5]; 
	wire signed [OUTPUT_WIDTH:0]   sub_temp[0:2]; 

	reg  signed [OUTPUT_WIDTH-1:0] output_register; 

  // Block Statements
  //   ------------------ CE Output Generation ------------------
	always @ (posedge clk or posedge reset) begin: ce_output
		if (reset == 1'b1) begin
			cur_count <= 16'd0;
		end
		else begin
			if (clk_enable == 1'b1) begin
				if (cur_count == FACTOR) begin
					cur_count <= 16'd0;
				end
				else begin
					cur_count <= cur_count + 1;
				end
			end
		end
	end // ce_output
	assign  phase_1 = (cur_count == 16'd1 && clk_enable == 1'b1)? 1 : 0;
  //   ------------------ CE Output Register ------------------
	always @ (posedge clk or posedge reset) begin: ce_output_register
		if (reset == 1'b1) begin
			ce_out_reg <= 1'b0;
		end
		else begin
			ce_out_reg <= phase_1;
		end
	end // ce_output_register
  //   ------------------ Input Register ------------------
	always @ (posedge clk or posedge reset) begin: input_reg_process
		if (reset == 1'b1) begin
			input_register <= 0;
		end
		else begin
			if (clk_enable == 1'b1) begin
				input_register <= filter_in;
			end
		end
	end // input_reg_process
  //   ------------------ Section # : Integrator ------------------
	assign section_in[1] = $signed({{(OUTPUT_WIDTH-INPUT_WIDTH){input_register[INPUT_WIDTH-1]}}, input_register});

	genvar j;
	generate for(j=1;j<=SECTIONS;j=j+1) begin : U
		assign sub_cast[2*(j-1)]   = section_in[j+3];
		assign add_cast[2*(j-1)]   = section_in[j];
		assign add_cast[2*(j-1)+1] = section_out[j];
		assign sub_cast[2*(j-1)+1] = diff[j];

		assign sum[j]              = add_temp[j-1][OUTPUT_WIDTH-1:0];
		assign section_out[j+3]    = sub_temp[j-1][OUTPUT_WIDTH-1:0];

		assign add_temp[j-1]       = add_cast[2*(j-1)] + add_cast[2*(j-1)+1];
		assign sub_temp[j-1]       = sub_cast[2*(j-1)] - sub_cast[2*(j-1)+1];
	end
	endgenerate

	integer m;
	always @ (posedge clk or posedge reset) begin: integrator_delay_section
		if (reset == 1'b1) begin
			for (m = 1; m<=SECTIONS; m=m+1) begin
				section_out[m] <= 0;
			end
		end
		else begin
			if (clk_enable == 1'b1) begin
				for (m = 1; m<=SECTIONS; m=m+1) begin
					section_out[m] <= sum[m];
				end
			end
		end
	end
  //   ------------------ Section # : Comb ------------------
	genvar i;
	generate for(i=1;i<2*SECTIONS;i=i+1) begin : U
		assign section_in[i+1] = section_out[i];
	end
	endgenerate

	integer n;
	always @ (posedge clk or posedge reset) begin: comb_delay_section
		if (reset == 1'b1) begin
			for (n = 1; n<=SECTIONS; n=n+1) begin
				diff[n] <= 0;
			end
		end
		else begin
			if (phase_1 == 1'b1) begin
				for (n = 1; n<=SECTIONS; n=n+1) begin
					diff[n] <= section_in[n+3];
				end
			end
		end
	end
  //   ------------------ Output Register ------------------
	always @ (posedge clk or posedge reset) begin: output_reg_process
		if (reset == 1'b1) begin
		output_register <= 0;
		end
		else begin
			if (phase_1 == 1'b1) begin
				output_register <= section_out6;
			end
		end
	end
	assign ce_out = ce_out_reg;
	assign filter_out = output_register;

endmodule  // CIC_Down
