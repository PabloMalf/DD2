# DD2
Diseño Esclavo SPI.

El diseño está estructurado de manera que existen 5 modulos principales. 

+ com_spi: es el encargado de la comunicación y de la iteracción con las lineas físicas. 
	- Entradas:
		- cs_in: chip select. Linea física. La controla el master spi.
		- clk_in: reloj que llega por la linea clk. La controla el master spi
		- SDI: son los datos que se reciben por la linea SDI del spi.
		- dato_tx(7 downto 0): dato que se quiere mandar por la linea SDO. Logica_spi es el módulo que le pasa este valor. (8 bit?)
		- init_tx: señal de un bit que indica que se ha cargado un nuevo dato en dato_out y que este debe ser enviado. Se debe activar durante un ciclo de reloj

	- Salidas:
		· SDO: datos al master spi
		· dato_rx(7 downto 0): dato que se ha recibido por la linea SDO (8 bit?). Este valor se envía después de haber paralelizado el valor recibido por la linea SDI.
		· data_ready: dato_in puede ser leido. Se activa durante un ciclo de reloj cuando se ha recibido un byte
		· init_rx: Se ha detectado una señal de start. Se activa durante un ciclo de reloj

+ logica_spi: se encarga de decidir que acciones se deben tomar.
	- Entradas:
		- dato_in (8 downto 0): es el dato que se ha leído de la linea SDI. Se debe leer cuando data_ready está activa. El valor puede caducar si se reciben mas datos por la linea. (8 bit ?) 
		- data_ready: viene de com_spi. Cuando esta linea está activa, se debe leer el dato que está en la señal dato_in
		- can_send_data: viene de com_spi. Informa de si este modulo esta preparado para que se le pase un dato que se enviará por la linea SDO
		- tecla_pulsada: se ha detectado una pulsación
		- tecla (3 downto 0): la tecla que se ha detectado
		- reg_value_read: en caso de que se quiera leer un registro, esta señal contiene el valor de este. Este valor lo pone reg_slave.

	- Salidas:
		- dato_out (7 downto 0): dato que se va a enviar por la linea SDO. (8 bit?)
		- reg_dir (15 downto 0): salida que se conecta al modulo reg_slave. Esta señal contiene el registro que se va a leer o a escribir.
		- reg_r_w: indica al modulo reg_slave si se va a leer o a escribir un registro.
		- reg_value_write (7 downto 0): Contiene el valor del registro que se va a escribir en la posicion que indica reg_dir.


+ reg_slave: Se comporta como una memoria con el valor de todos los registros. Dados los pocos registros que se van a utilizar, se modela con flip-flops en vez de usar celdas de memoria
	- Entradas:
		- reg_r_w: Este valor lo pone logica_spi. Indica si se va a leer o a escribir un registro.
		- reg_dir (15 downto 0): direccion del registro. Resumen:
			- 0x0000: configuración A. Tras un reset debe valer 0x00.
			- 0x0001: configuración B. Tras un reset debe valer 0x00.
			- 0x0002: configuración y estatus
			- 0x0003: tipo de chip
			- 0x0004 & 0x0005: Product ID (opcional)
			- 0x0006: Chip grade (opcional)
			- 0x0007: reservado.
			- 0x0008 & 0x0009: Puntero. La especificación no obliga a implementarlo de ninguna forma en específico.
			- 0x000A: Debug.
			- 0x000B: versión de spi
			- 0x000C & 0x000D: Vendor ID. Vale 0x0456.
			- 0x000E: reservado.
		- reg_value_write (7 downto 0): en caso de que se quiera escribir un registro, esta señal contiene el valor de este. Este valor lo pone logica_spi
	
	- Salidas:
		- reg_value_read (7 downto 0): valor del registro que se quiere leer

+ timer: gestiona los tiempos que se deben de respetar
	- Entradas:

	- Salidas:
		- tic: tic de 5 ms que se le pasa al controlador del teclado


+ ctrl_tec: controlador del teclado
	- Entradas:
		· tic
		· columna
	
	- Salidas:
		· fila
		· tecla_pulsada
		· tecla (3 downto 0)
