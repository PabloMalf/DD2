library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.pack_test_reloj.all;

entity test_estimulos_reloj is
port(clk:     	  in std_logic;
     nRst:        in std_logic;
     tic_025s:    out std_logic;
     tic_1s:      out std_logic;
     ena_cmd:     out std_logic;
     cmd_tecla:   out std_logic_vector(3 downto 0);
     pulso_largo: out std_logic;
     modo:        in std_logic;
     segundos:    in std_logic_vector(7 downto 0);
     minutos:     in std_logic_vector(7 downto 0);
     horas:       in std_logic_vector(7 downto 0);
     AM_PM:       in std_logic;
     info:        in std_logic_vector(1 downto 0)
    );
end entity;

architecture test of test_estimulos_reloj is

signal j: std_logic_vector (7 downto 0);
signal k: std_logic_vector (7 downto 0);

begin
  -- Tic para el incremento continuo de campo. Escalado. 
  process
  begin
    tic_025s <= '0';
    for i in 1 to 3 loop
       wait until clk'event and clk = '1';
    end loop;

    tic_025s <= '1';
    wait until clk'event and clk = '1';

  end process;
  -- Tic de 1 seg. Escalado.
  process
  begin
    tic_1s <= '0';
    for i in 1 to 15 loop
       wait until clk'event and clk = '1';
    end loop;

    tic_1s <= '1';
    wait until clk'event and clk = '1';

  end process;


  process
  begin
    ena_cmd  <= '0';
    cmd_tecla <= (others => '0');
    pulso_largo <= '0';

    -- Esperamos el final del Reset
    wait until nRst'event and nRst = '1';

    for i in 1 to 9 loop
       wait until clk'event and clk = '1';
    end loop;

    -- Cuenta en formato de 12 horas
    wait until clk'event and clk = '1';


    -- Esperar a las 11 y 58 AM

--- comprobar que funciona las 24 horas en modo 12h
    esperar_hora(horas, minutos, AM_PM, clk, '0', X"12"&X"02");
	
	esperar_hora(horas, minutos, AM_PM, clk, '0', X"12"&X"01");
	
	report " ///////////////////////////// HE HECHO EL MODO 12H ////////////////////////////////";
	
	-- Cambio de 12h a 24 horas
	
	cambiar_modo_12_24(ena_cmd, cmd_tecla, clk);

--- comprobar que funciona las 24 horas en modo 24h
	
	esperar_hora(horas, minutos, AM_PM, clk, '0', X"00"&X"05");
	
	esperar_hora(horas, minutos, AM_PM, clk, '0', X"00"&X"04");
	
	report " ///////////////////////////// HE HECHO EL MODO 24H ////////////////////////////////";
 
-- inicializamos la signal para el bucle
     j<=X"00";
     k<=X"00";

     for i in 0 to 11 loop  
	
	
	esperar_hora(horas, minutos, AM_PM, clk, '0', j&X"15");
        cambiar_modo_12_24(ena_cmd, cmd_tecla, clk);
        esperar_hora(horas, minutos, AM_PM, clk, '0', j&X"30");
        cambiar_modo_12_24(ena_cmd, cmd_tecla, clk);
     j<= j+1;
   
  end loop;
      
      for i in 0 to 11 loop 
	
	esperar_hora(horas, minutos, AM_PM, clk, '0', j&X"15");
        cambiar_modo_12_24(ena_cmd, cmd_tecla, clk);
        esperar_hora(horas, minutos, AM_PM, clk, '0', k&X"30");
        cambiar_modo_12_24(ena_cmd, cmd_tecla, clk);
      j<= j+1;
      k<= k+1; 

     end loop;
	
	
	-----------------------------------------------------------------
  

    assert false
    report "done"
    severity failure;
  end process;

end test;
