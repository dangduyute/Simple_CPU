class Monitor;
    virtual add_if     vif;
    mailbox #(packet)  m2s_mb;
    int                clks_per_bit;
    int                num_txn;

    function new(virtual add_if vif,
                 mailbox #(packet) m2s_mb,
                 int clks_per_bit,
                 int num_txn);
        this.vif          = vif;
        this.m2s_mb       = m2s_mb;
        this.clks_per_bit = clks_per_bit;
        this.num_txn      = num_txn;
    endfunction

  
    task recv_byte(output bit [7:0] data);
      
        @(negedge vif.Tx_out);

       
        repeat (clks_per_bit/2) @(posedge vif.CLK);

     
        for (int i = 0; i < 8; i++) begin
            repeat (clks_per_bit) @(posedge vif.CLK);
            data[i] = vif.Tx_out;
        end

    
        repeat (clks_per_bit) @(posedge vif.CLK);
    endtask

    task complete_result(output bit [15:0] data);
        bit [7:0] msb_reg, lsb_reg;

        recv_byte(msb_reg);   // byte 1 = MSB
        recv_byte(lsb_reg);   // byte 2 = LSB

        data = {msb_reg, lsb_reg};
    endtask

    task run();
        packet    p;
        bit [15:0] rxdata;
        logic signed [15:0] act;
        @(posedge vif.CLK);

        while (1) begin
            complete_result(rxdata);  
            p = new();
            p.act_data = rxdata;     
            act = rxdata;
            $display("[%0t] MON : pkt act=%0d (%0b)",
                     $time, act, act);

            m2s_mb.put(p);
        end
    endtask
endclass
