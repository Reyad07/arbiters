/*

                  +----------------------+
req_i ----------->| Rotate Requests      |
                  +----------------------+
                             |
                             | req_rot
                             ▼
                  +----------------------+
                  | Fixed Priority       |
                  | Arbiter (fp_arb)     |
                  +----------------------+
                             |
                             | grant_rot
                             ▼
                  +----------------------+
                  | Rotate Grant Back    |
                  +----------------------+
                             |
                             ▼
                         grant_o

                     ▲
                     │
               last_grant register

rotation is done by shifting. shift amount is determined by last grant
   
    shift_amnt = last_grant + 1


*/
module rr_arb #(
        parameter N = 16    // Number of requesters
    )(
        input logic             clk_i,
        input logic             arst_n,
        
        input logic [N-1:0]     req_i,
        output logic [N-1:0]    grant_o
    );

    logic [$clog2(N)-1:0] last_grant;
    
    // for connecting with the fixed point arbiter
    logic [N-1:0] req_rot;
    logic [N-1:0] grant_rot;
    
    logic [$clog2(N)-1:0] shift_amnt;

    always_comb begin
        if (last_grant == (N-1))
            shift_amnt = 0;
        else
            shift_amnt = last_grant + 1;
    end

    // -------------------------------------------------------------------------------
    // Requests rotator 
    // the requester immediately after last_grant should become the highest priority
    //
    // implementation example:
    // N = 4, shift_amnt = 2
    // req_rot [0] = req_i[(0+2)%4] = req_i[2%4] = req_i[2]
    // req_rot [1] = req_i[3]
    // req_rot [2] = req_i[0]
    // req_rot [3] = req_i[1]
    // -------------------------------------------------------------------------------
    always_comb begin
        
        for (int i = 0; i < N; i++)
            req_rot[i] = req_i[(i+shift_amnt) % N];
    end
    
    // --------------------------------------------------------------------------------
    // Fixed Priority arbiter instantiation
    // --------------------------------------------------------------------------------
    fp_arb #(
        .N(N)
    ) u_fp_arb
    (
        .req_i(req_rot),
        .grant_o(grant_rot)
    );

    //-----------------------------------------
    // Rotate Grant Back
    //-----------------------------------------
    always_comb begin
        for (int i = 0; i < N; i++)
            grant_o[(i+shift_amnt) % N] = grant_rot[i];
    end
    
    //-----------------------------------------
    // Update last_grant/pointer
    //-----------------------------------------
    always_ff @(posedge clk or negedge arst_n) begin
        if (~arst_n) begin
            last_grant <= N-1;  //  so that the first search starts from 0
        end
        else begin
            for (int i = 0; i<N; i++) begin
                if (grant_o[i]) last_grant <= i;
            end
        end
    end

endmodule
