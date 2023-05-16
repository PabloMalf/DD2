-- Temporizador para SPI

-- Designer: Grupo 2
-- Date: 2023-04-24;
-- Version: 1.0;

-- No hace falta estos tics pero se queda el modelo para reusarlo


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

    entity timer is
    port (
        clk :       in std_logic;
        nRst :     in std_logic;
       
        tic_5ms:    buffer std_logic;
        tic_2_5ms:  buffer std_logic;
        tic_0_5s:   buffer std_logic

    
    );
    end timer;

    architecture rtl of timer is

        signal cnt_2_5ms :         std_logic_vector(16 downto 0); -- MODULO 125000
        signal cnt_5ms :  std_logic_vector(18 downto 0); -- MODULO 2
        signal cnt_0_5s :          std_logic_vector(7 downto 0); -- MODULO 100
        
        constant div_2_5ms : natural:= 124999;
        constant div_5ms : natural:= 1;
        constant div_0_5s : natural:= 99;

        begin


--- timer de 2.5 ms
        process (clk, nRst)
        begin 
            if nRst='0' then
                cnt_2_5ms <= (others => '0'); 
            elsif clk'event and clk='1' then
                if cnt_2_5ms = div_2_5ms then
                    cnt_2_5ms<= (others => '0');
                else
                    cnt_2_5ms <= cnt_2_5ms + 1;
                end if;
            end if;
        end process;

        tic_2_5ms <= '1' when cnt_2_5ms = div_5ms else '0';


--- timer de 5 ms, siendo un tic cada 2 tics de 2.5 ms
        process (clk, nRst)
        begin 
            if nRst='0' then
                cnt_5ms <= (others => '0'); 
            elsif clk'event and clk='1' then
                if tic_2_5ms='1' then
                    if cnt_5ms = div_5ms then
                        cnt_5ms<= (others => '0');
                    else
                        cnt_5ms <= cnt_5ms + 1;
                    end if;
                end if;
            end if;
        end process;

        tic_5ms <= '1' when cnt_5ms = div_5ms and tic_2_5ms else '0';

-- timer de 0.5 s, siendo un tic cada 200 tics  de 2.5 ms

        process (clk, nRst)
        begin 
            if nRst='0' then
                cnt_0_5s <= (others => '0'); 
            elsif clk'event and clk='1' then
                if tic_5ms='1' then
                    if cnt_0_5s = div_0_5s then
                        cnt_0_5s<= (others => '0');
                    else
                        cnt_0_5s <= cnt_0_5s + 1;
                    end if;
                end if;
            end if;
        end process;

        tic_0_5s <= '1' when cnt_0_5s = div_0_5s and tic_5ms else '0';
    
    end rtl;
    
