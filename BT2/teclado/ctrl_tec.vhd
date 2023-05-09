library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ctrl_tec is
port(clk           : in std_logic;
     nRst          : in std_logic;
     tic           : in std_logic;
     columna       : in std_logic_vector(3 downto 0);
     fila          : buffer std_logic_vector(3 downto 0);
     tecla_pulsada : buffer std_logic;
     tecla         : buffer std_logic_vector(3 downto 0)
     );  
end entity;

architecture rtl of ctrl_tec is
--  signal cnt_125 : std_logic_vector(6 downto 0);
  signal cnt_fila: std_logic_vector(1 downto 0);                -- Indica en que fila estamos
  signal tecla_pulsada_activada: std_logic;                     -- Detecta que se ha activado tecla_pulsada
  signal tecla_pulsada_reg: std_logic;                          -- Detecta que hay una columna pulsada
  signal cnt_pulso_largo: std_logic_vector(8 downto 0);         -- Cuenta tics de 5 ms para detectar un pulso largo
--  signal ena_cnt_pulso_largo: std_logic;                      -- Cuando esta habilitada, el contador de pulsos largos esta activo
  signal reg_columna: std_logic_vector(3 downto 0);             -- Registra la ultima columna que se ha pulsado
  signal ena_pulso_largo: std_logic;                            -- Cuando se aciva el pulso largo, no se debe activar tecla_pulsada
begin
  
  process(nRst, clk)                                            -- Se muestrean las filas
  begin
    if nRst = '0' then
--      cnt_125 <= (others => '0');
      fila <= "1110";
    elsif clk = '1' and clk'event then
--      if cnt_125 < 125 then
--        cnt_125 <= cnt_125 + 1;
--      else 
--        cnt_125 <= (others => '0');
      if tecla_pulsada_reg = '0' and tic = '1' then 
        if fila /= "0111" then
          fila <= fila(2 downto 0) & '1';                                   -- Aumenta cada 125 ciclos (1,25 ms)
        else 
          fila <= "1110";
        end if;
      end if;
    end if;
  end process;
  
  process(nRst,clk)
  begin
    if nRst = '0' then
      tecla_pulsada <= '0'; 
      tecla_pulsada_reg <= '0';
      tecla_pulsada_activada <= '0';
    elsif clk = '1' and clk'event then
      if columna = 15 then
        tecla_pulsada_reg <= '0';
      end if;
      
      if columna /= 15 then 
        tecla_pulsada_reg <= '1';
        tecla_pulsada <= '0';
        tecla_pulsada_activada <= '0';
      elsif ena_pulso_largo = '1' and tecla_pulsada_activada = '0' then
        tecla_pulsada_activada <= '1';
        tecla_pulsada <= '1';
      elsif ena_pulso_largo = '1' and tecla_pulsada_activada = '1' then
        tecla_pulsada <= '0';
      end if;
    end if;
  end process;
  
--  tecla_pulsada_reg <= '1' when columna /= 15 else '0';
 
  process(nRst, clk)                                            -- Registra la pulsacion
  begin
    if nRst = '0' then
--      ena_cnt_pulso_largo <= '0';
      ena_pulso_largo <= '0';
      cnt_pulso_largo <= (others => '0');
      reg_columna <= (others => '0');
--      pulso_largo <= '0';
    elsif clk = '1' and clk'event then
      if tic = '1' and tecla_pulsada_reg = '1' then            -- Se ha detectado una pulsacion: se inicia el contador para detectar pulsos largos
        reg_columna <= columna;
--        ena_cnt_pulso_largo <= '1';
      end if;
      
      if tic = '1' and reg_columna /= 15 then
        if cnt_pulso_largo < 400 then
          cnt_pulso_largo <= cnt_pulso_largo + 1;
 --         pulso_largo <= '0';
        else
--          cnt_pulso_largo <= (others => '0');
 --         pulso_largo <= '1';
          ena_pulso_largo <= '0';
        end if;
      end if;
      
      if columna = 15 then 
        ena_pulso_largo <= '1';
        cnt_pulso_largo <= (others => '0');
      end if;
    end if;
  end process;
  
  
  tecla <= X"1" when reg_columna = X"E" and fila = X"E" else
           X"2" when reg_columna = X"D" and fila = X"E" else
           X"3" when reg_columna = X"B" and fila = X"E" else
           X"4" when reg_columna = X"E" and fila = X"D" else
           X"5" when reg_columna = X"D" and fila = X"D" else
           X"6" when reg_columna = X"B" and fila = X"D" else
           X"7" when reg_columna = X"E" and fila = X"B" else
           X"8" when reg_columna = X"D" and fila = X"B" else
           X"9" when reg_columna = X"B" and fila = X"B" else
           X"A" when reg_columna = X"E" and fila = X"7" else
           X"B" when reg_columna = X"B" and fila = X"7" else
           x"C" when reg_columna = X"7" and fila = X"7" else
           x"D" when reg_columna = X"7" and fila = X"B" else
           x"E" when reg_columna = X"7" and fila = X"D" else
           x"F" when reg_columna = X"7" and fila = X"E" else
           X"0";

end rtl; 



