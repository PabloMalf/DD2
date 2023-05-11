library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity logica_spi is
port(clk:             in     std_logic;
     nRst:            in     std_logic; 
     --ENTRADAS
     --Com_SPI
     init_rx:         in     std_logic;
   --  fin_rx:          in     std_logic;  no lo usamos en ningun lado 
     dato_rx:         in     std_logic_vector(7 downto 0);
     dato_ready:      in     std_logic;                            --1 ciclo de reloj??
     --Registros
     ena_out:         in     std_logic;                     --Entrada de registros que indica que el dato esta listo y se puede leer
     dato_out_reg:    in     std_logic_vector(7 downto 0);
     --SALIDAS
     --Com_SPI
     init_tx:         buffer std_logic;
     dato_tx:         buffer std_logic_vector(7 downto 0);
     modo_3_4_hilos:  buffer     std_logic;
     --Registros
     dato_in_reg:     buffer std_logic_vector(7 downto 0);
     nWR:             buffer std_logic;                                 
     adr_reg:         buffer std_logic_vector(4 downto 0);  
     ena_in:          buffer std_logic                    --Salida para registros que indica que el dato esta listo y sepuede escribir en el registro
    );
end entity;

architecture rtl of logica_spi is
  type t_estado_escritura is (streaming, single); --estados de lectura/escritura
  signal estado_escritura: t_estado_escritura;
  type t_estado_bit is (MSB, LSB); --estados de modos de bit mas significativo
  signal estado_bit: t_estado_bit; 
  type t_orden_escritura is (ascendente, descendente ); --estados de asc/desc
  signal orden_escritura: t_orden_escritura;
   type t_hilos is (hilos3, hilos4 ); --estados de asc/desc
  signal n_hilos: t_hilos;

  signal adr_com : std_logic_vector(15 downto 0); --direccion de 16 bits del adr que viene del com_spi
  signal adr_T1  : std_logic_vector(7 downto 0);
  signal contador: std_logic_vector (4 downto 0);
  --Explicacion contador multiplo: para las tramas single carrier la primera y segunda trama son address,
  --la sigiente es dato, y luego se vuelve a repetir, es decir cada 3.
  signal contador_multiplo : std_logic_vector (4 downto 0); --suma cada 3 de contadoto =r (para single carrier)
  signal adr_com_actual : std_logic_vector(15 downto 0); --direccion de 16 bits del adr que viene del com_spi
  
  signal nWR_actual: std_logic; -- Guarda el estado de lectura/escritura. Es el bit menos significativo de adr_com
  signal cambio_contador: std_logic_vector (1 downto 0); --indica si hay que cambiar el contador
begin
  --PREGUNTAS PROFE:
        --Se puede usar la funcion reverse???? respuesta: si pero hayq ue tener cuidado por si no es sintetizable
        
  -- cositas qeu faltan: 
