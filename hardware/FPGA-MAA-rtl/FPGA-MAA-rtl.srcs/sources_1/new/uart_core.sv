`timescale 1ns / 1ps

/* -----------------------------------------------------------------
Design: uart_core
Author: Johnathin Fooks
Date:   19 October 2026

Overview:
----------------------------------------------------------------- */

module uart_core

// ports

(
    // integration
    input  logic       clock,
    input  logic       reset,
    // rx
    input  logic       rx_i,
    output logic       rx_valid,
    output logic [7:0] rx_data,
    // tx
    output logic       tx_o,
    input  logic       tx_start,
    output logic       tx_busy,
    input  logic [7:0] tx_data
    
);

uart_rx uart_rx (
    .clock(clock),
    .reset(reset),
    .rx_i(rx_i),
    .rx_valid(rx_valid),
    .rx_data(rx_data)
);

uart_tx uart_tx (
    .clock(clock),
    .reset(reset),
    .tx_o(tx_o),
    .tx_start(tx_start),
    .tx_busy(tx_busy),
    .tx_data(tx_data)
);

endmodule
