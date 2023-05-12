library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library modelsim_lib; -- spies
use modelsim_lib.util.all; 

library work;
use work.pack_test_spi.all;

entity test_top is
end entity;

architecture test of test_top is
  signal nRst:        std_logic;
  signal clk:         std_logic;

  signal MSB_1st:     std_logic;
  signal mode_3_4_h:  std_logic;
  signal str_sgl_ins: std_logic;
  signal add_up:      std_logic;

  signal SDIO:        std_logic;
  signal SDO:         std_logic;

  signal tic_tecla:   std_logic;
  signal tecla:       std_logic_vector(3 downto 0);

  signal seg:         std_logic_vector(7 downto 0);
  signal mux_disp:    std_logic_vector(3 downto 0); 

  signal nCS:      std_logic;
  signal info_disp: std_logic_vector(2 downto 0);
  signal reg_tx:    std_logic_vector(15 downto 0); 


  constant Tclk: time := 5 ns;

begin 
  process
  begin
    clk <= '0';
    wait for Tclk/2;
 
    clk <= '1';
    wait for Tclk/2;

  end process;

  dut: entity work.top_sim(estructural)

  port map(clk         => clk,
           nRst        => nRst,
           MSB_1st     => MSB_1st,
           mode_3_4_h  => mode_3_4_h,
           str_sgl_ins => str_sgl_ins,
           add_up      => add_up,
           SDIO_m      => SDIO,
           SDIO_s      => SDIO,
           SDO_m       => SDO,
           SDO_s       => SDO,
           seg         => seg,
           mux_disp    => mux_disp,
           tecla     => tecla,
           tecla_pulsada  => tic_tecla); 

process
begin

    -- Inicializacion de los spies 
    init_signal_spy("/test_top/dut/nCS", "/nCS");
    init_signal_spy("/test_top/dut/info_disp", "/info_disp");
    init_signal_spy("/test_top/dut/reg_tx", "/reg_tx");


  nRst <= '1';
  wait until clk'event and clk = '1';
  nRst <= '0';

-- CTRL_MS
  tic_tecla <= '0';
  tecla <= (others => '0');

  wait until clk'event and clk = '1';
  nRst <= '1';

  wait for 5* Tclk;
  wait until clk'event and clk = '1';
  
------------------------------------------------------------------------------------------
--------------STREAMING-------------------------------------------------------------------
------------------------------------------------------------------------------------------

--ESCRIBIR EN EL REGISTRO DE CONFIGURACION EN MODO 4 HILOS, ASCENDENTE, Y MSB-FIRST
report "Escribo en configuración 00 =ASCENDENTE, MSB-first, 4 hilos => X3C";
-- X"3C" => ASCENDENTE, 4 HILOS, MSB-FIRST
-- CONF
  add_up <= '1';
  MSB_1st <= '0';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '0';

