module Input_Memory (
    input  wire                 CLK,
	input  wire					RST,

	/* From Controller */
	input  wire  				Load_MSB_a_en_in,
	input  wire  				Load_LSB_a_en_in,
	input  wire  				Load_MSB_b_en_in,
	input  wire  				Load_LSB_b_en_in,

	/* From RX UART Interface */
	input  wire	signed [7:0] 	Rx_Byte_in,   

	/* To Datapath */
	output reg 	signed [15:0] 	a_out,
	output reg 	signed [15:0] 	b_out
);

    //==================================================//
    //                        Regs                      //
    //==================================================//
	reg signed [15:0] a_next_r;
	reg signed [15:0] b_next_r;

    //==================================================//
    //                 Combinational Logic              //
    //==================================================//
	always @(*) begin
		// m?c ??nh gi? nguyên
		a_next_r = a_out;
		b_next_r = b_out;

		// ----- A operand -----
		if (Load_MSB_a_en_in) begin
			a_next_r[15:8] = Rx_Byte_in;
		end
		else if (Load_LSB_a_en_in) begin
			a_next_r[7:0]  = Rx_Byte_in;
		end

		// ----- B operand -----
		if (Load_MSB_b_en_in) begin
			b_next_r[15:8] = Rx_Byte_in;
		end
		else if (Load_LSB_b_en_in) begin
			b_next_r[7:0]  = Rx_Byte_in;
		end
	end

    //==================================================//
    //                 Sequential Logic                 //
    //==================================================//
    always @(posedge CLK or negedge RST) begin
		if (RST == 0) begin
			a_out <= 16'sd0;
			b_out <= 16'sd0;
		end
        else begin
			a_out <= a_next_r;
			b_out <= b_next_r;
		end
    end

endmodule
