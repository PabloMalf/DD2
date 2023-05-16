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
    signal reg16 : std_logic_vector(7 downto 0);
    signal reg17 : std_logic_vector(7 downto 0);
    
    begin

    process(clk, nRst)
    begin
        if nRst='0' then
            reg0 <= (4=> '1', 3=> '1',others => '0');
            reg1 <= (others => '0');
            
            reg16 <= (others => '0');
            reg17 <= (others => '0');
  
            dato_reg <= (others => '0');
            ena_out <= '0';
        
        elsif clk'event and clk='1' then
            if nWR= '0' and ena_in='1' then -- nWR= '0' es decir, escritura
                case adr_reg is
                    when "00000" => reg0 <= dato_in_reg;
                    when "00001" => reg1 <= dato_in_reg;
                    when "10000" => reg16 <= dato_in_reg;
                    when others => reg17 <= dato_in_reg;
                     
                end case;
                ena_out <= '0';

            elsif nWR='1' and ena_in='1' then  --  es decir, lectura

                case adr_reg is
                    when "00000" => dato_reg <= reg0;
                    when "00001" => dato_reg <= reg1;

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
