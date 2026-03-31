`ifdef BSV_ASSIGNMENT_DELAY
`else
`define BSV_ASSIGNMENT_DELAY
`endif

`default_nettype none

module URAM1
  #(parameter PIPELINED  = 0,
    parameter ADDR_WIDTH = 1,
    parameter DATA_WIDTH = 1,
    parameter MEMSIZE    = 1)
   (input  wire                  CLK,
    input  wire                  EN,
    input  wire                  WE,
    input  wire [ADDR_WIDTH-1:0] ADDR,
    input  wire [DATA_WIDTH-1:0] DI,
    output wire [DATA_WIDTH-1:0] DO);

   (* ram_style = "ultra" *) reg [DATA_WIDTH-1:0] RAM [0:MEMSIZE-1];
   reg [DATA_WIDTH-1:0] do_r;
   reg [DATA_WIDTH-1:0] do_r2;

`ifdef BSV_NO_INITIAL_BLOCKS
`else
   integer i;
   initial begin
      for (i = 0; i < MEMSIZE; i = i + 1)
         RAM[i] = {DATA_WIDTH{1'b0}};
      do_r  = {DATA_WIDTH{1'b0}};
      do_r2 = {DATA_WIDTH{1'b0}};
   end
`endif

   always @(posedge CLK) begin
      if (EN) begin
         if (WE) begin
            RAM[ADDR] <= `BSV_ASSIGNMENT_DELAY DI;
            do_r      <= `BSV_ASSIGNMENT_DELAY DI;
         end
         else begin
            do_r      <= `BSV_ASSIGNMENT_DELAY RAM[ADDR];
         end
      end
      do_r2 <= `BSV_ASSIGNMENT_DELAY do_r;
   end

   assign DO = (PIPELINED != 0) ? do_r2 : do_r;
endmodule

`default_nettype wire
