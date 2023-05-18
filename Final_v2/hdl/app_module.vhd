library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity app_module is
port(nRst:               in     std_logic;							-- Reset asíncrono
     clk:                in     std_logic;							-- 50 MHz

     -- Interfaz teclado:
     tic_tecla:          in     std_logic;							-- Indica que se ha pulsado un tecla en el teclado (debe tener 1 ciclo de reloj de duración)
     tecla:              in     std_logic_vector(3 downto 0);	    -- Código que identifica la tecla que ha sido pulsada

     -- Interfaz master:
     start:              buffer std_logic;    						-- Orden de ejecucion (hacia el master SPI)
     no_bytes:           buffer std_logic_vector(2 downto 0); 		-- Numero de bytes totales en la transferencia (incluyendo direccion) (hacia el master SPI)
     dato_wr:            buffer std_logic_vector(47 downto 0);	    -- dato de entrada (alineado a la izquierda) (hacia el master SPI)
     dato_rd:            in     std_logic_vector(7 downto 0); 	    -- valor del byte leido (desde el master SPI)
     ena_rd:             in     std_logic;   						-- valida a nivel alto a dato_rd  (desde el master SPI)           
     rdy:                in     std_logic;  						-- unidad preparada para aceptar start (desde el master SPI)        

     -- Status Master
     str_sgl_ins_master: in std_logic;	    						-- 0 -> modo streaming, 1 -> modo single instruction
     add_up_master:      in std_logic;                              -- 0 -> modo decremento de dirección, 1 -> modo incremento de direccion
	 MSB_1st_master:     in std_logic;							    -- 0 -> modo MSB First, 1 -> modo LSB First
	 mode_3_4_h_master:  in std_logic;
	 
	 -- Interfaz Slave
	 -- Status Slave 
     str_sgl_ins_slave:  in std_logic;	    						-- 0 -> modo streaming, 1 -> modo single instruction
     add_up_slave:       in std_logic;                              -- 0 -> modo decremento de dirección, 1 -> modo incremento de direccion
	 MSB_1st_slave:      in std_logic;							    -- 0 -> modo MSB First, 1 -> modo LSB First
	 mode_3_4_h_slave:   in std_logic;
	 
     -- Interfaz display:
     info_disp:          buffer std_logic_vector(2 downto 0);	    -- bits(1 downto 0) -> display que está siendo editado, bit(2) -> modo de edición de registros de configuracion (0) o de operacion (1)
     reg_tx:             buffer std_logic_vector(31 downto 0); 	    -- Información para los cuatro dígitos hexadecimales ( uno por display)
	 
	 -- Senales para modo chequeo
     mode_check:         buffer std_logic; -- '0' configuracion y transferencia, '1' chequeo
     check_ok:           buffer std_logic  -- '0' Master-Esclavo distinta configuración, '1' misma configuración
	 
	 );	    						
	 

end entity;

architecture rtl of app_module is
  type   t_estado is (reg_op_st, 
                      to_reg_op_st, 
                      reg_conf_st,
                      to_reg_conf_st);

  signal estado: t_estado;

  signal tx:           std_logic;
  signal rx:           std_logic;
  signal cambiar_modo: std_logic;
  signal shift:        std_logic;
  signal inc:          std_logic;
  signal dec:          std_logic;
  signal idx:          std_logic_vector(1 downto 0);
  
