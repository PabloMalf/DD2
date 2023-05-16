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
  signal mux_disp:    std_logic_vector(7 downto 0); 

  signal nCS:      std_logic;
  signal info_disp: std_logic_vector(2 downto 0);
  signal reg_tx:    std_logic_vector(31 downto 0); 

 -- signal tecla_pulsada
  constant Tclk: time := 20 ns;

begin 
  process
  begin
    clk <= '0';
    wait for Tclk/2;
 
    clk <= '1';
    wait for Tclk/2;

  end process;

dut: entity work.top_sim(estructural)
--     generic map (fdc_timer_2_5ms => 2, fdc_timer_0_5s => 8)

     port map(clk         => clk,
              nRst        => nRst,
              MSB_1st_master     => MSB_1st,
              mode_3_4_h_master  => mode_3_4_h,
              str_sgl_ins_master => str_sgl_ins,
              add_up_master      => add_up,
              SDIO_m      => SDIO,
              SDIO_s      => SDIO,
              SDO_m       => SDO,
              SDO_s       => SDO,
              seg         => seg,
              mux_disp    => mux_disp,
              tecla => tecla,
              tecla_pulsada => tic_tecla); 

process
begin
    report "Copia de nCS y nCSB";
    init_signal_spy("/test_top/dut/nCSB", "/nCS");
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
  
-- CONF
  add_up <= '0';
  MSB_1st <= '0';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '0';
  report "MASTER EN MODO DESCENDENTE, MSB, 4H, STREAMING";

-------- PRUEBA 1: se cargan los datos AAAA en los registros de operacion, y despues se leen. --------------------------------
-------  INTERES: comprobar que los bits se leen correctamente y se escriben adecuadamente.
  report "*****************INICIO PRUEBA 1*****************";
