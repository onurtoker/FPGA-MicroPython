// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

`timescale 1 ns / 1 ps

module testbench_ez;

    `include "constants.vh"

	reg clk = 1;
	reg resetn = 0;
	wire trap;

	// clock generation
	always #5 clk = ~clk;
	
	// init sequence
	initial begin
		$timeformat(-6, 3, " us", 16);
		
		repeat (10) @(posedge clk);
        $display("\nReset/Start   at time %0t", $time); 
        $display("----------------------------------");
		resetn <= 1;
		        
		repeat (100_000_000) @(posedge clk);
		$display("\nTime out      at time %0t", $time); 
        $display("----------------------------------");
		$finish;
	end

`ifdef VCD_GENERATE	
	initial begin
		$dumpfile("testbench.vcd");
		$dumpvars();
	end
`endif
	
	// Handle ECALL and finish the simulation
	always @(posedge clk) begin
		if (mem_valid && mem_ready && mem_instr && (mem_rdata == 32'h 0000_0073)) begin
		  	repeat (10) @(posedge clk);
			$display("\nECALL received at time %0t", $time);
			$display("-----------------------------------");
		  	$finish;
		end
	end

	wire mem_valid;
	wire mem_instr;
	reg mem_ready;
	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire [ 3:0] mem_wstrb;
	reg  [31:0] mem_rdata;

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
            3'b100: 	{mem_ready, mem_rdata} = {mem_ready_ram , mem_rdata_ram };
            3'b010: 	{mem_ready, mem_rdata} = {mem_ready_uart, mem_rdata_uart};
            3'b001: 	{mem_ready, mem_rdata} = {mem_ready_gpio, mem_rdata_gpio};
            default:begin
            			//$display("Illegal memory address %8x %1x %1x %1x", mem_addr, RAM_CS, UART_CS, GPIO_CS);
            		end
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
        .rx         (uart_in),
        .tx         (uart_out)
    );

    assign uart_in = 1;    // RX always idle

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

endmodule



