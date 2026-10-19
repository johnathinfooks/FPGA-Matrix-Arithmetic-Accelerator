`timescale 1ns / 1ps

/* -----------------------------------------------------------------
Design: Top interface with Matrix Arithmetic Accelerator
Author: Johnathin Fooks
Date:

Overview:
----------------------------------------------------------------- */

module top

// ports

(
    input logic clock,
    input logic reset,
    // UART signals
    input logic uart_rx_i,
    output logic uart_tx_o
);

// UART

logic uart_rx_valid;
logic [7:0] uart_rx_data;
logic uart_tx_start;
logic uart_tx_busy;
logic [7:0] uart_tx_data;

logic [7:0] current_number;

uart_core uart_core(
    .clock(clock),
    .reset(reset),
    .rx_i(uart_rx_i),
    .rx_valid(uart_rx_valid),
    .rx_data(uart_rx_data),
    .tx_o(uart_tx_o),
    .tx_start(uart_tx_start),
    .tx_busy(uart_tx_busy),
    .tx_data(uart_tx_data)
);

always_ff @(posedge clock) begin
    if (reset) begin
        current_number <= 8'b00000000;
        uart_tx_data   <= 8'b00000000;
        uart_tx_start  <= 1'b0;
    end else begin
        if (uart_rx_valid) begin
            current_number <= uart_rx_data;
        end

        // Default low so each transmit request is a one-cycle pulse.
        uart_tx_start <= 1'b0;

        if (!uart_tx_busy && !uart_tx_start) begin
            uart_tx_data  <= current_number;
            uart_tx_start <= 1'b1;
        end
    end
end

endmodule
