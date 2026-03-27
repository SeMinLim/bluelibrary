//=============================================================================
// File: URAM2.v
// Description: Parameterized True Dual Port UltraRAM for Bluespec Integration
//=============================================================================
module URAM2 #(
		parameter DATA_WIDTH = 512,
		parameter ADDR_WIDTH = 10
	)(
		// Port A
		input  wire CLKA,
		input  wire ENA,
		input  wire WEA,
		input  wire [ADDR_WIDTH-1:0] ADDRA,
		input  wire [DATA_WIDTH-1:0] DIA,
		output reg  [DATA_WIDTH-1:0] DOA,

		// Port B
		input  wire CLKB,
		input  wire ENB,
		input  wire WEB,
		input  wire [ADDR_WIDTH-1:0] ADDRB,
		input  wire [DATA_WIDTH-1:0] DIB,
		output reg  [DATA_WIDTH-1:0] DOB
);
	(* ram_style = "ultra" *)
	reg [DATA_WIDTH-1:0] ram [0:(1<<ADDR_WIDTH)-1];

	always @(posedge CLKA) begin
		if (ENA) begin
			if (WEA) ram[ADDRA] <= DIA;
			DOA <= ram[ADDRA];
		end
	end

	always @(posedge CLKB) begin
		if (ENB) begin
			if (WEB) ram[ADDRB] <= DIB;
			DOB <= ram[ADDRB];
		end
	end
endmodule
