package CRC32;

// Semantics match the serial loop:
//   fb = crc[0] ^ data_in[i];
//   crc = (crc >> 1) ^ (fb ? POLY_REFLECTED : 0);
// with i increasing from 0 (LSB first) to data_width-1.
// No final xorout is applied. 'crc_in' is the incoming CRC state.
// CRC32  reflected polynomial: 0xEDB88320
// CRC32C reflected polynomial: 0x82F63B78

function Bit#(32) crc32_update_32_reflected(Bit#(32) crc_in, Bit#(32) data_in);
	return {crc_in[0] ^ crc_in[1] ^ crc_in[2] ^ crc_in[3] ^ crc_in[5] ^ crc_in[6] ^ crc_in[7] ^ 
		crc_in[15] ^ crc_in[19] ^ crc_in[21] ^ crc_in[22] ^ crc_in[25] ^ crc_in[31] ^ 
		data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[6] ^ 
		data_in[7] ^ data_in[15] ^ data_in[19] ^ data_in[21] ^ data_in[22] ^ data_in[25] ^ data_in[31], // next_crc[31]

		crc_in[3] ^ crc_in[4] ^ crc_in[7] ^ crc_in[14] ^ crc_in[15] ^ crc_in[18] ^ crc_in[19] ^ 
		crc_in[20] ^ crc_in[22] ^ crc_in[24] ^ crc_in[25] ^ crc_in[30] ^ crc_in[31] ^ 
		data_in[3] ^ data_in[4] ^ data_in[7] ^ data_in[14] ^ data_in[15] ^ data_in[18] ^ 
		data_in[19] ^ data_in[20] ^ data_in[22] ^ data_in[24] ^ data_in[25] ^ data_in[30] ^ data_in[31], // next_crc[30]

		crc_in[0] ^ crc_in[1] ^ crc_in[5] ^ crc_in[7] ^ crc_in[13] ^ crc_in[14] ^ crc_in[15] ^ crc_in[17] ^ 
		crc_in[18] ^ crc_in[22] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[29] ^ crc_in[30] ^ crc_in[31] ^ 
		data_in[0] ^ data_in[1] ^ data_in[5] ^ data_in[7] ^ data_in[13] ^ data_in[14] ^ data_in[15] ^ data_in[17] ^ 
		data_in[18] ^ data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[25] ^ data_in[29] ^ data_in[30] ^ data_in[31], // next_crc[29]

		crc_in[0] ^ crc_in[4] ^ crc_in[6] ^ crc_in[12] ^ crc_in[13] ^ crc_in[14] ^ crc_in[16] ^ crc_in[17] ^ 
		crc_in[21] ^ crc_in[22] ^ crc_in[23] ^ crc_in[24] ^ crc_in[28] ^ crc_in[29] ^ crc_in[30] ^ 
		data_in[0] ^ data_in[4] ^ data_in[6] ^ data_in[12] ^ data_in[13] ^ data_in[14] ^ data_in[16] ^ 
		data_in[17] ^ data_in[21] ^ data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[28] ^ data_in[29] ^ data_in[30], // next_crc[28]

		crc_in[0] ^ crc_in[1] ^ crc_in[2] ^ crc_in[6] ^ crc_in[7] ^ crc_in[11] ^ crc_in[12] ^ crc_in[13] ^ 
		crc_in[16] ^ crc_in[19] ^ crc_in[20] ^ crc_in[23] ^ crc_in[25] ^ crc_in[27] ^ crc_in[28] ^ crc_in[29] ^ crc_in[31] ^ 
		data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[6] ^ data_in[7] ^ data_in[11] ^ data_in[12] ^ data_in[13] ^ data_in[16] ^ 
		data_in[19] ^ data_in[20] ^ data_in[23] ^ data_in[25] ^ data_in[27] ^ data_in[28] ^ data_in[29] ^ data_in[31], // next_crc[27]

		crc_in[2] ^ crc_in[3] ^ crc_in[7] ^ crc_in[10] ^ crc_in[11] ^ crc_in[12] ^ crc_in[18] ^ crc_in[21] ^ 
		crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[28] ^ crc_in[30] ^ crc_in[31] ^ 
		data_in[2] ^ data_in[3] ^ data_in[7] ^ data_in[10] ^ data_in[11] ^ data_in[12] ^ data_in[18] ^ data_in[21] ^ 
		data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[27] ^ data_in[28] ^ data_in[30] ^ data_in[31], // next_crc[26]

		crc_in[1] ^ crc_in[2] ^ crc_in[6] ^ crc_in[9] ^ crc_in[10] ^ crc_in[11] ^ crc_in[17] ^ crc_in[20] ^ 
		crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[29] ^ crc_in[30] ^ 
		data_in[1] ^ data_in[2] ^ data_in[6] ^ data_in[9] ^ data_in[10] ^ data_in[11] ^ data_in[17] ^ data_in[20] ^ 
		data_in[23] ^ data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[27] ^ data_in[29] ^ data_in[30], // next_crc[25]

		crc_in[2] ^ crc_in[3] ^ crc_in[6] ^ crc_in[7] ^ crc_in[8] ^ crc_in[9] ^ crc_in[10] ^ crc_in[15] ^ 
		crc_in[16] ^ crc_in[21] ^ crc_in[23] ^ crc_in[24] ^ crc_in[26] ^ crc_in[28] ^ crc_in[29] ^ crc_in[31] ^ 
		data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[9] ^ data_in[10] ^ data_in[15] ^ 
		data_in[16] ^ data_in[21] ^ data_in[23] ^ data_in[24] ^ data_in[26] ^ data_in[28] ^ data_in[29] ^ data_in[31], // next_crc[24]

		crc_in[0] ^ crc_in[3] ^ crc_in[8] ^ crc_in[9] ^ crc_in[14] ^ crc_in[19] ^ crc_in[20] ^ crc_in[21] ^ 
		crc_in[23] ^ crc_in[27] ^ crc_in[28] ^ crc_in[30] ^ crc_in[31] ^ 
		data_in[0] ^ data_in[3] ^ data_in[8] ^ data_in[9] ^ data_in[14] ^ data_in[19] ^ data_in[20] ^ 
		data_in[21] ^ data_in[23] ^ data_in[27] ^ data_in[28] ^ data_in[30] ^ data_in[31], // next_crc[23]

		crc_in[2] ^ crc_in[7] ^ crc_in[8] ^ crc_in[13] ^ crc_in[18] ^ crc_in[19] ^ 
		crc_in[20] ^ crc_in[22] ^ crc_in[26] ^ crc_in[27] ^ crc_in[29] ^ crc_in[30] ^ 
		data_in[2] ^ data_in[7] ^ data_in[8] ^ data_in[13] ^ data_in[18] ^ data_in[19] ^ data_in[20] ^ 
		data_in[22] ^ data_in[26] ^ data_in[27] ^ data_in[29] ^ data_in[30], // next_crc[22]

		crc_in[0] ^ crc_in[2] ^ crc_in[3] ^ crc_in[5] ^ crc_in[12] ^ crc_in[15] ^ 
		crc_in[17] ^ crc_in[18] ^ crc_in[22] ^ crc_in[26] ^ crc_in[28] ^ crc_in[29] ^ crc_in[31] ^ 
		data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[12] ^ data_in[15] ^ data_in[17] ^ 
		data_in[18] ^ data_in[22] ^ data_in[26] ^ data_in[28] ^ data_in[29] ^ data_in[31], // next_crc[21]

		crc_in[0] ^ crc_in[3] ^ crc_in[4] ^ crc_in[5] ^ crc_in[6] ^ crc_in[7] ^ crc_in[11] ^ crc_in[14] ^ crc_in[15] ^ 
		crc_in[16] ^ crc_in[17] ^ crc_in[19] ^ crc_in[22] ^ crc_in[27] ^ crc_in[28] ^ crc_in[30] ^ crc_in[31] ^ 
		data_in[0] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[11] ^ data_in[14] ^ data_in[15] ^ 
		data_in[16] ^ data_in[17] ^ data_in[19] ^ data_in[22] ^ data_in[27] ^ data_in[28] ^ data_in[30] ^ data_in[31], // next_crc[20]

		crc_in[0] ^ crc_in[1] ^ crc_in[4] ^ crc_in[7] ^ crc_in[10] ^ crc_in[13] ^ crc_in[14] ^ crc_in[16] ^ crc_in[18] ^ 
		crc_in[19] ^ crc_in[22] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[29] ^ crc_in[30] ^ crc_in[31] ^ 
		data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[7] ^ data_in[10] ^ data_in[13] ^ data_in[14] ^ data_in[16] ^ data_in[18] ^ 
		data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[26] ^ data_in[27] ^ data_in[29] ^ data_in[30] ^ data_in[31], // next_crc[19]

		crc_in[0] ^ crc_in[3] ^ crc_in[6] ^ crc_in[9] ^ crc_in[12] ^ crc_in[13] ^ crc_in[15] ^ crc_in[17] ^ 
		crc_in[18] ^ crc_in[21] ^ crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[28] ^ crc_in[29] ^ crc_in[30] ^ 
		data_in[0] ^ data_in[3] ^ data_in[6] ^ data_in[9] ^ data_in[12] ^ data_in[13] ^ data_in[15] ^ data_in[17] ^ 
		data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[28] ^ data_in[29] ^ data_in[30], // next_crc[18]

		crc_in[2] ^ crc_in[5] ^ crc_in[8] ^ crc_in[11] ^ crc_in[12] ^ crc_in[14] ^ crc_in[16] ^ crc_in[17] ^ 
		crc_in[20] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[27] ^ crc_in[28] ^ crc_in[29] ^ 
		data_in[2] ^ data_in[5] ^ data_in[8] ^ data_in[11] ^ data_in[12] ^ data_in[14] ^ data_in[16] ^ data_in[17] ^ 
		data_in[20] ^ data_in[23] ^ data_in[24] ^ data_in[25] ^ data_in[27] ^ data_in[28] ^ data_in[29], // next_crc[17]

		crc_in[1] ^ crc_in[4] ^ crc_in[7] ^ crc_in[10] ^ crc_in[11] ^ crc_in[13] ^ crc_in[15] ^ crc_in[16] ^ 
		crc_in[19] ^ crc_in[22] ^ crc_in[23] ^ crc_in[24] ^ crc_in[26] ^ crc_in[27] ^ crc_in[28] ^ 
		data_in[1] ^ data_in[4] ^ data_in[7] ^ data_in[10] ^ data_in[11] ^ data_in[13] ^ data_in[15] ^ data_in[16] ^ 
		data_in[19] ^ data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[26] ^ data_in[27] ^ data_in[28], // next_crc[16]

		crc_in[1] ^ crc_in[2] ^ crc_in[5] ^ crc_in[7] ^ crc_in[9] ^ crc_in[10] ^ crc_in[12] ^ crc_in[14] ^ 
		crc_in[18] ^ crc_in[19] ^ crc_in[23] ^ crc_in[26] ^ crc_in[27] ^ crc_in[31] ^ 
		data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[7] ^ data_in[9] ^ data_in[10] ^ data_in[12] ^ 
		data_in[14] ^ data_in[18] ^ data_in[19] ^ data_in[23] ^ data_in[26] ^ data_in[27] ^ data_in[31], // next_crc[15]

		crc_in[0] ^ crc_in[1] ^ crc_in[4] ^ crc_in[6] ^ crc_in[8] ^ crc_in[9] ^ crc_in[11] ^ 
		crc_in[13] ^ crc_in[17] ^ crc_in[18] ^ crc_in[22] ^ crc_in[25] ^ crc_in[26] ^ crc_in[30] ^ 
		data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[6] ^ data_in[8] ^ data_in[9] ^ data_in[11] ^ 
		data_in[13] ^ data_in[17] ^ data_in[18] ^ data_in[22] ^ data_in[25] ^ data_in[26] ^ data_in[30], // next_crc[14]

		crc_in[0] ^ crc_in[3] ^ crc_in[5] ^ crc_in[7] ^ crc_in[8] ^ crc_in[10] ^ crc_in[12] ^ 
		crc_in[16] ^ crc_in[17] ^ crc_in[21] ^ crc_in[24] ^ crc_in[25] ^ crc_in[29] ^ 
		data_in[0] ^ data_in[3] ^ data_in[5] ^ data_in[7] ^ data_in[8] ^ data_in[10] ^ data_in[12] ^ 
		data_in[16] ^ data_in[17] ^ data_in[21] ^ data_in[24] ^ data_in[25] ^ data_in[29], // next_crc[13]

		crc_in[2] ^ crc_in[4] ^ crc_in[6] ^ crc_in[7] ^ crc_in[9] ^ crc_in[11] ^ crc_in[15] ^ 
		crc_in[16] ^ crc_in[20] ^ crc_in[23] ^ crc_in[24] ^ crc_in[28] ^ 
		data_in[2] ^ data_in[4] ^ data_in[6] ^ data_in[7] ^ data_in[9] ^ data_in[11] ^ data_in[15] ^ 
		data_in[16] ^ data_in[20] ^ data_in[23] ^ data_in[24] ^ data_in[28], // next_crc[12]

		crc_in[1] ^ crc_in[3] ^ crc_in[5] ^ crc_in[6] ^ crc_in[8] ^ crc_in[10] ^ crc_in[14] ^ 
		crc_in[15] ^ crc_in[19] ^ crc_in[22] ^ crc_in[23] ^ crc_in[27] ^ 
		data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[6] ^ data_in[8] ^ data_in[10] ^ data_in[14] ^ 
		data_in[15] ^ data_in[19] ^ data_in[22] ^ data_in[23] ^ data_in[27], // next_crc[11]

		crc_in[0] ^ crc_in[2] ^ crc_in[4] ^ crc_in[5] ^ crc_in[7] ^ crc_in[9] ^ crc_in[13] ^ 
		crc_in[14] ^ crc_in[18] ^ crc_in[21] ^ crc_in[22] ^ crc_in[26] ^ 
		data_in[0] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[7] ^ data_in[9] ^ 
		data_in[13] ^ data_in[14] ^ data_in[18] ^ data_in[21] ^ data_in[22] ^ data_in[26], // next_crc[10]

		crc_in[0] ^ crc_in[2] ^ crc_in[4] ^ crc_in[5] ^ crc_in[7] ^ crc_in[8] ^ crc_in[12] ^ crc_in[13] ^ 
		crc_in[15] ^ crc_in[17] ^ crc_in[19] ^ crc_in[20] ^ crc_in[22] ^ crc_in[31] ^ 
		data_in[0] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[7] ^ data_in[8] ^ data_in[12] ^ 
		data_in[13] ^ data_in[15] ^ data_in[17] ^ data_in[19] ^ data_in[20] ^ data_in[22] ^ data_in[31], // next_crc[9]

		crc_in[0] ^ crc_in[2] ^ crc_in[4] ^ crc_in[5] ^ crc_in[11] ^ crc_in[12] ^ crc_in[14] ^ crc_in[15] ^ 
		crc_in[16] ^ crc_in[18] ^ crc_in[22] ^ crc_in[25] ^ crc_in[30] ^ crc_in[31] ^ 
		data_in[0] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[11] ^ data_in[12] ^ data_in[14] ^ 
		data_in[15] ^ data_in[16] ^ data_in[18] ^ data_in[22] ^ data_in[25] ^ data_in[30] ^ data_in[31], // next_crc[8]

		crc_in[1] ^ crc_in[3] ^ crc_in[4] ^ crc_in[10] ^ crc_in[11] ^ crc_in[13] ^ crc_in[14] ^ 
		crc_in[15] ^ crc_in[17] ^ crc_in[21] ^ crc_in[24] ^ crc_in[29] ^ crc_in[30] ^ 
		data_in[1] ^ data_in[3] ^ data_in[4] ^ data_in[10] ^ data_in[11] ^ data_in[13] ^ data_in[14] ^ 
		data_in[15] ^ data_in[17] ^ data_in[21] ^ data_in[24] ^ data_in[29] ^ data_in[30], // next_crc[7]

		crc_in[0] ^ crc_in[2] ^ crc_in[3] ^ crc_in[9] ^ crc_in[10] ^ crc_in[12] ^ crc_in[13] ^ 
		crc_in[14] ^ crc_in[16] ^ crc_in[20] ^ crc_in[23] ^ crc_in[28] ^ crc_in[29] ^ 
		data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[9] ^ data_in[10] ^ data_in[12] ^ data_in[13] ^ 
		data_in[14] ^ data_in[16] ^ data_in[20] ^ data_in[23] ^ data_in[28] ^ data_in[29], // next_crc[6]

		crc_in[0] ^ crc_in[3] ^ crc_in[5] ^ crc_in[6] ^ crc_in[7] ^ crc_in[8] ^ crc_in[9] ^ crc_in[11] ^ 
		crc_in[12] ^ crc_in[13] ^ crc_in[21] ^ crc_in[25] ^ crc_in[27] ^ crc_in[28] ^ crc_in[31] ^ 
		data_in[0] ^ data_in[3] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[9] ^ 
		data_in[11] ^ data_in[12] ^ data_in[13] ^ data_in[21] ^ data_in[25] ^ data_in[27] ^ data_in[28] ^ data_in[31], // next_crc[5]

		crc_in[2] ^ crc_in[4] ^ crc_in[5] ^ crc_in[6] ^ crc_in[7] ^ crc_in[8] ^ crc_in[10] ^ crc_in[11] ^ 
		crc_in[12] ^ crc_in[20] ^ crc_in[24] ^ crc_in[26] ^ crc_in[27] ^ crc_in[30] ^ 
		data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[10] ^ 
		data_in[11] ^ data_in[12] ^ data_in[20] ^ data_in[24] ^ data_in[26] ^ data_in[27] ^ data_in[30], // next_crc[4]

		crc_in[1] ^ crc_in[3] ^ crc_in[4] ^ crc_in[5] ^ crc_in[6] ^ crc_in[7] ^ crc_in[9] ^ crc_in[10] ^ 
		crc_in[11] ^ crc_in[19] ^ crc_in[23] ^ crc_in[25] ^ crc_in[26] ^ crc_in[29] ^ 
		data_in[1] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[9] ^ 
		data_in[10] ^ data_in[11] ^ data_in[19] ^ data_in[23] ^ data_in[25] ^ data_in[26] ^ data_in[29], // next_crc[3]

		crc_in[0] ^ crc_in[2] ^ crc_in[3] ^ crc_in[4] ^ crc_in[5] ^ crc_in[6] ^ crc_in[8] ^ crc_in[9] ^ 
		crc_in[10] ^ crc_in[18] ^ crc_in[22] ^ crc_in[24] ^ crc_in[25] ^ crc_in[28] ^ 
		data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[8] ^ data_in[9] ^ 
		data_in[10] ^ data_in[18] ^ data_in[22] ^ data_in[24] ^ data_in[25] ^ data_in[28], // next_crc[2]

		crc_in[1] ^ crc_in[2] ^ crc_in[3] ^ crc_in[4] ^ crc_in[5] ^ crc_in[7] ^ crc_in[8] ^ crc_in[9] ^ 
		crc_in[17] ^ crc_in[21] ^ crc_in[23] ^ crc_in[24] ^ crc_in[27] ^ 
		data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[7] ^ data_in[8] ^ 
		data_in[9] ^ data_in[17] ^ data_in[21] ^ data_in[23] ^ data_in[24] ^ data_in[27], // next_crc[1]

		crc_in[0] ^ crc_in[1] ^ crc_in[2] ^ crc_in[3] ^ crc_in[4] ^ crc_in[6] ^ crc_in[7] ^ crc_in[8] ^ 
		crc_in[16] ^ crc_in[20] ^ crc_in[22] ^ crc_in[23] ^ crc_in[26] ^ 
		data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ 
		data_in[7] ^ data_in[8] ^ data_in[16] ^ data_in[20] ^ data_in[22] ^ data_in[23] ^ data_in[26] // next_crc[0]
	};