-- CTRL_MS
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  editar_reg_conf (tic_tecla, tecla, info_disp, reg_tx, X"0", X"3C",clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

 -- ESCRIBIR EN LOS REGISTROS DE OPERACION ASCENDENTE 4 HILOS MSB-FIRST STREAMING
 report "Escribo en operacion  => Ascendente, MSB-first, 4 hilos => X1234";
                                            
-- CONF
  add_up <= '1';
  MSB_1st <= '0';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '0';

-- CTRL_MS
  set_modo_reg_op (tic_tecla, tecla, info_disp, clk);
  editar_reg_op (tic_tecla, tecla, info_disp, reg_tx, X"4321", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

--ESCRIBIR EN EL REGISTRO DE CONFIGURACION EN MODO 4 HILOS, ASCENDENTE, STREAMING Y LSB-FIRST
report "Escribo en configuración 00 ASCENDENTE, LSB-first, 4 hilos => X7E";

-- X"18" => DESCENSION, 4 HILOS, MSB-FIRST
-- CONF
  add_up <= '1';
  MSB_1st <= '1';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '0';

-- CTRL_MS
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  editar_reg_conf (tic_tecla, tecla, info_disp, reg_tx, X"0", X"7E", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

--ESCRIBIR EN LOS REGISTROS DE OPERACION: ASCENDENTE 4 HILOS LSB-FIRST STREAMING 
report "Escribo en operacion  => ASCENDENTE, LSB-first, 4 hilos => X9128";
                                           
-- CONF
  add_up <= '1';
  MSB_1st <= '1';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '0';

-- CTRL_MS
  set_modo_reg_op (tic_tecla, tecla, info_disp, clk);
  editar_reg_op (tic_tecla, tecla, info_disp, reg_tx, X"9128", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

--ESCRIBIR EN EL REGISTRO DE CONFIGURACION EN MODO 4 HILOS, DESCENDENTE, STREAMING Y MSB-FIRST
report "Escribo en configuración 00 DESCENDENTE, MSB-first, 4 hilos => X18";
-- X"18" => DESCENDENTE, 4 HILOS, MSB-FIRST
                                             
-- CONF
  add_up <= '0';
  MSB_1st <= '0';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '0';

-- CTRL_MS
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  editar_reg_conf (tic_tecla, tecla, info_disp, reg_tx, X"0", X"18", clk); 
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer
  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
--
 --Escritura de los 2 registros de op -- MODO 4 HILOS, DESCENDENTE, STREAMING Y MSB-FIRST -> 
  report "Escribo en operacion => DESCENDENTE, MSB-first, 4 hilos => X9A2C";
 
-- ESCRIBIR EN LOS REGISTROS DE OPERACION ASCENSION 4 HILOS MSB-FIRST STREAMING                                             
-- CONF
  add_up <= '0';
  MSB_1st <= '0';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '0';

-- CTRL_MS
  set_modo_reg_op (tic_tecla, tecla, info_disp, clk);
  editar_reg_op (tic_tecla, tecla, info_disp, reg_tx, X"9A2C", clk); --- CON 1234 FUNCIONA BIEN
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
--
-- ESCRIBIR EN EL REGISTRO DE CONFIGURACION 00 PARA MODO DESCENDENTE,LSB- FIRST, 4HILOS
-- X"5A" => DESCENDENTE, 4 HILOS, LSB-FIRST
-- CONF
  add_up <= '0';
  MSB_1st <= '1';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '0';
-- CTRL_MS
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  editar_reg_conf (tic_tecla, tecla, info_disp, reg_tx, X"0", X"5A", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
--
-- ESCRIBIR EN LOS REGISTROS DE OPERACION DESCENSION 4 HILOS LSB-FIRST STREAMING                                             
-- CONF
  add_up <= '0';
  MSB_1st <= '1';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '0';

-- CTRL_MS
  set_modo_reg_op (tic_tecla, tecla, info_disp, clk);
  editar_reg_op (tic_tecla, tecla, info_disp, reg_tx, X"DEF1", clk); 
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

--------------------------------------------------------------------------------------------
-------------------------SINGLE-------------------------------------------------------------
--------------------------------------------------------------------------------------------

--ESCRIBIR EN EL REGISTRO DE CONFIGURACION EN MODO 4 HILOS, ASCENSION, 4 HILOS Y MSB-FIRST
report "Escribo en configuración 00 => Ascendente, MSB-first, 4 hilos => X3C";
-- X"3C" => ASCENSION, 4 HILOS, MSB-FIRST

-- CONF
  add_up <= '1';
  MSB_1st <= '0';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '0';

-- CTRL_MS
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  editar_reg_conf (tic_tecla, tecla, info_disp, reg_tx, X"0", X"3C", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

--ESCRIBIR EN EL REGISTRO DE CONFIGURACION 01 PARA MODO SINGLE INSTRUCCTION
report "Escribo en configuración 01 =>SINGLE => X80";

-- CONF
  add_up <= '1';
  MSB_1st <= '0';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '1';

-- CTRL_MS
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  editar_reg_conf (tic_tecla, tecla, info_disp, reg_tx, X"1", X"80", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- ESCRIBIR EN LOS REGISTROS DE OPERACION ASCENSION 4 HILOS MSB-FIRST SINGLE                                           
-- CONF
  add_up <= '1';
  MSB_1st <= '0';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '1';

-- CTRL_MS
  set_modo_reg_op (tic_tecla, tecla, info_disp, clk);
  editar_reg_op (tic_tecla, tecla, info_disp, reg_tx, X"2345", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- Escribo en configuración 00 = >ASCENDENTE, MSB-first, 4 hilos => X18
--ESCRIBIR EN EL REGISTRO DE CONFIGURACION EN MODO 4 HILOS, ASCENDENTE, SINGLE Y MSB-FIRST
report "Escribo en configuración 00 =ASCENDENTE, MSB-first, 4 hilos => X5A";

-- X"18" => DESCENSION, 4 HILOS, MSB-FIRST
-- CONF
  add_up <= '1';
  MSB_1st <= '1';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '1';

-- CTRL_MS
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  editar_reg_conf (tic_tecla, tecla, info_disp, reg_tx, X"0", X"7E", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

 -- ESCRIBIR EN LOS REGISTROS DE OPERACION ASCENSION 4 HILOS MSB-FIRST SINGLE 
report "Escribo en operacion  => Ascendente, MSB-first, 4 hilos => X6789";
                                           
-- CONF
  add_up <= '1';
  MSB_1st <= '1';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '1';

-- CTRL_MS
  set_modo_reg_op (tic_tecla, tecla, info_disp, clk);
  editar_reg_op (tic_tecla, tecla, info_disp, reg_tx, X"6789", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';


--ESCRIBIR EN EL REGISTRO DE CONFIGURACION EN MODO 4 HILOS, DESCENDENTE, STREAMING Y MSB-FIRST
report "Escribo en configuración 00 =DESCENDENTE, LSB-first, 4 hilos => X18";
-- X"7E" => ASCENSION, 4 HILOS, LSB-FIRST
                                             
-- CONF
  add_up <= '1';
  MSB_1st <= '0';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '1';

-- CTRL_MS
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  editar_reg_conf (tic_tecla, tecla, info_disp, reg_tx, X"0", X"18", clk); 
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';


-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer
  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

 --Escritura de los 2 registros de op --ASCENSION, MODO 4 HILOS, ASCENSION, SINGLE Y MSB-FIRST -> 
  report "Escribo en operacion => Ascendente, MSB-first, 4 hilos => XABCD";
 
-- ESCRIBIR EN LOS REGISTROS DE OPERACION ASCENSION 4 HILOS LSB-FIRST STREAMING                                             
-- CONF
  add_up <= '1';
  MSB_1st <= '0';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '1';

-- CTRL_MS
  set_modo_reg_op (tic_tecla, tecla, info_disp, clk);
  editar_reg_op (tic_tecla, tecla, info_disp, reg_tx, X"ABCD", clk); 
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- ESCRIBIR EN EL REGISTRO DE CONFIGURACION 00 PARA MODO DESCENSION,LSB- FIRST, 4HILOS
-- X"5A" => DESCENSION, 4 HILOS, LSB-FIRST
-- CONF
  add_up <= '0';
  MSB_1st <= '1';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '1';
-- CTRL_MS
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  editar_reg_conf (tic_tecla, tecla, info_disp, reg_tx, X"0", X"5A", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
--
-- ESCRIBIR EN LOS REGISTROS DE OPERACION DESCENSION 4 HILOS LSB-FIRST STREAMING                                             
-- CONF
  add_up <= '0';
  MSB_1st <= '1';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '1';

-- CTRL_MS
  set_modo_reg_op (tic_tecla, tecla, info_disp, clk);
  editar_reg_op (tic_tecla, tecla, info_disp, reg_tx, X"EF12", clk); 
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer

  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

  assert false
  report "Fin del test"
  severity failure;

end process;
end test;
