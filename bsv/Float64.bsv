package Float64;

import Vector::*;
import FIFO::*;
import FloatingPoint::*;

// -----------------------------------------------------------------------------
// Functional models for BSIM
//
// Note:
//   - The historical bluelib bdpi.cpp already provides bdpi_sqrt64,
//     bdpi_mult_double, and bdpi_divisor_double.
//   - bdpi_exp64 is new and should be added to bdpi.cpp if BSIM is used.
// -----------------------------------------------------------------------------
import "BDPI" function Bit#(64) bdpi_exp64(Bit#(64) data);
import "BDPI" function Bit#(64) bdpi_sqrt64(Bit#(64) data);
import "BDPI" function Bit#(64) bdpi_divisor_double(Bit#(64) a, Bit#(64) b);
import "BDPI" function Bit#(64) bdpi_mult_double(Bit#(64) a, Bit#(64) b);

// -----------------------------------------------------------------------------
// Latencies for a U50 / 250 MHz-oriented double-precision starting point.
//
// These are best-effort U50 defaults until the corresponding fp_*64 IP cores are
// actually generated and measured in Vivado:
//   * add/sub keep the older reference values (15)
//   * mult keeps the older reference value (16)
//   * div/sqrt use PG060's max-latency rule: FractionWidth + 4 = 53 + 4 = 57
//   * fma mirrors the 32-bit relation: add + mult - 2 = 29
//   * exp is chosen as fma + 4 = 33, mirroring the 32-bit spacing
//   * sqrt-cube is modeled as sqrt + mult = 73
// -----------------------------------------------------------------------------
typedef 16 MultLatency64;
typedef 15 AddLatency64;
typedef 15 SubLatency64;
typedef 57 DivLatency64;
typedef 57 SqrtLatency64;
typedef 29 FmaLatency64;
typedef 33 ExpLatency64;
typedef 73 SqrtCubeLatency64;

