`timescale 1ns / 1ps

// temporary AI testbench ; i dont wanna write all that rn
// @todo: do a test by 10,000 cases

module tb_uart_tx;

logic       clk = 0;
logic       reset;
logic       tx_o;
logic       tx_start;
logic       tx_busy;
logic [7:0] tx_data;

localparam integer BIT_TIME_NS = 8680;
localparam logic [7:0] TEST_BYTE = 8'hA5;

uart_tx dut (
    .clk      (clk),
    .reset    (reset),
    .tx_o     (tx_o),
    .tx_start (tx_start),
    .tx_busy  (tx_busy),
    .tx_data  (tx_data)
);

// 100 MHz clock: 10 ns period.
always #5 clk = ~clk;

initial begin
    reset    = 1;
    tx_start = 0;
    tx_data  = 0;

    // Keep reset asserted across several rising clock edges.
    repeat (3) @(negedge clk);
    reset = 0;

    @(negedge clk);

    if (tx_o !== 1'b1 || tx_busy !== 1'b0)
        $fatal(1, "Incorrect idle outputs");

    // Apply inputs on falling edges so they are stable
    // when the DUT samples them on a rising edge.
    tx_data  = TEST_BYTE;
    tx_start = 1;

    @(negedge clk);
    tx_start = 0;

    // Transmission has started. Move near the start-bit center.
    #(BIT_TIME_NS / 2);

    if (tx_o !== 1'b0 || tx_busy !== 1'b1)
        $fatal(1, "Incorrect start bit or busy signal");

    // Changing the input must not change the captured byte.
    tx_data = 8'h00;

    // Check each data bit at its center, bit 0 first.
    for (int i = 0; i < 8; i++) begin
        #(BIT_TIME_NS);

        if (tx_o !== TEST_BYTE[i])
            $fatal(1, "Bit %0d: expected %b, got %b",
                   i, TEST_BYTE[i], tx_o);

        if (tx_busy !== 1'b1)
            $fatal(1, "Busy dropped during data transmission");
    end

    // Check the stop bit.
    #(BIT_TIME_NS);

    if (tx_o !== 1'b1 || tx_busy !== 1'b1)
        $fatal(1, "Incorrect stop bit or busy signal");

    // Wait until the complete stop bit has finished.
    @(negedge tx_busy);
    @(negedge clk);

    if (tx_o !== 1'b1)
        $fatal(1, "Output did not return to idle");

    $display("PASS: UART transmission completed correctly");
    $finish;
end

// Prevent a broken transmitter from leaving the simulation waiting forever.
initial begin
    #200_000;
    $fatal(1, "Simulation timed out");
end

endmodule