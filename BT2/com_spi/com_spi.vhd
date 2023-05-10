-----------------------------------------------------------------------------------------------------
-- Modulo de comunicacion spi.
-- Este modulo se encarga de la comunicacion y de interactuar con las líneas físicas.
-----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity com_spi is
port(clk           : in std_logic;
     nRst          : in std_logic;
     cs_in         : in std_logic;                          -- Linea Chip Select
     clk_in        : in std_logic;                          -- Linea CLK
     dato_tx       : in std_logic_vector(7 downto 0);       -- Dato que el esclavo quiere mandar por la linea
     init_tx       : in std_logic;                          -- Informa de que el dato es nuevo
     SDI           : inout std_logic;                          -- Linea SDI
     SDO           : buffer std_logic;                      -- Linea SDO
     dato_rx       : buffer std_logic_vector(7 downto 0);   -- Dato que se ha recibido del master
     data_ready    : buffer std_logic;                      -- dato_rx puede ser leido. Se activa durante un pulso de reloj cuando se ha recibido un byte.
     init_rx       : buffer std_logic);                      -- Indica el inicio de la comunicación
   --  modo_3_4_hilos: in     std_logic);                     -- El modulo de logica envia informacion sobre si se debe enviar a 3 o 4 hilos. 0 = 4 hilos (por defecto), 1 = 3 hilos
--     data_sent     : buffer std_logic);                     -- se ha enviado el dato
end entity;

architecture rtl of com_spi is
-- señales auxiliares
  signal sclk_T1: std_logic;                         -- registro sclk
  signal reg_clk: std_logic;                         -- clk_spi limpio
  
  signal cs_T1: std_logic;                           -- registro cs
  signal reg_cs: std_logic;                          -- cs limpio
  
  signal SDI_T1: std_logic;                          -- registro SDI
  signal reg_SDI: std_logic;                         -- SDI limpio
  
  signal prev_reg_clk: std_logic;                    -- guarda el valor anterior de la señal reg_clk para detectar flancos de subida
  signal flanco_subida_clk_in: std_logic;
--  signal dato_completo: std_logic;
  signal reg_dato_in: std_logic_vector(7 downto 0);  -- lo que se va recibiendo por la linea mas un bit extra que indica si se ha leido todo el byte
  signal cnt_rcv_bit: std_logic_vector (3 downto 0); -- numero de bits que se van recibiendo
  
  signal reg_dato_out: std_logic_vector(7 downto 0); -- guarda el valor de dato_tx
  signal enviando: std_logic;                        -- si está activa, se están enviando datos por la linea SDO_no_Z
  signal cnt_send_bit: std_logic_vector(3 downto 0); -- numero de bits que se han enviado
  signal desplazar_reg_dato_out: std_logic;          -- se desplaza reg_dato_out para que en su LSB se incluya el valor que se enviara por la linea
    
  signal prev_reg_cs: std_logic;                     -- Para detectar cambios en la linea
--  signal reg_init_rx: std_logic;                     -- se activa cuando se ha detectado una señal de start, se enviará la señal cuando se reciba el dato completo
  signal SDO_no_Z: std_logic;
begin
  
  process(nRst, clk)
  -- doble flip-flop
  begin
    if nRst = '0' then
      sclk_T1 <= '0';
      reg_clk <= '0';
      
      cs_T1 <= '0';
      reg_cs <= '0';
      
      SDI_T1 <= '0';
      reg_SDI <= '0';
    elsif clk'event and clk = '1' then
      sclk_T1 <= clk_in;
      reg_clk <= sclk_T1;
      
      cs_T1  <= cs_in;
      reg_cs <= cs_T1;
      
      SDI_T1  <= SDI;
      reg_SDI <= SDI_T1;
    end if;
  end process;

  process (nRst, clk)
  -- se encarga de muestrear la linea clk_in para detectar flancos.
  begin
    if nRst = '0' then
      flanco_subida_clk_in <= '0';
    elsif clk'event and clk = '1' then
      prev_reg_clk <= reg_clk;
      if reg_clk /= prev_reg_clk and reg_clk = '1' then
        flanco_subida_clk_in <= '1';
      else
        flanco_subida_clk_in <= '0';
      end if;
    end if;
  end process;

  process (nRst, clk)
  -- Cambios en la linea cs
  begin
    if nRst = '0' then
      init_rx <= '0';
      prev_reg_cs <= '0';
    elsif clk'event and clk = '1' then
      prev_reg_cs <= reg_cs;    
      if reg_cs /= prev_reg_cs and reg_cs = '0' then          -- Condicion de start
        init_rx <= '1';
      else
        init_rx <= '0';
      end if;
    end if;
  end process;

  process(nRst,clk)
  -- se encarga de leer la linea sdi y almacenar los bits en reg_dato_in
  begin
    if nRst = '0' then
      reg_dato_in <= (others => '0');
      cnt_rcv_bit <= (others => '0');
      data_ready <= '0';
    elsif clk'event and clk = '1' then
      if reg_cs = '0' then                                 -- Se detecta un nivel bajo en la linea de cs: El master va a enviar datos
        if flanco_subida_clk_in = '1' then                             -- Hay que recoger el valor de la linea SDI
          if cnt_rcv_bit < 7 then
            cnt_rcv_bit <= cnt_rcv_bit + 1;
            reg_dato_in <= reg_dato_in(6 downto 0) & reg_SDI;
            data_ready <= '0';
          elsif cnt_rcv_bit = 7 then
            cnt_rcv_bit <= cnt_rcv_bit + 1;
            reg_dato_in <= reg_dato_in(6 downto 0) & reg_SDI;
            if reg_SDI /= 'Z' then
              data_ready <= '1';
            end if;
          else
            cnt_rcv_bit <= (0 => '1', others => '0');
            reg_dato_in <= (others => '0');
            data_ready <= '0';
          end if;
        else 
          data_ready <= '0';                              -- Solo se debe activar 1 ciclo de reloj
        end if;
      end if;
    end if;
  end process;
  
  -- Pasa los datos en el orden que los ha recibido
  dato_rx <= reg_dato_in when cnt_rcv_bit = 8 and reg_dato_in >= 0 else
             dato_rx;
  
  process(nRst,clk)
  -- recibe un dato del modulo de logica y lo envia por linea SDO_no_Z cuando el master aporta un reloj
  begin
    if nRst = '0' then
      reg_dato_out <= (others => '0');
      enviando <= '0';
      cnt_send_bit <= (others => '0');
      SDO_no_Z <= '1';
    elsif clk'event and clk = '1' then
      if init_tx = '1' then
        reg_dato_out <= dato_tx;
        enviando <= '1';
        cnt_send_bit <= (others => '0');
      elsif enviando = '1' then
        if cnt_send_bit /= 9 and flanco_subida_clk_in = '1' and reg_SDI = 'Z' then
          cnt_send_bit <= cnt_send_bit + 1;
          reg_dato_out <= reg_dato_out(6 downto 0) & '0';
          SDO_no_Z <= reg_dato_out(7);
        elsif cnt_send_bit = 9 then
          cnt_send_bit <= (others => '0');
          enviando <= '0';
          SDO_no_Z <= '1';
        end if;
      end if;
    end if;
  end process;
   
   SDI <= 'Z' ;
  --when cnt_send_bit=0 
  --         else SDO_no_Z when modo_3_4_hilos = '1' 
  --         else 'Z';
  
  SDO <= 'Z' when cnt_send_bit=0 
          else SDO_no_Z ;
          --when modo_3_4_hilos /= '1' 
          --else 'Z';
end rtl;