`default_nettype none

module URAMFIFO
  #(parameter integer DATA_WIDTH = 1,
    parameter integer DEPTH      = 16)
   (input  wire                  CLK,
    input  wire                  RST,
    input  wire                  ENQ,
    input  wire [DATA_WIDTH-1:0] DI,
    input  wire                  DEQ,
    input  wire                  CLR,
    output wire [DATA_WIDTH-1:0] DO,
    output wire                  FULL_N,
    output wire                  EMPTY_N);

   localparam integer COUNT_W = (DEPTH <= 2) ? 1 : $clog2(DEPTH + 1);
   localparam integer PROG_EMPTY_THRESH_I = 1;
   localparam integer PROG_FULL_THRESH_I  = (DEPTH > 1) ? (DEPTH - 1) : 1;

   wire [DATA_WIDTH-1:0] dout;
   wire                  full;
   wire                  empty;
   wire                  rd_rst_busy;
   wire                  wr_rst_busy;
   wire                  rst_i = RST | CLR;

   xpm_fifo_sync #(
      .DOUT_RESET_VALUE   ("0"),
      .ECC_MODE           ("no_ecc"),
      .FIFO_MEMORY_TYPE   ("ultra"),
      .FIFO_READ_LATENCY  (0),
      .FIFO_WRITE_DEPTH   (DEPTH),
      .FULL_RESET_VALUE   (0),
      .PROG_EMPTY_THRESH  (PROG_EMPTY_THRESH_I),
      .PROG_FULL_THRESH   (PROG_FULL_THRESH_I),
      .RD_DATA_COUNT_WIDTH(COUNT_W),
      .READ_DATA_WIDTH    (DATA_WIDTH),
      .READ_MODE          ("fwft"),
      .SIM_ASSERT_CHK     (0),
      .USE_ADV_FEATURES   ("0000"),
      .WAKEUP_TIME        (0),
      .WRITE_DATA_WIDTH   (DATA_WIDTH),
      .WR_DATA_COUNT_WIDTH(COUNT_W)
   ) xpm_fifo_sync_inst (
      .almost_empty (),
      .almost_full  (),
      .data_valid   (),
      .dbiterr      (),
      .dout         (dout),
      .empty        (empty),
      .full         (full),
      .overflow     (),
      .prog_empty   (),
      .prog_full    (),
      .rd_data_count(),
      .rd_rst_busy  (rd_rst_busy),
      .sbiterr      (),
      .underflow    (),
      .wr_ack       (),
      .wr_data_count(),
      .wr_rst_busy  (wr_rst_busy),
      .din          (DI),
      .injectdbiterr(1'b0),
      .injectsbiterr(1'b0),
      .rd_en        (DEQ & ~empty & ~rd_rst_busy),
      .rst          (rst_i),
      .sleep        (1'b0),
      .wr_clk       (CLK),
      .wr_en        (ENQ & ~full & ~wr_rst_busy)
   );

   assign DO      = dout;
   assign FULL_N  = ~full;
   assign EMPTY_N = ~empty;
endmodule

`default_nettype wire
