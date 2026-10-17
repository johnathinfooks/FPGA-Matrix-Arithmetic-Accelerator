`timescale 1ns / 1ps

module top (
    input logic clk,
    input logic reset,
    output logic uart_tx_o
);



uart_tx tx (
    .clk(clk),
    .reset(reset),
    .tx_o(uart_tx_o),
    .tx_start(1'b1),
    .tx_busy(),
    .tx_data(8'b00110101) // h35; ascii char '5'
);

endmodule
