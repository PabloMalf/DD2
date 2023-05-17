library IEEE;
use IEEE.std_logic_1164.all;


entity SPI is
    port(
    clk  : in std_logic;
    nRst : in std_logic;
    SDI  : inout std_logic;
    nCS   : in std_logic;
    SDO  : buffer std_logic;
    sclk : in std_logic;
    mode_3_4_h_slave: buffer std_logic;
    str_sgl_ins_slave : buffer std_logic;
    add_up_slave : buffer std_logic;
    MSB_1st_slave : buffer std_logic
    );
end SPI;

architecture struct of SPI is

    signal dato_tx : std_logic_vector(7 downto 0);-- datos que transmitimos por SDO
    signal dato_rx : std_logic_vector(7 downto 0);-- datps que recibimos por SDI

    signal ena_out : std_logic;
    signal ena_in : std_logic; -- para hablar con los registros

    signal nWR : std_logic;
    signal adr_reg : std_logic_vector(4 downto 0);

    signal dato_in_reg : std_logic_vector(7 downto 0);
    signal dato_out_reg : std_logic_vector(7 downto 0);
    
    
begin
 com_SPI: entity work.com_spi(rtl)
 port map (
    clk => clk,
    nRst => nRst,
    -- lineas SPI
    SDI => SDI,
    nCS => nCS,
    SDO => SDO,
    clk_in => sclk,
    -- comunicacion con los registros
    ena_out       => ena_out,
    ena_in        => ena_in,
    dato_out_reg  => dato_out_reg,
    dato_in_reg   => dato_in_reg,
    nWR           => nWR,
    adr_reg       => adr_reg,
    -- chequeo de consistencia
    modo_3_4_hilos => mode_3_4_h_slave,
    str_sgl_ins_slave => str_sgl_ins_slave,
    add_up_slave => add_up_slave,
    MSB_1st_slave => MSB_1st_slave
 );

 regs: entity work.regs(rtl)
    port map(clk => clk,
            nRst => nRst,
            ena_in => ena_in,
            nWR => nWR,
            adr_reg => adr_reg,
            dato_in_reg => dato_in_reg,
            ena_out => ena_out,
            dato_reg => dato_out_reg);

end struct;
