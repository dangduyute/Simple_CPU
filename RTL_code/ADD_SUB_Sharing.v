module ADD_SUB_Sharing (
    input  wire                 ADD_SUB_Select_in,   
    input  wire signed [15:0]   a_in,                
    input  wire signed [15:0]   b_in,               
    output wire signed [15:0]   c_out                
);

    //==================================================//
    //                       Wires                      //
    //==================================================//
    wire signed [15:0] b_mod_w;    
    wire signed [16:0] sum_ext_w; 
    wire signed [16:0] sat_max_w;
    wire signed [16:0] sat_min_w;

    //==================================================//
    //                  Constant bounds                 //
    //==================================================//
    assign sat_max_w = 17'sd32767; 
    assign sat_min_w = -17'sd32768;

    //==================================================//
    //                 Combinational Logic              //
    //==================================================//

 
    assign b_mod_w = b_in ^ {16{ADD_SUB_Select_in}};

 
    assign sum_ext_w = {a_in[15], a_in}
                     + {b_mod_w[15], b_mod_w}
                     + ADD_SUB_Select_in;

   
    assign c_out = (sum_ext_w > sat_max_w) ? sat_max_w[15:0] :
                   (sum_ext_w < sat_min_w) ? sat_min_w[15:0] :
                                             sum_ext_w[15:0];

endmodule
