// How the higher_pri_reqs is begin calculated: 
// Say, N = 4,and req = 4'b1001
// here, 0 bit is selected as the highest priority
// Now,
//      higher_pri_reqs[0] = 1'b0;  // already hardcoded
//      higher_pri_reqs[1] = higher_pri_reqs[0] | req[0] = 0 | 1 = 1 
//      higher_pri_reqs[2] = higher_pri_reqs[1] | req[1] = 1 | 0 = 1 
//      higher_pri_reqs[3] = higher_pri_reqs[2] | req[2] = 1 | 0 = 1 
//
// So, higher_pri_reqs[3:0] = 4'b1110;
//     ~higher_pri_reqs[3:0] = 4'b0001;
//
//  Finally, grant = req[3:0] & ~higher_pri_reqs[3:0];
//                 = 4'b1001 & 4'b0001;
//                 = 4'b0001;
// So bit 0 will get the final grant


module fp_arb #(
    parameter N = 16    // Number of requsters
    )(
    input logic [N-1:0] req_i,    // who made the request
    output logic [N-1:0] grant_o  // who will get the grant
    );
    
    logic [N-1:0] higher_pri_reqs;
    
    // Bit 0 has the  highest priority
    // because there are no requester above bit 0 which has more priority
    always_comb higher_pri_reqs [0] = 1'b0;

    // Logic to choose higher priority requests: parallel ripple OR logic
    always_comb begin
        for (int i = 1; i < N; i++) begin
            higher_pri_reqs[i] = higher_pri_reqs[i-1] | req_i[i-1];
        end
    end
    
    // Final grant vector generation
    // a requester receives a grant only if it requested access and no lower-indexed 
    // (higher_priority) requester is active
    always_comb grant_o = req_i  & ~higher_pri_reqs;

endmodule

