//=============================================================================
// File: Serializer.bsv
// Description: High-throughput Data Width Converters and Stream Utilities
// Repository: bluelibrary (Custom BSV/Verilog Arsenal)
// Features: 
// - Zero 1-cycle bubble latency (using mkBypassFIFO for outputs)
// - Fmax optimized (1-stage PipelineShiftRight for high-frequency 512-bit routing)
// - Safe provisos to prevent 0-bit synthesis errors
//=============================================================================
package Serializer;

import FIFO::*;
import SpecialFIFOs::*;

import Vector::*;
import Assert::*;
import GetPut::*;


interface SerializerIfc#(numeric type srcSz, numeric type multiplier);
	method Action put(Bit#(srcSz) data);
	method ActionValue#(Bit#(TDiv#(srcSz,multiplier))) get;
endinterface
interface DeSerializerIfc#(numeric type srcSz, numeric type multiplier);
	method Action put(Bit#(srcSz) data);
	method ActionValue#(Bit#(TMul#(srcSz,multiplier))) get;
endinterface
interface PipelineShiftIfc#(numeric type sz, numeric type shiftsz);
	method Action put(Bit#(sz) v, Bit#(shiftsz) shift);
	method ActionValue#(Bit#(sz)) get;
endinterface
interface SerializerFreeformIfc#(numeric type srcSz, numeric type dstSz);
	method Action put(Bit#(srcSz) data);
	method ActionValue#(Bit#(dstSz)) get;
endinterface
//-----------------------------------------------------------------------------
// [1] mkSerializer
//-----------------------------------------------------------------------------
module mkSerializer (SerializerIfc#(srcSz, multiplier))
	provisos (
		Div#(srcSz, multiplier, dstSz),
		Add#(a__, dstSz, srcSz),
		Add#(b__, 2, multiplier)
	);

	FIFO#(Bit#(srcSz)) inQ  <- mkFIFO;
	FIFO#(Bit#(dstSz)) outQ <- mkBypassFIFO; // Apply BypassFIFo to delete latency bubble

	Reg#(Bit#(srcSz)) buffer <- mkReg(0);
	Reg#(Bit#(TLog#(multiplier))) bufIdx <- mkReg(0);

	rule procin;
		if ( bufIdx == 0 ) begin
			let d = inQ.first;
			inQ.deq;
			buffer <= (d >> valueOf(dstSz));
			bufIdx <= fromInteger(valueOf(multiplier)-1);
			outQ.enq(truncate(d));
		end else begin
			outQ.enq(truncate(buffer));
			buffer <= (buffer >> valueOf(dstSz));
			bufIdx <= bufIdx - 1;
        	end
    	endrule


	method Action put(Bit#(srcSz) data) = inQ.enq(data);
	method ActionValue#(Bit#(dstSz)) get;
		outQ.deq; 
		return outQ.first;
	endmethod
endmodule
//-----------------------------------------------------------------------------
// [2] mkDeSerializer
//-----------------------------------------------------------------------------
module mkDeSerializer (DeSerializerIfc#(srcSz, multiplier))
	provisos (
		Mul#(srcSz, multiplier, dstSz),
		Add#(a__, srcSz, dstSz),
		Add#(b__, 2, multiplier)
	);

	FIFO#(Bit#(srcSz)) inQ  <- mkFIFO;
	FIFO#(Bit#(dstSz)) outQ <- mkBypassFIFO;

	Reg#(Bit#(dstSz)) buffer <- mkReg(0);
	Reg#(Bit#(TAdd#(1,TLog#(multiplier)))) bufIdx <- mkReg(0);

	rule procin;
		Integer shiftup = (valueOf(multiplier)-1) * valueOf(srcSz);

		if ( bufIdx + 2 <= fromInteger(valueOf(multiplier)) ) begin
			let d = inQ.first; 
			inQ.deq;
			buffer <= (buffer >> valueOf(srcSz)) | (zeroExtend(d) << shiftup);
			bufIdx <= bufIdx + 1;
		end else begin
			let d = inQ.first; 
			inQ.deq;
			
			Bit#(dstSz) td = (buffer >> valueOf(srcSz)) | (zeroExtend(d) << shiftup);

			buffer <= 0;
			bufIdx <= 0;
			outQ.enq(td);
		end
	endrule


	method Action put(Bit#(srcSz) data) = inQ.enq(data);
	method ActionValue#(Bit#(dstSz)) get;
		outQ.deq; 
		return outQ.first;
	endmethod
endmodule
//-----------------------------------------------------------------------------
// [3] mkPipelineShiftRight
//-----------------------------------------------------------------------------
module mkPipelineShiftRight(PipelineShiftIfc#(sz, shiftsz));
	// Fmax defense opimization
	// Cut the critical path through getting input by using mkFIFO and generate 1-cycle latch
	// Achieve 100 percent throughput via throwing output by using mkBypassFIFO
	FIFO#(Tuple2#(Bit#(sz), Bit#(shiftsz))) inQ <- mkFIFO;
	FIFO#(Bit#(sz)) outQ <- mkBypassFIFO;

	rule doShift;
		let val   = tpl_1(inQ.first);
		let shift = tpl_2(inQ.first);
		
		inQ.deq;
		outQ.enq(val >> shift);
	endrule


	method Action put(Bit#(sz) v, Bit#(shiftsz) shift);
		inQ.enq(tuple2(v,shift));
	endmethod
	method ActionValue#(Bit#(sz)) get;
		outQ.deq; 
		return outQ.first;
	endmethod
endmodule
//-----------------------------------------------------------------------------
// [4] mkSerializerFreeform
//-----------------------------------------------------------------------------
module mkSerializerFreeform(SerializerFreeformIfc#(srcSz, dstSz))
	provisos (
		Add#(a__, dstSz, srcSz),
		Add#(b__, srcSz, TMul#(srcSz,2)),
		Add#(c__, dstSz, TMul#(srcSz,2))
	);

	Integer idst = valueOf(dstSz);
	Integer isrc = valueOf(srcSz);

	FIFO#(Bit#(srcSz)) inQ <- mkFIFO;
	FIFO#(Bit#(dstSz)) outQ <- mkBypassFIFO;

	Reg#(Bit#(srcSz)) buffer <- mkReg(0);
	Reg#(Bit#(TAdd#(1,TLog#(srcSz)))) offset <- mkReg(0);

	PipelineShiftIfc#(TMul#(srcSz,2), TAdd#(1,TLog#(srcSz))) shifter <- mkPipelineShiftRight;

	rule serialize;
		if ( offset == 0 ) begin
			inQ.deq;
			let nbuf = zeroExtend(inQ.first);
			buffer <= inQ.first;
			offset <= fromInteger(idst);
			shifter.put(nbuf, 0);
		end else if ( offset + fromInteger(idst) < fromInteger(isrc) ) begin
			offset <= offset + fromInteger(idst);
			shifter.put(zeroExtend(buffer), offset);
		end else if ( offset + fromInteger(idst) == fromInteger(isrc) ) begin
			offset <= 0;
			shifter.put(zeroExtend(buffer), offset);
		end else begin
			inQ.deq;
			buffer <= inQ.first;
			let hbuf = {inQ.first, buffer};
			shifter.put(hbuf, offset);
			offset <= offset - fromInteger(isrc-idst);
		end
	endrule


	method Action put(Bit#(srcSz) data) = inQ.enq(data);
	method ActionValue#(Bit#(dstSz)) get;
		let d <- shifter.get; 
		return truncate(d);
	endmethod
endmodule
//-----------------------------------------------------------------------------
// Stream Utility Modules
//-----------------------------------------------------------------------------
module mkStreamReplicate#(Integer framesize) (FIFO#(dtype))
	provisos( Bits#(dtype, dtypeSz) );
	staticAssert(framesize<256, "framesize must be < 256" );
	staticAssert(framesize>0, "framesize must be > 0" );

	Reg#(Bit#(8)) repIdx <- mkReg(0);
	Reg#(dtype) buffer <- mkReg(?);

	FIFO#(dtype) outQ <- mkBypassFIFO;
	FIFO#(dtype) inQ <- mkFIFO;

	rule replicate;
		if ( repIdx == 0 ) begin
			repIdx <= fromInteger(framesize-1);
			let d = inQ.first; 
			inQ.deq;
			outQ.enq(d);
			buffer <= d;
		end else begin
			repIdx <= repIdx - 1;
			outQ.enq(buffer);
		end
	endrule

	
	method enq = inQ.enq; 
	method deq = outQ.deq; 
	method first = outQ.first; 
	method clear = outQ.clear;
endmodule

module mkStreamSerializeLast#(Integer framesize) (FIFO#(Bool));
	staticAssert(framesize<256, "framesize must be < 256" );
	staticAssert(framesize>0, "framesize must be > 0" );

	Reg#(Bit#(8)) repIdx <- mkReg(0);
	Reg#(Bool) isLast <- mkReg(False);
	FIFO#(Bool) outQ <- mkBypassFIFO;
	FIFO#(Bool) inQ <- mkFIFO;

	rule replicate;
		if ( repIdx == 0 ) begin
			repIdx <= fromInteger(framesize-1);
			let d = inQ.first; 
			inQ.deq;
			outQ.enq(False);
			isLast <= d;
		end else begin
			repIdx <= repIdx - 1;
			outQ.enq( (repIdx == 1) ? isLast : False );
		end
	endrule


	method enq = inQ.enq; 
	method deq = outQ.deq; 
	method first = outQ.first; 
	method clear = outQ.clear;
endmodule

module mkStreamSkip#(Integer framesize, Integer offset) (FIFO#(dtype))
	provisos( Bits#(dtype, dtypeSz) );

	staticAssert(framesize<256, "framesize must be < 256" );
	staticAssert(offset<framesize, "offset must be < framesize" );

	Reg#(Bit#(8)) skipIdx <- mkReg(0);
	FIFO#(dtype) outQ <- mkBypassFIFO;

	method Action enq(dtype data);
		if ( skipIdx == fromInteger(offset) ) outQ.enq(data);
		skipIdx <= (skipIdx + 1 >= fromInteger(framesize)) ? 0 : skipIdx + 1;
	endmethod


	method deq = outQ.deq; 
	method first = outQ.first; 
	method clear = outQ.clear;
endmodule

endpackage: Serializer
