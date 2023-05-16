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
     nCS           : in std_logic;                          -- Linea Chip Select
     clk_in        : in std_logic;                          -- Linea CLK
     dato_tx       : in std_logic_vector(7 downto 0);       -- Dato que el esclavo quiere mandar por la linea
     init_tx       : in std_logic;                          -- Informa de que el dato es nuevo
     SDI           : inout std_logic;                          -- Linea SDI
     SDO           : buffer std_logic;                      -- Linea SDO
     dato_rx       : buffer std_logic_vector(7 downto 0);   -- Dato que se ha recibido del master
     data_ready    : buffer std_logic;                      -- dato_rx puede ser leido. Se activa durante un pulso de reloj cuando se ha recibido un byte.
     init_rx       : buffer std_logic;                      -- Indica el inicio de la comunicación
     modo_3_4_hilos: in     std_logic);                     -- El modulo de logica envia informacion sobre si se debe enviar a 3 o 4 hilos. 0 = 4 hilos (por defecto), 1 = 3 hilos
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
  signal flanco_bajada_clk_in : std_logic;

  signal reg_dato_in: std_logic_vector(7 downto 0);  -- lo que se va recibiendo por la linea mas un bit extra que indica si se ha leido todo el byte
  signal cnt_rcv_bit: std_logic_vector (3 downto 0); -- numero de bits que se van recibiendo
  
  signal reg_dato_out: std_logic_vector(7 downto 0); -- guarda el valor de dato_tx
  signal enviando: std_logic;                        -- si está activa, se están enviando datos por la linea SDO_no_Z
  signal cnt_send_bit: std_logic_vector(3 downto 0); -- numero de bits que se han enviado
--  signal desplazar_reg_dato_out: std_logic;          -- se desplaza reg_dato_out para que en su LSB se incluya el valor que se enviara por la linea
    
  signal prev_reg_cs: std_logic;                     -- Para detectar cambios en la linea
--  signal reg_init_rx: std_logic;                     -- se activa cuando se ha detectado una señal de start, se enviará la señal cuando se reciba el dato completo
  signal SDO_no_Z: std_logic;
  signal buf_data_tx: std_logic_vector (7 downto 0); -- si se esta enviando un dato y se pide que se envíe otro, se guarda en este buffer hasta que se pueda enviar.
  signal hay_datos_en_buf_retransmision: std_logic;
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

       cs_T1  <= nCS;
       reg_cs <= cs_T1;

       SDI_T1  <= SDI;
       reg_SDI <= SDI_T1;
     end if;
   end process;

--  reg_clk <= clk_in;
--  reg_cs <= nCS;
--  reg_SDI <= SDI;

  process (nRst, clk)
  -- se encarga de muestrear la linea clk_in para detectar flancos.
  begin
    if nRst = '0' then
      prev_reg_clk <= '0';
    elsif clk'event and clk = '1' then
      prev_reg_clk <= reg_clk;
    end if;
  end process;
  
  flanco_subida_clk_in <= '1' when reg_clk /= prev_reg_clk and reg_clk = '1' else '0';
  flanco_bajada_clk_in<= '1' when reg_clk /= prev_reg_clk and reg_clk = '0' else '0';
  
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
        if flanco_subida_clk_in = '1' and reg_SDI /= 'Z' then                             -- Hay que recoger el valor de la linea SDI
          if cnt_rcv_bit < 7 then
            cnt_rcv_bit <= cnt_rcv_bit + 1;
            reg_dato_in <= reg_dato_in(6 downto 0) & reg_SDI;
            data_ready <= '0';
          elsif cnt_rcv_bit = 7 then
            cnt_rcv_bit <= cnt_rcv_bit + 1;
            reg_dato_in <= reg_dato_in(6 downto 0) & reg_SDI;
            data_ready <= '1';
           elsif cnt_rcv_bit = 8 then
              cnt_rcv_bit <= (0 => '1', others => '0');
          end if;
        elsif cnt_rcv_bit = 8 then  
            reg_dato_in <= reg_dato_in(6 downto 0) & reg_SDI;
            data_ready <= '0';
        else 
          data_ready <= '0';                              -- Solo se debe activar 1 ciclo de reloj
        end if;
       elsif reg_cs = '1' or data_ready = '1' then
        cnt_rcv_bit <= (others => '0');
      end if;
    end if;
  end process;
  
  -- Pasa los datos en el orden que los ha recibido
  dato_rx <= reg_dato_in when cnt_rcv_bit = 8 and data_ready = '1' and reg_dato_in >= 0 else
             dato_rx;
  
  process(nRst,clk)
  -- recibe un dato del modulo de logica y lo envia por linea SDO_no_Z cuando el master aporta un reloj
  begin
    if nRst = '0' then
      reg_dato_out <= (others => '0');
      enviando <= '0';
      cnt_send_bit <= (others => '0');
      SDO_no_Z <= '0';
      hay_datos_en_buf_retransmision<= '0';
    elsif clk'event and clk = '1' then
      if reg_cs /= '0' then
        cnt_send_bit <= (others => '0');
        enviando <= '0';
      elsif init_tx = '1' and enviando = '0' then
        reg_dato_out <= dato_tx;
        enviando <= '1';
      elsif init_tx = '1' and enviando = '1' then -- se esta enviando un dato, se guarda el siguiente en un buffer.
        hay_datos_en_buf_retransmision <= '1';
        buf_data_tx <= dato_tx; 
      
      elsif enviando = '1' then
        if cnt_send_bit < 7 and flanco_bajada_clk_in= '1' then
          cnt_send_bit <= cnt_send_bit + 1;
          reg_dato_out <= reg_dato_out(6 downto 0) & '0';
          SDO_no_Z <= reg_dato_out(7);
        elsif cnt_send_bit = 7 and flanco_bajada_clk_in= '1' then
          if hay_datos_en_buf_retransmision = '1' then
            reg_dato_out<= buf_data_tx;
          else
            reg_dato_out <= reg_dato_out(6 downto 0) & '0';
          end if;
          cnt_send_bit <= cnt_send_bit + 1;
          SDO_no_Z <= reg_dato_out(7);
        elsif cnt_send_bit = 8 and flanco_bajada_clk_in= '1' then
          cnt_send_bit <= (0 => '1', others => '0');
          SDO_no_Z <= reg_dato_out(7);
          reg_dato_out <= reg_dato_out(6 downto 0) & '0';
          hay_datos_en_buf_retransmision <= '0';
          buf_data_tx <= (others => '0');
            
         elsif cnt_send_bit = 8 and flanco_subida_clk_in = '1' then
          if hay_datos_en_buf_retransmision = '0' then
            enviando <= '0';
            cnt_send_bit <= (others => '0');
          end if;
        end if;
        --elsif cnt_send_bit= 8 and flanco_bajada_clk_in= '1' and reg_SDI = 'Z'  then
          
        
      end if;
    end if;
  end process;
   
 SDI <= 'Z' when cnt_send_bit=0 
        else SDO_no_Z when modo_3_4_hilos = '0' 
        else 'Z';
  
  SDO <= 'Z' when reg_SDI /= 'Z' or reg_cs /= '0' or cnt_send_bit= 0 
         else SDO_no_Z when flanco_bajada_clk_in = '1' -- and modo_3_4_hilos /= '0'
         else SDO when modo_3_4_hilos = '1' 
         else 'Z';
end rtl;