// add_if.sv
interface add_if (input logic CLK);
    logic        RST;       // active-low reset
    logic        Rx_in;
    logic        Tx_out;
    logic [7:0]  LED_out;
endinterface
