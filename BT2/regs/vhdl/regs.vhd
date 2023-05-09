-- Registros del spi
-- Almacenara la informacion en funcion de la direccion de entrada y de salida.
-- entradas: 
-- clk: reloj del origen 
-- nRst: reset asincrono para inicializar el registro
-- nWR: habilita la escritura o lectura de los registros
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
    adr_reg :    in std_logic_vector(4 downto 0);
    dato_reg:    buffer std_logic_vector(7 downto 0);
    nWR:         in std_logic;
    ena_in:      in std_logic;
    ena_out:     buffer std_logic
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
    signal reg16 : std_logic_vector(7 downto 0);
    signal reg17 : std_logic_vector(7 downto 0);
    
    begin

    process(clk, nRst)
    begin
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
            reg11 <= (others => '0');
            reg12 <= (others => '0');
            reg13 <= (others => '0');
            reg14 <= (others => '0');
            reg15 <= (others => '0');
            reg16 <= (others => '0');
            reg17 <= (others => '0');
  
            dato_reg <= (others => '0');
            ena_out <= '0';
        
        elsif clk'event and clk='1' then
            if nWR= '0' and ena_in='1' then
                case adr_reg is
                    when "00000" => reg0 <= dato_in_reg;
                    when "00001" => reg1 <= dato_in_reg;
                    when "00010" => reg2 <= dato_in_reg;
                    when "00011" => reg3 <= dato_in_reg;
                    when "00100" => reg4 <= dato_in_reg;
                    when "00101" => reg5 <= dato_in_reg;
                    when "00110" => reg6 <= dato_in_reg;
                    when "00111" => reg7 <= dato_in_reg;
               --     when "1000" => reg8 <= dato_in_reg;
                    when "01001" => reg9 <= dato_in_reg;
                    when "01010" => reg10 <= dato_in_reg;
                    when "01011" => reg11 <= dato_in_reg;
                    when "01100" => reg12 <= dato_in_reg;
                    when "01101" => reg13 <= dato_in_reg;
                    when "01110" => reg14 <= dato_in_reg;
                    when "01111" => reg15 <= dato_in_reg;
                    when "10000" => reg16 <= dato_in_reg;
                    when "10001" => reg17 <= dato_in_reg;
                    when others => reg8 <= dato_in_reg;

                end case;
                ena_out <= '1';

            elsif nWR='1' and ena_in='1' then  -- es decir, nWR='1'

                case adr_reg is
                    when "00000" => dato_reg <= reg0;
                    when "00001" => dato_reg <= reg1;
                    when "00010" => dato_reg <= reg2;
                    when "00011" => dato_reg <= reg3;
                    when "00100" => dato_reg <= reg4;
                    when "00101" => dato_reg <= reg5;
                    when "00110" => dato_reg <= reg6;
                    when "00111" => dato_reg <= reg7;
                    when "01000" => dato_reg <= reg8;
                    when "01001" => dato_reg <= reg9;
                    when "01010" => dato_reg <= reg10;
                    when "01011" => dato_reg <= reg11;
                    when "01100" => dato_reg <= reg12;
                    when "01101" => dato_reg <= reg13;
                    when "01110" => dato_reg <= reg14;
                    when "01111" => dato_reg <= reg15;
                    when "10000" => dato_reg <= reg16;
                    when "10001" => dato_reg <= reg17;
                    when others => dato_reg <= "XXXXXXXX";
                end case;
                ena_out <= '1';
            else 
            
            ena_out <='0';

            end if;
        end if;

    end process;

end rtl;