-- CTRL_MS
  set_modo_reg_op (tic_tecla, tecla, info_disp, clk);
  editar_reg_op (tic_tecla, tecla, info_disp, reg_tx, X"AAAA", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir
  report "Escritura de los 2 registros de op -> AAAA";
    
  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
  
-- CTRL_MS
  pulsar(tic_tecla, tecla, X"F" , clk);  --Leer 
  
  -- Lectura de los 2 registros de op -> *
  report "Lectura de los 2 registros de op -> AAAA";
  
  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
  report "*****************FIN PRUEBA 1*****************";
  
  assert reg_tx(15 downto 0) = X"AAAA"
  report "PRUEBA 1 NO SUPERADA: VALOR INCORRECTO EN REGISTROS"
  severity failure;
  
--------------------------------------------------------  FIN PRUEBA 1 -------------------------------------------------------- 

-------- PRUEBA 2: se cargan los datos 1234 en los registros de operacion, despues se leen y despues se cambia al modo configuracion 
--                 de registros (sin cambiar datos), se vuelve al modo de registros de operacion y se vuelven a leer
-------- INTERES: comprobar que cada dato va a al registro correspondiente, y que los datos se mantienen
  report "*****************INICIO PRUEBA 2*****************";
-- CONF
  add_up <= '0';
  MSB_1st <= '0';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '0';
  report "MASTER EN MODO DESCENDENTE, MSB, 4H, STREAMING";
    
  -- CTRL_MS
  set_modo_reg_op (tic_tecla, tecla, info_disp, clk);
  editar_reg_op (tic_tecla, tecla, info_disp, reg_tx, X"1234", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir
  report "Escritura de los 2 registros de op -> 1234";
  
  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
  
  -- LECTURA
  set_modo_reg_op(tic_tecla, tecla, info_disp, clk);
  pulsar(tic_tecla, tecla, X"F" , clk);  --leer
  report "[Tecla F]: Primera lectura de los 2 registros de operacion -> 1234";
  
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  editar_reg_conf (tic_tecla, tecla, info_disp, reg_tx, X"0", X"18", clk);    -- Configuracion a 4 hilos (por defecto)
  set_modo_reg_op (tic_tecla, tecla, info_disp, clk);
  pulsar(tic_tecla, tecla, X"F" , clk);  --leer
  report "[Tecla F]: Segunda lectura de los 2 registros de operacion -> 1234";

   
  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
  
  assert reg_tx(15 downto 0) = X"1234"
  report "PRUEBA 2 NO SUPERADA: La segunda lectura no se corresponde con el valor 1234"
  severity failure;
  
  report "*****************FIN PRUEBA 2*****************";
--------------------------------------------------------  FIN PRUEBA 2 -------------------------------------------------------- 
  
------ PRUEBA 3: se cambia al modo ascendente, se leen los registros de configuracion, se carga un dato en los registros de operacion y se lee
------ INTERES: verificar el funcionamiento del modo ascendente + msb + streaming + 4 hilos
  report "*****************INICIO PRUEBA 3*****************";
  -- CONF
  add_up      <= '0';
  MSB_1st     <= '0';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '0';
  report "MASTER EN MODO DESCENDENTE, MSB, 4H, STREAMING";
  
-- CTRL_MS
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  editar_reg_conf (tic_tecla, tecla, info_disp, reg_tx, X"0", X"3C", clk);    -- X24 (ascendente) + X18 (4 hilos) = X3C
--  editar_reg_conf (tic_tecla, tecla, info_disp, reg_tx, X"0", X"0F", clk);    -- X24 (ascendente) + X18 (4 hilos) = X3C
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir
  report "[Tecla E]: Escritura de registro 0 (configuracion) -> X3C: ESTADO ASCENDENTE";
  
  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';

  -- CONF
  add_up <= '1';
  MSB_1st <= '0';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '0';
  report "MASTER EN MODO ASCENDENTE, MSB, 4H, STREAMING";
  
  pulsar(tic_tecla, tecla, X"A" , clk);  --forzar que reg_tx cambie
  
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  pulsar(tic_tecla, tecla, X"F" , clk);  --leer
  report "[Tecla F]: Lectura de los registros de conf -> 003C";
  
  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
  
  assert reg_tx(15 downto 0) = X"003C"
  report "PRUEBA 3 NO SUPERADA: No se ha detectado el valor correcto en el registro de configuracion"
  severity failure;
  
  -- CAMBIO A LOS REGISTROS DE OPERACION, CARGO UN DATO Y LEO
  set_modo_reg_op(tic_tecla, tecla, info_disp, clk);
  editar_reg_op (tic_tecla, tecla, info_disp, reg_tx, X"5678", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  -- escribir
  report "[Tecla E]: Escritura de los 2 registros de operacion -> 5678";
  
  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
  
  set_modo_reg_op (tic_tecla, tecla, info_disp, clk);
  editar_reg_op (tic_tecla, tecla, info_disp, reg_tx, X"5678", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir
  report "[Tecla E]: Escritura de los 2 registros de op -> 5678";
  
  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
  
  set_modo_reg_op (tic_tecla, tecla, info_disp, clk);
  pulsar(tic_tecla, tecla, X"F" , clk);  --leer
  report "[Tecla F]: Lectura de los 2 registros de operacion -> 5678";
   
  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
  
  assert reg_tx(15 downto 0) = X"5678"
  report "PRUEBA 3 NO SUPERADA: La lectura de los registros de operacion no se corresponde con el valor 5678"
  severity failure;
  
  report "*****************FIN PRUEBA 3*****************";
--------------------------------------------------------  FIN PRUEBA 3 -------------------------------------------------------- 

--- PRUEBA 4: se mantiene el modo ascendente, se carga un dato no valido en los registros de configuracion, se leen los registros de configuracion,
---           se cambia a los registros de operacion, se leen los registros de operacion.
--- INTERES: Verificar que el esclavo es consistente ante datos no validos en registros de configuracion.
  report "*****************INICIO PRUEBA 4*****************";
  -- CONF
  add_up <= '1';
  MSB_1st <= '0';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '0';
  report "MASTER EN MODO ASCENDENTE, MSB, 4H, STREAMING";
  
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  editar_reg_conf (tic_tecla, tecla, info_disp, reg_tx, X"0", X"0F", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir
  report "Se ha enviado un dato no valido al registro 0";
  
--  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
  
  pulsar(tic_tecla, tecla, X"A" , clk);  --forzar que reg_tx cambie
  
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  pulsar(tic_tecla, tecla, X"F" , clk);  --leer
  report "[Tecla F]: Lectura de los registros de conf -> 000F";
  
  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
  
  assert (reg_tx(15 downto 0) /= X"000F" and reg_tx(15 downto 0) = X"003C") -- Ultimo valor valido
  report "PRUEBA 4 NO SUPERADA: No se ha detectado el valor correcto en el registro de configuracion"
  severity failure;
  
 -- CTRL_MS
  set_modo_reg_op (tic_tecla, tecla, info_disp, clk);
  editar_reg_op (tic_tecla, tecla, info_disp, reg_tx, X"9ABC", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir
  report "[Tecla E]: Escritura de los 2 registros de op -> 9ABC";
  
  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
  
  pulsar(tic_tecla, tecla, X"F" , clk);  --leer
  report "[Tecla F]: Lectura de los 2 registros de op -> 9ABC";
  
  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
  
  assert reg_tx(15 downto 0) = X"9ABC"
  report "PRUEBA 4 NO SUPERADA: No se ha detectado el valor correcto en los registros de operacion"
  severity failure;
 
  report "*****************FIN PRUEBA 4*****************";
---- Pregunta: Ahora mismo el esclavo solo guarda datos en el registro 0 si es un dato valido, pero esto deberia ser asi, o se deberia de guardar?
--------------------------------------------------------  FIN PRUEBA 4 -------------------------------------------------------- 

---- Prueba 5: Se cambia al modo LSB y se editan los registros de configuracion (con un dato no valido) y de operacion. Despues se lee, primero configuracion
----           y despues operacion.
---- INTERES: Verificar funcionamiento de esta configuracion
  report "*****************INICIO PRUEBA 5*****************";
  
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  editar_reg_conf (tic_tecla, tecla, info_disp, reg_tx, X"0", X"7E", clk); -- Si se pone 42 se configura en LSB pero se pone en descendente y 3 hilos. X7E = X42 (LSB) + X24 (ascendente) + X18 (4 hilos)
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir
  report "[Tecla E]: Escritura de registro 0 (configuracion) -> X7E: ESTADO LSB, ASCENDENTE, 4H";
  
  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
                                    ---- ESCRITURA ----
  -- CONFIGURACION: MODO LSB, ASCENDENTE Y STREAMING
  add_up <= '1';
  MSB_1st <= '1';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '0';
  report "MASTER EN MODO ASCENDENTE, LSB, 4H, STREAMING";
  
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  editar_reg_conf (tic_tecla, tecla, info_disp, reg_tx, X"0", X"F0", clk);  -- Dato no valido
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir
  report "[Prueba 5]: Dato no valido en el registro de configuracion 0";
  
--  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
   
  -- CTRL_MS
  set_modo_reg_op (tic_tecla, tecla, info_disp, clk);
  editar_reg_op (tic_tecla, tecla, info_disp, reg_tx, X"F012", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir
  report "[Tecla E]: Escritura de registros de operacion -> F012";
  
  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
                                  ---- LECTURA ----
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  pulsar(tic_tecla, tecla, X"F" , clk);  --leer
  report "[Tecla F]: Lectura de los 2 registros de conf -> 007E";
  
  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
  
  assert (reg_tx(15 downto 0) /= X"00F0" and reg_tx(15 downto 0) = X"007E") -- Ultimo valor valido
  report "PRUEBA 5 NO SUPERADA: No se ha detectado el valor correcto en el registro de configuracion"
  severity failure;
  
  set_modo_reg_op (tic_tecla, tecla, info_disp, clk);
  pulsar(tic_tecla, tecla, X"F" , clk);  --leer
  report "[Tecla F]: Lectura de los 2 registros de op -> F012";
  
  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
  
  assert reg_tx(15 downto 0) = X"F012"
  report "PRUEBA 5 NO SUPERADA: No se ha detectado el valor correcto en los registros de operacion"
  severity failure;
  report "*****************FIN PRUEBA 5*****************";
--------------------------------------------------------  FIN PRUEBA 5 -------------------------------------------------------- 

---- Prueba 6: Se cambia al modo single y se editan los registros de configuracion (con un dato no valido) y de operacion. Despues se lee, primero 
----           configuracion y despues operacion.
---- INTERES: Verificar funcionamiento de esta configuracion
  report "*****************INICIO PRUEBA 6*****************";
  
  -- CONF
  add_up <= '1';
  MSB_1st <= '1';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '0';
  report "MASTER EN MODO ASCENDENTE, LSB, 4H, STREAMING";
  
  -- CTRL_MS
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  editar_reg_conf (tic_tecla, tecla, info_disp, reg_tx, X"1", X"80", clk); 
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir
  report "[Tecla E]: Escritura de registro 1 de configuracion -> X80: ESTADO SINGLE";
  
  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
  
  add_up <= '1';
  MSB_1st <= '1';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '1';
  report "MASTER EN MODO ASCENDENTE, LSB, 4H, SINGLE";
  
                        ---- ESCRITURA -----
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  editar_reg_conf (tic_tecla, tecla, info_disp, reg_tx, X"0", X"F0", clk);  -- Dato no valido
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir
  report "[Prueba 6]: Dato no valido en el registro de configuracion 0";
  
  --  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
   
  -- CTRL_MS
  set_modo_reg_op (tic_tecla, tecla, info_disp, clk);
  editar_reg_op (tic_tecla, tecla, info_disp, reg_tx, X"3456", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir
  
  report "[Tecla E]: Escritura de registros de operacion -> 3456";
  
  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
                                  ---- LECTURA ----
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  pulsar(tic_tecla, tecla, X"F" , clk);  --leer
  report "[Tecla F]: Lectura de los 2 registros de conf -> 807E";
  
  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
  
  assert (reg_tx(15 downto 0) /= X"00F0" and reg_tx(15 downto 0) = X"007E") -- Ultimo valor valido
  report "PRUEBA 6 NO SUPERADA: No se ha detectado el valor correcto en el registro de configuracion" -- Si falla: probablemente el slave cambie a MSB cuando no debe
  severity failure;
  
  set_modo_reg_op (tic_tecla, tecla, info_disp, clk);
  pulsar(tic_tecla, tecla, X"F" , clk);  --leer
  report "[Tecla F]: Lectura de los 2 registros de op -> 3456";
  
  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
  
  assert reg_tx(7 downto 0) = X"34"
  report "PRUEBA 6 NO SUPERADA: No se ha detectado el valor correcto en los registros de operacion"
  severity failure;
  
--  assert reg_tx(7 downto 0) = X"56"
--  report "PRUEBA 6 NO SUPERADA: No se ha detectado el valor correcto en los registros de operacion"
--  severity failure;

  report "*****************FIN PRUEBA 6*****************";
--------------------------------------------------------  FIN PRUEBA 6 -------------------------------------------------------- 
  
  set_modo_reg_conf (tic_tecla, tecla, info_disp, clk);
  pulsar(tic_tecla, tecla, X"F" , clk);  --leer
  report "[Tecla F]: Lectura de registros de configuracion  -> 2480";
  
  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';  
 
  -- CTRL_MS
  set_modo_reg_op (tic_tecla, tecla, info_disp, clk);
  editar_reg_op (tic_tecla, tecla, info_disp, reg_tx, X"F012", clk);
  pulsar(tic_tecla, tecla, X"E" , clk);  --Escribir
  report "[Tecla E]: Escritura de registros de operacion -> F012";
  
  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';
  
  -- CONF
  add_up <= '1';
  MSB_1st <= '0';
  mode_3_4_h  <= '1';
  str_sgl_ins <= '1';
  report "MASTER EN MODO ASCENDENTE, MSB, 4H, SINGLE";
  
  set_modo_reg_op (tic_tecla, tecla, info_disp, clk);
  pulsar(tic_tecla, tecla, X"F" , clk);  --leer
  report "[Tecla F]: Lectura de registros de operacion  -> F012";
  wait until nCS'event and nCS = '1';
  wait for 50* Tclk;
  wait until clk'event and clk = '1';  

  assert false
  report "Fin del test"
  severity failure;

end process;
end test;
