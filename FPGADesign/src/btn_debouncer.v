module btn_debouncer #(parameter
    CLKIN_FREQ = 27_000_000, // 27MHz
    DEBOUNCE_PERIOD = 1e-3, // 1ms
    IDLE_STATE = 1'b1 //default assumes an active-low button with weak pull-up 
)(
    input clk,
    input reset,// active high
    input noisyIn,
    output reg debounceOut
);
    localparam integer DEBOUNCE_CYCLES = CLKIN_FREQ * DEBOUNCE_PERIOD;
    reg[$clog2(DEBOUNCE_CYCLES) - 1:0] delayCounter;
    reg noisyBuff1;
    reg noisyBuff2;
    reg debouncerReady;

    always@(posedge clk) begin
        if (reset) begin
            delayCounter <= 0;
            debouncerReady <= 1;
            {noisyBuff2, noisyBuff1} <= {IDLE_STATE, IDLE_STATE};
            debounceOut <= IDLE_STATE;
        end else begin
            {noisyBuff2, noisyBuff1} <= {noisyBuff1, noisyIn}; //CDC
            if (debouncerReady) begin
                debounceOut <= noisyBuff2;
                if (noisyBuff2 != IDLE_STATE) begin
                    //debounceOut <= !IDLE_STATE;
                    debouncerReady <= 0;
                end
            end else begin
                delayCounter <= delayCounter + 1;
                if (delayCounter == DEBOUNCE_CYCLES) begin
                    delayCounter <= 0;
                    //debounceOut <= IDLE_STATE;
                    debouncerReady <= 1;
                end
            end
        end
    end

    initial begin
        delayCounter = 0;
        debouncerReady = 1;
        {noisyBuff2, noisyBuff1} <= {IDLE_STATE, IDLE_STATE};
        debounceOut = IDLE_STATE;
    end
endmodule