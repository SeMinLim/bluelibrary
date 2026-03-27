//=============================================================================
// File: URAM.bsv
// Description: Pure URAM Core Servers
//=============================================================================
package URAM;

import BRAM::*;

import FIFO::*;
import FIFOF::*;
import SpecialFIFOs::*;

import GetPut::*;
import DReg::*;
//-----------------------------------------------------------------------------
// [1] Single Port URAM BVI Wrapper and Server
//-----------------------------------------------------------------------------
interface RawUram1#(type addr, type data);
	method Action reqA(Bool we, addr a, data d);
	method data respA();
endinterface


import "BVI" URAM1 =
module mkRawURAM1(RawUram1#(addr, data))
	provisos (Bits#(addr, sz_addr), Bits#(data, sz_data));

	parameter DATA_WIDTH = valueOf(sz_data);
	parameter ADDR_WIDTH = valueOf(sz_addr);

	default_clock clk(CLKA);
	default_reset no_reset;

	method reqA(WEA, ADDRA, DIA) enable(ENA);
	method DOA respA(); 

	schedule (reqA, respA) CF (reqA, respA);
endmodule

module mkURAM1Server#(BRAM_Configure cfg)(BRAM1Port#(addr, data))
	provisos (Bits#(addr, sz_addr), Bits#(data, sz_data));

	RawUram1#(addr, data) raw <- mkRawURAM1;
	
	FIFO#(data) respFifoA <- mkBypassFIFO;
	Reg#(Bool) readReqA <- mkDReg(False);

	rule catchA (readReqA); 
		respFifoA.enq(raw.respA()); 
	endrule


	interface BRAMServer portA;
		interface Put request;
			method Action put(BRAMRequest#(addr, data) req);
				raw.reqA(req.write, req.address, req.datain);
				if (!req.write || req.responseOnWrite) readReqA <= True;
			endmethod
		endinterface
		interface Get response;
			method ActionValue#(data) get();
				respFifoA.deq; 
				return respFifoA.first;
			endmethod
		endinterface
    endinterface
endmodule
//--------------------------------------------------------------------------
// [2] Dual Port URAM BVI Wrapper and Server
//--------------------------------------------------------------------------
interface RawUram2#(type addr, type data);
	method Action reqA(Bool we, addr a, data d);
	method data respA();
	method Action reqB(Bool we, addr a, data d);
	method data respB();
endinterface


import "BVI" URAM2 =
module mkRawURAM2(RawUram2#(addr, data))
	provisos (Bits#(addr, sz_addr), Bits#(data, sz_data));

	parameter DATA_WIDTH = valueOf(sz_data);
	parameter ADDR_WIDTH = valueOf(sz_addr);

	default_clock clk(CLKA, CLKB);
	default_reset no_reset;

	method reqA(WEA, ADDRA, DIA) enable(ENA);
	method DOA respA(); 

	method reqB(WEB, ADDRB, DIB) enable(ENB);
	method DOB respB();

	schedule (reqA, respA, reqB, respB) CF (reqA, respA, reqB, respB);
endmodule

module mkURAM2Server#(BRAM_Configure cfg)(BRAM2Port#(addr, data))
	provisos (Bits#(addr, sz_addr), Bits#(data, sz_data));

	RawUram2#(addr, data) raw <- mkRawURAM2;

	FIFO#(data) respFifoA <- mkBypassFIFO;
	FIFO#(data) respFifoB <- mkBypassFIFO;

	Reg#(Bool) readReqA <- mkDReg(False);
	Reg#(Bool) readReqB <- mkDReg(False);

	rule catchA (readReqA); 
		respFifoA.enq(raw.respA()); 
	endrule
	rule catchB (readReqB); 
		respFifoB.enq(raw.respB()); 
	endrule


	interface BRAMServer portA;
		interface Put request;
			method Action put(BRAMRequest#(addr, data) req);
				raw.reqA(req.write, req.address, req.datain);
				if (!req.write || req.responseOnWrite) readReqA <= True;
			endmethod
		endinterface
		interface Get response;
			method ActionValue#(data) get();
				respFifoA.deq; 
				return respFifoA.first;
			endmethod
		endinterface
	endinterface
	interface BRAMServer portB;
		interface Put request;
			method Action put(BRAMRequest#(addr, data) req);
				raw.reqB(req.write, req.address, req.datain);
				if (!req.write || req.responseOnWrite) readReqB <= True;
			endmethod
		endinterface
		interface Get response;
			method ActionValue#(data) get();
				respFifoB.deq; 
				return respFifoB.first;
			endmethod
		endinterface
	endinterface
endmodule

endpackage
