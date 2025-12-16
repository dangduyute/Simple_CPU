class Scoreboard;
    mailbox #(packet) s2s_mb;   // Stimulus -> Scoreboard (opcode, A, B)
    mailbox #(packet) m2s_mb;   // Monitor  -> Scoreboard (result)
    int               num_txn;  
    int               err_cnt;
     semaphore         drv_sem;
    function new(mailbox #(packet) s2s_mb,
                 mailbox #(packet) m2s_mb,
                 int num_txn,
                 semaphore drv_sem);
        this.s2s_mb  = s2s_mb;
        this.m2s_mb  = m2s_mb;
        this.num_txn = num_txn;
        this.err_cnt = 0;
        this.drv_sem = drv_sem;
    endfunction

    function automatic logic signed [15:0] sat_addsub(
        input logic signed [15:0] a,
        input logic signed [15:0] b,
        input bit                 sub    
    );
        logic signed [15:0] b_xor;
        logic signed [16:0] sum;

        b_xor = b ^ {16{sub}};
        sum   = {a[15], a} + {b_xor[15], b_xor} + sub;

        if (sum > 17'sd32767)
            sat_addsub = 16'sd32767;
        else if (sum < -17'sd32768)
            sat_addsub = -16'sd32768;
        else
            sat_addsub = sum[15:0];
    endfunction

    // ----------------------------
    // Golden model cho ALU
    // ----------------------------
    function automatic logic signed [15:0] golden_model(
        input bit [7:0]          opcode,
        input logic signed [15:0] a,
        input logic signed [15:0] b
    );
        logic signed [15:0] res;
        logic signed [31:0] mul_raw;

        unique case (opcode)
            0: begin
                res = a;
            end
            1: begin
                res = sat_addsub(a, b, 1'b0);
            end
            2: begin
                res = sat_addsub(a, b, 1'b1);
            end
            3: begin
                mul_raw = a * b;
                res     = mul_raw[15:0];
            end
            4: begin
                res = a & b;
            end
            5: begin
                res = a | b;
            end
            6: begin
                res = ~a;
            end
            7: begin
                res = a ^ b;
            end
            default: begin
                res = res;
            end
        endcase

        return res;
    endfunction

    // ----------------------------
    // Task run chính
    // ----------------------------
    task run();
        packet op_pkt, a_pkt, b_pkt, res_pkt;
        bit   [7:0]          opcode_8;
        logic signed [15:0]  a16, b16;
        logic signed [15:0]  exp_res, act_res;
        drv_sem.put(1);
        while(1) begin
            s2s_mb.get(op_pkt);   // opcode trong data_in
            s2s_mb.get(a_pkt);    // A trong data_in
            s2s_mb.get(b_pkt);    // B trong data_in

            opcode_8 = op_pkt.data_in[7:0];

            a16 = {8'b0, a_pkt.data_in};  
            b16 = {8'b0, b_pkt.data_in};
            m2s_mb.get(res_pkt);
            act_res = res_pkt.act_data; 
            exp_res = golden_model(opcode_8, a16, b16);
            if (act_res !== exp_res) begin
                $error("SCB : MIS op=%0d  a=%0d  b=%0d  exp=%0d (0x%0b)  act=%0d (%0b)",
                       
                       opcode_8,
                       a16, b16,
                       exp_res, exp_res,
                       act_res, act_res);
                err_cnt++;
            end
            else begin
                $display("[%0t] SCB : PASS  op=%0d  a=%0d  b=%0d  exp=%0d (0x%0b)   act=%0d  (%0b)",
                         $time,
                         opcode_8,
                         a16, b16,
                         act_res, act_res,
                         exp_res,exp_res);
            end
            drv_sem.put(1);
        end
    endtask
endclass
