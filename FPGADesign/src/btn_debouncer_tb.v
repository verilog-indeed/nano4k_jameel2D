`timescale 1 ns/10 ps

module btn_debouncer_tb;
    reg clkin, rst, stimulus;
    wire response;
        
    always #(37.04/2) clkin <= ~clkin; //27MHz
    always #60 stimulus <= $urandom % 2; //randomly assign 0 or 1

    btn_debouncer #(
        .CLKIN_FREQ(27000000),
        .DEBOUNCE_PERIOD(100e-9)
    ) DUT (
        .clk(clkin),
        .reset(rst),
        .noisyIn(stimulus),
        .debounceOut(response)
    );

    initial begin
        $dumpfile("sim/waveforms/btn_debouncer_tb_waves.vcd");
        $dumpvars(0, btn_debouncer_tb);
        $dumpon;

        clkin = 0;
        rst = 1;
        stimulus = 1;
        #100; 
        rst = 0;
        #10000;
        $finish;
    end
endmodule