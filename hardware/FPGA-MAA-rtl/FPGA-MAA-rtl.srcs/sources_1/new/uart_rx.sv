`timescale 1ns / 1ps

// @todo: comment brief documentation
// @todo: elaborate documentation
// @todo: formal verification

/* -----------------------------------------------------------------
Design: receive submodule of uart_core
Author: Johnathin Fooks
Date:   19 October 2026

Overview:
----------------------------------------------------------------- */

module uart_rx

// ports

(
    input  logic       clock,
    input  logic       reset,
    input  logic       rx_i,
    output logic       rx_valid,
    output logic [7:0] rx_data
);

// declarations and spaces used

typedef enum bit [1:0] {
    IDLE  = 2'b00,
    START = 2'b01,
    DATA  = 2'b10,
    DONE  = 2'b11
} uart_rx_state_t;

uart_rx_state_t state;

logic [2:0] bit_i;
logic [9:0] cycle_count;
logic [7:0] rx_data_buffer;

(* ASYNC_REG = "TRUE" *) logic rx_meta;
(* ASYNC_REG = "TRUE" *) logic rx_sync;

localparam int unsigned CYCLES_PERIOD      = 868;
localparam int unsigned CYCLES_HALF_PERIOD = 434;

// sync external signal to our clock

always_ff @(posedge clock) begin
    if (reset) begin
        rx_meta <= 1'b1;
        rx_sync <= 1'b1;
    end
    else begin
        rx_meta <= rx_i;
        rx_sync <= rx_meta;
    end
end

// state machine
always_ff @(posedge clock) begin

    if (reset) begin
        state          <= IDLE;
        bit_i          <= 0;
        cycle_count    <= 0;
        rx_data_buffer <= 0;
        rx_data        <= 0;
        rx_valid       <= 1'b0;
    end
    
    else begin
        rx_valid <= 1'b0;
        case (state)

            IDLE: begin
                cycle_count <= 0;
                bit_i       <= 0;

                if (rx_sync == 1'b0) begin
                    state <= START;
                end
            end

            START: begin
                if (cycle_count == CYCLES_HALF_PERIOD - 1) begin
                    cycle_count <= 0;

                    if (rx_sync == 1'b0) begin
                        state <= DATA;
                    end
                    else begin
                        state <= IDLE;
                    end
                end
                else begin
                    cycle_count <= cycle_count + 1;
                end
            end

            DATA: begin
                if (cycle_count == CYCLES_PERIOD - 1) begin
                    cycle_count <= 0;

                    rx_data_buffer[bit_i] <= rx_sync;

                    if (bit_i == 7) begin
                        state <= DONE;
                    end
                    else begin
                        bit_i <= bit_i + 1;
                    end
                end
                else begin
                    cycle_count <= cycle_count + 1;
                end
            end

            DONE: begin
                if (cycle_count == CYCLES_PERIOD - 1) begin
                    cycle_count <= 0;
                    state       <= IDLE;
                    if (rx_sync == 1'b1) begin
                        rx_data  <= rx_data_buffer;
                        rx_valid <= 1'b1;
                    end
                end
                else begin
                    cycle_count <= cycle_count + 1;
                end
            end

            default: begin
                state       <= IDLE;
                bit_i       <= 0;
                cycle_count <= 0;
            end

        endcase
    end
end

endmodule : uart_rx