// -----------------------------------------------------------------------------
// Shared helpers
// -----------------------------------------------------------------------------
function Double bitsToDouble64(Bit#(64) x);
   return unpack(x);
endfunction

function Bit#(64) doubleToBits64(Double f);
   return pack(f);
endfunction

interface FpFilterImportIfc#(numeric type width);
   method Action enq(Bit#(width) a);
   method ActionValue#(Bit#(width)) get;
endinterface

interface FpPairImportIfc#(numeric type width);
   method Action enqa(Bit#(width) a);
   method Action enqb(Bit#(width) b);
   method ActionValue#(Bit#(width)) get;
endinterface

interface FpThreeOpImportIfc#(numeric type width);
   method Action enqa(Bit#(width) a);
   method Action enqb(Bit#(width) b);
   method Action enqc(Bit#(width) c);
   method Action enqop(Bit#(8) op);
   method ActionValue#(Bit#(width)) get;
endinterface

interface FpFilterIfc#(numeric type width);
   method Action enq(Bit#(width) a);
   method Action deq;
   method Bit#(width) first;
endinterface

interface FpPairIfc#(numeric type width);
   method Action enq(Bit#(width) a, Bit#(width) b);
   method Action deq;
   method Bit#(width) first;
endinterface

interface FpThreeOpIfc#(numeric type width);
   method Action enq(Bit#(width) a, Bit#(width) b, Bit#(width) c, Bool addition);
   method Action deq;
   method Bit#(width) first;
endinterface

// -----------------------------------------------------------------------------
// Imported floating-point IPs
// -----------------------------------------------------------------------------
import "BVI" fp_sub64 =
module mkFpSubImport64#(Clock aclk, Reset arst) (FpPairImportIfc#(64));
   default_clock no_clock;
   default_reset no_reset;

   input_clock (aclk) = aclk;
   method m_axis_result_tdata get enable(m_axis_result_tready)
                               ready(m_axis_result_tvalid)
                               clocked_by(aclk);

   method enqa(s_axis_a_tdata) enable(s_axis_a_tvalid)
                               ready(s_axis_a_tready)
                               clocked_by(aclk);
   method enqb(s_axis_b_tdata) enable(s_axis_b_tvalid)
                               ready(s_axis_b_tready)
                               clocked_by(aclk);

   schedule (get, enqa, enqb) CF (get, enqa, enqb);
endmodule

import "BVI" fp_add64 =
module mkFpAddImport64#(Clock aclk, Reset arst) (FpPairImportIfc#(64));
   default_clock no_clock;
   default_reset no_reset;

   input_clock (aclk) = aclk;
   method m_axis_result_tdata get enable(m_axis_result_tready)
                               ready(m_axis_result_tvalid)
                               clocked_by(aclk);

   method enqa(s_axis_a_tdata) enable(s_axis_a_tvalid)
                               ready(s_axis_a_tready)
                               clocked_by(aclk);
   method enqb(s_axis_b_tdata) enable(s_axis_b_tvalid)
                               ready(s_axis_b_tready)
                               clocked_by(aclk);

   schedule (get, enqa, enqb) CF (get, enqa, enqb);
endmodule

import "BVI" fp_mult64 =
module mkFpMultImport64#(Clock aclk, Reset arst) (FpPairImportIfc#(64));
   default_clock no_clock;
   default_reset no_reset;

   input_clock (aclk) = aclk;
   method m_axis_result_tdata get enable(m_axis_result_tready)
                               ready(m_axis_result_tvalid)
                               clocked_by(aclk);

   method enqa(s_axis_a_tdata) enable(s_axis_a_tvalid)
                               ready(s_axis_a_tready)
                               clocked_by(aclk);
   method enqb(s_axis_b_tdata) enable(s_axis_b_tvalid)
                               ready(s_axis_b_tready)
                               clocked_by(aclk);

   schedule (get, enqa, enqb) CF (get, enqa, enqb);
endmodule

import "BVI" fp_div64 =
module mkFpDivImport64#(Clock aclk, Reset arst) (FpPairImportIfc#(64));
   default_clock no_clock;
   default_reset no_reset;

   input_clock (aclk) = aclk;
   method m_axis_result_tdata get enable(m_axis_result_tready)
                               ready(m_axis_result_tvalid)
                               clocked_by(aclk);

   method enqa(s_axis_a_tdata) enable(s_axis_a_tvalid)
                               ready(s_axis_a_tready)
                               clocked_by(aclk);
   method enqb(s_axis_b_tdata) enable(s_axis_b_tvalid)
                               ready(s_axis_b_tready)
                               clocked_by(aclk);

   schedule (get, enqa, enqb) CF (get, enqa, enqb);
endmodule

import "BVI" fp_sqrt64 =
module mkFpSqrtImport64#(Clock aclk, Reset arst) (FpFilterImportIfc#(64));
   default_clock no_clock;
   default_reset no_reset;

   input_clock (aclk) = aclk;
   method m_axis_result_tdata get enable(m_axis_result_tready)
                               ready(m_axis_result_tvalid)
                               clocked_by(aclk);
   method enq(s_axis_a_tdata) enable(s_axis_a_tvalid)
                              ready(s_axis_a_tready)
                              clocked_by(aclk);

   schedule (get, enq) CF (get, enq);
endmodule

import "BVI" fp_exp64 =
module mkFpExpImport64#(Clock aclk, Reset arst) (FpFilterImportIfc#(64));
   default_clock no_clock;
   default_reset no_reset;

   input_clock (aclk) = aclk;
   method m_axis_result_tdata get enable(m_axis_result_tready)
                               ready(m_axis_result_tvalid)
                               clocked_by(aclk);
   method enq(s_axis_a_tdata) enable(s_axis_a_tvalid)
                              ready(s_axis_a_tready)
                              clocked_by(aclk);

   schedule (get, enq) CF (get, enq);
endmodule

import "BVI" fp_fma64 =
module mkFpFmaImport64#(Clock aclk, Reset arst) (FpThreeOpImportIfc#(64));
   default_clock no_clock;
   default_reset no_reset;

   input_clock (aclk) = aclk;
   method m_axis_result_tdata get enable(m_axis_result_tready)
                               ready(m_axis_result_tvalid)
                               clocked_by(aclk);

   method enqa(s_axis_a_tdata) enable(s_axis_a_tvalid)
                               ready(s_axis_a_tready)
                               clocked_by(aclk);
   method enqb(s_axis_b_tdata) enable(s_axis_b_tvalid)
                               ready(s_axis_b_tready)
                               clocked_by(aclk);
   method enqc(s_axis_c_tdata) enable(s_axis_c_tvalid)
                               ready(s_axis_c_tready)
                               clocked_by(aclk);
   method enqop(s_axis_operation_tdata) enable(s_axis_operation_tvalid)
                                        ready(s_axis_operation_tready)
                                        clocked_by(aclk);

   schedule (get, enqa, enqb, enqc, enqop) CF (get, enqa, enqb, enqc, enqop);
endmodule

module mkFpSub64 (FpPairIfc#(64));
   Clock curClk <- exposeCurrentClock;
   Reset curRst <- exposeCurrentReset;

   FIFO#(Bit#(64)) outQ <- mkFIFO;
`ifdef BSIM
   Vector#(SubLatency64, FIFO#(Bit#(64))) latencyQs <- replicateM(mkFIFO);
   for (Integer i = 0; i < valueOf(SubLatency64)-1; i = i + 1) begin
      rule relay;
         latencyQs[i].deq;
         latencyQs[i+1].enq(latencyQs[i].first);
      endrule
   end
   rule relayOut;
      Integer lastIdx = valueOf(SubLatency64)-1;
      latencyQs[lastIdx].deq;
      outQ.enq(latencyQs[lastIdx].first);
   endrule
`else
   FpPairImportIfc#(64) fp_sub <- mkFpSubImport64(curClk, curRst);
   rule getOut;
      let v <- fp_sub.get;
      outQ.enq(v);
   endrule
`endif

   method Action enq(Bit#(64) a, Bit#(64) b);
`ifdef BSIM
      Double fm = bitsToDouble64(a) - bitsToDouble64(b);
      latencyQs[0].enq(doubleToBits64(fm));
`else
      fp_sub.enqa(a);
      fp_sub.enqb(b);
`endif
   endmethod

   method Action deq;
      outQ.deq;
   endmethod

   method Bit#(64) first;
      return outQ.first;
   endmethod
endmodule

module mkFpAdd64 (FpPairIfc#(64));
   Clock curClk <- exposeCurrentClock;
   Reset curRst <- exposeCurrentReset;

   FIFO#(Bit#(64)) outQ <- mkFIFO;
`ifdef BSIM
   Vector#(AddLatency64, FIFO#(Bit#(64))) latencyQs <- replicateM(mkFIFO);
   for (Integer i = 0; i < valueOf(AddLatency64)-1; i = i + 1) begin
      rule relay;
         latencyQs[i].deq;
         latencyQs[i+1].enq(latencyQs[i].first);
      endrule
   end
   rule relayOut;
      Integer lastIdx = valueOf(AddLatency64)-1;
      latencyQs[lastIdx].deq;
      outQ.enq(latencyQs[lastIdx].first);
   endrule
`else
   FpPairImportIfc#(64) fp_add <- mkFpAddImport64(curClk, curRst);
   rule getOut;
      let v <- fp_add.get;
      outQ.enq(v);
   endrule
`endif

   method Action enq(Bit#(64) a, Bit#(64) b);
`ifdef BSIM
      Double fm = bitsToDouble64(a) + bitsToDouble64(b);
      latencyQs[0].enq(doubleToBits64(fm));
`else
      fp_add.enqa(a);
      fp_add.enqb(b);
`endif
   endmethod

   method Action deq;
      outQ.deq;
   endmethod

   method Bit#(64) first;
      return outQ.first;
   endmethod
endmodule

module mkFpMult64 (FpPairIfc#(64));
   Clock curClk <- exposeCurrentClock;
   Reset curRst <- exposeCurrentReset;

   FIFO#(Bit#(64)) outQ <- mkFIFO;
`ifdef BSIM
   Vector#(MultLatency64, FIFO#(Bit#(64))) latencyQs <- replicateM(mkFIFO);
   for (Integer i = 0; i < valueOf(MultLatency64)-1; i = i + 1) begin
      rule relay;
         latencyQs[i].deq;
         latencyQs[i+1].enq(latencyQs[i].first);
      endrule
   end
   rule relayOut;
      Integer lastIdx = valueOf(MultLatency64)-1;
      latencyQs[lastIdx].deq;
      outQ.enq(latencyQs[lastIdx].first);
   endrule
`else
   FpPairImportIfc#(64) fp_mult <- mkFpMultImport64(curClk, curRst);
   rule getOut;
      let v <- fp_mult.get;
      outQ.enq(v);
   endrule
`endif

   method Action enq(Bit#(64) a, Bit#(64) b);
`ifdef BSIM
      latencyQs[0].enq(bdpi_mult_double(a, b));
`else
      fp_mult.enqa(a);
      fp_mult.enqb(b);
`endif
   endmethod

   method Action deq;
      outQ.deq;
   endmethod

   method Bit#(64) first;
      return outQ.first;
   endmethod
endmodule

module mkFpDiv64 (FpPairIfc#(64));
   Clock curClk <- exposeCurrentClock;
   Reset curRst <- exposeCurrentReset;

   FIFO#(Bit#(64)) outQ <- mkFIFO;
`ifdef BSIM
   Vector#(DivLatency64, FIFO#(Bit#(64))) latencyQs <- replicateM(mkFIFO);
   for (Integer i = 0; i < valueOf(DivLatency64)-1; i = i + 1) begin
      rule relay;
         latencyQs[i].deq;
         latencyQs[i+1].enq(latencyQs[i].first);
      endrule
   end
   rule relayOut;
      Integer lastIdx = valueOf(DivLatency64)-1;
      latencyQs[lastIdx].deq;
      outQ.enq(latencyQs[lastIdx].first);
   endrule
`else
   FpPairImportIfc#(64) fp_div <- mkFpDivImport64(curClk, curRst);
   rule getOut;
      let v <- fp_div.get;
      outQ.enq(v);
   endrule
`endif

   method Action enq(Bit#(64) a, Bit#(64) b);
`ifdef BSIM
      latencyQs[0].enq(bdpi_divisor_double(a, b));
`else
      fp_div.enqa(a);
      fp_div.enqb(b);
`endif
   endmethod

   method Action deq;
      outQ.deq;
   endmethod

   method Bit#(64) first;
      return outQ.first;
   endmethod
endmodule

module mkFpSqrt64 (FpFilterIfc#(64));
   Clock curClk <- exposeCurrentClock;
   Reset curRst <- exposeCurrentReset;

   FIFO#(Bit#(64)) outQ <- mkFIFO;
`ifdef BSIM
   Vector#(SqrtLatency64, FIFO#(Bit#(64))) latencyQs <- replicateM(mkFIFO);
   for (Integer i = 0; i < valueOf(SqrtLatency64)-1; i = i + 1) begin
      rule relay;
         latencyQs[i].deq;
         latencyQs[i+1].enq(latencyQs[i].first);
      endrule
   end
   rule relayOut;
      Integer lastIdx = valueOf(SqrtLatency64)-1;
      latencyQs[lastIdx].deq;
      outQ.enq(latencyQs[lastIdx].first);
   endrule
`else
   FpFilterImportIfc#(64) fp_sqrt <- mkFpSqrtImport64(curClk, curRst);
   rule getOut;
      let v <- fp_sqrt.get;
      outQ.enq(v);
   endrule
`endif

   method Action enq(Bit#(64) a);
`ifdef BSIM
      latencyQs[0].enq(bdpi_sqrt64(a));
`else
      fp_sqrt.enq(a);
`endif
   endmethod

   method Action deq;
      outQ.deq;
   endmethod

   method Bit#(64) first;
      return outQ.first;
   endmethod
endmodule

module mkFpExp64 (FpFilterIfc#(64));
   Clock curClk <- exposeCurrentClock;
   Reset curRst <- exposeCurrentReset;

   FIFO#(Bit#(64)) outQ <- mkFIFO;
`ifdef BSIM
   Vector#(ExpLatency64, FIFO#(Bit#(64))) latencyQs <- replicateM(mkFIFO);
   for (Integer i = 0; i < valueOf(ExpLatency64)-1; i = i + 1) begin
      rule relay;
         latencyQs[i].deq;
         latencyQs[i+1].enq(latencyQs[i].first);
      endrule
   end
   rule relayOut;
      Integer lastIdx = valueOf(ExpLatency64)-1;
      latencyQs[lastIdx].deq;
      outQ.enq(latencyQs[lastIdx].first);
   endrule
`else
   FpFilterImportIfc#(64) fp_exp <- mkFpExpImport64(curClk, curRst);
   rule getOut;
      let v <- fp_exp.get;
      outQ.enq(v);
   endrule
`endif

   method Action enq(Bit#(64) a);
`ifdef BSIM
      latencyQs[0].enq(bdpi_exp64(a));
`else
      fp_exp.enq(a);
`endif
   endmethod

   method Action deq;
      outQ.deq;
   endmethod

   method Bit#(64) first;
      return outQ.first;
   endmethod
endmodule

module mkFpFma64 (FpThreeOpIfc#(64));
   Clock curClk <- exposeCurrentClock;
   Reset curRst <- exposeCurrentReset;

   FIFO#(Bit#(64)) outQ <- mkFIFO;
`ifdef BSIM
   Vector#(FmaLatency64, FIFO#(Bit#(64))) latencyQs <- replicateM(mkFIFO);
   for (Integer i = 0; i < valueOf(FmaLatency64)-1; i = i + 1) begin
      rule relay;
         latencyQs[i].deq;
         latencyQs[i+1].enq(latencyQs[i].first);
      endrule
   end
   rule relayOut;
      Integer lastIdx = valueOf(FmaLatency64)-1;
      latencyQs[lastIdx].deq;
      outQ.enq(latencyQs[lastIdx].first);
   endrule
`else
   FpThreeOpImportIfc#(64) fp_fma <- mkFpFmaImport64(curClk, curRst);
   rule getOut;
      let v <- fp_fma.get;
      outQ.enq(v);
   endrule
`endif

   method Action enq(Bit#(64) a, Bit#(64) b, Bit#(64) c, Bool addition);
`ifdef BSIM
      Double prod = bitsToDouble64(bdpi_mult_double(a, b));
      Double fm   = addition ? (prod + bitsToDouble64(c))
                             : (prod - bitsToDouble64(c));
      latencyQs[0].enq(doubleToBits64(fm));
`else
      fp_fma.enqa(a);
      fp_fma.enqb(b);
      fp_fma.enqc(c);
      fp_fma.enqop(addition ? 8'd0 : 8'd1);
`endif
   endmethod

   method Action deq;
      outQ.deq;
   endmethod

   method Bit#(64) first;
      return outQ.first;
   endmethod
endmodule

module mkFpSqrtCube64 (FpFilterIfc#(64));
   Clock curClk <- exposeCurrentClock;
   Reset curRst <- exposeCurrentReset;

   FIFO#(Bit#(64)) outQ <- mkFIFO;
`ifdef BSIM
   Vector#(SqrtCubeLatency64, FIFO#(Bit#(64))) latencyQs <- replicateM(mkFIFO);
   for (Integer i = 0; i < valueOf(SqrtCubeLatency64)-1; i = i + 1) begin
      rule relay;
         latencyQs[i].deq;
         latencyQs[i+1].enq(latencyQs[i].first);
      endrule
   end
   rule relayOut;
      Integer lastIdx = valueOf(SqrtCubeLatency64)-1;
      latencyQs[lastIdx].deq;
      outQ.enq(latencyQs[lastIdx].first);
   endrule
`else
   FpFilterImportIfc#(64) fp_sqrt <- mkFpSqrtImport64(curClk, curRst);
   FpPairImportIfc#(64)   fp_mult <- mkFpMultImport64(curClk, curRst);

   // Delay the original input by the sqrt latency so that the multiplier sees
   // (sqrt(a), a) in the same cycle.
   Vector#(SqrtLatency64, FIFO#(Bit#(64))) relayQs <- replicateM(mkFIFO);
   for (Integer i = 0; i < valueOf(SqrtLatency64)-1; i = i + 1) begin
      rule relayInput;
         relayQs[i].deq;
         relayQs[i+1].enq(relayQs[i].first);
      endrule
   end

   rule getSqrt;
      Integer lastIdx = valueOf(SqrtLatency64)-1;
      let root <- fp_sqrt.get;
      let a    = relayQs[lastIdx].first;
      relayQs[lastIdx].deq;
      fp_mult.enqa(root);
      fp_mult.enqb(a);
   endrule

   rule getOut;
      let v <- fp_mult.get;
      outQ.enq(v);
   endrule
`endif

   method Action enq(Bit#(64) a);
`ifdef BSIM
      Bit#(64) root = bdpi_sqrt64(a);
      latencyQs[0].enq(bdpi_mult_double(root, a));
`else
      fp_sqrt.enq(a);
      relayQs[0].enq(a);
`endif
   endmethod

   method Action deq;
      outQ.deq;
   endmethod

   method Bit#(64) first;
      return outQ.first;
   endmethod
endmodule

endpackage: Float64
