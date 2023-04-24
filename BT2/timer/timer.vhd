-- Temporizador para SPI

-- Genera las señales de temporizacion para el resto de los modulos del SPI
-- Todas son de un periodo de reloj y son los siguientes:
-- tds_min: 5 ns;
-- tdh_min: 2 ns;
-- tacces_max: 60 ns;
-- tz_max: 20 ns;

-- Genericos: a la viste de si hacen falta

-- Designer: Grupo 2
-- Date: 2023-04-24;
-- Version: 1.0;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

    entity timer is
    port (
        clk :       in std_logic;
        nRst :     in std_logic;
        tds_min :   buffer std_logic;
        tdh_min :   buffer std_logic;
        tacces_max: buffer std_logic;
        tz_max :    buffer std_logic
    
    );
    end timer;

    architecture rtl of timer is
        signal cnt_div_tdsmin :     std_logic_vector(1 downto 0); -- MODULO 3
        signal cnt_div_taccesmax :  std_logic_vector(5 downto 0); -- MODULO 30
        signal cnt_div_tzmax :      std_logic_vector(4 downto 0); -- MODULO 10
        signal cnt_div_tdhmin :     std_logic; -- MODULO 1
        -- para la salida T_DH_MIN no haría falta dado que va con la salida del reloj pero lo optimiza quartus
        constant div_6ns : natural:= 2;
        constant div_60ns : natural:= 29;
        constant div_20ns : natural:= 9;
        constant div_2ns : natural:= 1;

        begin

        divisor_tDS_min: process (clk, nRst)
        begin
            if (nRst = '0') then
                cnt_div_tdsmin <= (others => '0');
            
            elsif clk'event and clk='1' then
                if (tds_min='1') then
                    cnt_div_tdsmin <= (others => '0');
                else
                    cnt_div_tdsmin <= cnt_div_tdsmin + 1;
                end if;
            end if;
        end process divisor_tDS_min;

        tds_min <= '1' when cnt_div_tdsmin = div_6ns else '0';

--------------------------------------------------------------------------
        
        divisor_tZ_max: process (clk, nRst)
        begin
            if (nRst = '0') then
                cnt_div_tzmax <= (others => '0');
            
            elsif clk'event and clk='1' then
                if (tz_max='1') then
                    cnt_div_tzmax <= (others => '0');
                else
                    cnt_div_tzmax <= cnt_div_tzmax + 1;
                end if;
            end if;
        end process divisor_tZ_max;

        tz_max <= '1' when cnt_div_tzmax = div_20ns else '0';

--------------------------------------------------------------------------

        divisor_tacces_max: process (clk, nRst)
        begin
            if (nRst = '0') then
                cnt_div_taccesmax <= (others => '0');
            
            elsif clk'event and clk='1' then
                if (tacces_max='1') then
                    cnt_div_taccesmax <= (others => '0');
                else
                    cnt_div_taccesmax <= cnt_div_taccesmax + 1;
                end if;
            end if;
        end process divisor_tacces_max;

        tacces_max <= '1' when cnt_div_taccesmax = div_60ns else '0';

--------------------------------------------------------------------------
        
        divisor_tdh_min: process (clk, nRst)
        begin
            if (nRst = '0') then
                cnt_div_tdhmin <= '0';
            
            elsif clk'event and clk='1' then
                tdh_min <= not tdh_min;
            end if;
        end process divisor_tdh_min;
        --- PREGUNTA: podemos directamente conectar el reloj en el portmap como la salida de del tic????

    
    end rtl;
    
