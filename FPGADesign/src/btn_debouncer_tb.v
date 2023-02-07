`timescale 1 ns/10 ps

module btn_debouncer_tb;
    reg clkin, rst, stimulus, response;
        
    always #(37.04/2) clk <= ~clk; //27MHz
    always #60 stimulus <= $srandom(42) % 2; //randomly assign 0 or 1 with seed of 42

    btn_debouncer #(
        .CLKIN_FREQ(27000000),
        .DEBOUNCE_PERIOD(1e-3)
    ) DUT (
        .clk(clkin),
        .reset(rst),
        .noisyIn(stimulus),
        .debounceOut(response)
    );

    initial begin
        clk = 0;
        rst = 1;
        #100; 
        rst = 0;
        
    end
endmodule