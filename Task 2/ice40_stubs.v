`default_nettype none

// Stub for the iCE40 High Frequency Oscillator
module SB_HFOSC #(
    parameter CLKHF_DIV = "0b00"
)(
    input  wire CLKHFPU,
    input  wire CLKHFEN,
    output reg  CLKHF
);
    initial CLKHF = 0;
    // Generate a dummy clock (toggles to create a wave)
    // ~12 MHz clock -> period is ~83ns, so toggle every 41ns
    always #41 CLKHF = (CLKHFPU & CLKHFEN) ? ~CLKHF : 1'b0;
endmodule

// Stub for the iCE40 PLL Core
module SB_PLL40_CORE #(
    parameter FEEDBACK_PATH = "SIMPLE",
    parameter DIVR = 4'b0,
    parameter DIVF = 7'b0,
    parameter DIVQ = 3'b0,
    parameter FILTER_RANGE = 3'b0,
    parameter PLLOUT_SELECT = "GENCLK"
)(
    input  wire REFERENCECLK,
    input  wire RESETB,
    input  wire BYPASS,
    output wire PLLOUTCORE,
    output wire PLLOUTGLOBAL,
    output reg  LOCK
);
    // For simulation, just pass the reference clock straight through
    assign PLLOUTCORE = REFERENCECLK;
    assign PLLOUTGLOBAL = REFERENCECLK;
   
    // Tell the system the PLL is instantly stable ("locked")
    initial LOCK = 0;
    always @(posedge REFERENCECLK) LOCK <= 1'b1;
endmodule
