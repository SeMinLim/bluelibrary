//=============================================================================
// File: URAMFIFO.bsv
// Description: High-Performance URAM-based FIFO (Drop-in for BRAMFIFO)
// Features:
// - 100% Concurrent Enq/Deq (Free-running counters, no scheduling conflicts)
// - Dynamic Depth & Resource Trimming (Wrap-around pointers for Vivado)
// - Latency Hiding (Internal prefetch buffer)
//=============================================================================
package URAMFIFO;

import BRAM::*;
import URAM::*;     

import FIFO::*;
import FIFOF::*;
import SpecialFIFOs::*;
//--------------------------------------------------------------------------
// [1] Core Implementation: Sized URAM FIFOF
//--------------------------------------------------------------------------
module mkSizedURAMFIFOF#(Integer depth)(FIFOF#(data))
	provisos (Bits#(data, sz_data));

	// Max 64K, but Vivado will use only actual needed depth
	BRAM2Port#(Bit#(16), data) uram <- mkURAM2Server(defaultValue);

	// Free-running counters with no conflicts and full pipelining scheme
	Reg#(Bit#(17)) totalEnq <- mkReg(0); 
	Reg#(Bit#(17)) totalReq <- mkReg(0); 
	Reg#(Bit#(17)) totalDeq <- mkReg(0); 

	Reg#(Bit#(16)) wrPtr  <- mkReg(0); 
	Reg#(Bit#(16)) reqPtr <- mkReg(0); 

	// Latency hiding buffer
	FIFOF#(data) outBuffer <- mkSizedFIFOF(8); 

	// State calculations via 2's complement
	Bit#(17) count              = totalEnq - totalDeq;
	Bit#(17) availToReq         = totalEnq - totalReq;
	Bit#(17) itemsInFlightOrBuf = totalReq - totalDeq;

	// Pointer wrap-around for wasting resource like dumbass 
	function Bit#(16) nextPtr(Bit#(16) p);
		return (p == fromInteger(depth - 1)) ? 0 : p + 1;
	endfunction

	// Rules: URAM -> Buffer Prefetch
	rule prefetch ( (availToReq > 0) && (itemsInFlightOrBuf < 8) );
		uram.portB.request.put(BRAMRequest{write:False, responseOnWrite:False, address:reqPtr, datain:?});
		reqPtr   <= nextPtr(reqPtr);
		totalReq <= totalReq + 1;
	endrule

	rule gather;
		let d <- uram.portB.response.get();
		outBuffer.enq(d);
	endrule


	method Action enq(data d) if ( count < fromInteger(depth) );
		uram.portA.request.put(BRAMRequest{write:True, responseOnWrite:False, address:wrPtr, datain:d});
		wrPtr    <= nextPtr(wrPtr);
		totalEnq <= totalEnq + 1;
	endmethod
	method Action deq() if ( outBuffer.notEmpty() );
		outBuffer.deq(); 
		totalDeq <= totalDeq + 1;
	endmethod
	method data first() if ( outBuffer.notEmpty() );
		return outBuffer.first();
	endmethod
	method Action clear();
		totalEnq <= 0;
		totalReq <= 0;
		totalDeq <= 0;
		wrPtr    <= 0; 
		reqPtr   <= 0; 
		outBuffer.clear();
	endmethod
	method Bool notEmpty() = outBuffer.notEmpty();
	method Bool notFull()  = (count < fromInteger(depth));
endmodule
//--------------------------------------------------------------------------
// [2] Wrapper: Sized URAM FIFO
//--------------------------------------------------------------------------
module mkSizedURAMFIFO#(Integer depth)(FIFO#(data))
	provisos (Bits#(data, sz_data));

	FIFOF#(data) f <- mkSizedURAMFIFOF(depth);


	method enq   = f.enq;
	method deq   = f.deq;
	method first = f.first;
	method clear = f.clear;
endmodule

endpackage
