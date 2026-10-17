`timescale 1ns / 1ps

module uart_tx (
    input  logic       clk,
    input  logic       reset,
    output logic       tx_o,
    input  logic       tx_start,
    output logic       tx_busy,
    input  logic [7:0] tx_data
);

typedef enum bit [1:0] {
    IDLE  = 2'b00,
    START = 2'b01,
    DATA  = 2'b10,
    DONE  = 2'b11
} uart_tx_state_t;

// local spaces and constants we will use

uart_tx_state_t state;
logic [2:0] bit_i;          // 0-7 bit index
logic [9:0] baud_counter;   // 0-1023 baud counter for 868 cycle period
logic [7:0] tx_data_buffer; // buffer for saved data
localparam int unsigned CYCLES_PERIOD = 868;

// combinational stuff based on current state

always_comb begin
    tx_o    = 1'b1;
    tx_busy = (state != IDLE);

    case (state)
        START:   tx_o = 1'b0;
        DATA:    tx_o = tx_data_buffer[bit_i];
        default: tx_o = 1'b1; // Idle and stop bit.
    endcase
end

// state machine

always_ff @(posedge clk) begin

    if (reset) begin
        state          <= IDLE;
        bit_i          <= 0;
        baud_counter   <= 0;
        tx_data_buffer <= 0;
    end
    
    else begin
        case (state)
            
            IDLE: begin
                baud_counter <= 0;
                bit_i <= 0;
                if (tx_start) begin
                    tx_data_buffer <= tx_data;
                    state <= START;
                end
            end
            
            START: begin
                if (baud_counter == CYCLES_PERIOD - 1) begin
                    baud_counter <= 0;
                    state <= DATA;
                end
                else begin
                    baud_counter <= baud_counter + 1;
                end
            end
            
            DATA: begin
                if (baud_counter == CYCLES_PERIOD - 1) begin
                    baud_counter <= 0;
                    if (bit_i == 7) begin
                        state <= DONE;
                    end
                    else begin
                        bit_i <= bit_i + 1;
                    end
                end
                else begin
                    baud_counter <= baud_counter + 1;
                end
            end
            
            DONE: begin
                if (baud_counter == CYCLES_PERIOD - 1) begin
                    baud_counter <= 0;
                    state <= IDLE;
                end
                else begin
                    baud_counter <= baud_counter + 1;
                end
            end
            
            default: begin
                state        <= IDLE;
                bit_i        <= 0;
                baud_counter <= 0;
            end
            
        endcase
    end
end

endmodule
