`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 11:00:38 AM
// Design Name: 
// Module Name: ram32b
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

module ram32b(
	input              clk, 
	input              mem_valid,
	input              mem_instr,
	output reg         mem_ready,
	input [31:0]       mem_addr,
	input [31:0]       mem_wdata,
	input [ 3:0]       mem_wstrb,
	output reg[31:0]   mem_rdata,
	input              CS
);
    
    `include "constants.vh"    

    integer i;

    // RAM 
    (* keep = "true" *) reg[31:0] memory [0:RAM_32B_SIZE-1];  

/*
	initial begin
		memory[0] = 32'h 03500293; //         li    t0, 0x35				
		memory[1] = 32'h 0001e337; //         lui   t1, 0x01e       # upper 20 bits => 0x01E << 12 = 0x0001E000       
		memory[2] = 32'h 00532023; //         sw    t0, 0(t1)       # store t0 to that address
		memory[3] = 32'h 00000073; //         ecall
	end
*/

	initial begin
	    //for (i = 0; i < RAM_32B_SIZE; i = i + 1)
        //    memory[i] = 32'h0000_0000;
	    //$readmemh("C:\\Users\\onur\\Desktop\\test_newlib_malloc.hex", memory);
	    //$readmemh("C:\\Users\\onur\\Desktop\\test_newlib_mandelbrot.hex", memory);
	    //$readmemh("C:\\Users\\onur\\Desktop\\uP_ArtyA7.hex", memory);
	    $readmemh(`FIRMWARE_HEXFILE, memory);
	end

	always @(posedge clk) begin
		mem_ready <= 0;
		if (mem_valid && !mem_ready && CS) begin
            mem_ready <= 1;
            mem_rdata <= memory[mem_addr >> 2];
            if (mem_wstrb[0]) memory[mem_addr >> 2][ 7: 0] <= mem_wdata[ 7: 0];
            if (mem_wstrb[1]) memory[mem_addr >> 2][15: 8] <= mem_wdata[15: 8];
            if (mem_wstrb[2]) memory[mem_addr >> 2][23:16] <= mem_wdata[23:16];
            if (mem_wstrb[3]) memory[mem_addr >> 2][31:24] <= mem_wdata[31:24];
        end
	end
	    
endmodule


