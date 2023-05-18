onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_top/nRst
add wave -noupdate /test_top/clk
add wave -noupdate -group master_spi /test_top/dut/master_spi_3_4_hilos/rdy
add wave -noupdate -group master_spi /test_top/dut/master_spi_3_4_hilos/nCS
add wave -noupdate -group master_spi /test_top/dut/master_spi_3_4_hilos/SPC
add wave -noupdate -group master_spi /test_top/dut/master_spi_3_4_hilos/SDI
add wave -noupdate -group master_spi /test_top/dut/master_spi_3_4_hilos/SDIO
add wave -noupdate -group master_spi /test_top/dut/master_spi_3_4_hilos/cnt_SPC
add wave -noupdate -group master_spi /test_top/dut/master_spi_3_4_hilos/fdc_cnt_SPC
add wave -noupdate -group master_spi /test_top/dut/master_spi_3_4_hilos/SPC_posedge
add wave -noupdate -group master_spi /test_top/dut/master_spi_3_4_hilos/SPC_negedge
add wave -noupdate -group master_spi /test_top/dut/master_spi_3_4_hilos/cnt_bits_SPC
add wave -noupdate -group master_spi /test_top/dut/master_spi_3_4_hilos/SDI_syn
add wave -noupdate -group master_spi /test_top/dut/master_spi_3_4_hilos/SDI_meta
add wave -noupdate -group master_spi /test_top/dut/master_spi_3_4_hilos/SDIO_syn
add wave -noupdate -group master_spi /test_top/dut/master_spi_3_4_hilos/SDIO_meta
add wave -noupdate -group master_spi /test_top/dut/master_spi_3_4_hilos/reg_SPI
add wave -noupdate -group master_spi /test_top/dut/master_spi_3_4_hilos/nWR_RD
add wave -noupdate -group master_spi /test_top/dut/master_spi_3_4_hilos/n_ctrl_SDIO
add wave -noupdate -group master_spi /test_top/dut/master_spi_3_4_hilos/n_ctrl_SDIO_dly1
add wave -noupdate -group master_spi /test_top/dut/master_spi_3_4_hilos/n_ctrl_SDIO_dly2
add wave -noupdate -group master_spi /test_top/dut/master_spi_3_4_hilos/SDIO_o
add wave -noupdate -group master_spi /test_top/dut/master_spi_3_4_hilos/fin
add wave -noupdate -group master_spi /test_top/dut/master_spi_3_4_hilos/no_bytes_r
add wave -noupdate -group master_spi /test_top/dut/master_spi_3_4_hilos/SPC_LH
add wave -noupdate -group Presentacion /test_top/dut/presentacion/tic_2_5ms
add wave -noupdate -group Presentacion /test_top/dut/presentacion/tic_0_5s
add wave -noupdate -group Presentacion /test_top/dut/presentacion/info_disp
add wave -noupdate -group Presentacion /test_top/dut/presentacion/reg_tx
add wave -noupdate -group Presentacion /test_top/dut/presentacion/seg
add wave -noupdate -group Presentacion /test_top/dut/presentacion/mux_disp
add wave -noupdate -group Presentacion /test_top/dut/presentacion/mode_check
add wave -noupdate -group Presentacion /test_top/dut/presentacion/check_ok
add wave -noupdate -group Presentacion /test_top/dut/presentacion/barra_roja
add wave -noupdate -group Presentacion /test_top/dut/presentacion/barra_amar
add wave -noupdate -group Presentacion /test_top/dut/presentacion/barra_verd
add wave -noupdate -group Presentacion /test_top/dut/presentacion/led0
add wave -noupdate -group Presentacion /test_top/dut/presentacion/led1
add wave -noupdate -group Presentacion /test_top/dut/presentacion/led2
add wave -noupdate -group Presentacion /test_top/dut/presentacion/mode_3_4_h_slave
add wave -noupdate -group Presentacion /test_top/dut/presentacion/reg_mux
add wave -noupdate -group Presentacion /test_top/dut/presentacion/HEX
add wave -noupdate -group Presentacion /test_top/dut/presentacion/punto
add wave -noupdate -group Presentacion /test_top/dut/presentacion/cnt_campo
add wave -noupdate -group Consistencia /test_top/dut/add_up_master
add wave -noupdate -group Consistencia /test_top/dut/add_up_slave
add wave -noupdate -group Consistencia /test_top/dut/mode_3_4_h_master
add wave -noupdate -group Consistencia /test_top/dut/mode_3_4_h_slave
add wave -noupdate -group Consistencia /test_top/dut/MSB_1st_master
add wave -noupdate -group Consistencia /test_top/dut/MSB_1st_slave
add wave -noupdate -group Consistencia /test_top/dut/str_sgl_ins_master
add wave -noupdate -group Consistencia /test_top/dut/str_sgl_ins_slave
add wave -noupdate -group Consistencia /test_top/dut/check_ok
add wave -noupdate -group Consistencia /test_top/dut/mode_check
add wave -noupdate -group Interfaz_SPI /test_top/dut/SPI/dato_tx
add wave -noupdate -group Interfaz_SPI /test_top/dut/SPI/dato_rx
add wave -noupdate -group Interfaz_SPI /test_top/dut/SPI/ena_out
add wave -noupdate -group Interfaz_SPI /test_top/dut/SPI/ena_in
add wave -noupdate -group Interfaz_SPI /test_top/dut/SPI/nWR
add wave -noupdate -group Interfaz_SPI /test_top/dut/SPI/adr_reg
add wave -noupdate -group Interfaz_SPI /test_top/dut/SPI/dato_in_reg
add wave -noupdate -group Interfaz_SPI /test_top/dut/SPI/dato_out_reg
add wave -noupdate -expand -group app_module /test_top/dut/app_module/info_disp
add wave -noupdate -expand -group app_module /test_top/dut/app_module/mode_check
add wave -noupdate -expand -group app_module /test_top/dut/app_module/check_ok
add wave -noupdate -expand -group app_module /test_top/dut/app_module/estado
add wave -noupdate -expand -group app_module /test_top/dut/app_module/tx
add wave -noupdate -expand -group app_module /test_top/dut/app_module/rx
add wave -noupdate -expand -group app_module /test_top/dut/app_module/cambiar_modo
add wave -noupdate -expand -group app_module /test_top/dut/app_module/shift
add wave -noupdate -expand -group app_module /test_top/dut/app_module/inc
add wave -noupdate -expand -group app_module /test_top/dut/app_module/dec
add wave -noupdate -expand -group app_module /test_top/dut/app_module/idx
add wave -noupdate -expand -group app_module -radix hexadecimal /test_top/dut/app_module/reg_tx
add wave -noupdate -expand -group AUTOMATA_COM_SPI /test_top/dut/SPI/com_SPI/estado
add wave -noupdate -expand -group AUTOMATA_COM_SPI /test_top/dut/SPI/com_SPI/reg_clk
add wave -noupdate -expand -group AUTOMATA_COM_SPI /test_top/dut/SPI/com_SPI/reg_cs
add wave -noupdate -expand -group AUTOMATA_COM_SPI /test_top/dut/SPI/com_SPI/reg_SDI
add wave -noupdate -expand -group AUTOMATA_COM_SPI /test_top/dut/SPI/com_SPI/SDO
add wave -noupdate -expand -group AUTOMATA_COM_SPI -radix unsigned /test_top/dut/SPI/com_SPI/cnt_rcv_bit
add wave -noupdate -expand -group AUTOMATA_COM_SPI /test_top/dut/SPI/com_SPI/flanco_subida_clk_in
add wave -noupdate -expand -group AUTOMATA_COM_SPI /test_top/dut/SPI/com_SPI/flanco_bajada_clk_in
add wave -noupdate -expand -group AUTOMATA_COM_SPI -radix hexadecimal /test_top/dut/SPI/com_SPI/reg_adr
add wave -noupdate -expand -group AUTOMATA_COM_SPI -radix hexadecimal /test_top/dut/SPI/com_SPI/reg_dato_in
add wave -noupdate -expand -group AUTOMATA_COM_SPI -radix hexadecimal /test_top/dut/SPI/com_SPI/cnt_send_bit
add wave -noupdate -expand -group AUTOMATA_COM_SPI /test_top/dut/SPI/com_SPI/reg_dato_out
add wave -noupdate -expand -group AUTOMATA_COM_SPI /test_top/dut/SPI/com_SPI/SDO_no_Z
add wave -noupdate -expand -group AUTOMATA_COM_SPI /test_top/dut/SPI/com_SPI/nWR
add wave -noupdate -expand -group AUTOMATA_COM_SPI /test_top/dut/SPI/com_SPI/fdc_cnt_rcv_dato
add wave -noupdate -expand -group AUTOMATA_COM_SPI /test_top/dut/SPI/com_SPI/fdc_cnt_adr
add wave -noupdate -expand -group AUTOMATA_COM_SPI /test_top/dut/SPI/ena_in
add wave -noupdate -expand -group AUTOMATA_COM_SPI /test_top/dut/SPI/ena_out
add wave -noupdate -expand -group REGISTROS -radix hexadecimal /test_top/dut/SPI/regs/dato_in_reg
add wave -noupdate -expand -group REGISTROS -radix hexadecimal /test_top/dut/SPI/regs/adr_reg
add wave -noupdate -expand -group REGISTROS -radix hexadecimal /test_top/dut/SPI/regs/dato_reg
add wave -noupdate -expand -group REGISTROS /test_top/dut/SPI/regs/ena_in
add wave -noupdate -expand -group REGISTROS /test_top/dut/SPI/regs/ena_out
add wave -noupdate -expand -group REGISTROS /test_top/dut/SPI/regs/ena_in
add wave -noupdate -expand -group REGISTROS /test_top/dut/SPI/regs/ena_out
add wave -noupdate -expand -group REGISTROS /test_top/dut/SPI/regs/nWR
add wave -noupdate -expand -group REGISTROS -radix hexadecimal /test_top/dut/SPI/regs/reg0
add wave -noupdate -expand -group REGISTROS -radix hexadecimal /test_top/dut/SPI/regs/reg1
add wave -noupdate -expand -group REGISTROS -radix hexadecimal /test_top/dut/SPI/regs/reg16
add wave -noupdate -expand -group REGISTROS -radix hexadecimal /test_top/dut/SPI/regs/reg17
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1910438 ps} 0}
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
WaveRestoreZoom {0 ps} {18070500 ps}
