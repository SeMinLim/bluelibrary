package Serializer;

import FIFO::*;
import SpecialFIFOs::*;
import Vector::*;
import Assert::*;

interface SerializerIfc#(numeric type srcSz, numeric type multiplier);
   method Action put(Bit#(srcSz) data);
   method ActionValue#(Bit#(TDiv#(srcSz, multiplier))) get;
endinterface

interface DeSerializerIfc#(numeric type srcSz, numeric type multiplier);
   method Action put(Bit#(srcSz) data);
   method ActionValue#(Bit#(TMul#(srcSz, multiplier))) get;
endinterface

interface PipelineShiftIfc#(numeric type sz, numeric type shiftsz);
   method Action put(Bit#(sz) v, Bit#(shiftsz) shift);
   method ActionValue#(Bit#(sz)) get;
endinterface

interface SerializerFreeformIfc#(numeric type srcSz, numeric type dstSz);
   method Action put(Bit#(srcSz) data);
   method ActionValue#(Bit#(dstSz)) get;
endinterface

function Bit#(TAdd#(n, n)) lowExtended(Bit#(n) x);
   Bit#(n) zeros = 0;
   return { zeros, x };
endfunction

function Bit#(TAdd#(n, n)) joinedWords(Bit#(n) hi, Bit#(n) lo);
   return { hi, lo };
endfunction

module mkSerializer(SerializerIfc#(srcSz, multiplier))
   provisos (
      Div#(srcSz, multiplier, dstSz),
      Add#(1, a__, multiplier),
      Add#(b__, dstSz, srcSz)
   );

   FIFO#(Bit#(srcSz)) inQ  <- mkFIFO;
   FIFO#(Bit#(dstSz)) outQ <- mkFIFO;

   Reg#(Bit#(srcSz)) buffer <- mkReg(0);
   Reg#(UInt#(TAdd#(1, TLog#(multiplier)))) piecesLeft <- mkReg(0);

   rule loadNewWord (piecesLeft == 0);
      let d = inQ.first;
      inQ.deq;

      outQ.enq(truncate(d));
      buffer <= d >> valueOf(dstSz);
      piecesLeft <= fromInteger(valueOf(multiplier) - 1);
   endrule

   rule emitBufferedWord (piecesLeft > 0);
      outQ.enq(truncate(buffer));
      buffer <= buffer >> valueOf(dstSz);
      piecesLeft <= piecesLeft - 1;
   endrule

   method Action put(Bit#(srcSz) data);
      inQ.enq(data);
   endmethod

   method ActionValue#(Bit#(dstSz)) get;
      let d = outQ.first;
      outQ.deq;
      return d;
   endmethod
endmodule

module mkStreamReplicate#(Integer framesize)(FIFO#(dtype))
   provisos(Bits#(dtype, dtypeSz));

   staticAssert(framesize > 0,   "mkStreamReplicate framesize must be larger than 0");
   staticAssert(framesize < 256, "mkStreamReplicate framesize must be less than 256");

   Reg#(UInt#(8)) repCount <- mkReg(0);
   Reg#(dtype)    buffer   <- mkRegU;
   FIFO#(dtype)   inQ      <- mkFIFO;
   FIFO#(dtype)   outQ     <- mkFIFO;

   rule loadNewValue (repCount == 0);
      let d = inQ.first;
      inQ.deq;

      outQ.enq(d);
      buffer <= d;
      repCount <= fromInteger(framesize - 1);
   endrule

   rule emitReplica (repCount > 0);
      outQ.enq(buffer);
      repCount <= repCount - 1;
   endrule

   method Action enq(dtype data);
      inQ.enq(data);
   endmethod

   method Action deq;
      outQ.deq;
   endmethod

   method dtype first;
      return outQ.first;
   endmethod

   method Action clear;
      inQ.clear;
      outQ.clear;
      repCount <= 0;
   endmethod
endmodule

module mkStreamSerializeLast#(Integer framesize)(FIFO#(Bool));
   staticAssert(framesize > 0,   "mkStreamSerializeLast framesize must be larger than 0");
   staticAssert(framesize < 256, "mkStreamSerializeLast framesize must be less than 256");

   Reg#(UInt#(8)) repCount    <- mkReg(0);
   Reg#(Bool)     pendingLast <- mkReg(False);
   FIFO#(Bool)    inQ         <- mkFIFO;
   FIFO#(Bool)    outQ        <- mkFIFO;

   rule loadNewFlag (repCount == 0);
      let d = inQ.first;
      inQ.deq;

      if (framesize == 1) begin
         outQ.enq(d);
         pendingLast <= False;
         repCount <= 0;
      end
      else begin
         outQ.enq(False);
         pendingLast <= d;
         repCount <= fromInteger(framesize - 1);
      end
   endrule

   rule emitTailFlag (repCount > 0);
      if (repCount == 1) begin
         outQ.enq(pendingLast);
      end
      else begin
         outQ.enq(False);
      end
      repCount <= repCount - 1;
   endrule

   method Action enq(Bool data);
      inQ.enq(data);
   endmethod

   method Action deq;
      outQ.deq;
   endmethod

   method Bool first;
      return outQ.first;
   endmethod

   method Action clear;
      inQ.clear;
      outQ.clear;
      repCount <= 0;
      pendingLast <= False;
   endmethod
endmodule

module mkDeSerializer(DeSerializerIfc#(srcSz, multiplier))
   provisos (
      Mul#(srcSz, multiplier, dstSz),
      Add#(1, a__, multiplier),
      Add#(b__, srcSz, dstSz)
   );

   FIFO#(Bit#(srcSz)) inQ  <- mkFIFO;
   FIFO#(Bit#(dstSz)) outQ <- mkFIFO;

   Reg#(Bit#(dstSz)) buffer <- mkReg(0);
   Reg#(UInt#(TAdd#(1, TLog#(multiplier)))) count <- mkReg(0);

   Integer shiftup = (valueOf(multiplier) - 1) * valueOf(srcSz);

   rule accumulate;
      let d = inQ.first;
      inQ.deq;

      Bit#(dstSz) nextBuffer = (buffer >> valueOf(srcSz)) | (zeroExtend(d) << shiftup);

      if (count == fromInteger(valueOf(multiplier) - 1)) begin
         outQ.enq(nextBuffer);
         buffer <= 0;
         count <= 0;
      end
      else begin
         buffer <= nextBuffer;
         count <= count + 1;
      end
   endrule

   method Action put(Bit#(srcSz) data);
      inQ.enq(data);
   endmethod

   method ActionValue#(Bit#(dstSz)) get;
      let d = outQ.first;
      outQ.deq;
      return d;
   endmethod
endmodule

module mkStreamSkip#(Integer framesize, Integer offset)(FIFO#(dtype))
   provisos(Bits#(dtype, dtypeSz));

   staticAssert(framesize > 0,      "mkStreamSkip framesize must be larger than 0");
   staticAssert(framesize < 256,    "mkStreamSkip framesize must be less than 256");
   staticAssert(offset >= 0,        "mkStreamSkip offset must be non-negative");
   staticAssert(offset < framesize, "mkStreamSkip offset must be less than the framesize");

   Reg#(UInt#(8)) skipIdx <- mkReg(0);
   FIFO#(dtype)   outQ    <- mkFIFO;

   method Action enq(dtype data);
      if (skipIdx == fromInteger(offset)) begin
         outQ.enq(data);
      end

      if (skipIdx + 1 >= fromInteger(framesize)) begin
         skipIdx <= 0;
      end
      else begin
         skipIdx <= skipIdx + 1;
      end
   endmethod

   method Action deq;
      outQ.deq;
   endmethod

   method dtype first;
      return outQ.first;
   endmethod

   method Action clear;
      outQ.clear;
      skipIdx <= 0;
   endmethod
endmodule

module mkPipelineShiftStage#(
      Integer stageIdx,
      FIFO#(Tuple2#(Bit#(sz), Bit#(shiftsz))) inQ,
      FIFO#(Tuple2#(Bit#(sz), Bit#(shiftsz))) outQ
   )(Empty);

   rule doStage;
      let args = inQ.first;
      inQ.deq;

      let val   = tpl_1(args);
      let shift = tpl_2(args);
      Bit#(sz) nextVal = (shift[stageIdx] == 1'b1) ? (val >> (1 << stageIdx)) : val;

      outQ.enq(tuple2(nextVal, shift));
   endrule
endmodule

module mkPipelineShiftRight(PipelineShiftIfc#(sz, shiftsz))
   provisos(Add#(1, a__, shiftsz));

   Vector#(shiftsz, FIFO#(Tuple2#(Bit#(sz), Bit#(shiftsz)))) stageQs <- replicateM(mkPipelineFIFO);
   FIFO#(Bit#(sz)) outQ <- mkBypassFIFO;

   for (Integer i = valueOf(shiftsz) - 1; i > 0; i = i - 1) begin
      Empty stage <- mkPipelineShiftStage(i, stageQs[i], stageQs[i - 1]);
   end

   rule doStage0;
      let args = stageQs[0].first;
      stageQs[0].deq;

      let val   = tpl_1(args);
      let shift = tpl_2(args);
      Bit#(sz) nextVal = (shift[0] == 1'b1) ? (val >> 1) : val;

      outQ.enq(nextVal);
   endrule

   method Action put(Bit#(sz) v, Bit#(shiftsz) shift);
      stageQs[valueOf(shiftsz) - 1].enq(tuple2(v, shift));
   endmethod

   method ActionValue#(Bit#(sz)) get;
      let v = outQ.first;
      outQ.deq;
      return v;
   endmethod
endmodule

module mkSerializerFreeform(SerializerFreeformIfc#(srcSz, dstSz))
   provisos (
      Add#(1, a__, srcSz),
      Add#(1, b__, dstSz),
      Add#(c__, dstSz, srcSz),
      Add#(d__, dstSz, TAdd#(srcSz, srcSz))
   );

   UInt#(TAdd#(1, TLog#(srcSz))) srcU = fromInteger(valueOf(srcSz));
   UInt#(TAdd#(1, TLog#(srcSz))) dstU = fromInteger(valueOf(dstSz));

   FIFO#(Bit#(srcSz)) inQ <- mkFIFO;

   Reg#(Bit#(srcSz)) buffer <- mkReg(0);
   Reg#(UInt#(TAdd#(1, TLog#(srcSz)))) offset <- mkReg(0);

   PipelineShiftIfc#(TAdd#(srcSz, srcSz), TAdd#(1, TLog#(srcSz))) shifter <- mkPipelineShiftRight;

   rule serialize;
      if (offset == 0) begin
         let d = inQ.first;
         inQ.deq;

         shifter.put(lowExtended(d), 0);
         buffer <= d;

         UInt#(TAdd#(1, TLog#(srcSz))) nextOffset = dstU;
         if (nextOffset == srcU) begin
            offset <= 0;
         end
         else begin
            offset <= nextOffset;
         end
      end
      else begin
         UInt#(TAdd#(1, TLog#(srcSz))) nextOffset = offset + dstU;

         if (nextOffset < srcU) begin
            shifter.put(lowExtended(buffer), pack(offset));
            offset <= nextOffset;
         end
         else if (nextOffset == srcU) begin
            shifter.put(lowExtended(buffer), pack(offset));
            offset <= 0;
         end
         else begin
            let d = inQ.first;
            inQ.deq;

            Bit#(TAdd#(srcSz, srcSz)) merged = joinedWords(d, buffer);
            shifter.put(merged, pack(offset));
            buffer <= d;
            offset <= nextOffset - srcU;
         end
      end
   endrule

   method Action put(Bit#(srcSz) data);
      inQ.enq(data);
   endmethod

   method ActionValue#(Bit#(dstSz)) get;
      let d <- shifter.get;
      return truncate(d);
   endmethod
endmodule

endpackage: Serializer
