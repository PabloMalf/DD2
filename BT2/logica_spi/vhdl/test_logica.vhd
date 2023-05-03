library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity test_logica_spi is
end entity;

architecture test of test_logica_spi is
  signal clk:           std_logic;
  signal nRst:          std_logic;
  
  signal dato_tx:       std_logic_vector(7 downto 0);
  signal dato_rx:       std_logic_vector(7 downto 0);
  signal init_tx:       std_logic;
  signal init_rx:       std_logic;
  signal dato_ready:    std_logic;

  signal ena_out:       std_logic;
  signal dato_out_reg:  std_logic_vector(7 downto 0);
  signal dato_in_reg:   std_logic_vector(7 downto 0);
  
  signal nWR:           std_logic;
  signal adr_reg:       std_logic_vector(3 downto 0);
  signal ena_in:        std_logic;
  
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
  
  dut: entity work.logica_spi(rtl)
       port map(clk           => clk,
                nRst          => nRst,
                dato_tx       => dato_tx,
                dato_rx       => dato_rx,
                init_tx       => init_tx,
                dato_ready    => dato_ready,
                init_rx       => init_rx,
                ena_out       => ena_out,
                dato_out_reg  => dato_out_reg,
                dato_in_reg   => dato_in_reg,
                nWR           => nWR,
                adr_reg       => adr_reg,
                ena_in        => ena_in);

process
  begin
    nRst <= '0';
    init_rx <= '0';
    dato_ready <= '0';
    wait until clk = '1' and clk'event;
    wait until clk = '1' and clk'event;
    nRst <= '1';
    
    init_rx <= '1';
    wait until clk'event and clk = '1';
    init_rx <= '0';
    wait for 8*Tclk_spi;
    wait until clk'event and clk = '1';
    
    -- Direccion
    dato_rx <= "00000000";
    dato_ready <= '0';
    wait until clk'event and clk = '1';
    dato_ready <= '0';
    wait for 8*Tclk_spi;        
    wait until clk'event and clk = '1';
    dato_rx <= "00000011";
    dato_ready <= '1';
    wait until clk'event and clk = '1';
    dato_ready <= '0';
	wait for 8*Tclk_spi;        
    wait until clk'event and clk = '1';
    dato_rx <= "00000100";
    dato_ready <= '1';
    wait until clk'event and clk = '1';
    dato_ready <= '0';
    
wait until clk'event and clk = '1';
    wait for 8*Tclk_spi;        
    wait until clk'event and clk = '1';
    dato_rx <= "10001111";
    dato_ready <= '1';
    wait until clk'event and clk = '1';
    dato_ready <= '0';
    
wait for 8*Tclk_spi;        
    wait until clk'event and clk = '1';
    dato_rx <= "10101010";
    dato_ready <= '1';
    wait until clk'event and clk = '1';
    dato_ready <= '0';
    
wait until clk'event and clk = '1';
    wait for 8*Tclk_spi;        
    wait until clk'event and clk = '1';
    dato_rx <= "00001111";
    dato_ready <= '1';
    wait until clk'event and clk = '1';
    dato_ready <= '0';
    
    
    assert false severity failure;
end process;
end test;