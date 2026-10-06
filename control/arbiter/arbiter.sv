// Priority arbiter: Examine multiple request signals, 
//  grant access to the highest-priority requester.
// Highest-index request has the highest priority.
// Only one grant can be active at a time.
// If a high-priorty requester keeps being high-priority,
//  other requesters starve. Grant will only be given to that
//  requester until it stops requesting.

// *for loop*
    // Arbiter scans req from MSB to LSB.
    // First asserted request receives the grant (grant[i]).
    // priority_flag breaks the loop by being HIGH when
    //  highest-priority requester is found.

module arbiter #(
    parameter int WIDTH = 4
) (
    input   logic   [WIDTH-1:0] req,    // Request signals
    output  logic   [WIDTH-1:0] grant   // Granted requester
);

    logic priority_flag;

    always_comb begin : request_grant
        grant           = '0;
        priority_flag   = 0;

        // Lookup: *for loop*
        for (int i = WIDTH-1; i >= 0; i--) begin
            if (!priority_flag) begin
                if (req[i]) begin
                    grant[i]        = 1;
                    priority_flag   = 1;
                end
            end
        end
    end

endmodule
