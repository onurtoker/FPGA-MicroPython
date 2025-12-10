`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     FPU
// Engineer:    Onur Toker
// 
// Create Date: 11/26/2025 08:21:31 PM
// Design Name: 
// Module Name: top_design
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

module topdesign_ez(
    input   CLK100MHZ,
    input   [3:0] btn,      // buttons
    output  uart_rxd_out, 
    output  jd0,        
    input   uart_txd_in,
    input   jd1,
    output  [3:0] led,
    input   [3:0] sw
);

    `include "constants.vh"

    assign clk          = CLK100MHZ;
	assign resetn_a     = ~btn[0];
	assign uart_rxd_out = uart_out;
	assign jd0          = uart_out;
	assign uart_in      = sw[0] ? jd1 : uart_txd_in;
	
	wire trap;

	wire mem_valid;
	wire mem_instr;
	reg mem_ready;
	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire [ 3:0] mem_wstrb;
	reg  [31:0] mem_rdata;
	
    cdc_sync Ucdc1(
        .clk(clk),
        .i_async(resetn_a),
        .o_sync(resetn)
    ); 

    cdc_sync Ucdc2(
        .clk(clk),
        .i_async(uart_in),
        .o_sync(uart_in_sync)
    ); 

	picorv32 #(
	) Uprv32i (
		.clk         (clk        ),
		.resetn      (resetn     ),
		.trap        (trap       ),
		.mem_valid   (mem_valid  ),
		.mem_instr   (mem_instr  ),
		.mem_ready   (mem_ready  ),
		.mem_addr    (mem_addr   ),
		.mem_wdata   (mem_wdata  ),
		.mem_wstrb   (mem_wstrb  ),
		.mem_rdata   (mem_rdata  )
	);

    // Address decoding logic 
`ifdef ARCH_120K
    assign RAM_CS   = (mem_addr >= 32'h 0000_0000) & (mem_addr <= 32'h 0001_DFFF);	// 120K RAM
    assign UART_CS  = (mem_addr >= 32'h 0001_E000) & (mem_addr <= 32'h 0001_E00F);
    assign GPIO_CS  = (mem_addr >= 32'h 0001_F000) & (mem_addr <= 32'h 0001_F003);
`elsif ARCH_300K
    assign RAM_CS   = (mem_addr >= 32'h 0000_0000) & (mem_addr <= 32'h 004A_FFFF);	// 300K RAM
    assign UART_CS  = (mem_addr >= 32'h 1000_0000) & (mem_addr <= 32'h 1000_000F);	// UART TX and RX regs
    assign GPIO_CS  = (mem_addr >= 32'h 2000_0000) & (mem_addr <= 32'h 2000_000F);	// GPIO
`endif
    
    always @* begin
        {mem_ready, mem_rdata} = 0;
        case ({RAM_CS, UART_CS, GPIO_CS}) 
            'b100: {mem_ready, mem_rdata} = {mem_ready_ram , mem_rdata_ram };
            'b010: {mem_ready, mem_rdata} = {mem_ready_uart, mem_rdata_uart};
            'b001: {mem_ready, mem_rdata} = {mem_ready_gpio, mem_rdata_gpio};
            default: ;    // no chip selected
        endcase
    end
    
    wire [31:0] mem_rdata_ram, mem_rdata_uart, mem_rdata_gpio;
    
    ram32b Uram(
        .clk        (clk),
        .mem_valid  (mem_valid),
        .mem_ready  (mem_ready_ram),
        .mem_addr   (mem_addr),
        .mem_wdata  (mem_wdata),
        .mem_wstrb  (mem_wstrb),
        .mem_rdata  (mem_rdata_ram),
        .CS         (RAM_CS)
    );

    uart32b Uuart(
        .clk        (clk),
        .mem_valid  (mem_valid),
        .mem_ready  (mem_ready_uart),
        .mem_addr   (mem_addr),
        .mem_wdata  (mem_wdata),
        .mem_wstrb  (mem_wstrb),
        .mem_rdata  (mem_rdata_uart),
        .CS         (UART_CS),
        .resetn     (resetn),
        .rx         (uart_in_sync),
        .tx         (uart_out)
    );
    
    wire [31:0] gpio_o;
    gpio32b Ugpio(
        .clk        (clk),
        .mem_valid  (mem_valid),
        .mem_ready  (mem_ready_gpio),
        .mem_addr   (mem_addr),
        .mem_wdata  (mem_wdata),
        .mem_wstrb  (mem_wstrb),
        .mem_rdata  (mem_rdata_gpio),
        .CS         (GPIO_CS),
        .resetn     (resetn),
        .gpio_o     (gpio_o)
    );
         
    assign led = gpio_o;
       
endmodule
