class Stimulus;
    mailbox #(packet) s2d_mb;   // Stimulus -> Driver
    mailbox #(packet) s2s_mb;   // Stimulus -> Scoreboard
    int num_txn;
    function new(mailbox #(packet) s2d_mb,
                 mailbox #(packet) s2s_mb,
                 int num_txn);
        this.s2d_mb  = s2d_mb;
        this.s2s_mb  = s2s_mb;
        this.num_txn = num_txn;
    endfunction

    task run();
        packet p_drv, p_scb;
        repeat(1) begin
        int i = 0;
        p_drv = new();
        if( p_drv.randomize() with { data_in inside{[1:7]}; }) begin
            $display("OPCODE is %0d",p_drv.data_in);
        end 
        else $display("Randomize failed");
        p_scb = new();
        p_scb.copy(p_drv);
        s2d_mb.put(p_drv);   // cho Driver
        s2s_mb.put(p_scb);   // cho Scoreboard
        repeat(2) begin
            p_drv = new();
            if( p_drv.randomize()with { data_in inside {[-255:255]}; } ) begin
                if(i == 0) begin
                $display("a is %0d",p_drv.data_in);
                i++;
                end
                else begin
                $display("b is %0d",p_drv.data_in);
                i=0;
                end
            end 
            else $display("Randomize failed");
            p_scb = new();             
            p_scb.copy(p_drv);
            s2d_mb.put(p_drv);   // cho Driver
            s2s_mb.put(p_scb);   // cho Scoreboard
        end
        #4500;
        end
    endtask
endclass
