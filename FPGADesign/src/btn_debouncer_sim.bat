del "sim\btn_debouncer_tb.out"
del "sim\waveforms\btn_debouncer_tb_waves.vcd"

iverilog -o "sim\btn_debouncer_tb.out" -g2001 btn_debouncer_tb.v btn_debouncer.v 
vvp "sim\btn_debouncer_tb.out"
gtkwave "sim\waveforms\btn_debouncer_tb_waves.vcd"