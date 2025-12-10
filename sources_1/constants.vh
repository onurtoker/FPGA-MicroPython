// Parameters

//============================================================================================
// ARCHITECTURE SELECTION (Select one)
//============================================================================================

//`define ARCH_120K
`define ARCH_300K


//============================================================================================
// FIRMWARE SELECTION (Select one)
//============================================================================================

// 120KB firwares
//`define FIRMWARE "C:\\Users\\onur\\Desktop\\test_newlib_malloc.hex"
//`define FIRMWARE "C:\\Users\\onur\\Desktop\\test_newlib_mandelbrot.hex"

// 300 KB firmwares
`define FIRMWARE_HEXFILE "C:\\Users\\onur\\Desktop\\uPfw.hex"

//============================================================================================
// Generate VCD file
//============================================================================================
`define VCD_GENERATE

//============================================================================================
// DO NOT EDIT BELOW THIS LINE
//============================================================================================

`ifdef ARCH_120K
parameter RAM_SIZE_KB  = 120;
`elsif ARCH_300K
parameter RAM_SIZE_KB  = 300;
`endif

parameter RAM_32B_SIZE = RAM_SIZE_KB * 1024 / 4;
