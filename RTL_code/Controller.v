module Controller (
    input  wire 				CLK,
    input  wire 				RST,        // active-low async reset
	
	/* From RX UART Interface */	
    input  wire    				Rx_DV_in,
	
	/* From TX UART Interface */	
	input  wire					Tx_Done_in,
	
	/* From Datapath (ALU) */
	input  wire					c_valid_in,
	
	/* For Datapath (ALU) */
    output wire  				En_out,
	
	/* For Instruction Memory */
	output wire  				Load_INS_en_out,
	
	/* For Input Memory */
	output wire  				Load_MSB_a_en_out,
	output wire  				Load_LSB_a_en_out,
	output wire  				Load_MSB_b_en_out,
	output wire  				Load_LSB_b_en_out,
	
	/* To TX UART Interface */
	output wire 				Tx_DV_out,
	
	/* To Core (select MSB/LSB to send) */
	output wire					MLSB_SEL_Tx_Byte_out
);

    //==================================================//
    //                   State encoding                 //
    //==================================================//
    localparam [1:0] ST_IDLE = 2'b00;
	localparam [1:0] ST_LOAD = 2'b01;
	localparam [1:0] ST_EXE  = 2'b10;
    localparam [1:0] ST_SEND = 2'b11;

    //==================================================//
    //                       Regs                       //
    //==================================================//
	reg [1:0] state_q,   state_d;
	reg [2:0] load_cnt_q, load_cnt_d;   // ??m byte nh?n t? RX (0..5)
	reg [1:0] send_cnt_q, send_cnt_d;   // ??m byte g?i qua TX  (0..2)
	reg       tx_req_q,  tx_req_d;      // yêu c?u TX g?i

    //==================================================//
    //                 Combinational Logic              //
    //==================================================//

	// ---------- Next-state & counters ----------
	always @(*) begin
		// m?c ??nh gi? nguyên
		state_d    = state_q;
		load_cnt_d = load_cnt_q;
		send_cnt_d = send_cnt_q;
		tx_req_d   = tx_req_q;

		//------------------ FSM ------------------//
		case (state_q)
			ST_IDLE: begin
				// b?t ??u nh?n gói m?i khi có byte t? RX
				if (Rx_DV_in)
					state_d = ST_LOAD;
			end

			ST_LOAD: begin
				// khi ??m ?? 5 byte (1 INS + 4 cho A/B) => sang EXE
				if (load_cnt_q == 3'd5)
					state_d = ST_EXE;
			end

			ST_EXE: begin
				// ch? ALU báo k?t qu? h?p l?
				if (c_valid_in)
					state_d = ST_SEND;
			end

			ST_SEND: begin
				// sau khi g?i xong 2 byte và TX báo Done => quay l?i IDLE
				if ((send_cnt_q == 2'd2) && Tx_Done_in)
					state_d = ST_IDLE;
			end

			default: begin
				state_d = ST_IDLE;
			end
		endcase

		//---------------- load_cnt_d ----------------//
		// reset counter khi vào EXE
		if (state_q == ST_EXE) begin
			load_cnt_d = 3'd0;
		end
		else if ((state_q == ST_IDLE || state_q == ST_LOAD) && Rx_DV_in) begin
			load_cnt_d = load_cnt_q + 3'd1;
		end

		//---------------- send_cnt_d ----------------//
		if (state_q == ST_IDLE) begin
			send_cnt_d = 2'd0;
		end
		else if (state_q == ST_SEND && tx_req_q) begin
			// m?i l?n yêu c?u g?i 1 byte thì t?ng
			send_cnt_d = send_cnt_q + 2'd1;
		end
		if (state_q == ST_SEND &&
		    (c_valid_in || Tx_Done_in) &&
		    (send_cnt_q < 2)) begin
			tx_req_d = 1'b1;
		end
		else begin
			tx_req_d = 1'b0;
		end
	end

    //==================================================//
    //                 Sequential Logic                 //
    //==================================================//
	
	always @(posedge CLK or negedge RST) begin
		if (RST == 0) begin
			state_q    <= ST_IDLE;
			load_cnt_q <= 3'd0;
			send_cnt_q <= 2'd0;
			tx_req_q   <= 1'b0;
		end
		else begin
			state_q    <= state_d;
			load_cnt_q <= load_cnt_d;
			send_cnt_q <= send_cnt_d;
			tx_req_q   <= tx_req_d;
		end
	end

    //==================================================//
    //                       Outputs                    //
    //==================================================//

	
	assign En_out = (state_q == ST_EXE);

	
	assign Load_INS_en_out   = (Rx_DV_in && state_q == ST_IDLE);
	assign Load_MSB_a_en_out = (Rx_DV_in && load_cnt_q == 3'd1);
	assign Load_LSB_a_en_out = (Rx_DV_in && load_cnt_q == 3'd2);
	assign Load_MSB_b_en_out = (Rx_DV_in && load_cnt_q == 3'd3);
	assign Load_LSB_b_en_out = (Rx_DV_in && load_cnt_q == 3'd4);


	assign Tx_DV_out            = tx_req_q;
	assign MLSB_SEL_Tx_Byte_out = send_cnt_q[0];  

endmodule
