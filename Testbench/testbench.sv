module tb_Add_IP;
    import add_tb_pkg::*;
    logic CLK;
    add_if vif(CLK);

    localparam int CLKS_PER_BIT = 217;
    localparam int NUM_TXN      = 10;
    localparam int NUM_ROUND         = 10;
    // DUT
    Add_IP dut (
        .CLK    (CLK),
        .RST    (vif.RST),
        .Rx_in  (vif.Rx_in),
        .Tx_out (vif.Tx_out),
        .LED_out(vif.LED_out)
    );

    // Clock gen
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;   // 100 MHz
    end

    // Reset (active-low)
    initial begin
        vif.RST   = 1'b0;
        vif.Rx_in = 1'b1;        
        repeat (10) @(posedge CLK);
        vif.RST = 1'b1;
    end

    // Mailbox
    mailbox #(packet) s2d_mb = new();   // Stimulus -> Driver
    mailbox #(packet) s2s_mb = new();   // Stimulus -> Scoreboard
    mailbox #(packet) m2s_mb = new();   // Monitor  -> Scoreboard
     semaphore drv_sem = new(0);
    // Components
    Stimulus   stim;
    Driver     drv;
    Monitor    mon;
    Scoreboard scb;

    initial begin
        stim = new(s2d_mb, s2s_mb, NUM_TXN);
        drv  = new(vif, s2d_mb, CLKS_PER_BIT, NUM_TXN, drv_sem);
        mon  = new(vif, m2s_mb, CLKS_PER_BIT, NUM_TXN);
        scb  = new(s2s_mb, m2s_mb, NUM_TXN, drv_sem);
      
        @(posedge vif.RST);

  
    
     for (int r = 0; r < NUM_ROUND; r++) begin
        $display("=== ROUND %0d START ===", r);

        
            stim.run();

        $display("=== ROUND %0d DONE ===", r);
        end
          fork
        drv.run();
        mon.run();
        scb.run();
        join_none
       
    end
 
endmodule
