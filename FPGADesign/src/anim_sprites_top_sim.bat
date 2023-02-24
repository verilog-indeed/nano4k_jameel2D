del "sim\anim_sprites_top_tb.out"
del "sim\waveforms\anim_sprites_top_tb_waves.vcd"

iverilog -o "sim\anim_sprites_top_tb.out" -g2012 anim_sprites_top_tb.v anim_sprites_top.v hdmi_tx.v btn_debouncer.v gowin_pllvr\gowin_pllvr.v prim_sim.v synchronous_encoder_serializer.v num_of_ones.v
vvp "sim\anim_sprites_top_tb.out"
rem gtkwave "sim\waveforms\anim_sprites_top_tb_waves.vcd"