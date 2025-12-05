module Instruction_Memory (
    input  wire                 CLK,
	input  wire					RST,

	/* From Controller */
	input  wire  				Load_INS_en_in,

	/* From RX UART Interface */
	input  wire	signed [7:0] 	Rx_Byte_in,   

	/* To Datapath */
	output reg  [7:0] 			INS_out
);

    //==================================================//
    //                        Regs                      //
    //==================================================//
	reg [7:0] ins_next_r;

    //==================================================//
    //                 Combinational Logic              //
    //==================================================//
	always @(*) begin
		ins_next_r = INS_out;

		if (Load_INS_en_in) begin
			ins_next_r = Rx_Byte_in[7:0];
		end
	end

    //==================================================//
    //                 Sequential Logic                 //
    //==================================================//
    always @(posedge CLK or negedge RST) begin
		if (RST == 0) begin
			INS_out <= 8'd0;
		end
        else begin
			INS_out <= ins_next_r;
		end
    end

endmodule
