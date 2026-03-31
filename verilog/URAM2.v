`ifdef BSV_ASSIGNMENT_DELAY
`else
`define BSV_ASSIGNMENT_DELAY
`endif

`default_nettype none

module URAM2
  #(parameter PIPELINED  = 0,
    parameter ADDR_WIDTH = 1,
    parameter DATA_WIDTH = 1,
    parameter MEMSIZE    = 1)
   (input  wire                  CLK,
    input  wire                  ENA,
    input  wire                  WEA,
    input  wire [ADDR_WIDTH-1:0] ADDRA,
    input  wire [DATA_WIDTH-1:0] DIA,
    output wire [DATA_WIDTH-1:0] DOA,
    input  wire                  ENB,
    input  wire                  WEB,
    input  wire [ADDR_WIDTH-1:0] ADDRB,
    input  wire [DATA_WIDTH-1:0] DIB,
    output wire [DATA_WIDTH-1:0] DOB);

   (* ram_style = "ultra" *) reg [DATA_WIDTH-1:0] RAM [0:MEMSIZE-1];
   reg [DATA_WIDTH-1:0] doa_r;
   reg [DATA_WIDTH-1:0] dob_r;
   reg [DATA_WIDTH-1:0] doa_r2;
   reg [DATA_WIDTH-1:0] dob_r2;

`ifdef BSV_NO_INITIAL_BLOCKS
`else
   integer i;
   initial begin
      for (i = 0; i < MEMSIZE; i = i + 1)
         RAM[i] = {DATA_WIDTH{1'b0}};
      doa_r  = {DATA_WIDTH{1'b0}};
      dob_r  = {DATA_WIDTH{1'b0}};
      doa_r2 = {DATA_WIDTH{1'b0}};
      dob_r2 = {DATA_WIDTH{1'b0}};
   end
`endif

   // UltraRAM uses a single common clock. This wrapper keeps two BRAM-like ports
   // but both ports are synchronous to the same CLK.
   always @(posedge CLK) begin
      if (ENA) begin
         if (WEA) begin
            RAM[ADDRA] <= `BSV_ASSIGNMENT_DELAY DIA;
            doa_r      <= `BSV_ASSIGNMENT_DELAY DIA;
         end
         else begin
            doa_r      <= `BSV_ASSIGNMENT_DELAY RAM[ADDRA];
         end
      end
      doa_r2 <= `BSV_ASSIGNMENT_DELAY doa_r;
   end

   always @(posedge CLK) begin
      if (ENB) begin
         if (WEB) begin
            RAM[ADDRB] <= `BSV_ASSIGNMENT_DELAY DIB;
            dob_r      <= `BSV_ASSIGNMENT_DELAY DIB;
         end
         else begin
            dob_r      <= `BSV_ASSIGNMENT_DELAY RAM[ADDRB];
         end
      end
      dob_r2 <= `BSV_ASSIGNMENT_DELAY dob_r;
   end

   assign DOA = (PIPELINED != 0) ? doa_r2 : doa_r;
   assign DOB = (PIPELINED != 0) ? dob_r2 : dob_r;
endmodule

`default_nettype wire
