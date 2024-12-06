/////////////////////////////////////////////////////////
//  File name : tb_fcfs_rrarbiter.sv
//  Version   : 0.4
//  Description :  Implementation of testbench for FCFS 
//                 parameterized round robin arbiter
/////////////////////////////////////////////////////////
module tb_FCFS_Weighted_RR_Arbiter;

    // Parameters
    parameter Requestors = 4;
    parameter QUANTUM = 10;

    // Instance of the Interface
    arbiter #(Requestors) orbit();

    // Define priority_t enum correctly
    typedef enum logic [2:0] {
        LO = 3'b001,  // Low priority
        MED = 3'b010, // Medium priority
        HI = 3'b100  // High priority
    } priority_t;

    // Structure for Packet Information
    typedef struct {
        logic [7:0] requestor_id; 
        logic [7:0] data;         
        priority_t prior;         
        logic [31:0] time_present;   
    } packet_t;

    // Packet Array
    packet_t packets[Requestors];

    // Instantiate the DUT 
    FCFS_Weighted_RR_Arbiter #(
        .Requestors(Requestors),
        .QUANTUM(QUANTUM)
    ) DUT (
        .arbit(orbit)
    );

    // Clock Generation
    always #5 orbit.clk = ~orbit.clk; 

    // Task to Initialize Packets
    task initialize_packets();
        for (int i = 0; i < Requestors; i++) begin  // Looping from 0 to Requestors-1
            packets[i].requestor_id = i;
            packets[i].data = 8'd0;      
            packets[i].prior = LO;      
            packets[i].time_present = 32'd0; 
        end
    endtask

    // Task to Randomize Requests and Priorities
    task randomize_requests();
        for (int i = 0; i < Requestors; i++) begin  // Looping from 0 to Requestors-1
            if ($urandom_range(0, 1)) begin
                packets[i].time_present = $time; // Record current time as timestamp
                packets[i].prior = priority_t'($urandom_range(0, 2)); // Assign random priority
                orbit.req[i] = 1; // Set request signal
            end else begin
                orbit.req[i] = 0; // Clear request signal
            end
        end
    endtask

    // Task to Assign Weights Based on Priorities
    task assign_weights();
        for (int i = 0; i < Requestors; i++) begin  // Looping from 0 to Requestors-1
            case (packets[i].prior)
                LO: orbit.weights[i] = 8'd1;
                MED: orbit.weights[i] = 8'd2;
                HI: orbit.weights[i] = 8'd3;
            endcase
        end
    endtask

    // Initial Block to Drive Stimulus
    initial begin
        // Setup initial conditions
        orbit.clk = 0;
        orbit.reset = 0;
        orbit.req = 4'b0000;
        initialize_packets();

        #20 orbit.reset = 1; // Reset signal deasserted after 20 ns

        // Apply random stimuli over time
        repeat (10) begin
            #20 randomize_requests(); 
            assign_weights();  // Assign weights after requests are randomized
        end

        #100 $finish; // End the simulation after 100 ns
    end

    // Monitor Outputs for Debugging
    initial begin
      $monitor("Time: %0t | req[3:0]: %b | grant[3:0]: %b | Priorities[3:0]: %0d %0d %0d %0d | Time[3:0]: %0d %0d %0d %0d",
                 $time, orbit.req, orbit.grant,
                 packets[3].prior, packets[2].prior, packets[1].prior, packets[0].prior,
                 packets[3].time_present, packets[2].time_present, packets[1].time_present, packets[0].time_present);
    end

    // Assertions for Validity

    // Ensure only one grant is active at any given time
    always_ff @(posedge orbit.clk) begin
        assert($countones(orbit.grant) <= 1) 
            else $error("Assertion Failed: More than one grant active simultaneously at time %0t", $time);

        // Ensure that if a grant is active, it corresponds to a valid request
        if (orbit.grant != 0) begin
            assert(|(orbit.grant & orbit.req)) 
                else $error("Assertion Failed: Grant given to a non-requesting source at time %0t", $time);
        end
    end

endmodule
