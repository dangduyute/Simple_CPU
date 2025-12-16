
`define NOP		       			0
`define ADD		       			1
`define SUB		       			2
`define MUL		       			3
`define AND		       			4
`define OR		       			5
`define NOT		       			6
`define XOR		       			7

module ALU (
    input  wire                 CLK,
	input  wire					RST,
	input  wire					En_in,

	/* From Instruction_Memory */
	input  wire [7:0]   	    INS_in,      // Instruction (use INS_in[2:0])

    /* From Input_Memory */
    input  wire signed [15:0]   a_in,        // input A (Q8.7)
    input  wire signed [15:0]   b_in,        // input B (Q8.7)

    /* To Output / Datapath */
    output reg  signed [15:0]   c_out,       // output C (Q8.7)
	output reg 					c_valid_out
);

    //==================================================//
    //                       Wires                      //
    //==================================================//
	wire [2:0]              op_code_w;          // opcode = INS_in[2:0]
	wire                    use_sub_w;          // 0 = ADD, 1 = SUB
	
	wire signed [31:0]		mul_full_w;
	
    wire signed [15:0] 		res_nop_w;
	wire signed [15:0] 		res_addsub_w;
	wire signed [15:0] 		res_mul_w;  
	wire signed [15:0] 		res_and_w, res_or_w;
	wire signed [15:0] 		res_not_w, res_xor_w;	
	
    //==================================================//
    //                     Instances                    //
    //==================================================//
	
	ADD_SUB_Sharing u_add_sub (
		.ADD_SUB_Select_in (use_sub_w),
		.a_in              (a_in),
		.b_in              (b_in),
		.c_out             (res_addsub_w)
	);

    //==================================================//
    //                 Combinational Logic              //
    //==================================================//

    assign op_code_w = INS_in[2:0];

    // Ch?n ADD hay SUB cho adder chia s?
	assign use_sub_w = (op_code_w == `SUB);

	// Arithmetic Ops
    assign res_nop_w   = a_in;
	assign mul_full_w  = $signed(a_in) * $signed(b_in);
	assign res_mul_w   = mul_full_w[15:0];   // gi? 16 bit th?p (truncate Q8.7)
	
	// Logic Ops
    assign res_and_w   = a_in & b_in;
	assign res_or_w    = a_in | b_in;
	assign res_not_w   = ~a_in;
	assign res_xor_w   = a_in ^ b_in;
	
    //==================================================//
    //                 Sequential Logic                 //
    //==================================================//
	
    always @(posedge CLK or negedge RST) begin
		if (RST == 0) begin
			c_out       <= 16'sd0;
			c_valid_out <= 1'b0;
		end
        else begin
			if (En_in) begin
				case (op_code_w)
					`NOP: begin
						c_out       <= res_nop_w;
						c_valid_out <= 1'b1;
					end

					`ADD: begin
						c_out       <= res_addsub_w;
						c_valid_out <= 1'b1;
					end

					`SUB: begin
						c_out       <= res_addsub_w;
						c_valid_out <= 1'b1;
					end

					`MUL: begin
						c_out       <= res_mul_w;
						c_valid_out <= 1'b1;
					end

					`AND: begin
						c_out       <= res_and_w;
						c_valid_out <= 1'b1;
					end

					`OR: begin
						c_out       <= res_or_w;
						c_valid_out <= 1'b1;
					end

					`NOT: begin
						c_out       <= res_not_w;
						c_valid_out <= 1'b1;
					end

					`XOR: begin
						c_out       <= res_xor_w;
						c_valid_out <= 1'b1;
					end

					default: begin
						c_out       <= c_out;    // gi? giá tr? c?
						c_valid_out <= 1'b0;
					end
				endcase
			end
			else begin
				// không enable: gi? output nh?ng h? valid
				c_out       <= c_out;
				c_valid_out <= 1'b0;
			end
		end
    end

endmodule
