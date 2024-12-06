/////////////////////////////////////////////////////////
//  File name : fcfs_rr_arbiter.sv
//  Version   : 0.3
//  Description :  Implementation of FCFS 
//                 parameterized round robin arbiter
/////////////////////////////////////////////////////////
interface arbiter #(parameter Requestors = 4) ();
    logic clk, reset;
    logic [Requestors-1:0] req;
    logic [7:0] weights [Requestors];
    logic [Requestors-1:0] grant;
endinterface

// Define priority_t as a standalone type
typedef enum logic [2:0] {
    LO = 3'b001,
    MED = 3'b010,
    HI = 3'b100
} priority_t;

module FCFS_Weighted_RR_Arbiter #(
    parameter Requestors = 4,
    parameter QUANTUM = 2
) (
    arbiter arbit 
);

    typedef struct {
        logic [7:0] data;
        priority_t prior;
        logic [31:0] present_time;
    } packet_t;

    packet_t pack_request[Requestors];
    logic [15:0] quantum_counter;
    logic [3:0] grant_index;
    logic [Requestors-1:0] filter;
    logic [Requestors-1:0] filtered_request;

    
    assign filtered_request = arbit.req & filter;
    
    // Grant Logic
    always_comb begin
        arbit.grant = 0;
         // All requests initially allowed
        if (filtered_request != 0) begin
            for (int i = 0; i < Requestors; i++) begin
                if (filtered_request[i]) begin
                    arbit.grant[i] = 1'b1;
                    grant_index = i;
                    break; // Grant to the first valid request
                end
            end
        end
    end

    // Quantum Counter and Scheduling
    always_ff @(posedge arbit.clk or negedge arbit.reset) begin
        if (!arbit.reset) begin
            quantum_counter <= 0;
        end else if (arbit.grant != 0) begin
            quantum_counter <= quantum_counter + 1;
            if (quantum_counter >= (pack_request[grant_index].prior * QUANTUM)) begin
                quantum_counter <= 0; // Reset counter after granting
                filter[grant_index] <= 1'b0; // Temporarily mask the granted request
            end
        end else begin
            filter <= '1; // Reset filter when no grants
        end
    end

endmodule
