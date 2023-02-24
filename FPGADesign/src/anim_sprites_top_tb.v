`timescale 1 ns/10 ps

module anim_sprites_top_tb;
    reg xtal, buttonX, buttonY;
    //always #(37.04/2) xtal <= ~xtal; //27MHz
    always #(1) xtal <= ~xtal; //27MHz


    anim_sprites_top DUT (
        .crystalCLK(xtal), 
        .btn_X_raw(buttonX), 
        .btn_Y_raw(buttonY)
    );
    initial begin
        
        $dumpfile("sim/waveforms/anim_sprites_top_tb_waves.vcd");
        $dumpvars(0, anim_sprites_top_tb);
        $dumpon;
        
        buttonX = 1;
        buttonY = 1;
        xtal = 0;
        #100
        buttonX = 0;
        #200
        buttonX = 1;
        #250
        buttonX = 0;
        #350
        buttonX = 1;

        #100000;
        $finish;
    end
endmodule