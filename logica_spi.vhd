library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity interfaz_i2c is
port(clk:             in     std_logic;
     nRst:            in     std_logic; 
     --ENTRADAS
     --Com_SPI
     init_rx:         in     std_logic;
     fin_rx:          in     std_logic;   
     dato_rx:         in     std_logic_vector(7 downto 0);
     dato_ready:      in     std_logic;                            --1 ciclo de reloj??
     --Registros
     dato_out_reg:    in     std_logic_vector(7 downto 0);
     --SALIDAS
     --Com_SPI
     init_tx:         buffer std_logic;
     fin_tx:          buffer std_logic;   
     dato_tx:         buffer std_logic_vector(7 downto 0);
     --Registros
     dato_in_reg:     buffer std_logic_vector(7 downto 0);
     nWR:             buffer std_logic;                                 
     adr_reg:         buffer std_logic_vector(3 downto 0);              

    );
end entity;

architecture estructural of interfaz_i2c is
  type t_estado_escritura is (streaming, single); --estados de lectura/escritura
  signal estado_escritura: t_estado;
  type t_estado_bit is (MSB, LSB); --estados de modos de bit mas significativo
  signal estado_bit: t_estado; 
  
  signal adr_com : std_logic_vector(15 downto 0); --direccion de 16 bits del adr que viene del com_spi
  signal adr_T1  : std_logic_vector(7 downto 0);
  signal contador: std_logic_vector (4 downto 0);
  --Explicacion contador multiplo: para las tramas single carrier la primera y segunda trama son address,
  --la sigiente es dato, y luego se vuelve a repetir, es decir cada 3.
  signal contador_multiplo : std_logic_vector (4 downto 0); --suma cada 3 de contador (para single carrier)
begin
  --PREGUNTAS PROFE:
        --Se puede usar la funcion reverse????
        
  

  ---ESTADO DEL AUTOMATA DE STREAMING/SINGLE-... y el de LSB/MSB
  process(clk, nRst)       
  begin
    if nRst = '0' then
      estado_escritura<= streaming;
      estado_bit<=MSB;
    elsif clk'event and clk = '1' then
      case estado_escritura is
        when streaming => 
           if (adr_com+ contador - 2) = X"0001" and dato_rx(7)='1' and estado=MSB then
              estado <= single;
            elsif (adr_com+ contador - 2) = X"0001" and dato_rx(0)='1' and estado=LSB then 
              estado <= single;
           end if;
        when single=>
            if adr_com = X"0001" and dato_rx(7)='0' and estado=MSB then
              estado <= streaming;
            elsif adr_com= X"0001" and dato_rx(0)='0' and estado=LSB then 
              estado <= streaming;
           end if;
      end case;
      
    end if ;
  end process;
  --Explicacion de reverse : segun internet es una funcion de std_logic_1164
  adr_T1<= dato_rx when init_rx='1' and contador=0  and estado_bit=MSB
           std_logic_vector(reverse(unsigned(dato_rx))) when init_rx='1' and contador=0  and estado_bit=LSB
           dato_rx when contador_multiplo=0 and estado_bit=MSB else 
           std_logic_vector(reverse(unsigned(dato_rx))) when contador_multiplo=0 and estado_bit=LSB
           else X"00";
  adr_com<= adr_T1 & dato_rx when estado_escritura=streaming and contador=1 and estado_bit=MSB else  --convierte el adr en algo legible para Registros
            adr_T1 & std_logic_vector(reverse(unsigned(dato_rx))) when estado_escritura=streaming and contador=1 and estado_bit=LSB else 
            adr_T1 & dato_rx when contador_multiplo=1 and estado_bit=MSB else 
            adr_T1 & std_logic_vector(reverse(unsigned(dato_rx))) when contador_multiplo=1 and estado_bit=LSB
            else X"0000";  
  
  --- ESCRITURA/LECTURA DE REGISTROS
  process(clk, nRst)       
  begin
    if nRst = '0' then
      dato_in_reg<= (others => '0');
      nWR<= '1';
    elsif clk'event and clk = '1' then
      if estado=steaming and data_ready='1' and  adr_com(0)='0'  then   --CASO STREAMING ESCRITURA
          nWR<= '0';                                                    
          adr_reg<= adr_com(5 downto 1)+ contador - 2;                     --Escribo la direccion y el dato para registro
          if estado=MSB then 
            dato_in_reg<= dato_rx;
          else
            dato_in_reg<= std_logic_vector(reverse(unsigned(dato_rx)));
          end if;
      elsif estado=single and  contador_multiplo=1 and  data_ready='1' and  adr_com(0)='0 then --CASO SINGLE ESCRITURA
           nWR<= '0';
           adr_reg<= adr_com;
           if estado=MSB then 
            dato_in_reg<= dato_rx;
          else
            dato_in_reg<= std_logic_vector(reverse(unsigned(dato_rx)));
          end if;
      elsif data_ready='1' and  adr_com(0)='1'  then                       --CASO LECTURA  PARA REGISTROS
          nWR<= '1'; 
          adr_reg<= adr_com(5 downto 1);
      end if; 
  end process;
  
  
  --CONTADOR DE DATOS DE COM_SPI
    process(clk, nRst)       
    begin
    if nRst = '0' then
      contador<= (others => '0');
      contador_multiplo<= (others => '0');
      
    elsif clk'event and clk = '1' then
      if init_tx='1'  then   
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