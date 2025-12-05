class Driver;
    virtual add_if     vif;
    mailbox #(packet)  s2d_mb;
    int                clks_per_bit;
    int                num_txn;
    semaphore          drv_sem;
    function new(virtual add_if vif,
                 mailbox #(packet) s2d_mb,
                 int clks_per_bit,
                 int num_txn,
                 semaphore drv_sem);
        this.vif          = vif;
        this.s2d_mb       = s2d_mb;
        this.clks_per_bit = clks_per_bit;
        this.num_txn      = num_txn;
        this.drv_sem      = drv_sem;
    endfunction

    // -----------------------------
    // G?i 1 bit UART
    // -----------------------------
    task send_bit(bit b);
        vif.Rx_in = b;
        repeat (clks_per_bit) @(posedge vif.CLK);
    endtask

    // -----------------------------
    // G?i 1 byte UART (frame)
    // -----------------------------
    task send_byte(bit [7:0] data);
        // idle 1 bit


        // start bit
        send_bit(1'b0);

        // 8 data bits LSB-first
        for (int i = 0; i < 8; i++)
            send_bit(data[i]);

        // stop bit
        send_bit(1'b1);
    endtask

    // -----------------------------
    // Task: g?i OPCODE (1 packet)
    // -----------------------------
    task automatic send_opcode();
        packet p;
        bit [7:0] opcode;
        s2d_mb.get(p);   // l?y packet opcode t? Stimulus
        opcode = p.data_in[7:0];
        $display("[%0t] DRV : send OPCODE = %0d",
                 $time, opcode);

        send_byte(opcode);
    endtask

    // -----------------------------
    // Task: g?i 2 toán h?ng A, B
    // -----------------------------
    task automatic send_operands();
        packet p;
        logic signed [15:0] val;
        bit [7:0] msb, lsb;
    
        // ----- A -----
        s2d_mb.get(p);
        val = p.data_in;           // 16-bit signed [-255..255]
        msb = val[15:8];
        lsb = val[7:0];
    
        $display("[%0t] DRV : send A = %0d  (%0b)",
                 $time, val, val);
    
        send_byte(msb);   // g?i MSB tr??c
        send_byte(lsb);   // r?i LSB
    
        // ----- B -----
        s2d_mb.get(p);
        val = p.data_in;
        msb = val[15:8];
        lsb = val[7:0];
    
        $display("[%0t] DRV : send B = %0d  (%0b)",
                 $time, val, val);
    
        send_byte(msb);
        send_byte(lsb);
    endtask

    // -----------------------------
    // Task run chính
    // -----------------------------
    task run();
        vif.Rx_in = 1'b1;          // idle
        @(posedge vif.CLK);

        // ví d? m?i l?n Stimulus phát 1 b? {opcode, a, b}
        // thì mình l?p vô h?n: c? nh?n 1 b? r?i g?i
        forever begin
            drv_sem.get(1);
            send_opcode();     // l?y packet 1
            send_operands();   // l?y packet 2,3
        end
    endtask
endclass
