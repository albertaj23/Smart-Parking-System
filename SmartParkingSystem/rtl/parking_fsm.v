// Parking Finite State Machine
// Manages parking states using sequential logic
// Author: Akshat Raj (24BCE0043)

module parking_fsm #(
    parameter MAX_CAPACITY = 10
)(
    input wire clk,
    input wire reset,
    input wire [3:0] current_count,
    output reg parking_full,
    output reg entry_allowed
);

    // State encoding
    localparam [1:0] EMPTY = 2'b00;
    localparam [1:0] AVAILABLE = 2'b01;
    localparam [1:0] FULL = 2'b10;

    // State registers - D flip-flops
    reg [1:0] current_state, next_state;

    // State register - sequential logic
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= EMPTY;
        else
            current_state <= next_state;
    end

    // Next state logic - combinational
    always @(*) begin
        case (current_state)
            EMPTY: begin
                if (current_count > 0)
                    next_state = AVAILABLE;
                else
                    next_state = EMPTY;
            end
            
            AVAILABLE: begin
                if (current_count >= MAX_CAPACITY)
                    next_state = FULL;
                else if (current_count == 0)
                    next_state = EMPTY;
                else
                    next_state = AVAILABLE;
            end
            
            FULL: begin
                if (current_count < MAX_CAPACITY)
                    next_state = AVAILABLE;
                else
                    next_state = FULL;
            end
            
            default: next_state = EMPTY;
        endcase
    end

    // Output logic - combinational
    always @(*) begin
        case (current_state)
            EMPTY: begin
                parking_full = 1'b0;
                entry_allowed = 1'b1;
            end
            
            AVAILABLE: begin
                parking_full = 1'b0;
                entry_allowed = 1'b1;
            end
            
            FULL: begin
                parking_full = 1'b1;
                entry_allowed = 1'b0;
            end
            
            default: begin
                parking_full = 1'b0;
                entry_allowed = 1'b1;
            end
        endcase
    end

endmodule