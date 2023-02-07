module anim_sprites_top (
    input crystalCLK,
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
    wire spr_enable = spr_x_en && spr_y_en;
    reg spr_data_rd;
    wire[2:0] spr_addr_y = verticalPix - spr_y;
    wire[2:0] spr_addr_x = 12'd7 - (horizontalPix - spr_x);

    //Misc
	localparam INDIGO = {8'd75   , 8'd0   , 8'd130   };
    localparam	WHITE	= {8'd255 , 8'd255 , 8'd255 };//{R,G,B}
    localparam	RED		= {8'd255, 8'd0   , 8'd0    };

    always@(posedge crystalCLK) begin: sprite_drawing
        if (spr_enable) begin
            if (bmap[spr_addr_y][spr_addr_x] == 1'b1) begin
                currentPixel <= INDIGO;
            end else begin
                currentPixel <= WHITE;
            end
        end else begin
            currentPixel <= WHITE;
        end
        if (verticalPix == 11'd8) 
            currentPixel <= RED;
    end
    
    always@(posedge crystalCLK) begin: sprite_enable
        //Column check
        if (horizontalPix == (spr_x - 1))
            spr_x_en <= 1;
        if (horizontalPix == (spr_x + 7))
            spr_x_en <= 0;

        //Row check
        if (verticalPix == (spr_y - 1))
            spr_y_en <= 1;
        if (verticalPix == (spr_y + 8)) //lets row 7 finish before disabling
            spr_y_en <= 0;

        //Reset at new scanline/frame
        if (hsync)
            spr_x_en <= 0;
        if (vsync)
            spr_y_en <= 0;
    end

// comment to make icarus stfu
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