begin

 process(clk, nRst)
 begin
   if nRst = '0' then
      mode_check <= '0';
   elsif clk'event and clk='1' then
      if tecla=X"1" then
         mode_check <= '0';
			--reg_tx <= (others => '0');
	  elsif tecla=X"2" then
	     mode_check <= '1';
	  end if;
   end if;
   
 end process;
     
 
 -- Sentencias de control en modo de transferencias
 tx <= rdy and tic_tecla when estado = reg_op_st   and tecla = X"E" and mode_check='0'                                                                      else
       rdy and tic_tecla when estado = reg_conf_st and tecla = X"E" and (reg_tx(11 downto 8) /= 0) and mode_check='0'                                       else
       rdy and tic_tecla when estado = reg_conf_st and tecla = X"E" and (reg_tx(7 downto 4) = (reg_tx(0)&reg_tx(1)&reg_tx(2)&reg_tx(3))) and mode_check='0' else
       '0';

 rx <= rdy and tic_tecla when tecla = X"F" and mode_check='0' else
       '0';

 cambiar_modo <= tic_tecla when tecla = X"C" and mode_check='0' else
                 '0';

 shift <= tic_tecla when (estado = reg_op_st or estado = reg_conf_st) and tecla = X"D" and mode_check='0' else
          '0';

 inc   <= tic_tecla and rdy when (estado = reg_op_st or estado = reg_conf_st) and tecla = X"A" and mode_check='0' else
          '0';

 dec   <= tic_tecla and rdy when (estado = reg_op_st or estado = reg_conf_st) and tecla = X"B" and mode_check='0' else
          '0';
		  
 check_ok <= '1' when (str_sgl_ins_master = str_sgl_ins_slave and
                       MSB_1st_master     = MSB_1st_slave     and
                       mode_3_4_h_master  = mode_3_4_h_slave  and
                       add_up_master      = add_up_slave)     and mode_check = '1' else
                       '0';
		  
		  
  process(clk, nRst)
  begin
    if nRst = '0' then
      estado <= reg_op_st;
      start <= '0';
      no_bytes <="000";
      dato_wr <= (others => '0');
      reg_tx  <= (others => '0');
      idx <= "00";

    elsif clk'event and clk = '1' then
	 if mode_check = '0' then
      if shift = '1' then
        if info_disp(2) = '1' and idx = 2 then
          idx <= "00";

        else
          idx <= idx + 1;

        end if;

      elsif inc = '1' then
        case idx is
          when "00" => 
            reg_tx(3 downto 0) <= reg_tx(3 downto 0)+ 1; 

          when "01" => 
            reg_tx(7 downto 4) <= reg_tx(7 downto 4)+ 1;

          when "10" =>
            if info_disp(2) = '0' then  
              reg_tx(11 downto 8) <= reg_tx(11 downto 8)+ 1;

            else
              reg_tx(8) <= not reg_tx(8);

            end if;

          when "11" => 
            reg_tx(15 downto 12) <= reg_tx(15 downto 12)+ 1;

          when others => null;
        end case;

      elsif dec = '1' then
        case idx is
          when "00" => 
            reg_tx(3 downto 0) <= reg_tx(3 downto 0) - 1; 

          when "01" => 
            reg_tx(7 downto 4) <= reg_tx(7 downto 4) - 1;

          when "10" => 
            if info_disp(2) = '0' then  
              reg_tx(11 downto 8) <= reg_tx(11 downto 8) - 1;

            else
              reg_tx(8) <= not reg_tx(8);

            end if;

          when "11" => 
            reg_tx(15 downto 12) <= reg_tx(15 downto 12) - 1;

          when others => null;
        end case;

      elsif ena_rd = '1' then
        if info_disp(2) = '0' then  
          reg_tx(15 downto 0) <= reg_tx(7 downto 0) & dato_rd;

        else
          reg_tx(7 downto 0) <= dato_rd;              

        end if;


      else
        case estado is
          when reg_op_st =>
            if tx ='1' then
              idx <= "00";
              estado <= to_reg_op_st;
              start <= '1';
              if str_sgl_ins_master = '0' then
                no_bytes <= "100";
                if add_up_master = '1' then 
                  dato_wr(47 downto 16) <= X"0010"&reg_tx(15 downto 0);

                else
                  dato_wr(47 downto 16) <= X"0011"&reg_tx(15 downto 0);

                end if;

              else
                no_bytes <= "110";
                dato_wr  <= X"0010"&reg_tx(15 downto 8)& X"0011"&reg_tx(7 downto 0);

              end if;

            elsif rx = '1' then
              idx <= "00";
              estado <= to_reg_op_st;
              start <= '1';
              if str_sgl_ins_master = '0' then
                no_bytes <= "100";
                if add_up_master = '1' then 
                  dato_wr(47 downto 32) <= X"8010";

                else
                  dato_wr(47 downto 32) <= X"8011";

                end if;

              else
                no_bytes <= "110";
                dato_wr  <= X"8010"&X"00"&X"8011"&X"00";

              end if;

            elsif cambiar_modo = '1' then
              estado <= reg_conf_st;
              reg_tx  <= (others => '0');
              idx <= "00";

            end if;

          when to_reg_op_st =>
            start <= '0';
            estado <= reg_op_st;

          when reg_conf_st =>
            if tx = '1' then
              estado <= to_reg_conf_st;
              start  <= '1';
              no_bytes <= "011";
              dato_wr(47 downto 24) <= X"000"&reg_tx(11 downto 0);

            elsif rx = '1' then
              estado <= to_reg_conf_st;
              start <= '1';
              no_bytes <= "011";
              dato_wr(47 downto 32) <= X"800"&reg_tx(11 downto 8);

            elsif cambiar_modo = '1' then
              estado <= reg_op_st;
              reg_tx  <= (others => '0');
              idx <= "00";

            end if;

          when to_reg_conf_st =>
            start <= '0';
            estado <= reg_conf_st;

        end case;
      end if;
	  
	  else
	   if tecla=X"1" then
		  reg_tx <= (others => '0'); -- DISPLAYS A 0000
		  idx <= "00";
		  
      else
		
			if    mode_3_4_h_slave = '0' then
			  reg_tx(7 downto 0)   <= X"30"; -- "3H"
			
			else
			  reg_tx(7 downto 0)   <= X"40"; -- "4H"
			  
			end if;
			
			if MSB_1st_slave = '0'     then
			  reg_tx(15 downto 8)  <= X"12"; -- "ΠS"
			  
			else
			  reg_tx(15 downto 8)  <= X"32"; -- "LS"
			  
			end if;
			
			if add_up_slave = '0'      then
				 reg_tx(23 downto 16) <= X"4C"; -- "dC"
			  
			else
				 reg_tx(23 downto 16) <= X"5C"; -- "IC"
			
			end if;
			
			if str_sgl_ins_slave = '0' then
			  reg_tx(31 downto 24) <= X"26"; -- "St"
			
			else
			  reg_tx(31 downto 24) <= X"25"; -- "SI"
			
			end if;
		  end if;
	   end if;
    end if;
  end process;

  info_disp <= '0'&idx when estado = reg_op_st or estado = to_reg_op_st  else
               '1'&idx;

end rtl;