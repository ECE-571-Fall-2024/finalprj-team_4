//*******************************************************************
// File name : fcfs_rr_arbiter_tb.sv
// Author : Saishree
// Date Modified : 28/11/2024
// Description:  
//*******************************************************************
module tb_fcfs_arbiter;
    parameter NUM_REQUESTS = 4;

    logic clk, reset_n;
    logic [NUM_REQUESTS-1:0] rqst;
    logic [NUM_REQUESTS-1:0] grant;

    // Instantiate the arbiter
    fcfs_arbiter #(.NUM_REQUESTS(NUM_REQUESTS)) DUT (
        .clk(clk),
        .reset_n(reset_n),
        .req(req),
        .grant(grant)
    );

	always begin: clock_generator
		#5 clk = ~clk;
	end: clock_generator
    
    initial begin
        // Initialize signals
        clk = 0;
        reset_n = 0;
        rqst = '0;

        // Reset the system
        #10 reset_n = 1;

        // Apply requests
    end
endmodule
