`timescale 1ns / 1ps

// @todo: write formal verification
// @todo: write elaborate documentation

/* -----------------------------------------------------------------
Design: transmit submodule of uart_core
Author: Johnathin Fooks
Date:   19 October 2026

Overview: A finite state machine that has states for the
UART serial communication protocol. Transmitting on the UART
protocol is given a data byte, from idle do start bit, do 8 
bits of data, do end bit, back to idle.
- IDLE
- - Serial output = 1
- - If start transmit signal: got to START
- START
- - Serial output = 0
- - If single bit period has passed: go to DATA
- DATA
- - Serial output = data[bit_incrementation_counter]
- - If we are on the last bit: go to DONE
- - else: If single bit period has passed increment bit counter
- DONE
- - Serial output = dont change since last bit
- - If single bit period has passed: go to IDLE
----------------------------------------------------------------- */

module uart_tx

// ports

(
    input  logic       clock,
    input  logic       reset,
    output logic       tx_o,
    input  logic       tx_start, // initiates start of transmit
    output logic       tx_busy,
    input  logic [7:0] tx_data
);

// declarations and spaces used

typedef enum bit [1:0] {
    IDLE  = 2'b00,
    START = 2'b01,
    DATA  = 2'b10,
    DONE  = 2'b11
} uart_tx_state_t;

uart_tx_state_t state;
logic [2:0] bit_i;
logic [9:0] cycle_count;
logic [7:0] tx_data_buffer;
localparam int unsigned CYCLES_PERIOD = 868;

// combinational logic for mapping current state to output

always_comb begin
    tx_o    = 1'b1;             // idle
    tx_busy = (state != IDLE);

    case (state)
        START:   tx_o = 1'b0;   // start signal
        DATA:    tx_o = tx_data_buffer[bit_i]; // transmitting data
        default: tx_o = 1'b1;   // idle
    endcase
end

// state machine

always_ff @(posedge clock) begin

    if (reset) begin
        state          <= IDLE;
        bit_i          <= 0;
        cycle_count    <= 0;
        tx_data_buffer <= 0;
    end
    
    else begin
        case (state)
            
            IDLE: begin
                cycle_count <= 0;
                bit_i <= 0;
                if (tx_start) begin
                    tx_data_buffer <= tx_data;
                    state <= START;
                end
            end
            
            START: begin
                if (cycle_count == CYCLES_PERIOD - 1) begin
                    cycle_count <= 0;
                    state <= DATA;
                end
                else begin
                    cycle_count <= cycle_count + 1;
                end
            end
            
            DATA: begin
                if (cycle_count == CYCLES_PERIOD - 1) begin
                    cycle_count <= 0;
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
                    state <= IDLE;
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

endmodule : uart_tx
