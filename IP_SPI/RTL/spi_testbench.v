`default_nettype none
 
`include "riscv.v"
 
module bench();
 
    // ── Reset ────────────────────────────────────────────────────────
    // Active HIGH. Held high for 500ns then released.
    // Clock is generated internally by SB_HFOSC (via ice40_stubs.v).
    reg RESET = 1;
 
    // ── SOC Output Wires ─────────────────────────────────────────────
    wire [4:0]  LEDS;
    wire        TXD;
    wire [31:0] GPIO_OUT;
    wire [31:0] GPIO_OE;
 
    // ── SPI Wires ─────────────────────────────────────────────────────
    wire SPI_SCLK;
    wire SPI_MOSI;
    wire SPI_CS_N;
 
    // ── MISO Loopback (spec requirement) ──────────
    // Whatever master sends on MOSI is immediately received on MISO.
    // This simulates a slave echoing back the same byte.
    wire SPI_MISO = SPI_MOSI;
 
    // ── SOC Instantiation ─────────────────────────────────────────────
    SOC dut (
        .RESET    (RESET),
        .LEDS     (LEDS),
        .RXD      (1'b1),       // UART RX idle
        .TXD      (TXD),
        .GPIO_OUT (GPIO_OUT),
        .GPIO_OE  (GPIO_OE),
        .GPIO_IN  (32'b0),
        .SPI_SCLK (SPI_SCLK),
        .SPI_MOSI (SPI_MOSI),
        .SPI_MISO (SPI_MISO),   // loopback connected here
        .SPI_CS_N (SPI_CS_N)
    );
 
    // ── Waveform Dump ─────────────────────────────────────────────────
    initial begin
        $dumpfile("sim4.vcd");
        $dumpvars(0, bench);
        RESET = 1;
        #500;
        RESET = 0;
    end
endmodule
