library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity presentacion is
port(clk:              in     std_logic;							-- 50 MHz
     nRst:             in     std_logic;							-- Reset asíncrono
     tic_2_5ms:        in     std_logic;							-- tic de 2,5 milisegundos
     tic_0_5s:         in     std_logic;							-- tic de 500 milisegundos
     info_disp:        in     std_logic_vector(2 downto 0);	    -- bits(1 downto 0) -> display que está siendo editado, bit(2) -> modo de edición de registros de configuracion (0) o de operacion (1)
     reg_tx:           in     std_logic_vector(31 downto 0);	    -- Información para los cuatro dígitos hexadecimales ( uno por display)
     seg:              buffer std_logic_vector(7 downto 0);		-- Salida para los segmentos del display
     mux_disp:         buffer std_logic_vector(7 downto 0);         -- Salida para la habilitación de los displays
	 
	 -- Mode Transfer/Check:
	 mode_check:       in     std_logic;
	 check_ok:         in     std_logic;
	 
	 -- Interfaz barras 
	 -- Activas a nivel bajo
	 barra_roja:       buffer std_logic;                           
	 barra_amar:       buffer std_logic; 
	 barra_verd:       buffer std_logic;
	 
	 -- Interfaz leds internos de las barras
	 -- Activas a nivel alto
	 led0:             buffer std_logic;
	 led1:             buffer std_logic;
	 led2:             buffer std_logic;
	 
	 -- Interfaz slave
	 mode_3_4_h_slave: in std_logic                              -- Gobernará la señal barra_amar
	 );		
          
end entity;

architecture rtl of presentacion is
  -- Multiplexacion de displays:
  signal reg_mux: std_logic_vector(7 downto 0);
  signal HEX:     std_logic_vector(4 downto 0);
  signal punto:   std_logic;
  
  signal cnt_campo: std_logic_vector(1 downto 0);
  
