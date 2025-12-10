`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 11:00:38 AM
// Design Name: 
// Module Name: gpio32b
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module gpio32b(
	input              clk, 
	input              mem_valid,
	//input mem_instr,
	output reg         mem_ready,
	input [31:0]       mem_addr,
	input [31:0]       mem_wdata,
	input [ 3:0]       mem_wstrb,
	output reg[31:0]   mem_rdata,
	input              CS,
	input wire         resetn,
	output wire[31:0]  gpio_o
);
    
    // RAM
	reg[31:0] gpio_reg = 0;  

    assign gpio_o = gpio_reg;

	always @(posedge clk) 
	    if (!resetn)
	       gpio_reg <= 0;
	    else begin
            mem_ready <= 0;            
            if (mem_valid && !mem_ready && CS) begin
                mem_ready <= 1;
                mem_rdata <= gpio_reg;
                if (mem_wstrb[0]) gpio_reg[ 7: 0] <= mem_wdata[ 7: 0];
                if (mem_wstrb[1]) gpio_reg[15: 8] <= mem_wdata[15: 8];
                if (mem_wstrb[2]) gpio_reg[23:16] <= mem_wdata[23:16];
                if (mem_wstrb[3]) gpio_reg[31:24] <= mem_wdata[31:24];
                
                // Debug 
                if (mem_wstrb) begin
                    $write("GPIO write %08x\n", mem_wdata);
                    $fflush();
                end

            end
        end

endmodule


