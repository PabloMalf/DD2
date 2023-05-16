
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity com_spi is
port(clk:             in     std_logic;
     nRst:            in     std_logic; 
     --Señales de master
     SDI           : inout std_logic;                          -- Linea SDI
     SDO           : buffer std_logic;                      -- Linea SDO
     nCS           : in std_logic;                          -- Linea Chip Select
     clk_in        : in std_logic;                          -- Linea CLK
     
     --Chequeo de consistencia
     str_sgl_ins_slave: buffer std_logic;
     add_up_slave:    buffer std_logic;
     MSB_1st_slave:   buffer std_logic;
     modo_3_4_hilos:  buffer     std_logic;
     --ENTRADAS Registros
     ena_out:         in     std_logic;                     --Entrada de registros que indica que el dato esta listo y se puede leer
     dato_out_reg:    in     std_logic_vector(7 downto 0);
     --SALIDAS Registros
     dato_in_reg:     buffer std_logic_vector(7 downto 0);
     nWR:             buffer std_logic;  --0 escribir 1 leer                                
     adr_reg:         buffer std_logic_vector(4 downto 0);  
     ena_in:          buffer std_logic                    --Salida para registros que indica que el dato esta listo y sepuede escribir en el registro

    );
end entity;


architecture rtl of com_spi is
  type t_estado is (espera_cs, escritura_registro, lectura_registro, pillo_adr, escritura_SDO); --estados de lectura_registro/escritura_registro
  signal estado: t_estado;

-- señales auxiliares
  signal sclk_T1: std_logic;                         -- registro sclk
  signal reg_clk: std_logic;                         -- clk_spi limpio
  
  signal cs_T1: std_logic;                           -- registro cs
  signal reg_cs: std_logic;                          -- cs limpio
  
  signal SDI_T1: std_logic;                          -- registro SDI
  signal reg_SDI: std_logic;                         -- SDI limpio
  signal cnt_rcv_bit: std_logic_vector (4 downto 0); -- numero de bits que se van recibiendo
  signal cnt_dato: std_logic_vector (3 downto 0); -- numero de bits que se van recibiendo

  signal flanco_subida_clk_in: std_logic;
  signal flanco_bajada_clk_in : std_logic;

  
  signal reg_adr: std_logic_vector(15 downto 0);  
  signal reg_dato_in: std_logic_vector(7 downto 0); 
  
  signal cnt_send_bit: std_logic_vector(3 downto 0); -- numero de bits que se han enviado
  signal reg_dato_out: std_logic_vector(7 downto 0); -- guarda el valor de dato_tx
  signal SDO_no_Z: std_logic;
  
  signal prev_reg_clk: std_logic;

