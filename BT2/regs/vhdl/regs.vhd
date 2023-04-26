-- Registros del spi
-- Almacenara la informacion en funcion de la direccion de entrada y de salida.
-- entradas: 
-- clk: reloj del origen 
-- nRst: reset asincrono para inicializar el registro
-- dato_in_reg: dato de entrada
-- adr_reg: direccion de entrada
-- salidas:
-- dato_reg: dato de salida


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity regs is

port(
    clk :        in std_logic;
    nRst :       in std_logic;
    dato_in_reg :in std_logic_vector(7 downto 0);
    adr_reg :    buffer std_logic_vector(3 downto 0);
    dato_reg:    buffer std_logic_vector(7 downto 0);
    );
end entity;


architecture rtl of regs is
    -- señales para el regisro --
    signal reg0 : std_logic_vector(7 downto 0);
    signal reg1 : std_logic_vector(7 downto 0);
    signal reg2 : std_logic_vector(7 downto 0);
    signal reg3 : std_logic_vector(7 downto 0);
    signal reg4 : std_logic_vector(7 downto 0);
    signal reg5 : std_logic_vector(7 downto 0);
    signal reg6 : std_logic_vector(7 downto 0);
    signal reg7 : std_logic_vector(7 downto 0);
    signal reg8 : std_logic_vector(7 downto 0);
    signal reg9 : std_logic_vector(7 downto 0);
    signal reg10 : std_logic_vector(7 downto 0);
    signal reg11 : std_logic_vector(7 downto 0);
    signal reg12 : std_logic_vector(7 downto 0);
    signal reg13 : std_logic_vector(7 downto 0);
    signal reg14 : std_logic_vector(7 downto 0);
    signal reg15 : std_logic_vector(7 downto 0);
    
    begin

    process(clk, nRst)
        if nRst='0' then
            reg0 <= (others => '0');
            reg1 <= (others => '0');
            reg2 <= (others => '0');
            reg3 <= (others => '0');
            reg4 <= (others => '0');
            reg5 <= (others => '0');
            reg6 <= (others => '0');
            reg7 <= (others => '0');
            reg8 <= (others => '0');
            reg9 <= (others => '0');
            reg10 <= (others => '0');

            dato_reg <= (others => '0');
        
        elsif clk'event and clk='1' then
            case adr_reg is
                when "0000" => reg0 <= dato_in_reg;
                when "0001" => reg1 <= dato_in_reg;
                when "0010" => reg2 <= dato_in_reg;
                when "0011" => reg3 <= dato_in_reg;
                when "0100" => reg4 <= dato_in_reg;
                when "0101" => reg5 <= dato_in_reg;
                when "0110" => reg6 <= dato_in_reg;
                when "0111" => reg7 <= dato_in_reg;
                when "1000" => reg8 <= dato_in_reg;
                when "1001" => reg9 <= dato_in_reg;
                when "1010" => reg10 <= dato_in_reg;
                when "1011" => reg11 <= dato_in_reg;
                when "1100" => reg12 <= dato_in_reg;
                when "1101" => reg13 <= dato_in_reg;
                when "1110" => reg14 <= dato_in_reg;
                when "1111" => reg15 <= dato_in_reg;
                when others => null;
            end case;
            
            case adr_reg is
                when "0000" => dato_reg <= reg0;
                when "0001" => dato_reg <= reg1;
                when "0010" => dato_reg <= reg2;
                when "0011" => dato_reg <= reg3;
                when "0100" => dato_reg <= reg4;
                when "0101" => dato_reg <= reg5;
                when "0110" => dato_reg <= reg6;
                when "0111" => dato_reg <= reg7;
                when "1000" => dato_reg <= reg8;
                when "1001" => dato_reg <= reg9;
                when "1010" => dato_reg <= reg10;
                when "1011" => dato_reg <= reg11;
                when "1100" => dato_reg <= reg12;
                when "1101" => dato_reg <= reg13;
                when "1110" => dato_reg <= reg14;
                when "1111" => dato_reg <= reg15;
                when others => null;
            end case;
        
        end if;

    end process;

end rtl;
