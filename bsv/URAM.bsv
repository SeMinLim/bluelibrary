package URAM;

import DefaultValue :: *;
import ClientServer :: *;
import FIFOF        :: *;
import GetPut       :: *;
import SpecialFIFOs :: *;

export LoadFormat(..), URAM_Configure(..);
export URAMRequest(..);
export URAMServer(..), URAMClient(..);
export URAM1Port(..), URAM2Port(..), URAM(..);
export mkURAM1Server;
export mkURAM2Server;
export mkURAM1;
export mkURAM;
export DefaultValue :: *;
export ClientServer :: *;
export GetPut       :: *;

/////////////////////////////////////////////////////////////////////
// Configuration and request types (kept intentionally close to BRAM.bsv)

typedef union tagged {
   void   None;
   String Hex;
   String Binary;
   } LoadFormat
   deriving (Eq, Bits);

typedef struct {
   Integer    memorySize;
   Integer    latency;                  // supported: 1 or 2
   LoadFormat loadFormat;               // only None is supported in this URAM wrapper
   Integer    outFIFODepth;
   Bool       allowWriteResponseBypass; // accepted for API compatibility; currently treated as False
   } URAM_Configure;

instance DefaultValue #(URAM_Configure);
   defaultValue = URAM_Configure {
      memorySize               : 0,
      latency                  : 1,
      loadFormat               : None,
      outFIFODepth             : 3,
      allowWriteResponseBypass : False
   };
endinstance

typedef struct {
   Bool write;
   Bool responseOnWrite;
   addr address;
   data datain;
   } URAMRequest#(type addr, type data)
   deriving (Bits, Eq);