begin
  -- doble flip-flop
  process(nRst, clk)
  begin
    if nRst = '0' then
      sclk_T1 <= '0';
      reg_clk <= '0';
      
      cs_T1 <= '1';
      reg_cs <= '1';
      
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
   
  process(clk, nRst)       
  begin
    if nRst = '0' then
      estado<= espera_cs;

      str_sgl_ins_slave<='0';
      add_up_slave<='0';
      MSB_1st_slave<='0';
      modo_3_4_hilos<='1';

    elsif clk'event and clk = '1' then
        if reg_cs='1' then 
          estado <= espera_cs;
        end if;
       case estado is
        when espera_cs => 
          if reg_cs='0' then
            estado <= pillo_adr;
          end if;
        when pillo_adr=>
            if cnt_rcv_bit=16 and nWR='0' then
              estado <= escritura_registro;
            elsif cnt_rcv_bit=16 and nWR='1' then 
              estado <= lectura_registro;
           end if;
        when escritura_registro=>
           if cnt_dato=8  then
            ena_in<='1';
            adr_reg<=reg_adr(4 downto 0);
              --CONROL DE ESCRITURA
              --MSB//LSB
              if reg_adr=X"0000" and reg_dato_in(6)='1' and reg_dato_in(1)= '1'    then
                MSB_1st_slave<='1';
              elsif reg_adr=X"0000" and reg_dato_in(6)='0' and reg_dato_in(1)= '0' then
                 MSB_1st_slave<='0';
              end if;
              --Ascendente/Descendente
              if reg_adr=X"0000" and reg_dato_in(5)='1' and reg_dato_in(2)= '1'    then
                add_up_slave<='1';
              elsif reg_adr=X"0000" and reg_dato_in(5)='0' and reg_dato_in(2)= '0' then
                 add_up_slave<='0';
              end if;
              --Streaming/single 
              if reg_adr=X"0001" and reg_dato_in(7)='1'    then
                str_sgl_ins_slave<='1';
              elsif reg_adr=X"0001" and reg_dato_in(6)='0' then
                 str_sgl_ins_slave<='0';
              end if;
              
              --ESTADOS
              
              if str_sgl_ins_slave='1' then 
                estado <= pillo_adr;
              
              end if;
           else 
             ena_in<='0';
           end if;
           
        when lectura_registro=> 
          if ena_out='0' then 
            ena_in<='1';
            adr_reg<=reg_adr(4 downto 0);
          elsif ena_out='1' then 
              estado <= escritura_SDO;
           end if; 
           
        when escritura_SDO=>    
          
          if cnt_send_bit = 7 and str_sgl_ins_slave = '0' then
            estado<=lectura_registro;
          elsif cnt_send_bit = 7 and str_sgl_ins_slave = '1' then
            estado<=lectura_registro;
          end if;  
          
      end case;  
    end if ;
  end process;
  --RECEPCION DEL ADR
    -- se encarga de leer la linea sdi y almacenar los bits en reg_adr
  process(nRst,clk)
  begin
    if nRst = '0' then
      reg_adr <= (others => '0');
      cnt_rcv_bit <= (others => '0');

    elsif clk'event and clk = '1' then
      if estado=pillo_adr then 
        if cnt_rcv_bit = 16 then
            cnt_rcv_bit <= (others => '0');
                
        end if;                     
        if flanco_subida_clk_in = '1'  then                             -- Hay que recoger el valor de la linea SDI
          if MSB_1st_slave='0' then
            reg_adr <= reg_adr(14 downto 0) & reg_SDI;
          else
            reg_adr <=  reg_SDI & reg_adr(14 downto 0) ;
          end if;
          
          if cnt_rcv_bit < 16 then
            cnt_rcv_bit <= cnt_rcv_bit + 1;
        
          end if; 
        end if;
       elsif estado=espera_cs then
        cnt_rcv_bit <= (others => '0');
        reg_adr <= (others => '0');
      end if;
       if (estado = escritura_registro and cnt_dato = 8) or (estado = lectura_registro and cnt_send_bit = 8)then
        if add_up_slave='0' then
          reg_adr<=reg_adr-1;
        elsif add_up_slave='1' then
          reg_adr<=reg_adr+1;
       end if;
     end if;
    end if;
  end process;

  nWR <= reg_adr(15);
  
  --PILLA UN DATO 
  -- se encarga de leer la linea sdi y almacenar los bits en reg_dato_in
  process(nRst,clk)
  begin
    if nRst = '0' then
      reg_dato_in <= (others => '0');
      cnt_dato <= (0=>'1', others => '0');  


    elsif clk'event and clk = '1' then
      if estado=escritura_registro then     
        if cnt_dato = 8 then
        cnt_dato <= (0=>'1', others => '0');                            -- Se detecta un nivel bajo en la linea de cs: El master va a enviar datos
        elsif flanco_subida_clk_in = '1'  then
          if MSB_1st_slave='0' then
            reg_dato_in <= reg_dato_in(6 downto 0) & reg_SDI;
          else
            reg_dato_in <=  reg_SDI & reg_dato_in(6 downto 0) ;
          end if; 
          if cnt_dato < 8 then
            cnt_dato <= cnt_dato + 1;

          end if; 
        end if;
       elsif estado=espera_cs then
        cnt_dato <= (0=>'1', others => '0');  
      end if;
    end if;
  end process;
  --ESCRIBE EN LINEA SDO
  process(nRst,clk)
  begin
    if nRst = '0' then
      reg_dato_out <= (others => '0');
      cnt_send_bit <= (others => '0');
      SDO_no_Z <= '0';
  
    elsif clk'event and clk = '1' then
      if estado=escritura_SDO  then
        if flanco_bajada_clk_in= '1'  then
          if MSB_1st_slave='0' then 
            reg_dato_out <= reg_dato_out(6 downto 0) & '0';
            SDO_no_Z <= reg_dato_out(7);
          else
            reg_dato_out <= '0' & reg_dato_out(6 downto 0) ;
            SDO_no_Z <= reg_dato_out(0);
          end if;
          if cnt_send_bit < 7  then
            cnt_send_bit <= cnt_send_bit + 1;
          elsif cnt_send_bit = 7  then
            cnt_send_bit<= (others =>'0');
          end if;
        end if;
    end if;
    end if;
  end process;
   
 SDI <= 'Z' when cnt_send_bit=0 
        else SDO_no_Z when modo_3_4_hilos = '0' 
        else 'Z';
  
  SDO <= 'Z' when reg_SDI /= 'Z' or reg_cs /= '0' or cnt_send_bit= 0 
         else SDO_no_Z when flanco_bajada_clk_in = '1' and modo_3_4_hilos /= '0'
         else SDO when modo_3_4_hilos = '1' 
         else 'Z';

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
  flanco_bajada_clk_in <= '1' when reg_clk /= prev_reg_clk and reg_clk = '0' else '0';
end rtl;