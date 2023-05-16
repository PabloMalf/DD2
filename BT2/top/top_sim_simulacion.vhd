library ieee;
use ieee.std_logic_1164.all;

entity top_sim is
    port (clk         : in std_logic;
          nRst        : in std_logic;
          MSB_1st_master     : in std_logic;
          mode_3_4_h_master  : in std_logic;
          str_sgl_ins_master : in std_logic;
          add_up_master      : in std_logic;
          SDIO_m        : inout std_logic;
          SDIO_s        : inout std_logic;
          SDO_m         : in std_logic;
          SDO_s         : buffer std_logic;
          seg           : buffer std_logic_vector(7 downto 0);
          mux_disp      : buffer std_logic_vector(7 downto 0);
          tecla         : in std_logic_vector(3 downto 0);
          tecla_pulsada : in std_logic
    );
end top_sim;

architecture estructural of top_sim is
  signal nCSB: std_logic;
  signal sclk: std_logic;
  
  signal start: std_logic;
  signal no_bytes: std_logic_vector(2 downto 0);
  signal dato_wr: std_logic_vector(47 downto 0);
  signal dato_rd: std_logic_vector(7 downto 0);
  signal ena_rd: std_logic;
  signal rdy: std_logic;
  signal info_disp: std_logic_vector(2 downto 0);
  signal reg_tx: std_logic_vector(31 downto 0);
  
  signal tic_2_5ms: std_logic;
  signal tic_0_5s: std_logic;

  signal tds_min : std_logic;
  signal tdh_min : std_logic;
  signal tacces_max : std_logic;
  signal tz_max : std_logic;
  signal timer_teclado : std_logic;
  
  signal str_sgl_ins_slave:  std_logic;
  signal add_up_slave:       std_logic;
  signal MSB_1st_slave:      std_logic;
  signal mode_3_4_h_slave: std_logic;
  
  signal mode_check: std_logic;
  signal check_ok: std_logic;
--  signal tecla : std_logic_vector(3 downto 0);
--  signal tecla_pulsada: std_logic;
begin
  SPI: entity work.spi(struct)
  port map(clk  => clk,
           nRst => nRst,
           SDI  => SDIO_s,
           nCS  => nCSB,
           SDO  => SDO_s,
           sclk => sclk,
           mode_3_4_h_slave => mode_3_4_h_slave,
           str_sgl_ins_slave => str_sgl_ins_slave,
           add_up_slave => add_up_slave,
           MSB_1st_slave => MSB_1st_slave
           );
  
  app_module: entity work.app_module(rtl)
  port map(nRst => nRst,
           clk  => clk,
           tic_tecla => tecla_pulsada,
           tecla => tecla,
           start => start,
           no_bytes => no_bytes,
           dato_wr => dato_wr,
           dato_rd => dato_rd,
           ena_rd => ena_rd,
           rdy => rdy,
           info_disp => info_disp,
           reg_tx => reg_tx,
           str_sgl_ins_master => str_sgl_ins_master,    
           add_up_master => add_up_master,
           MSB_1st_master => MSB_1st_master,
           mode_3_4_h_master => mode_3_4_h_master,
           str_sgl_ins_slave => str_sgl_ins_slave,    
           add_up_slave => add_up_slave,
           MSB_1st_slave => MSB_1st_slave,
           mode_3_4_h_slave => mode_3_4_h_slave,
           mode_check => mode_check,
           check_ok => check_ok
           );	
  
  master_spi_3_4_hilos: entity work.master_spi_3_4_hilos(rtl)
  port map(nRst => nRst,
           clk  => clk,
           MSB_1st_master => MSB_1st_master,
           mode_3_4_h_master => mode_3_4_h_master,
           str_sgl_ins_master => str_sgl_ins_master,
           start => start,
           no_bytes => no_bytes,
           dato_in => dato_wr,
           dato_rd => dato_rd,
           ena_rd => ena_rd,
           rdy => rdy,
           nCS => nCSB,
           SPC => sclk,
           SDI => SDO_m,       
           SDIO => SDIO_m
           );

  presentacion: entity work.presentacion(rtl)
  port map(clk => clk,
           nRst => nRst,
           tic_2_5ms => tic_2_5ms,
           tic_0_5s => tic_0_5s,
           info_disp => info_disp,
           reg_tx => reg_tx,
           seg => seg,
           mux_disp=> mux_disp,
           mode_check => mode_check,
           check_ok => check_ok,
           mode_3_4_h_slave => mode_3_4_h_slave
          ); 

end estructural;