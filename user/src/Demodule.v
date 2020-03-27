module Demodule #(
	parameter IQ_WIDTH     = 12,
	parameter INPUT_WIDTH  = 8,
	parameter OUTPUT_WIDTH = 24
)
(
    input                       clk_in,
    output                      clk_out,  
    input                       RST,

    input  [INPUT_WIDTH - 1:0]  data_in,
    output [OUTPUT_WIDTH - 1:0] Demodule_OUT
);

wire signed [IQ_WIDTH-1:0] I_SIG;
wire signed [IQ_WIDTH-1:0] Q_SIG;
IQ_Demodule #
(
	.INPUT_WIDTH(INPUT_WIDTH),
	.OUTPUT_WIDTH(IQ_WIDTH)
)
IQ_Demodule_u(
    .clk_in(clk_in),
    .clk_out(clk_out),
    .RST(RST),
    .LO_fre(32'd459561501),
    .data_in(data_in),
    .I_OUT(I_SIG),
    .Q_OUT(Q_SIG)
);

wire        [IQ_WIDTH-1:0] Y_diff;
wire        [IQ_WIDTH-1:0] Modulus;
wire        [31:0] phase_out;
Cordic #
(
    .XY_BITS(IQ_WIDTH),               
    .PH_BITS(32),                //1~32
    .ITERATIONS(16),             //1~32
    .CORDIC_STYLE("VECTOR")      //ROTATE  //VECTOR
)
Demodule_Gen_u 
(
    .clk_in(clk_in),
    .RST(RST),
    .x_i(I_SIG), 
    .y_i(Q_SIG),
    .phase_in(0),          
     
    .x_o(Modulus),
    .y_o(Y_diff),
    .phase_out(phase_out)
);

endmodule