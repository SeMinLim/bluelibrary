package BLShifter;
//--------------------------------------------------------------------------
// Multicycle Shifter
// NumStages = ceil(shiftsz / shift_bits_per_stage)
// Latency   = NumStages + 1 cycles from enq to valid first
//--------------------------------------------------------------------------
import FIFO::*;
import Vector::*;


typedef struct {
	in_type       data;
	Bit#(shiftsz) remShift;
} ShiftToken#(type in_type, numeric type shiftsz)
deriving (Bits);


interface BLShiftIfc#(type in_type, numeric type shiftsz, numeric type shift_bits_per_stage);
	method Action enq(in_type v, Bit#(shiftsz) shift);
	method Action deq;
	method in_type first;
endinterface
module mkPipelinedShift#(Bool shiftRight)(BLShiftIfc#(in_type, shiftsz, shift_bits_per_stage))
	provisos ( Bits#(in_type, insz), 
		   Bitwise#(in_type), 
		   Add#(1, a__, insz),                       // insz >= 1 
		   Add#(shift_bits_per_stage, b__, shiftsz), // shift_bits_per_stage <= shiftsz
		   Add#(1, c__, shift_bits_per_stage));      // shift_bits_per_stage >= 1

	Integer numStages    = valueOf(TDiv#(shiftsz, shift_bits_per_stage));
	Integer stageBits    = valueOf(shift_bits_per_stage);
	Integer totalShiftSz = valueOf(shiftsz);

	Vector#(TAdd#(1, TDiv#(shiftsz, shift_bits_per_stage)), 
		FIFO#(ShiftToken#(in_type, shiftsz))) stageQs <- replicateM(mkLFIFO);

	for (Integer i = 1; i <= numStages; i = i + 1) begin
		rule shiftRelay;
			let inTok = stageQs[i-1].first;
			stageQs[i-1].deq;

			in_type shiftedData = inTok.data;
			Bit#(shift_bits_per_stage) stageAmt = truncate(inTok.remShift);

			Integer stageBase = (i - 1) * stageBits;

			for (Integer j = 0; j < stageBits; j = j + 1) begin
				Integer shiftIdx = stageBase + j;

				// For a partial last stage, ignore out-of-range shift bits explicitly.
				if ((shiftIdx < totalShiftSz) && (stageAmt[j] == 1'b1)) begin
					Integer shiftAmount = 1 << shiftIdx;

					if (shiftRight) begin
						shiftedData = shiftedData >> shiftAmount;
					end else begin
						shiftedData = shiftedData << shiftAmount;
					end
				end
			end

			stageQs[i].enq(ShiftToken{data:shiftedData, remShift: inTok.remShift >> stageBits});
		endrule
	end


	method Action enq(in_type v, Bit#(shiftsz) shift);
		stageQs[0].enq(ShiftToken { data: v, remShift: shift });
	endmethod
	method Action deq;
		stageQs[numStages].deq;
	endmethod
	method in_type first;
		let outTok = stageQs[numStages].first;
		return outTok.data;
	endmethod
endmodule
endpackage
