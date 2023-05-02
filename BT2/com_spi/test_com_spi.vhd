library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity test_com_spi is
end entity;

architecture test of test_com_spi is
  signal clk:           std_logic;
  signal nRst:          std_logic;
  
  signal cs_in:         std_logic;
  signal clk_in:        std_logic;
  signal SDI:           std_logic;
  signal SDO:           std_logic;

  signal dato_tx:      std_logic_vector(7 downto 0);
  signal dato_rx:       std_logic_vector(7 downto 0);
  signal init_tx:        std_logic;
  
  signal data_ready:    std_logic;
  signal init_rx:       std_logic;
--  signal data_sent:     std_logic;
  
  
  constant Tclk:        time := 20 ns;
  constant Tclk_spi:    time := 200 ns;
  
  begin
  process
  begin
    clk <= '0';
    wait for Tclk/2;

    clk <= '1';
    wait for Tclk/2;

  end process;
  
  dut: entity work.com_spi(rtl)
       port map(clk           => clk,
                nRst          => nRst,
                cs_in         => cs_in,
                clk_in        => clk_in,
                SDI           => SDI,
                SDO           => SDO,
                dato_tx      => dato_tx,
                dato_rx       => dato_rx,
                init_tx        => init_tx,
                data_ready    => data_ready,
                init_rx       => init_rx);

-- Proceso de generacion del cs y del reloj del spi
process
begin
--  cs_in <= '0';                         -- Por defecto esta a '1' pero en esta simulación se asume que el chip siempre esta seleccionado
  clk_in <= '1';                        -- Valor por defecto
  -- 1. Genera un reloj spi sincrono con el sistema (ver punto 1 del siguiente proceso)
  wait for 149*Tclk;
  wait until clk'event and clk = '1';
-- cs_in <= '0';
  wait for 19*Tclk;
  wait until clk'event and clk = '1';
  for i in 0 to 8 loop
    clk_in <= '0';
    wait for Tclk_spi/2;
    clk_in <= '1';
    wait for Tclk_spi/2;
  end loop;
  
  wait for 100*Tclk;
  -- 2. Genera un reloj spi no sincronizado con el sistema
  wait for 53 ns; -- Numero primo
--  cs_in <= '0';   -- Poco relevante para el modulo de com_spi cuanto tiempo pase desde que se pone a '0'
  for i in 0 to 8 loop
    clk_in <= '0';
    wait for Tclk_spi/2;
    clk_in <= '1';
    wait for Tclk_spi/2;
  end loop;
end process;

process
  begin
    -- Reset
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    nRst <= '0';
    SDI <= '1';
    init_tx <= '0';
    dato_tx <= (others => '0');
    cs_in <= '1';
    
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    nRst <= '1';
    
    -- 1. Prueba a recibir un dato por la linea SDI cuando los datos se envian de manera sincrona
    wait until clk_in'event and clk_in = '1';
    cs_in <= '0';
    SDI <= '0';
    wait until clk_in'event and clk_in = '1';
    SDI <= '1';
    wait until clk_in'event and clk_in = '1';
    SDI <= '1';
    wait until clk_in'event and clk_in = '1';
    SDI <= '0';
    wait until clk_in'event and clk_in = '1';
    SDI <= '0';
    wait until clk_in'event and clk_in = '1';
    SDI <= '1';
    wait until clk_in'event and clk_in = '1';
    SDI <= '1';
    wait until clk_in'event and clk_in = '1';
    SDI <= '0';
    
    cs_in <= '0';
    
    wait for 2*Tclk_spi;
    wait until clk'event and clk = '1';
    assert dato_rx = "01100110"
    report "ERROR: Los datos no cuadran"
    severity failure;
    
    -- 2. Datos no sincronizados
    cs_in <= '1';
    wait until clk_in'event and clk_in = '1';
    cs_in <= '0';
    SDI <= '1';
    wait until clk_in'event and clk_in = '1';
    SDI <= '0';
    wait until clk_in'event and clk_in = '1';
    SDI <= '0';
    wait until clk_in'event and clk_in = '1';
    SDI <= '0';
    wait until clk_in'event and clk_in = '1';
    SDI <= '1';
    wait until clk_in'event and clk_in = '1';
    SDI <= '1';
    wait until clk_in'event and clk_in = '1';
    SDI <= '1';
    wait until clk_in'event and clk_in = '1';
    SDI <= '1';
    
    wait for 2*Tclk_spi;
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    
    assert dato_rx = "10001111"
    report "ERROR: Los datos no cuadran"
    severity failure;
    
    -- 3. Mandar un dato por la linea SDO
    dato_tx <= "10001001";
    init_tx <= '1';
    wait until clk'event and clk = '1';
    init_tx <= '0';
    
    wait for 100*Tclk_spi;
    
    assert false severity failure;
end process;
end test;