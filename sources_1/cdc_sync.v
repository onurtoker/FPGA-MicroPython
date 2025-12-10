`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 06:52:08 AM
// Design Name: 
// Module Name: cdc_sync
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

module cdc_sync(
    input wire clk,
    input wire i_async,
    output wire o_sync
    );
    
    (* ASYNC_REG = "TRUE" *) reg sync_0, sync_1, sync_2; 
    always @(posedge clk) 
    begin
        sync_2 <= sync_1;
        sync_1 <= sync_0; 
        sync_0 <= i_async;
    end
        
    assign o_sync = sync_2;
    
endmodule