endfunction

function Bit#(32) crc32c_update_32_reflected(Bit#(32) crc_in, Bit#(32) data_in);
	return {crc_in[0] ^ crc_in[1] ^ crc_in[3] ^ crc_in[4] ^ crc_in[5] ^ crc_in[6] ^ crc_in[8] ^ crc_in[10] ^ crc_in[13] ^ crc_in[14] ^ 
		crc_in[15] ^ crc_in[19] ^ crc_in[22] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[31] ^ 
		data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[8] ^ data_in[10] ^ data_in[13] ^ data_in[14] ^ 
		data_in[15] ^ data_in[19] ^ data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[27] ^ data_in[31], // next_crc[31]

		crc_in[0] ^ crc_in[2] ^ crc_in[3] ^ crc_in[4] ^ crc_in[5] ^ crc_in[7] ^ crc_in[9] ^ crc_in[12] ^ crc_in[13] ^ crc_in[14] ^ 
		crc_in[18] ^ crc_in[21] ^ crc_in[22] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[30] ^ 
		data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[7] ^ data_in[9] ^ data_in[12] ^ data_in[13] ^ data_in[14] ^ 
		data_in[18] ^ data_in[21] ^ data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[30], // next_crc[30]

		crc_in[1] ^ crc_in[2] ^ crc_in[3] ^ crc_in[4] ^ crc_in[6] ^ crc_in[8] ^ crc_in[11] ^ crc_in[12] ^ crc_in[13] ^ crc_in[17] ^ 
		crc_in[20] ^ crc_in[21] ^ crc_in[22] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[29] ^ 
		data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ data_in[8] ^ data_in[11] ^ data_in[12] ^ data_in[13] ^ data_in[17] ^ 
		data_in[20] ^ data_in[21] ^ data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[25] ^ data_in[29], // next_crc[29]

		crc_in[0] ^ crc_in[1] ^ crc_in[2] ^ crc_in[3] ^ crc_in[5] ^ crc_in[7] ^ crc_in[10] ^ crc_in[11] ^ crc_in[12] ^ crc_in[16] ^ 
		crc_in[19] ^ crc_in[20] ^ crc_in[21] ^ crc_in[22] ^ crc_in[23] ^ crc_in[24] ^ crc_in[28] ^ 
		data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[7] ^ data_in[10] ^ data_in[11] ^ data_in[12] ^ data_in[16] ^ 
		data_in[19] ^ data_in[20] ^ data_in[21] ^ data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[28], // next_crc[28]

		crc_in[0] ^ crc_in[1] ^ crc_in[2] ^ crc_in[4] ^ crc_in[6] ^ crc_in[9] ^ crc_in[10] ^ crc_in[11] ^ crc_in[15] ^ crc_in[18] ^ 
		crc_in[19] ^ crc_in[20] ^ crc_in[21] ^ crc_in[22] ^ crc_in[23] ^ crc_in[27] ^ 
		data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[6] ^ data_in[9] ^ data_in[10] ^ data_in[11] ^ data_in[15] ^ data_in[18] ^ 
		data_in[19] ^ data_in[20] ^ data_in[21] ^ data_in[22] ^ data_in[23] ^ data_in[27], // next_crc[27]

		crc_in[0] ^ crc_in[1] ^ crc_in[3] ^ crc_in[5] ^ crc_in[8] ^ crc_in[9] ^ crc_in[10] ^ crc_in[14] ^ crc_in[17] ^ crc_in[18] ^ 
		crc_in[19] ^ crc_in[20] ^ crc_in[21] ^ crc_in[22] ^ crc_in[26] ^ 
		data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[8] ^ data_in[9] ^ data_in[10] ^ data_in[14] ^ data_in[17] ^ data_in[18] ^ 
		data_in[19] ^ data_in[20] ^ data_in[21] ^ data_in[22] ^ data_in[26], // next_crc[26]

		crc_in[1] ^ crc_in[2] ^ crc_in[3] ^ crc_in[5] ^ crc_in[6] ^ crc_in[7] ^ crc_in[9] ^ crc_in[10] ^ crc_in[14] ^ crc_in[15] ^ crc_in[16] ^ 
		crc_in[17] ^ crc_in[18] ^ crc_in[20] ^ crc_in[21] ^ crc_in[22] ^ crc_in[23] ^ crc_in[24] ^ crc_in[26] ^ crc_in[27] ^ crc_in[31] ^ 
		data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[9] ^ 
		data_in[10] ^ data_in[14] ^ data_in[15] ^ data_in[16] ^ data_in[17] ^ data_in[18] ^ data_in[20] ^ 
		data_in[21] ^ data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[26] ^ data_in[27] ^ data_in[31], // next_crc[25]

		crc_in[0] ^ crc_in[1] ^ crc_in[2] ^ crc_in[4] ^ crc_in[5] ^ crc_in[6] ^ crc_in[8] ^ crc_in[9] ^ crc_in[13] ^ crc_in[14] ^ crc_in[15] ^ 
		crc_in[16] ^ crc_in[17] ^ crc_in[19] ^ crc_in[20] ^ crc_in[21] ^ crc_in[22] ^ crc_in[23] ^ crc_in[25] ^ crc_in[26] ^ crc_in[30] ^ 
		data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[8] ^ 
		data_in[9] ^ data_in[13] ^ data_in[14] ^ data_in[15] ^ data_in[16] ^ data_in[17] ^ data_in[19] ^ 
		data_in[20] ^ data_in[21] ^ data_in[22] ^ data_in[23] ^ data_in[25] ^ data_in[26] ^ data_in[30], // next_crc[24]

		crc_in[6] ^ crc_in[7] ^ crc_in[10] ^ crc_in[12] ^ crc_in[16] ^ crc_in[18] ^ crc_in[20] ^ crc_in[21] ^ crc_in[23] ^ crc_in[26] ^ 
		crc_in[27] ^ crc_in[29] ^ crc_in[31] ^ 
		data_in[6] ^ data_in[7] ^ data_in[10] ^ data_in[12] ^ data_in[16] ^ data_in[18] ^ data_in[20] ^ 
		data_in[21] ^ data_in[23] ^ data_in[26] ^ data_in[27] ^ data_in[29] ^ data_in[31], // next_crc[23]

		crc_in[0] ^ crc_in[1] ^ crc_in[3] ^ crc_in[4] ^ crc_in[8] ^ crc_in[9] ^ crc_in[10] ^ crc_in[11] ^ crc_in[13] ^ crc_in[14] ^ 
		crc_in[17] ^ crc_in[20] ^ crc_in[23] ^ crc_in[24] ^ crc_in[27] ^ crc_in[28] ^ crc_in[30] ^ crc_in[31] ^ 
		data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[4] ^ data_in[8] ^ data_in[9] ^ data_in[10] ^ data_in[11] ^ data_in[13] ^ 
		data_in[14] ^ data_in[17] ^ data_in[20] ^ data_in[23] ^ data_in[24] ^ data_in[27] ^ data_in[28] ^ data_in[30] ^ data_in[31], // next_crc[22]

		crc_in[1] ^ crc_in[2] ^ crc_in[4] ^ crc_in[5] ^ crc_in[6] ^ crc_in[7] ^ crc_in[9] ^ crc_in[12] ^ crc_in[14] ^ crc_in[15] ^ 
		crc_in[16] ^ crc_in[24] ^ crc_in[25] ^ crc_in[29] ^ crc_in[30] ^ crc_in[31] ^ 
		data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[9] ^ data_in[12] ^ 
		data_in[14] ^ data_in[15] ^ data_in[16] ^ data_in[24] ^ data_in[25] ^ data_in[29] ^ data_in[30] ^ data_in[31], // next_crc[21]

		crc_in[10] ^ crc_in[11] ^ crc_in[19] ^ crc_in[22] ^ crc_in[25] ^ crc_in[26] ^ 
		crc_in[27] ^ crc_in[28] ^ crc_in[29] ^ crc_in[30] ^ crc_in[31] ^ 
		data_in[10] ^ data_in[11] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[26] ^ data_in[27] ^ 
		data_in[28] ^ data_in[29] ^ data_in[30] ^ data_in[31], // next_crc[20]

		crc_in[9] ^ crc_in[10] ^ crc_in[18] ^ crc_in[21] ^ crc_in[24] ^ 
		crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[28] ^ crc_in[29] ^ crc_in[30] ^ 
		data_in[9] ^ data_in[10] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[25] ^ data_in[26] ^ 
		data_in[27] ^ data_in[28] ^ data_in[29] ^ data_in[30], // next_crc[19]

		crc_in[0] ^ crc_in[1] ^ crc_in[3] ^ crc_in[4] ^ crc_in[5] ^ crc_in[6] ^ crc_in[9] ^ crc_in[10] ^ crc_in[13] ^ crc_in[14] ^ 
		crc_in[15] ^ crc_in[17] ^ crc_in[19] ^ crc_in[20] ^ crc_in[22] ^ crc_in[28] ^ crc_in[29] ^ crc_in[31] ^ 
		data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[9] ^ data_in[10] ^ data_in[13] ^ data_in[14] ^ 
		data_in[15] ^ data_in[17] ^ data_in[19] ^ data_in[20] ^ data_in[22] ^ data_in[28] ^ data_in[29] ^ data_in[31], // next_crc[18]

		crc_in[1] ^ crc_in[2] ^ crc_in[6] ^ crc_in[9] ^ crc_in[10] ^ crc_in[12] ^ crc_in[15] ^ crc_in[16] ^ crc_in[18] ^ crc_in[21] ^ 
		crc_in[22] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[28] ^ crc_in[30] ^ crc_in[31] ^ 
		data_in[1] ^ data_in[2] ^ data_in[6] ^ data_in[9] ^ data_in[10] ^ data_in[12] ^ data_in[15] ^ data_in[16] ^ data_in[18] ^ data_in[21] ^ 
		data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[28] ^ data_in[30] ^ data_in[31], // next_crc[17]

		crc_in[0] ^ crc_in[1] ^ crc_in[5] ^ crc_in[8] ^ crc_in[9] ^ crc_in[11] ^ crc_in[14] ^ crc_in[15] ^ crc_in[17] ^ crc_in[20] ^ 
		crc_in[21] ^ crc_in[22] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[27] ^ crc_in[29] ^ crc_in[30] ^ 
		data_in[0] ^ data_in[1] ^ data_in[5] ^ data_in[8] ^ data_in[9] ^ data_in[11] ^ data_in[14] ^ data_in[15] ^ data_in[17] ^ 
		data_in[20] ^ data_in[21] ^ data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[25] ^ data_in[27] ^ data_in[29] ^ data_in[30], // next_crc[16]

		crc_in[0] ^ crc_in[4] ^ crc_in[7] ^ crc_in[8] ^ crc_in[10] ^ crc_in[13] ^ crc_in[14] ^ crc_in[16] ^ crc_in[19] ^ crc_in[20] ^ 
		crc_in[21] ^ crc_in[22] ^ crc_in[23] ^ crc_in[24] ^ crc_in[26] ^ crc_in[28] ^ crc_in[29] ^ 
		data_in[0] ^ data_in[4] ^ data_in[7] ^ data_in[8] ^ data_in[10] ^ data_in[13] ^ data_in[14] ^ data_in[16] ^ data_in[19] ^ data_in[20] ^ 
		data_in[21] ^ data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[26] ^ data_in[28] ^ data_in[29], // next_crc[15]

		crc_in[3] ^ crc_in[6] ^ crc_in[7] ^ crc_in[9] ^ crc_in[12] ^ crc_in[13] ^ crc_in[15] ^ crc_in[18] ^ crc_in[19] ^ crc_in[20] ^ 
		crc_in[21] ^ crc_in[22] ^ crc_in[23] ^ crc_in[25] ^ crc_in[27] ^ crc_in[28] ^ 
		data_in[3] ^ data_in[6] ^ data_in[7] ^ data_in[9] ^ data_in[12] ^ data_in[13] ^ data_in[15] ^ data_in[18] ^ data_in[19] ^ 
		data_in[20] ^ data_in[21] ^ data_in[22] ^ data_in[23] ^ data_in[25] ^ data_in[27] ^ data_in[28], // next_crc[14]

		crc_in[0] ^ crc_in[1] ^ crc_in[2] ^ crc_in[3] ^ crc_in[4] ^ crc_in[10] ^ crc_in[11] ^ crc_in[12] ^ crc_in[13] ^ crc_in[15] ^ 
		crc_in[17] ^ crc_in[18] ^ crc_in[20] ^ crc_in[21] ^ crc_in[23] ^ crc_in[25] ^ crc_in[31] ^ 
		data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[10] ^ data_in[11] ^ data_in[12] ^ data_in[13] ^ 
		data_in[15] ^ data_in[17] ^ data_in[18] ^ data_in[20] ^ data_in[21] ^ data_in[23] ^ data_in[25] ^ data_in[31], // next_crc[13]

		crc_in[2] ^ crc_in[4] ^ crc_in[5] ^ crc_in[6] ^ crc_in[8] ^ crc_in[9] ^ crc_in[11] ^ crc_in[12] ^ crc_in[13] ^ crc_in[15] ^ 
		crc_in[16] ^ crc_in[17] ^ crc_in[20] ^ crc_in[23] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[30] ^ crc_in[31] ^ 
		data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[8] ^ data_in[9] ^ data_in[11] ^ data_in[12] ^ data_in[13] ^ data_in[15] ^ 
		data_in[16] ^ data_in[17] ^ data_in[20] ^ data_in[23] ^ data_in[25] ^ data_in[26] ^ data_in[27] ^ data_in[30] ^ data_in[31], // next_crc[12]

		crc_in[0] ^ crc_in[6] ^ crc_in[7] ^ crc_in[11] ^ crc_in[12] ^ crc_in[13] ^ 
		crc_in[16] ^ crc_in[23] ^ crc_in[27] ^ crc_in[29] ^ crc_in[30] ^ crc_in[31] ^ 
		data_in[0] ^ data_in[6] ^ data_in[7] ^ data_in[11] ^ data_in[12] ^ data_in[13] ^ data_in[16] ^ data_in[23] ^ 
		data_in[27] ^ data_in[29] ^ data_in[30] ^ data_in[31], // next_crc[11]

		crc_in[5] ^ crc_in[6] ^ crc_in[10] ^ crc_in[11] ^ crc_in[12] ^ crc_in[15] ^ crc_in[22] ^ 
		crc_in[26] ^ crc_in[28] ^ crc_in[29] ^ crc_in[30] ^ 
		data_in[5] ^ data_in[6] ^ data_in[10] ^ data_in[11] ^ data_in[12] ^ data_in[15] ^ data_in[22] ^ data_in[26] ^ 
		data_in[28] ^ data_in[29] ^ data_in[30], // next_crc[10]

		crc_in[0] ^ crc_in[1] ^ crc_in[3] ^ crc_in[6] ^ crc_in[8] ^ crc_in[9] ^ crc_in[11] ^ crc_in[13] ^ crc_in[15] ^ crc_in[19] ^ 
		crc_in[21] ^ crc_in[22] ^ crc_in[23] ^ crc_in[24] ^ crc_in[26] ^ crc_in[28] ^ crc_in[29] ^ crc_in[31] ^ 
		data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[6] ^ data_in[8] ^ data_in[9] ^ data_in[11] ^ data_in[13] ^ data_in[15] ^ data_in[19] ^ 
		data_in[21] ^ data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[26] ^ data_in[28] ^ data_in[29] ^ data_in[31], // next_crc[9]

		crc_in[1] ^ crc_in[2] ^ crc_in[3] ^ crc_in[4] ^ crc_in[6] ^ crc_in[7] ^ crc_in[12] ^ crc_in[13] ^ crc_in[15] ^ 
		crc_in[18] ^ crc_in[19] ^ crc_in[20] ^ crc_in[21] ^ crc_in[24] ^ crc_in[26] ^ crc_in[28] ^ crc_in[30] ^ crc_in[31] ^ 
		data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ data_in[7] ^ data_in[12] ^ data_in[13] ^ data_in[15] ^ data_in[18] ^ 
		data_in[19] ^ data_in[20] ^ data_in[21] ^ data_in[24] ^ data_in[26] ^ data_in[28] ^ data_in[30] ^ data_in[31], // next_crc[8]

		crc_in[0] ^ crc_in[1] ^ crc_in[2] ^ crc_in[3] ^ crc_in[5] ^ crc_in[6] ^ crc_in[11] ^ crc_in[12] ^ crc_in[14] ^ crc_in[17] ^ 
		crc_in[18] ^ crc_in[19] ^ crc_in[20] ^ crc_in[23] ^ crc_in[25] ^ crc_in[27] ^ crc_in[29] ^ crc_in[30] ^ 
		data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[6] ^ data_in[11] ^ data_in[12] ^ data_in[14] ^ 
		data_in[17] ^ data_in[18] ^ data_in[19] ^ data_in[20] ^ data_in[23] ^ data_in[25] ^ data_in[27] ^ data_in[29] ^ data_in[30], // next_crc[7]

		crc_in[2] ^ crc_in[3] ^ crc_in[6] ^ crc_in[8] ^ crc_in[11] ^ crc_in[14] ^ crc_in[15] ^ crc_in[16] ^ crc_in[17] ^ crc_in[18] ^ 
		crc_in[23] ^ crc_in[25] ^ crc_in[27] ^ crc_in[28] ^ crc_in[29] ^ crc_in[31] ^ 
		data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[8] ^ data_in[11] ^ data_in[14] ^ data_in[15] ^ data_in[16] ^ data_in[17] ^ 
		data_in[18] ^ data_in[23] ^ data_in[25] ^ data_in[27] ^ data_in[28] ^ data_in[29] ^ data_in[31], // next_crc[6]

		crc_in[0] ^ crc_in[2] ^ crc_in[3] ^ crc_in[4] ^ crc_in[6] ^ crc_in[7] ^ crc_in[8] ^ crc_in[16] ^ crc_in[17] ^ crc_in[19] ^ 
		crc_in[23] ^ crc_in[25] ^ crc_in[28] ^ crc_in[30] ^ crc_in[31] ^ 
		data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[16] ^ data_in[17] ^ 
		data_in[19] ^ data_in[23] ^ data_in[25] ^ data_in[28] ^ data_in[30] ^ data_in[31], // next_crc[5]

		crc_in[0] ^ crc_in[2] ^ crc_in[4] ^ crc_in[7] ^ crc_in[8] ^ crc_in[10] ^ crc_in[13] ^ crc_in[14] ^ crc_in[16] ^ crc_in[18] ^ 
		crc_in[19] ^ crc_in[23] ^ crc_in[25] ^ crc_in[26] ^ crc_in[29] ^ crc_in[30] ^ crc_in[31] ^ 
		data_in[0] ^ data_in[2] ^ data_in[4] ^ data_in[7] ^ data_in[8] ^ data_in[10] ^ data_in[13] ^ data_in[14] ^ data_in[16] ^ 
		data_in[18] ^ data_in[19] ^ data_in[23] ^ data_in[25] ^ data_in[26] ^ data_in[29] ^ data_in[30] ^ data_in[31], // next_crc[4]

		crc_in[0] ^ crc_in[4] ^ crc_in[5] ^ crc_in[7] ^ crc_in[8] ^ crc_in[9] ^ crc_in[10] ^ crc_in[12] ^ crc_in[14] ^ crc_in[17] ^ 
		crc_in[18] ^ crc_in[19] ^ crc_in[23] ^ crc_in[26] ^ crc_in[27] ^ crc_in[28] ^ crc_in[29] ^ crc_in[30] ^ crc_in[31] ^ 
		data_in[0] ^ data_in[4] ^ data_in[5] ^ data_in[7] ^ data_in[8] ^ data_in[9] ^ data_in[10] ^ data_in[12] ^ data_in[14] ^ data_in[17] ^ 
		data_in[18] ^ data_in[19] ^ data_in[23] ^ data_in[26] ^ data_in[27] ^ data_in[28] ^ data_in[29] ^ data_in[30] ^ data_in[31], // next_crc[3]

		crc_in[3] ^ crc_in[4] ^ crc_in[6] ^ crc_in[7] ^ crc_in[8] ^ crc_in[9] ^ crc_in[11] ^ crc_in[13] ^ crc_in[16] ^ crc_in[17] ^ 
		crc_in[18] ^ crc_in[22] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[28] ^ crc_in[29] ^ crc_in[30] ^ 
		data_in[3] ^ data_in[4] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[9] ^ data_in[11] ^ data_in[13] ^ data_in[16] ^ data_in[17] ^ 
		data_in[18] ^ data_in[22] ^ data_in[25] ^ data_in[26] ^ data_in[27] ^ data_in[28] ^ data_in[29] ^ data_in[30], // next_crc[2]

		crc_in[2] ^ crc_in[3] ^ crc_in[5] ^ crc_in[6] ^ crc_in[7] ^ crc_in[8] ^ crc_in[10] ^ crc_in[12] ^ crc_in[15] ^ crc_in[16] ^ 
		crc_in[17] ^ crc_in[21] ^ crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[28] ^ crc_in[29] ^ 
		data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[10] ^ data_in[12] ^ data_in[15] ^ data_in[16] ^ 
		data_in[17] ^ data_in[21] ^ data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[27] ^ data_in[28] ^ data_in[29], // next_crc[1]

		crc_in[1] ^ crc_in[2] ^ crc_in[4] ^ crc_in[5] ^ crc_in[6] ^ crc_in[7] ^ crc_in[9] ^ crc_in[11] ^ crc_in[14] ^ crc_in[15] ^ crc_in[16] ^ 
		crc_in[20] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[28] ^ 
		data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[9] ^ data_in[11] ^ data_in[14] ^ data_in[15] ^ 
		data_in[16] ^ data_in[20] ^ data_in[23] ^ data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[27] ^ data_in[28] // next_crc[0]
	};
endfunction
endpackage: CRC32
