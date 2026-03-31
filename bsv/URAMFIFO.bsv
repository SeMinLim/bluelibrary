package URAMFIFO;

import FIFO  :: *;
import FIFOF :: *;

export mkSizedURAMFIFOF;
export mkSizedURAMFIFO;

import "BVI" URAMFIFO =
module vURAMFIFOF#(Integer depth)
                 (FIFOF#(t))
   provisos(Bits#(t, st), Add#(1, z__, st));

   parameter DATA_WIDTH = valueOf(st);
   parameter DEPTH      = depth;

   default_clock clk(CLK);
   default_reset rst(RST);

   method enq(DI) enable(ENQ);
   method deq() enable(DEQ);
   method DO first();
   method FULL_N notFull();
   method EMPTY_N notEmpty();
   method clear() enable(CLR);

   schedule (first, notEmpty) CF (first, notEmpty);
   schedule notFull CF notFull;
   schedule enq C enq;
   schedule deq C deq;
   schedule first SB deq;
   schedule notEmpty SB deq;
   schedule notFull SB enq;
   schedule (enq, notFull) CF (deq, first, notEmpty);
   schedule clear C (clear, enq, deq, first, notEmpty, notFull);
endmodule: vURAMFIFOF

module mkSizedURAMFIFOF#(Integer n)
                        (FIFOF#(t))
   provisos(Bits#(t, st), Add#(1, z__, st));

   if (n < 1)
      errorM("mkSizedURAMFIFOF: depth must be >= 1.");

   let f <- vURAMFIFOF(n);
   return f;
endmodule: mkSizedURAMFIFOF

module mkSizedURAMFIFO#(Integer n)
                       (FIFO#(t))
   provisos(Bits#(t, st), Add#(1, z__, st));

   let f <- mkSizedURAMFIFOF(n);
   return fifofToFifo(f);
endmodule: mkSizedURAMFIFO

endpackage: URAMFIFO
