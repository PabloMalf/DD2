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
    -- fin_tx:          buffer std_logic;   no lo usamos en ningun lado
     dato_tx:         buffer std_logic_vector(7 downto 0);
     --Registros
     dato_in_reg:     buffer std_logic_vector(7 downto 0);
     nWR:             buffer std_logic;                                 
     adr_reg:         buffer std_logic_vector(3 downto 0);  
     ena_in:          buffer std_logic;                    --Salida para registros que indica que el dato esta listo y sepuede escribir en el registro

    );
end entity;

architecture estructural of logica_spi is
  type t_estado_escritura is (streaming, single); --estados de lectura/escritura
  signal estado_escritura: t_estado;
  type t_estado_bit is (MSB, LSB); --estados de modos de bit mas significativo
  signal estado_bit: t_estado; 
  type t_orden_escritura is (ascendente, descendente ); --estados de asc/desc
  signal orden_escritura: t_orden_escritura;

  signal adr_com : std_logic_vector(15 downto 0); --direccion de 16 bits del adr que viene del com_spi
  signal adr_T1  : std_logic_vector(7 downto 0);
  signal contador: std_logic_vector (4 downto 0);
  --Explicacion contador multiplo: para las tramas single carrier la primera y segunda trama son address,
  --la sigiente es dato, y luego se vuelve a repetir, es decir cada 3.
  signal contador_multiplo : std_logic_vector (4 downto 0); --suma cada 3 de contador (para single carrier)
  signal adr_com_actual : std_logic_vector(15 downto 0); --direccion de 16 bits del adr que viene del com_spi
  
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
    elsif clk'event and clk = '1' then
      case estado_escritura is
        when streaming => 
           if adr_com_actual = X"0001" and dato_rx(7)='1' and estado_bit=MSB and dato_ready='1' then
              estado_escritura <= single;
            elsif adr_com_actual = X"0001" and dato_rx(0)='1' and estado_bit=LSB and dato_ready='1' then 
              estado_escritura <= single;
           end if;
        when single=>
            if adr_com = X"0001" and dato_rx(7)='0' and estado=MSB and dato_ready='1' then
              estado_escritura <= streaming;
            elsif adr_com= X"0001" and dato_rx(0)='0' and estado=LSB and dato_ready='1' then 
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
            if adr_com_actual = X"0000" and dato_rx(5)='1' and dato_rx(2)= '1' and dato_ready='1' then -- da igual que este en MSB o LSB dado que es palindromo y son iguales en los dos modos
              orden_escritura <= descendente;
            end if;

        when descendente => 
            if adr_com_actual = X"0000" and dato_rx(5)='0' and dato_rx(2)= '0' and dato_ready='1' then -- da igual que este en MSB o LSB dado que es palindromo y son iguales en los dos modos
              orden_escritura <= ascendente;
            end if;
        end case;

    end if ;
  end process;
  --Explicacion de reverse : segun internet es una funcion de std_logic_1164
  adr_T1<= dato_rx when contador=0  and estado_bit=MSB and data_ready='1'  else
           std_logic_vector(reverse(unsigned(dato_rx)))  when  contador=0  and estado_bit=LSB and data_ready='1' else
           dato_rx when contador_multiplo=0 and estado_bit=MSB and data_ready='1' else 
           std_logic_vector(reverse(unsigned(dato_rx))) when contador_multiplo=0 and estado_bit=LSB and data_ready='1'
           else X"00";
  adr_com<= adr_T1 & dato_rx when estado_escritura=streaming and contador=1 and estado_bit=MSB else  --convierte el adr en algo legible para Registros
            adr_T1 & std_logic_vector(reverse(unsigned(dato_rx))) when estado_escritura=streaming and contador=1 and estado_bit=LSB else 
            adr_T1 & dato_rx when contador_multiplo=1 and estado_bit=MSB else 
            adr_T1 & std_logic_vector(reverse(unsigned(dato_rx))) when contador_multiplo=1 and estado_bit=LSB
            else X"0000";  

    adr_com_actual<= adr_com + contador - 2 when orden_escritura=ascendente else -- address actual en caso de streaming dependiendo si es ascendente o descendente
                     adr_com - contador + 2 when orden_escritura=descendente else
                     X"0000";
  
  --- ESCRITURA/LECTURA DE REGISTROS
  process(clk, nRst)       
  begin
    if nRst = '0' then
      dato_in_reg<= (others => '0');
      nWR<= '1';
    elsif clk'event and clk = '1' then
      if estado=steaming and data_ready='1' and  adr_com(0)='0'  then   --CASO STREAMING ESCRITURA
          nWR<= '0';                                                    
          adr_reg<= adr_com_actual(5 downto 1);                     --Escribo la direccion y el dato para registro
          ena_in='1';
          if estado=MSB then 
            dato_in_reg<= dato_rx;
          else
            dato_in_reg<= std_logic_vector(reverse(unsigned(dato_rx)));
          end if;
      elsif estado=single and  contador_multiplo=1 and  data_ready='1' and  adr_com(0)='0 then --CASO SINGLE ESCRITURA
           nWR<= '0';
           ena_in='1';
           adr_reg<= adr_com_actual;
           if estado=MSB then 
            dato_in_reg<= dato_rx;
          else
            dato_in_reg<= std_logic_vector(reverse(unsigned(dato_rx)));
          end if;
      elsif data_ready='1' and  adr_com(0)='1'  then                       --CASO LECTURA  PARA REGISTROS
          nWR<= '1'; 
          adr_reg<= adr_com(5 downto 1); -- en este caso no hace falta igualarlo a adr_com_actual dado que da igual si es ascendente o descendente
      end if; 
  end process;
  
--- INFORMACION PARA COMUNICACION
    process(clk, nRst)
        if nRst='0' then
            init_tx<='0';

        elsif clk'event and clk='1' then
            if ena_out='1' then
              init_tx<='1';
              if estado_bit=MSB;
                dato_tx<=dato_out_reg;
              elsif estado_bit=LSB;
                dato_tx<=std_logic_vector(reverse(unsigned(dato_out_reg)));
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
  end process;

end rtl;