--   terminar de enviar la informacion con spi

  ---ESTADO DEL AUTOMATA DE STREAMING/SINGLE-... y el de LSB/MSB
  process(clk, nRst)       
  begin
    if nRst = '0' then
      estado_escritura<= streaming;
      estado_bit<=MSB;
      orden_escritura<=descendente;
      n_hilos<=hilos4;
    elsif clk'event and clk = '1' then
      case estado_escritura is
        when streaming => 
           if adr_com_actual = X"0001" and dato_rx(7)='1' and estado_bit=MSB and dato_ready='1' then
              estado_escritura <= single;
            elsif adr_com_actual = X"0001" and dato_rx(0)='1' and estado_bit=LSB and dato_ready='1' then 
              estado_escritura <= single;
           end if;
        when single=>
            if adr_com = X"0001" and dato_rx(7)='0' and estado_bit=MSB and dato_ready='1' then
              estado_escritura <= streaming;
            elsif adr_com= X"0001" and dato_rx(0)='0' and estado_bit=LSB and dato_ready='1' then 
              estado_escritura <= streaming;
           end if;
      end case;
      case estado_bit is -- controla MSB o LSB
        when MSB =>
            if adr_com_actual = X"0000" and dato_rx(6)='1' and dato_rx(1)= '1' and dato_ready='1' and orden_escritura = descendente then
              estado_bit <= LSB;
            end if;
        when LSB =>
            if adr_com_actual = X"0000" and dato_rx(6)='0' and dato_rx(1)= '0' and dato_ready='1' and orden_escritura = descendente then
              estado_bit <= MSB;
            end if;
        
            end case;
        
      case orden_escritura is
        when ascendente =>
            if adr_com_actual = X"0000" and dato_rx(5)='0' and dato_rx(2)= '0' and dato_ready='1' then -- da igual que este en MSB o LSB dado que es palindromo y son iguales en los dos modos
              orden_escritura <= descendente;
            end if;

        when descendente => 
            if adr_com_actual = X"0000" and dato_rx(5)='1' and dato_rx(2)= '1' and dato_ready='1' then -- da igual que este en MSB o LSB dado que es palindromo y son iguales en los dos modos
              orden_escritura <= ascendente;
            end if;
        end case;
        
        case n_hilos is
        when hilos4 =>
            if adr_com_actual = X"0000" and dato_rx(4)='0' and dato_rx(3)= '0' and dato_ready='1' then -- da igual que este en MSB o LSB dado que es palindromo y son iguales en los dos modos
              n_hilos <= hilos3;
            end if;

        when hilos3 => 
            if adr_com_actual = X"0000" and dato_rx(4)='1' and dato_rx(3)= '1' and dato_ready='1' then -- da igual que este en MSB o LSB dado que es palindromo y son iguales en los dos modos
              n_hilos <= hilos4;
            end if;
        end case;

    end if ;
  end process;
  --Señal para el numero de hilos
  modo_3_4_hilos<= '1' when n_hilos=hilos3 else '0';
  --Explicacion de reverse : segun internet es una funcion de std_logic_1164
  adr_T1<= dato_rx when contador = 0  and estado_bit=MSB and dato_ready='1' and estado_escritura=streaming else
           dato_rx(7) & dato_rx(6) & dato_rx(5) & dato_rx(4) & dato_rx(3) & dato_rx(2) &dato_rx(1) & dato_rx(0)  when  contador = 0  and estado_bit=LSB and dato_ready='1' and estado_escritura=streaming else
           dato_rx when contador_multiplo = 0 and estado_bit=MSB and dato_ready='1'  and estado_escritura=single else 
           dato_rx(7) & dato_rx(6) & dato_rx(5) & dato_rx(4) & dato_rx(3) & dato_rx(2) &dato_rx(1) & dato_rx(0) when contador_multiplo = 0 and estado_bit=LSB and dato_ready='1' and estado_escritura=single
           else adr_T1;
  adr_com<= adr_T1 & dato_rx when estado_escritura=streaming and contador=1 and estado_bit=MSB and dato_ready='1' else  --convierte el adr en algo legible para Registros
            adr_T1 & dato_rx(7) & dato_rx(6) & dato_rx(5) & dato_rx(4) & dato_rx(3) & dato_rx(2) &dato_rx(1) & dato_rx(0)when estado_escritura=streaming and contador=1 and estado_bit=LSB  and dato_ready='1' else 
            adr_T1 & dato_rx when contador_multiplo=1 and estado_bit=MSB  and estado_escritura=single and dato_ready='1' else 
            adr_T1 & dato_rx(7) & dato_rx(6) & dato_rx(5) & dato_rx(4) & dato_rx(3) & dato_rx(2) &dato_rx(1) & dato_rx(0)  when contador_multiplo=1 and estado_bit=LSB  and estado_escritura=single and dato_ready='1'
            else adr_com;  

    adr_com_actual<= ('0' & adr_com (14 downto 0)) + contador - 2 when orden_escritura=ascendente and contador /= 0 else -- address actual en caso de streaming dependiendo si es ascendente o descendente
                     ('0' & adr_com(14 downto 0)) - contador + 2 when orden_escritura=descendente and contador /= 0 else
                     X"FFFF";

    nWR_actual <= adr_com(15) when estado_bit = MSB and contador = 2 else
                  adr_com(0) when estado_bit= LSB and contador=2  else nWR_actual;  -- LSB
  --- ESCRITURA/LECTURA DE REGISTROS
  process(clk, nRst)       
  begin
    if nRst = '0' then
      --dato_in_reg<= (others => '0');
     -- nWR<= '1';
      --ena_in <= '0';
      cambio_contador <= (others => '0');
    elsif clk'event and clk = '1' then
     
      if estado_escritura=streaming and dato_ready='1' and  nWR_actual='0' and contador>=2 then   --CASO STREAMING ESCRITURA
          --nWR<= '0';                                                    
          --adr_reg<= adr_com_actual(4 downto 0); --(5 downto 1);                     --Escribo la direccion y el dato para registro
          --ena_in<='1';
          -- if estado_bit=MSB then 
          --   dato_in_reg<= dato_rx;
          -- else
          --   dato_in_reg<= dato_rx(7) & dato_rx(6) & dato_rx(5) & dato_rx(4) & dato_rx(3) & dato_rx(2) & dato_rx(1) & dato_rx(0);
          -- end if;
      elsif estado_escritura=single and  contador_multiplo = 1 and  dato_ready = '1' and  adr_com(15)= '0' then --CASO SINGLE ESCRITURA
           --nWR<= '0';
           --ena_in<='1';
           --adr_reg<= adr_com(4 downto 0);
          --  if estado_bit = MSB then 
          --   dato_in_reg <= dato_rx;
          -- else
          --   dato_in_reg<= dato_rx(7) & dato_rx(6) & dato_rx(5) & dato_rx(4) & dato_rx(3) & dato_rx(2) & dato_rx(1) & dato_rx(0);
          -- end if;

      elsif cambio_contador=0 and  nWR_actual='1' and estado_escritura=streaming and contador = 2 then                       --CASO LECTURA  PARA REGISTROS
          cambio_contador<=cambio_contador+1;
          --nWR<= '1';
          --ena_in <= '1';
          --adr_reg<= adr_com_actual(4 downto 0);--(5 downto 1); -- en este caso no hace falta igualarlo a adr_com_actual dado que da igual si es ascendente o descendente

      elsif cambio_contador=1 and nWR_actual='1' and estado_escritura=streaming and contador = 2 then
          --ena_in <= '0'; 
          cambio_contador<=cambio_contador+1;

      elsif cambio_contador=2 and nWR_actual='1' and estado_escritura=streaming and contador = 2 then       
          cambio_contador<=cambio_contador+1;
          --nWR<= '1';
          --ena_in <= '1'; 

          -- if orden_escritura=ascendente then
          --   adr_reg<= adr_com_actual(4 downto 0)+1;
          -- else
          --   adr_reg<= adr_com_actual(4 downto 0)-1;
          -- end if;   

      elsif cambio_contador=3 and nWR_actual='1' and estado_escritura=streaming and contador = 2 then
       -- ena_in <= '0'; 
                          
     elsif cambio_contador=0 and   adr_com(15)='1' and estado_escritura=single and contador_multiplo = 2 then                       --CASO LECTURA  PARA REGISTROS
        cambio_contador<=cambio_contador+1;
          --nWR<= '1'; 
          --ena_in <= '1';
          --adr_reg<= adr_com(4 downto 0);
      else 
        --ena_in <= '0';
      end if;
      if dato_ready='1' then   --CASO LESCTURA PARA QUE DURE UN CILO
      cambio_contador <= (others => '0');
      end if;
    end if;
  end process;
  ena_in<='1' when ((cambio_contador=0 or cambio_contador=2)  and  (( adr_com(15)='1' and estado_escritura=single and contador_multiplo = 2 ) or
  (nWR_actual='1' and estado_escritura=streaming and contador = 2 )))
  or (estado_escritura=streaming and dato_ready='1' and  nWR_actual='0' and contador>=2 ) or ( estado_escritura=single and  contador_multiplo = 1 and  dato_ready = '1' and  adr_com(15)= '0')
  else '0';
 nWR<=nWR_actual;
 adr_reg<=  adr_com_actual(4 downto 0)+1 when  orden_escritura=ascendente and (cambio_contador= 2 or cambio_contador= 3) and  (nWR_actual='1' and estado_escritura=streaming and contador = 2 ) else
 adr_com_actual(4 downto 0) - 1 when  (orden_escritura=descendente and (cambio_contador= 2 or cambio_contador= 3)  and  (nWR_actual='1' and estado_escritura=streaming and contador = 2 ))
 or (cambio_contador=0 and  nWR_actual='1' and estado_escritura=streaming and contador = 2) or (cambio_contador=0 and   adr_com(15)='1' and estado_escritura=single and contador_multiplo = 2)
 else adr_com_actual(4 downto 0) when (cambio_contador=0 and  nWR_actual='1' and estado_escritura=streaming and contador = 2 )or (estado_escritura=streaming and dato_ready='1' and  nWR_actual='0' and contador>=2)
 else adr_reg;

 dato_in_reg<=dato_rx when ((estado_escritura=single and  contador_multiplo = 1 and  dato_ready = '1' and  adr_com(15)= '0') or 
 (estado_escritura=single and  contador_multiplo = 1 and  dato_ready = '1' and  adr_com(15)= '0')) and estado_bit = MSB else
 dato_rx(0) & dato_rx(1) & dato_rx(2) & dato_rx(3) & dato_rx(4) & dato_rx(5) & dato_rx(6) & dato_rx(7);
--- INFORMACION PARA COMUNICACION
    process(clk, nRst)
    begin
      if nRst='0' then
          init_tx<='0';

      elsif clk'event and clk='1' then
          if ena_out='1' then
            init_tx<='1';
            if estado_bit=MSB then
              dato_tx<=dato_out_reg;
            elsif estado_bit=LSB then
              dato_tx<=dato_out_reg(7) & dato_out_reg(6) & dato_out_reg(5) & dato_out_reg(4) & dato_out_reg(3) & dato_out_reg(2) & dato_out_reg(1) & dato_out_reg(0);
            end if;
          else 
            init_tx<='0';
          end if;
      end if;    
    end process;
    
  --CONTADOR DE DATOS DE COM_SPI
    process(clk, nRst)       
    begin
      if nRst = '0' then
        contador<= (others => '0');
        contador_multiplo<= (others => '0');
      
      elsif clk'event and clk = '1' then
        if init_rx='1'  then   
          contador <= (others => '0');
        elsif dato_ready='1' then
          contador <= contador+1;
          if contador_multiplo/=2 then 
            contador_multiplo<=contador_multiplo+1;
          else 
            contador_multiplo <= (others => '0');
          end if;
        end if;
      end if;
  end process;

end rtl;