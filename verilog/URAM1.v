//=============================================================================
// File: URAM1.v
// Description: Parameterized Single Port UltraRAM for Bluespec Integration
//=============================================================================
module URAM1 #(
		parameter DATA_WIDTH = 512,
		parameter ADDR_WIDTH = 10
	)(
		input  wire CLKA,
		input  wire ENA,
		input  wire WEA,
		input  wire [ADDR_WIDTH-1:0] ADDRA,
		input  wire [DATA_WIDTH-1:0] DIA,
		output reg  [DATA_WIDTH-1:0] DOA
);
	(* ram_style = "ultra" *)
	reg [DATA_WIDTH-1:0] ram [0:(1<<ADDR_WIDTH)-1];

	always @(posedge CLKA) begin
		if (ENA) begin
			if (WEA) begin
				ram[ADDRA] <= DIA;
			end
			DOA <= ram[ADDRA];
		end
	end
endmodule
