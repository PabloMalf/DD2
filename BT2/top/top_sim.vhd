library ieee;
use ieee.std_logic_1164.all;

entity top_sim is
    port (clk         : in std_logic;
          nRst        : in std_logic;
          MSB_1st     : in std_logic;
          mode_3_4_h  : in std_logic;
          str_sgl_ins : in std_logic;
          add_up      : in std_logic;
          SDIO_m      : inout std_logic;
          SDIO_s      : inout std_logic;
          SDO_m       : in std_logic;
          SDO_s       : buffer std_logic;
          seg         : buffer std_logic_vector(7 downto 0);
          mux_disp    : buffer std_logic_vector(3 downto 0);
          columna     : in std_logic_vector(3 downto 0);
          fila        : buffer std_logic_vector(3 downto 0)
    );
end top_sim;

architecture estructural of top_sim is
  signal nCS: std_logic;
  signal sclk: std_logic;
  
  signal start: std_logic;
  signal no_bytes: std_logic_vector(2 downto 0);
  signal dato_wr: std_logic_vector(47 downto 0);
  signal dato_rd: std_logic_vector(7 downto 0);
  signal ena_rd: std_logic;
  signal rdy: std_logic;
  signal info_disp: std_logic_vector(2 downto 0);
  signal reg_tx: std_logic_vector(15 downto 0);
  
  signal tic_2_5ms: std_logic;
  signal tic_0_5s: std_logic;
  signal tic_5ms : std_logic;
  
  signal tecla : std_logic_vector(3 downto 0);
  signal tecla_pulsada: std_logic;
begin
  SPI: entity work.spi(struct)
  port map(clk  => clk,
           nRst => nRst,
           SDI  => SDIO_s,
           nCS   => nCS,
           SDO  => SDO_s,
           sclk => sclk
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
           str_sgl_ins => str_sgl_ins,
           add_up => add_up
           );	
  
  master_spi_3_4_hilos: entity work.master_spi_3_4_hilos(rtl)
  port map(nRst => nRst,
           clk  => clk,
           MSB_1st => MSB_1st,
           mode_3_4_h => mode_3_4_h,
           str_sgl_ins => str_sgl_ins,
           start => start,
           no_bytes => no_bytes,
           dato_in => dato_wr,
           dato_rd => dato_rd,
           ena_rd => ena_rd,
           rdy => rdy,
           nCS => nCS,
           SPC => sclk,
           SDI => SDO_m,         -- ???
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
           mux_disp=> mux_disp 
          );

  
  timer: entity work.timer(rtl)
  port map(clk => clk,
          nRst => nRst,
          tic_5ms => tic_5ms,
          tic_2_5ms => tic_2_5ms,
          tic_0_5s => tic_0_5s);        
  
  teclado: entity work.ctrl_tec(rtl)
  port map(clk => clk,
          nRst => nRst,
          tic => tic_5ms,
          columna => columna, 
          fila => fila,
          tecla_pulsada => tecla_pulsada,
          tecla =>tecla);
         
end estructural;