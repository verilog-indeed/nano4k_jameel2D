module btn_debouncer #(parameter
    CLKIN_FREQ = 27_000_000, // 27MHz
    DEBOUNCE_PERIOD = 1e-3 // 1ms
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
            debouncerReady <= 0;
            {noisyBuff2, noisyBuff1} <= 2'b00;
            debounceOut <= 1;
        end else begin
            if (debouncerReady) begin
                {noisyBuff2, noisyBuff1} <= {noisyBuff1, noisyIn}; //CDC
                if (debounceOut ^ noisyBuff2) begin //edge detection
                    debounceOut <= noisyBuff2;
                    debouncerReady <= 0;
                end
            end else begin
                delayCounter <= delayCounter + 1;
                if (delayCounter == DEBOUNCE_CYCLES) begin
                    delayCounter <= 0;
                    debouncerReady <= 1;
                end
            end
        end
    end

    initial begin
        delayCounter = 0;
        debouncerReady = 0;
        {noisyBuff2, noisyBuff1} = 2'b00;
        debounceOut = 1;
    end
endmodule