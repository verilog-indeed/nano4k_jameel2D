module anim_sprites_top (
    input crystalCLK, btn_X_raw, btn_Y_raw,
    output [2:0] tmdsChannel_p,
    output tmdsClockChannel_p,
    output [2:0] tmdsChannel_n,
    output tmdsClockChannel_n
);
    //HDMI interface signals
    reg[23:0] currentPixel; //{R8, G8, B8}
    wire signed [11:0] horizontalPix;
    wire signed [10:0] verticalPix;
    wire vsync, hsync;
    wire displayEnable;
    wire multiplierClkOut;

    //Sprite signals
    reg[7:0] bmap [7:0]; //8x8 monochrome sprite
    reg signed [11:0] spr_x; //top-left corner coordinates
    reg signed [10:0] spr_y;
    reg spr_x_en, spr_y_en;
    reg spr_data_rd;
    wire[2:0] spr_addr_y = verticalPix - spr_y;
    wire[2:0] spr_addr_x = 12'd7 - (horizontalPix - spr_x);

    //Misc
	localparam INDIGO = {8'd75   , 8'd0   , 8'd130   };
    localparam	WHITE	= {8'd255 , 8'd255 , 8'd255 };//{R,G,B}
    localparam	RED		= {8'd255, 8'd0   , 8'd0    };

    //Button signals
    wire btnX, btnY;

    always@(posedge crystalCLK) begin: sprite_drawing
        currentPixel <= WHITE;
        if (spr_enable)
            if (bmap[spr_addr_y][spr_addr_x] == 1'b1)
                currentPixel <= INDIGO;
    end
    
    
    //! Sprite enable generator.
    //! Sprites are activated one clock cycle before they're shown on screen
    //! to load them on the following cycle.  
    always@(posedge crystalCLK) begin: sprite_enable
        //Column check
        if (horizontalPix == (spr_x - 2))
        //activates on following clock cycle when hpix == spr_x - 1
            spr_x_en <= 1; 
        if (horizontalPix == (spr_x + 6))
            spr_x_en <= 0;

        //Row check
        if (verticalPix == spr_y)
        //will trigger during front porch, no need to activate in the row before
            spr_y_en <= 1;
        if (verticalPix == (spr_y + 8)) //lets row 7 finish before disabling
            spr_y_en <= 0;

        //Reset at new scanline/frame
        if (hsync)
            spr_x_en <= 0; //hsync reset might be unnecessary
        if (vsync)
            spr_y_en <= 0;
    end
    //! Sprite enable output
    wire spr_enable = spr_x_en && spr_y_en;

    always@(posedge crystalCLK) begin: input_ctl
        if (!btnX)
            spr_x <= spr_x + 1;
        if (!btnY)
            spr_y <= spr_y + 1;
    end


// comment instantiations to make icarus stfu
    Gowin_PLLVR clock_5x(
        .clkout(multiplierClkOut), //output clkout
        .clkin(crystalCLK) //input clkin
    );

    hdmi_tx video_transmitter(
        .pixelClock(crystalCLK),
        .serialClock(multiplierClkOut),
        .redByte(currentPixel[23:16]),
        .greenByte(currentPixel[15:8]),
        .blueByte(currentPixel[7:0]),
        .inActiveDisplay(displayEnable),
        .hPosCounter(horizontalPix),
        .vPosCounter(verticalPix),
        .tmds_clk_p(tmdsClockChannel_p),
        .tmds_clk_n(tmdsClockChannel_n),
        .tmds_data_p(tmdsChannel_p),
        .tmds_data_n(tmdsChannel_n),
        .hSync(hsync),
        .vSync(vsync)
    );

    btn_debouncer#(
        .CLKIN_FREQ(27000000),
        .DEBOUNCE_PERIOD(1e-3),
        .IDLE_STATE(1'b1)
    ) debounceX (
        .clk(crystalCLK),
        .noisyIn(btn_X_raw),
        //.debounceOut(btnX),
        .edgeDetectOut(btnX),
        .reset(1'b0)
    );

    btn_debouncer#(
        .CLKIN_FREQ(27000000),
        .DEBOUNCE_PERIOD(1e-3),
        .IDLE_STATE(1'b1)
    ) debounceY (
        .clk(crystalCLK),
        .noisyIn(btn_Y_raw),
        //.debounceOut(btnY),
        .edgeDetectOut(btnY),
        .reset(1'b0)
    );

    initial begin
        bmap[0]  = 8'b1111_1100;
        bmap[1]  = 8'b1000_0000;
        bmap[2]  = 8'b1000_0000;
        bmap[3]  = 8'b1111_1000;
        bmap[4]  = 8'b1000_0000;
        bmap[5]  = 8'b1000_0000;
        bmap[6]  = 8'b1000_0011;
        bmap[7]  = 8'b0000_0011;

        spr_x = 0;
        spr_y = 0;
    end
    
endmodule