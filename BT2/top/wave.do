onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_top/clk
add wave -noupdate /test_top/nRst
add wave -noupdate -expand -group Principal /test_top/MSB_1st
add wave -noupdate -expand -group Principal /test_top/mode_3_4_h
add wave -noupdate -expand -group Principal /test_top/str_sgl_ins
add wave -noupdate -expand -group Principal /test_top/add_up
add wave -noupdate -expand -group Principal /test_top/dut/sclk
add wave -noupdate -expand -group Principal /test_top/SDIO
add wave -noupdate -expand -group Principal /test_top/SDO
add wave -noupdate -expand -group Principal /test_top/nCSB
add wave -noupdate -expand -group Principal /test_top/tic_tecla
add wave -noupdate -expand -group Principal -radix hexadecimal /test_top/tecla
add wave -noupdate -expand -group Principal -radix hexadecimal /test_top/seg
add wave -noupdate -expand -group Principal /test_top/mux_disp
add wave -noupdate -expand -group Principal /test_top/info_disp
add wave -noupdate -expand -group Principal -radix hexadecimal /test_top/reg_tx
add wave -noupdate -group SPI -radix hexadecimal /test_top/dut/SPI/dato_tx
add wave -noupdate -group SPI -radix hexadecimal -childformat {{/test_top/dut/SPI/dato_rx(7) -radix hexadecimal} {/test_top/dut/SPI/dato_rx(6) -radix hexadecimal} {/test_top/dut/SPI/dato_rx(5) -radix hexadecimal} {/test_top/dut/SPI/dato_rx(4) -radix hexadecimal} {/test_top/dut/SPI/dato_rx(3) -radix hexadecimal} {/test_top/dut/SPI/dato_rx(2) -radix hexadecimal} {/test_top/dut/SPI/dato_rx(1) -radix hexadecimal} {/test_top/dut/SPI/dato_rx(0) -radix hexadecimal}} -subitemconfig {/test_top/dut/SPI/dato_rx(7) {-height 15 -radix hexadecimal} /test_top/dut/SPI/dato_rx(6) {-height 15 -radix hexadecimal} /test_top/dut/SPI/dato_rx(5) {-height 15 -radix hexadecimal} /test_top/dut/SPI/dato_rx(4) {-height 15 -radix hexadecimal} /test_top/dut/SPI/dato_rx(3) {-height 15 -radix hexadecimal} /test_top/dut/SPI/dato_rx(2) {-height 15 -radix hexadecimal} /test_top/dut/SPI/dato_rx(1) {-height 15 -radix hexadecimal} /test_top/dut/SPI/dato_rx(0) {-height 15 -radix hexadecimal}} /test_top/dut/SPI/dato_rx
add wave -noupdate -group SPI /test_top/dut/SPI/init_tx
add wave -noupdate -group SPI /test_top/dut/SPI/init_rx
add wave -noupdate -group SPI /test_top/dut/SPI/data_ready
add wave -noupdate -group SPI /test_top/dut/SPI/ena_out
add wave -noupdate -group SPI /test_top/dut/SPI/ena_in
add wave -noupdate -group SPI /test_top/dut/SPI/nWR
add wave -noupdate -group SPI -radix binary -childformat {{/test_top/dut/SPI/adr_reg(4) -radix hexadecimal} {/test_top/dut/SPI/adr_reg(3) -radix hexadecimal} {/test_top/dut/SPI/adr_reg(2) -radix hexadecimal} {/test_top/dut/SPI/adr_reg(1) -radix hexadecimal} {/test_top/dut/SPI/adr_reg(0) -radix hexadecimal}} -subitemconfig {/test_top/dut/SPI/adr_reg(4) {-height 15 -radix hexadecimal} /test_top/dut/SPI/adr_reg(3) {-height 15 -radix hexadecimal} /test_top/dut/SPI/adr_reg(2) {-height 15 -radix hexadecimal} /test_top/dut/SPI/adr_reg(1) {-height 15 -radix hexadecimal} /test_top/dut/SPI/adr_reg(0) {-height 15 -radix hexadecimal}} /test_top/dut/SPI/adr_reg
add wave -noupdate -group SPI -radix hexadecimal /test_top/dut/SPI/dato_in_reg
add wave -noupdate -group SPI -radix hexadecimal -childformat {{/test_top/dut/SPI/dato_out_reg(7) -radix hexadecimal} {/test_top/dut/SPI/dato_out_reg(6) -radix hexadecimal} {/test_top/dut/SPI/dato_out_reg(5) -radix hexadecimal} {/test_top/dut/SPI/dato_out_reg(4) -radix hexadecimal} {/test_top/dut/SPI/dato_out_reg(3) -radix hexadecimal} {/test_top/dut/SPI/dato_out_reg(2) -radix hexadecimal} {/test_top/dut/SPI/dato_out_reg(1) -radix hexadecimal} {/test_top/dut/SPI/dato_out_reg(0) -radix hexadecimal}} -subitemconfig {/test_top/dut/SPI/dato_out_reg(7) {-height 15 -radix hexadecimal} /test_top/dut/SPI/dato_out_reg(6) {-height 15 -radix hexadecimal} /test_top/dut/SPI/dato_out_reg(5) {-height 15 -radix hexadecimal} /test_top/dut/SPI/dato_out_reg(4) {-height 15 -radix hexadecimal} /test_top/dut/SPI/dato_out_reg(3) {-height 15 -radix hexadecimal} /test_top/dut/SPI/dato_out_reg(2) {-height 15 -radix hexadecimal} /test_top/dut/SPI/dato_out_reg(1) {-height 15 -radix hexadecimal} /test_top/dut/SPI/dato_out_reg(0) {-height 15 -radix hexadecimal}} /test_top/dut/SPI/dato_out_reg
add wave -noupdate -group SPI /test_top/dut/SPI/tds_min
add wave -noupdate -group SPI /test_top/dut/SPI/tdh_min
add wave -noupdate -group SPI /test_top/dut/SPI/tacces_max
add wave -noupdate -group SPI /test_top/dut/SPI/tz_max
add wave -noupdate -expand -group app_module /test_top/dut/app_module/idx
add wave -noupdate -expand -group app_module /test_top/dut/app_module/tx
add wave -noupdate -expand -group app_module /test_top/dut/app_module/rx
add wave -noupdate -group Master_SPI /test_top/dut/master_spi_3_4_hilos/cnt_SPC
add wave -noupdate -group Master_SPI /test_top/dut/master_spi_3_4_hilos/fdc_cnt_SPC
add wave -noupdate -group Master_SPI /test_top/dut/master_spi_3_4_hilos/SPC_posedge
add wave -noupdate -group presentacion /test_top/dut/presentacion/reg_mux
add wave -noupdate -group presentacion -radix hexadecimal /test_top/dut/presentacion/HEX
add wave -noupdate -group presentacion /test_top/dut/presentacion/punto
add wave -noupdate -expand -group com_spi /test_top/dut/SPI/com_SPI/reg_clk
add wave -noupdate -expand -group com_spi /test_top/dut/SPI/com_SPI/sclk_T1
add wave -noupdate -expand -group com_spi /test_top/dut/SPI/com_SPI/reg_SDI
add wave -noupdate -expand -group com_spi -radix hexadecimal -childformat {{/test_top/dut/SPI/com_SPI/dato_rx(7) -radix hexadecimal} {/test_top/dut/SPI/com_SPI/dato_rx(6) -radix hexadecimal} {/test_top/dut/SPI/com_SPI/dato_rx(5) -radix hexadecimal} {/test_top/dut/SPI/com_SPI/dato_rx(4) -radix hexadecimal} {/test_top/dut/SPI/com_SPI/dato_rx(3) -radix hexadecimal} {/test_top/dut/SPI/com_SPI/dato_rx(2) -radix hexadecimal} {/test_top/dut/SPI/com_SPI/dato_rx(1) -radix hexadecimal} {/test_top/dut/SPI/com_SPI/dato_rx(0) -radix hexadecimal}} -subitemconfig {/test_top/dut/SPI/com_SPI/dato_rx(7) {-height 15 -radix hexadecimal} /test_top/dut/SPI/com_SPI/dato_rx(6) {-height 15 -radix hexadecimal} /test_top/dut/SPI/com_SPI/dato_rx(5) {-height 15 -radix hexadecimal} /test_top/dut/SPI/com_SPI/dato_rx(4) {-height 15 -radix hexadecimal} /test_top/dut/SPI/com_SPI/dato_rx(3) {-height 15 -radix hexadecimal} /test_top/dut/SPI/com_SPI/dato_rx(2) {-height 15 -radix hexadecimal} /test_top/dut/SPI/com_SPI/dato_rx(1) {-height 15 -radix hexadecimal} /test_top/dut/SPI/com_SPI/dato_rx(0) {-height 15 -radix hexadecimal}} /test_top/dut/SPI/com_SPI/dato_rx
add wave -noupdate -expand -group com_spi /test_top/dut/SPI/com_SPI/data_ready
add wave -noupdate -expand -group com_spi -radix hexadecimal /test_top/dut/SPI/com_SPI/reg_dato_in
add wave -noupdate -expand -group com_spi -radix unsigned /test_top/dut/SPI/com_SPI/cnt_rcv_bit
add wave -noupdate -expand -group com_spi /test_top/dut/SPI/com_SPI/cs_T1
add wave -noupdate -expand -group com_spi /test_top/dut/SPI/com_SPI/reg_cs
add wave -noupdate -expand -group com_spi /test_top/dut/SPI/com_SPI/SDI_T1
add wave -noupdate -expand -group com_spi /test_top/dut/SPI/com_SPI/prev_reg_clk
add wave -noupdate -expand -group com_spi /test_top/dut/SPI/com_SPI/flanco_subida_clk_in
add wave -noupdate -expand -group com_spi -radix hexadecimal /test_top/dut/SPI/com_SPI/reg_dato_out
add wave -noupdate -expand -group com_spi /test_top/dut/SPI/com_SPI/enviando
add wave -noupdate -expand -group com_spi /test_top/dut/SPI/com_SPI/cnt_send_bit
add wave -noupdate -expand -group com_spi /test_top/dut/SPI/com_SPI/prev_reg_cs
add wave -noupdate -expand -group com_spi /test_top/dut/SPI/com_SPI/SDO_no_Z
add wave -noupdate -expand -group logica -radix hexadecimal /test_top/dut/SPI/logica_SPI/estado_escritura
add wave -noupdate -expand -group logica -radix hexadecimal /test_top/dut/SPI/logica_SPI/estado_bit
add wave -noupdate -expand -group logica -radix hexadecimal /test_top/dut/SPI/logica_SPI/orden_escritura
add wave -noupdate -expand -group logica -radix hexadecimal /test_top/dut/SPI/logica_SPI/adr_com
add wave -noupdate -expand -group logica -radix hexadecimal /test_top/dut/SPI/logica_SPI/adr_T1
add wave -noupdate -expand -group logica -radix hexadecimal /test_top/dut/SPI/logica_SPI/contador
add wave -noupdate -expand -group logica -radix hexadecimal /test_top/dut/SPI/logica_SPI/contador_multiplo
add wave -noupdate -expand -group logica -radix hexadecimal /test_top/dut/SPI/logica_SPI/adr_com_actual
add wave -noupdate -expand -group logica /test_top/dut/SPI/logica_SPI/ena_out
add wave -noupdate -expand -group logica /test_top/dut/SPI/logica_SPI/dato_out_reg
add wave -noupdate -expand -group logica /test_top/dut/SPI/logica_SPI/dato_in_reg
add wave -noupdate -expand -group logica /test_top/dut/SPI/logica_SPI/adr_reg
add wave -noupdate -expand -group logica /test_top/dut/SPI/logica_SPI/ena_in
add wave -noupdate -expand -group logica /test_top/dut/SPI/logica_SPI/contador
add wave -noupdate -expand -group logica -radix hexadecimal /test_top/dut/SPI/logica_SPI/nWR_actual
add wave -noupdate -expand -group reg -radix hexadecimal /test_top/dut/SPI/regs/reg0
add wave -noupdate -expand -group reg -radix hexadecimal /test_top/dut/SPI/regs/reg1
add wave -noupdate -expand -group reg -radix hexadecimal /test_top/dut/SPI/regs/reg2
add wave -noupdate -expand -group reg -radix hexadecimal /test_top/dut/SPI/regs/reg3
add wave -noupdate -expand -group reg -radix hexadecimal /test_top/dut/SPI/regs/reg4
add wave -noupdate -expand -group reg -radix hexadecimal /test_top/dut/SPI/regs/reg5
add wave -noupdate -expand -group reg -radix hexadecimal /test_top/dut/SPI/regs/reg6
add wave -noupdate -expand -group reg -radix hexadecimal /test_top/dut/SPI/regs/reg7
add wave -noupdate -expand -group reg -radix hexadecimal /test_top/dut/SPI/regs/reg8
add wave -noupdate -expand -group reg -radix hexadecimal /test_top/dut/SPI/regs/reg9
add wave -noupdate -expand -group reg -radix hexadecimal /test_top/dut/SPI/regs/reg10
add wave -noupdate -expand -group reg -radix hexadecimal /test_top/dut/SPI/regs/reg11
add wave -noupdate -expand -group reg -radix hexadecimal /test_top/dut/SPI/regs/reg12
add wave -noupdate -expand -group reg -radix hexadecimal /test_top/dut/SPI/regs/reg13
add wave -noupdate -expand -group reg -radix hexadecimal /test_top/dut/SPI/regs/reg14
add wave -noupdate -expand -group reg -radix hexadecimal /test_top/dut/SPI/regs/reg15
add wave -noupdate -expand -group reg -radix hexadecimal /test_top/dut/SPI/regs/reg16
add wave -noupdate -expand -group reg -radix hexadecimal /test_top/dut/SPI/regs/reg17
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3271225 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {7617659 ps}
