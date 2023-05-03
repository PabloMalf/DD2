library library IEEE;
use IEEE.std_logic_1164.all;


entity SPI is
    port(
    clk  : in std_logic;
    nRst : in std_logic;
    SDI  : in std_logic;
    CS   : in std_logic;
    SDO  : buffer std_logic;
    sclk : in std_logic;
    )
end SPI;

architecture struct of SPI is

    signal dato_tx : std_logic_vector(7 downto 0);
    signal dato_rx : std_logic_vector(7 downto 0);

    signal init_tx : std_logic;
    signal init_rx : std_logic;
    signal data_ready : std_logic;

    signal ena_out : std_logic;
    signal ena_in : std_logic;

    signal nWR : std_logic;
    signal adr_reg : std_logic_vector(3 downto 0);
    signal dato_in_reg : std_logic_vector(7 downto 0);

    signal dato_out_reg : std_logic_vector(7 downto 0);
begin
 com_SPI: entity work.com_spi(rtl)
 port map (
    clk => clk,
    nRst => nRst,
    SDI => SDI,
    cs_in => CS,
    SDO => SDO,
    clk_in => sclk,
    init_tx => init_tx,
    init_rx => init_rx,
    data_ready => data_ready, 
 );

 logica_SPI: entity work.logica_spi(rtl)
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

 regs: entity work.regs(rtl)
    port map(clk => clk,
            nRst => nRst,
            ena_in => ena_in,
            nWR => nWR,
            adr_reg => adr_reg,
            dato_in_reg => dato_in_reg,
            ena_out => ena_out,
            dato_out_reg => dato_out_reg);


end struct;