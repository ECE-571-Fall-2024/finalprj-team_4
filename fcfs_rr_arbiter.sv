//*******************************************************************
// File name : fcfs_rr_arbiter.sv
// Author : Saishree
// Date Modified : 28/11/2024
// Description:  
//*******************************************************************
module fcfs_arbiter #(
    parameter NUM_REQUESTS = 4  // Number of request lines (modifiable)
) (
    input  logic clk,                       // Clock signal
    input  logic reset_n,                     // Active-low reset
    input  logic [NUM_REQUESTS-1:0] rqst,    // Request signals
    output logic [NUM_REQUESTS-1:0] grant   // Grant signals
);

    // Internal signals
    logic [NUM_REQUESTS-1:0] served;        // Tracks if a request was served
    integer i;                              // Loop variable

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Reset all outputs
            grant <= '0;
            served <= '0;
        end else begin
            // Grant logic
            grant <= '0; // Default no grant
            for (i = 0; i < NUM_REQUESTS; i++) begin
                // Grant to the first unserved active request
                if (rqst[i] && !served[i]) begin
                    grant[i] <= 1'b1;
                    served[i] <= 1'b1; // Mark request as served
                    break; // Stop after granting one request
                end
            end

            // Clear 'served' if all requests are served
            if (rqst == '0) begin
                served <= '0;
            end
        end
    end
endmodule