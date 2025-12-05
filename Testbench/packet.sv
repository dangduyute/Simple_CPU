// packet.svh
class packet;

    rand logic signed  [15:0] data_in;   
         bit  [15:0] exp_data; 
         bit  [15:0] act_data; 

    function void post_randomize();
        exp_data = data_in;
    endfunction
    
    function void copy(packet p);
        data_in  = p.data_in;
        exp_data = p.exp_data;
        act_data = p.act_data;
    endfunction

    function void display(string tag);
        $display("[%0t] %s: data=%0d exp=%0d act=%0d",
                 $time, tag, data_in, exp_data, act_data);
    endfunction
endclass
