`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 11:00:38 AM
// Design Name: 
// Module Name: uart32b
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

module uart32b(
	input              clk, 
	input              mem_valid,
	//input mem_instr,
	output reg         mem_ready,
	input [31:0]       mem_addr,
	input [31:0]       mem_wdata,
	input [ 3:0]       mem_wstrb,
	output reg[31:0]   mem_rdata,
	input              CS,
	input              resetn,
	output             tx,
	input              rx
);
    
	always @(posedge clk) begin
        mem_ready <= 0;
        if (mem_valid && !mem_ready && CS) begin
        
            // TX REG (Read returns tx_full status, write sends to UART)
            if (mem_addr[3:0] == 4'h0) begin
                mem_ready <= 1;     
                mem_rdata <= tx_full;    // Read returns tx_full 
                if (mem_wstrb) begin
                    $write("%c", mem_wdata[7:0]);
                    $fflush();        
                end
            end
            // RX REG (Read returns 0xffffffff if rx_empty, otherwise 8-bit rx_data)
            else if ((mem_addr[3:0] == 4'h4) && !(&mem_wstrb)) begin
                mem_ready <= 1;    
                if (rx_empty) 
                    mem_rdata <= 32'h ffffffff;
                else
                    mem_rdata <= rx_data;           
            end            
            // Otherwise 
            else begin
                mem_ready <= 1;    
                mem_rdata <= 0;
            end                
        end
                
    end

    assign tx_en = mem_valid && !mem_ready && CS && (&mem_wstrb)  && (mem_addr[3:0] == 4'h0); 
    assign rx_en = mem_valid && !mem_ready && CS && !(&mem_wstrb) && (mem_addr[3:0] == 4'h4) && (~rx_empty);
       
    wire [7:0] rx_data;
    uart uart_unit(
        .clk(clk),              .reset(~resetn),    
        .rd_uart(rx_en),        .rx(rx),                    .r_data(rx_data),
        .wr_uart(tx_en),        .w_data(mem_wdata[7:0]),    .tx(tx),
        .tx_full(tx_full),      .rx_empty(rx_empty)
    );
                
endmodule


