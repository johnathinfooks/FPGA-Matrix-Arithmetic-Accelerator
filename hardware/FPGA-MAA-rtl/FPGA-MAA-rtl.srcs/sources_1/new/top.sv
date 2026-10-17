`timescale 1ns / 1ps

module top (
    input logic clk,
    input logic reset
);

// UART serial communication with host
uart_core uart_core (
    .clk(clk),
    .reset(reset)
);

initial begin   
    
end


endmodule