instance DefaultValue#(URAMRequest#(addr, data))
   provisos(DefaultValue#(addr), DefaultValue#(data));
   defaultValue = URAMRequest {
      write           : False,
      responseOnWrite : True,
      address         : defaultValue,
      datain          : defaultValue
   };
endinstance

typedef Server#(URAMRequest#(addr, data), data) URAMServer#(type addr, type data);
typedef Client#(URAMRequest#(addr, data), data) URAMClient#(type addr, type data);

interface URAM1Port#(type addr, type data);
   interface URAMServer#(addr, data) portA;
   (* always_ready *) method Action portAClear;
endinterface: URAM1Port

interface URAM2Port#(type addr, type data);
   interface URAMServer#(addr, data) portA;
   interface URAMServer#(addr, data) portB;
   (* always_ready *) method Action portAClear;
   (* always_ready *) method Action portBClear;
endinterface: URAM2Port

typedef URAM2Port URAM;

/////////////////////////////////////////////////////////////////////
// Low-level native URAM interfaces (not exported)

(* always_ready *)
interface URAM_PORT#(type addr, type data);
   method Action put(Bool write, addr address, data datain);
   method data read();
endinterface: URAM_PORT

interface URAM_DUAL_PORT#(type addr, type data);
   interface URAM_PORT#(addr, data) a;
   interface URAM_PORT#(addr, data) b;
endinterface: URAM_DUAL_PORT

/////////////////////////////////////////////////////////////////////
// BVI imports for URAM1.v and URAM2.v

import "BVI" URAM1 =
module vURAMCore1#(Integer memSize, Bool hasOutputRegister)
                  (URAM_PORT#(addr, data))
   provisos(Bits#(addr, addr_sz),
            Bits#(data, data_sz),
            Add#(1, a__, addr_sz),
            Add#(1, d__, data_sz));

   default_clock clk(CLK);
   default_reset rst();

   parameter PIPELINED  = Bit#(1)'(pack(hasOutputRegister));
   parameter ADDR_WIDTH = valueOf(addr_sz);
   parameter DATA_WIDTH = valueOf(data_sz);
   parameter MEMSIZE    = Bit#(TAdd#(1, addr_sz))'(fromInteger(memSize));

   method put(WE, (* reg *) ADDR, (* reg *) DI) enable(EN);
   method DO read();

   schedule (put, read) CF (read);
   schedule put C put;
endmodule: vURAMCore1

import "BVI" URAM2 =
module vURAMCore2#(Integer memSize, Bool hasOutputRegister)
                  (URAM_DUAL_PORT#(addr, data))
   provisos(Bits#(addr, addr_sz),
            Bits#(data, data_sz),
            Add#(1, a__, addr_sz),
            Add#(1, d__, data_sz));

   default_clock clk(CLK);
   default_reset rst();

   parameter PIPELINED  = Bit#(1)'(pack(hasOutputRegister));
   parameter ADDR_WIDTH = valueOf(addr_sz);
   parameter DATA_WIDTH = valueOf(data_sz);
   parameter MEMSIZE    = Bit#(TAdd#(1, addr_sz))'(fromInteger(memSize));

   interface URAM_PORT a;
      method put(WEA, (* reg *) ADDRA, (* reg *) DIA) enable(ENA);
      method DOA read();
   endinterface: a

   interface URAM_PORT b;
      method put(WEB, (* reg *) ADDRB, (* reg *) DIB) enable(ENB);
      method DOB read();
   endinterface: b

   schedule (a_read) CF (a_put, a_read);
   schedule a_put C a_put;
   schedule (b_read) CF (b_put, b_read);
   schedule b_put C b_put;
   schedule (a_put, a_read) CF (b_put, b_read);
endmodule: vURAMCore2

/////////////////////////////////////////////////////////////////////
// Internal server adapter

interface ServerWithClear#(type req, type resp);
   interface Server#(req, resp) server;
   (* always_ready *) method Action clear;
endinterface: ServerWithClear

function Bool responseRequired(URAMRequest#(addr, data) req);
   return (!req.write) || req.responseOnWrite;
endfunction

function Bool isLoadFormatNone(LoadFormat lf);
   case (lf) matches
      tagged None: return True;
      default:     return False;
   endcase
endfunction

module mkURAMAdapter#(URAM_Configure cfg, URAM_PORT#(addr, data) mem)
                    (ServerWithClear#(URAMRequest#(addr, data), data))
   provisos(Bits#(data, data_sz));

   FIFOF#(data) outData <- mkSizedBypassFIFOF(cfg.outFIFODepth);

   Reg#(UInt#(32)) pending <- mkReg(0);
   Reg#(Maybe#(Bool)) s1   <- mkReg(tagged Invalid);
   Reg#(Maybe#(Bool)) s2   <- mkReg(tagged Invalid);

   RWire#(Bool) newRespNeeded <- mkRWire;
   PulseWire    pwRespGet     <- mkPulseWire;
   PulseWire    pwClear       <- mkPulseWire;

   Bool okToRequest = (pending < fromInteger(cfg.outFIFODepth));

   rule advance;
      if (pwClear) begin
         s1      <= tagged Invalid;
         s2      <= tagged Invalid;
         pending <= 0;
         outData.clear;
      end
      else begin
         Maybe#(Bool) launched = newRespNeeded.wget;

         if (cfg.latency == 1) begin
            s1 <= launched;
            s2 <= tagged Invalid;
         end
         else begin
            s2 <= s1;
            s1 <= launched;
         end

         UInt#(32) nextPending = pending;
         if (launched matches tagged Valid .need &&& need)
            nextPending = nextPending + 1;
         if (pwRespGet)
            nextPending = nextPending - 1;
         pending <= nextPending;
      end
   endrule

   rule emitResp1 (cfg.latency == 1 &&& !pwClear &&& s1 matches tagged Valid .need &&& need);
      outData.enq(mem.read);
   endrule

   rule emitResp2 (cfg.latency == 2 &&& !pwClear &&& s2 matches tagged Valid .need &&& need);
      outData.enq(mem.read);
   endrule

   interface Server server;
      interface Put request;
         method Action put(URAMRequest#(addr, data) req) if (okToRequest);
            mem.put(req.write, req.address, req.datain);
            newRespNeeded.wset(responseRequired(req));
         endmethod
      endinterface

      interface Get response;
         method ActionValue#(data) get() if (outData.notEmpty);
            let d = outData.first;
            outData.deq;
            pwRespGet.send;
            return d;
         endmethod
      endinterface
   endinterface

   method Action clear;
      pwClear.send;
   endmethod
endmodule: mkURAMAdapter

/////////////////////////////////////////////////////////////////////
// Public modules

module mkURAM1Server#(URAM_Configure cfg)
                    (URAM1Port#(addr, data))
   provisos(Bits#(addr, addr_sz),
            Bits#(data, data_sz),
            Add#(1, a__, addr_sz),
            Add#(1, d__, data_sz));

   Integer addrSpace = 2 ** valueOf(addr_sz);

   if ((cfg.latency != 1) && (cfg.latency != 2))
      errorM("mkURAM1Server: cfg.latency must be 1 or 2.");

   if (cfg.outFIFODepth < 1)
      errorM("mkURAM1Server: cfg.outFIFODepth must be >= 1.");

   if (!isLoadFormatNone(cfg.loadFormat))
      errorM("mkURAM1Server: loadFormat other than None is not supported.");

   if ((cfg.memorySize != 0) && (cfg.memorySize > addrSpace))
      errorM("mkURAM1Server: cfg.memorySize exceeds the address space.");

   Integer memSize = (cfg.memorySize == 0) ? addrSpace : cfg.memorySize;
   Bool hasOutputRegister = (cfg.latency == 2);

   URAM_PORT#(addr, data) memory <- vURAMCore1(memSize, hasOutputRegister);
   ServerWithClear#(URAMRequest#(addr, data), data) portA_ <- mkURAMAdapter(cfg, memory);

   interface URAMServer portA = portA_.server;
   method Action portAClear = portA_.clear;
endmodule: mkURAM1Server

module mkURAM2Server#(URAM_Configure cfg)
                    (URAM2Port#(addr, data))
   provisos(Bits#(addr, addr_sz),
            Bits#(data, data_sz),
            Add#(1, a__, addr_sz),
            Add#(1, d__, data_sz));

   Integer addrSpace = 2 ** valueOf(addr_sz);

   if ((cfg.latency != 1) && (cfg.latency != 2))
      errorM("mkURAM2Server: cfg.latency must be 1 or 2.");

   if (cfg.outFIFODepth < 1)
      errorM("mkURAM2Server: cfg.outFIFODepth must be >= 1.");

   if (!isLoadFormatNone(cfg.loadFormat))
      errorM("mkURAM2Server: loadFormat other than None is not supported.");

   if ((cfg.memorySize != 0) && (cfg.memorySize > addrSpace))
      errorM("mkURAM2Server: cfg.memorySize exceeds the address space.");

   Integer memSize = (cfg.memorySize == 0) ? addrSpace : cfg.memorySize;
   Bool hasOutputRegister = (cfg.latency == 2);

   URAM_DUAL_PORT#(addr, data) memory <- vURAMCore2(memSize, hasOutputRegister);
   ServerWithClear#(URAMRequest#(addr, data), data) portA_ <- mkURAMAdapter(cfg, memory.a);
   ServerWithClear#(URAMRequest#(addr, data), data) portB_ <- mkURAMAdapter(cfg, memory.b);

   interface URAMServer portA = portA_.server;
   method Action portAClear = portA_.clear;

   interface URAMServer portB = portB_.server;
   method Action portBClear = portB_.clear;
endmodule: mkURAM2Server

(* deprecate = "Replaced by mkURAM1Server" *)
module mkURAM1#(Bool pipelined)
              (URAM1Port#(addr, data))
   provisos(Bits#(addr, addr_sz),
            Bits#(data, data_sz),
            Add#(1, a__, addr_sz),
            Add#(1, d__, data_sz));

   URAM_Configure cfg = defaultValue;
   cfg.latency = pipelined ? 2 : 1;
   cfg.allowWriteResponseBypass = False;

   (* hide *) let m <- mkURAM1Server(cfg);
   return m;
endmodule: mkURAM1

(* deprecate = "Replaced by mkURAM2Server" *)
module mkURAM#(Bool pipelined)
             (URAM2Port#(addr, data))
   provisos(Bits#(addr, addr_sz),
            Bits#(data, data_sz),
            Add#(1, a__, addr_sz),
            Add#(1, d__, data_sz));

   URAM_Configure cfg = defaultValue;
   cfg.latency = pipelined ? 2 : 1;
   cfg.allowWriteResponseBypass = False;

   (* hide *) let m <- mkURAM2Server(cfg);
   return m;
endmodule: mkURAM

endpackage: URAM