begin
  -- Control multiplexacion de displays
  process(clk, nRst)
  begin
    if nRst = '0' then
      reg_mux <= (0 => '0', others => '1');
	  
    elsif clk'event and clk = '1' then
	  if mode_check = '0' then
	    
		if reg_mux(3) /= '0' and reg_mux(2) /= '0' and reg_mux(1) /= '0' and reg_mux(0) /= '0' then -- 1111 1111
		  reg_mux <= (0 => '0', others => '1');
		  
		end if;
	    
		if tic_2_5ms = '1' then
		  reg_mux(3 downto 0) <= reg_mux(2 downto 0)&reg_mux(3); -- 1111 1110

		end if;
		
	  else
	    if reg_mux(3) /= '0' and reg_mux(2) /= '0' and reg_mux(1) /= '0' and reg_mux(0) /= '0' and reg_mux(7) /= '0' and reg_mux(6) /= '0' and reg_mux(5) /= '0' and reg_mux(4) /= '0' then -- 1111 1111
		  reg_mux <= (0 => '0', others => '1');
		  
		end if;
        	  
	    if tic_2_5ms = '1' then
		  if cnt_campo = 3    then -- 01 11 11 11 / 10 11 11 11
			reg_mux(7) <= not reg_mux(7); -- 0
			reg_mux(6) <= reg_mux(7);
			reg_mux(5 downto 0) <= (others => '1'); 
		   
		  elsif cnt_campo = 2 then -- 11 01 11 11 / 11 10 11 11
		    reg_mux(5) <= not reg_mux(5); 
			reg_mux(4) <= reg_mux(5);
			reg_mux(3 downto 0) <= (others => '1');
			reg_mux(7 downto 6) <= (others => '1');
		  
		  elsif cnt_campo = 1 then -- 11 11 01 11 / 11 11 10 11
		    reg_mux(3) <= not reg_mux(3); 
			reg_mux(2) <= reg_mux(3);
			reg_mux(1 downto 0) <= (others => '1');
			reg_mux(7 downto 4) <= (others => '1');
		  
		  elsif cnt_campo = 0 then -- 11 11 11 01 / 11 11 11 10
		    reg_mux(1) <= not reg_mux(1); 
			reg_mux(0) <= reg_mux(1);
			reg_mux(7 downto 2) <= (others => '1');
		  end if;
		end if;	
		
	  end if;
    end if;
  end process;

  -- Segnales de multiplexacion
  mux_disp <= reg_mux               when info_disp(2) = '0' and mode_check = '0' else
              reg_mux or "11110100" when                        mode_check = '0' else  -- Apaga el disp cuando reg control
			     reg_mux;                   

  -- Mux decodificador BCD-7seg              
  HEX <= '0'&reg_tx(3 downto 0)   when reg_mux = X"FE"                        and mode_check = '0' else -- 11111110
         '1'&reg_tx(3 downto 0)   when reg_mux = X"FE"                        and mode_check = '1' else -- -> valdrá H
         '0'&reg_tx(7 downto 4)   when reg_mux = X"FD"                                             else -- -> valdrá solo 3 o 4 en modo chequeo
         '0'&reg_tx(11 downto 8)  when reg_mux = X"FB"                        and mode_check = '0' else
		 '0'&reg_tx(11 downto 8)  when reg_mux = X"F7" and info_disp(2) = '1' and mode_check = '0' else
		 
		 '1'&reg_tx(11 downto 8)  when reg_mux = X"FB"                        and mode_check = '1' else -- -> valdrá S
         '0'&reg_tx(15 downto 12) when reg_mux = X"F7"                        and mode_check = '0' else -- -> comprobar si esta línea es correcta
		 '1'&reg_tx(15 downto 12) when reg_mux = X"F7"                        and mode_check = '1' else -- -> valdrá Π o L 
		 '0'&reg_tx(19 downto 16) when reg_mux = X"EF"                                             else -- -> valdrá C
  	     '1'&reg_tx(23 downto 20) when reg_mux = X"DF"                        and mode_check = '1' else -- -> valdrá I o d
		 '1'&reg_tx(27 downto 24) when reg_mux = X"BF"                        and mode_check = '1' else -- -> valdrá t o I
		 '1'&reg_tx(31 downto 28) when reg_mux = X"7F"                        and mode_check = '1' else "00000";     -- -> valdrá S
		 
  -- Decodificador HEX  a 7 segmentos: salidas activas a nivel alto
  process(HEX)
  begin
    case HEX is                         --abcdefg
      when "00000" => seg(6 downto 0) <= "1111110"; -- 0 
      when "00001" => seg(6 downto 0) <= "0110000"; -- 1
      when "00010" => seg(6 downto 0) <= "1101101"; -- 2 
      when "00011" => seg(6 downto 0) <= "1111001"; -- 3
      when "00100" => seg(6 downto 0) <= "0110011"; -- 4
      when "00101" => seg(6 downto 0) <= "1011011"; -- 5
      when "00110" => seg(6 downto 0) <= "1011111"; -- 6
      when "00111" => seg(6 downto 0) <= "1110000"; -- 7
      when "01000" => seg(6 downto 0) <= "1111111"; -- 8
      when "01001" => seg(6 downto 0) <= "1110011"; -- 9

      when "01010" => seg(6 downto 0) <= "1110111"; -- A
      when "01011" => seg(6 downto 0) <= "0011111"; -- B
      when "01100" => seg(6 downto 0) <= "1001110"; -- C
      when "01101" => seg(6 downto 0) <= "0111101"; -- D
      when "01110" => seg(6 downto 0) <= "1001111"; -- E
      when "01111" => seg(6 downto 0) <= "1000111"; -- F
	  
	  when "10000" => seg(6 downto 0) <= "0110111"; -- H
	  when "10001" => seg(6 downto 0) <= "1110110"; -- Π
	  when "10010" => seg(6 downto 0) <= "1011011"; -- S
	  when "10011" => seg(6 downto 0) <= "0001110"; -- L
	  when "10100" => seg(6 downto 0) <= "0111101"; -- d
	  when "10101" => seg(6 downto 0) <= "0000110"; -- I
	  when "10110" => seg(6 downto 0) <= "0001111"; -- t
	  
	  
      when others => seg(6 downto 0) <= "XXXXXXX";
  
    end case;
  end process;

  -- Intermitencia edicion
  -- Control multiplexacion de displays
  process(clk, nRst)
  begin
    if nRst = '0' then
      punto <= '0';
      cnt_campo <= "11";
    elsif clk'event and clk = '1' then
      if tic_0_5s = '1' then      
        punto <= not punto;
        if mode_check = '1' then
		   if cnt_campo /= "00" then
				cnt_campo <= cnt_campo - 1;
			else
			   cnt_campo <= "11";
			end if;
			
        end if;
      end if;
	  end if;
  end process;

  seg(7) <= punto when (info_disp = 0 and reg_mux = X"FE") and mode_check = '0' else
            punto when (info_disp = 4 and reg_mux = X"FE") and mode_check = '0' else
            punto when (info_disp = 1 and reg_mux = X"FD") and mode_check = '0' else
            punto when (info_disp = 5 and reg_mux = X"FD") and mode_check = '0' else
            punto when (info_disp = 2 and reg_mux = X"FB") and mode_check = '0' else
            punto when (info_disp = 3 and reg_mux = X"F7") and mode_check = '0' else
            punto when (info_disp = 6 and reg_mux = X"F7") and mode_check = '0' else
            '0';

				
  process(clk, nRst)
  begin
	if nRst = '0' then
	  led0       <= '0';
	  led1       <= '0';
	  led2       <= '0';
	elsif clk'event and clk = '1' then
	  if barra_roja = '0' or barra_amar = '0' or barra_verd = '0' then
		led0 <= '1';
		led1 <= '1';
		led2 <= '1';
	  else
		led0 <= '0';
	    led1 <= '0';
	    led2 <= '0';
      end if;
    end if;
  end process;
  

  barra_roja <= '0' when mode_check = '1' and check_ok = '0' else
	            '1';
				
  barra_amar <= '0' when mode_3_4_h_slave = '0'              else 
	            '1';
				
  barra_verd <= '0' when mode_check = '1' and check_ok = '1' else
                '1';  
  
end rtl;