`timescale 1 ns/10 ps

module btn_debouncer_tb;
    reg clkin, rst, stimulus;
    wire response, singleCycle;
        
    always #(37.04/2) clkin <= ~clkin; //27MHz
    //always #60 stimulus <= $urandom % 2; //randomly assign 0 or 1

    btn_debouncer #(
        .CLKIN_FREQ(27000000),
        .DEBOUNCE_PERIOD(250e-9),
        .IDLE_STATE(1'b1)
    ) DUT (
        .clk(clkin),
        .reset(rst),
        .noisyIn(stimulus),
        .debounceOut(response),
        .edgeDetectOut(singleCycle)
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
        #100;
        stimulus = 0;
        #60;
        stimulus = 1;
        #60;
        stimulus = 0;
        #60;
        stimulus = 1;
        #60;
        stimulus = 0;
        #300;
        stimulus = 1;
        #1000;
        stimulus = 0;
        #60;
        stimulus = 1;
        #60;
        stimulus = 0;
        #60;
        stimulus = 1;
        #60;
        stimulus = 0;
        #300;
        stimulus = 1;
        #1000;
        $finish;
    end
endmodule