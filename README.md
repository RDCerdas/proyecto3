# Proyecto 3 Verificacion Funcional
Robert Cerdas
David Solorzano

## Link del git

https://github.com/RDCerdas/proyecto3

## Codigo para correrlo

El código se compila mediante el comando `source comando.sh`. Sin embargo, se observó que en algunos casos se obtenía un error al cargar las herramientas por lo que podría se necesario correr `source /mnt/vol_NFS_rh003/estudiantes/archivos_config/synopsys_tools.sh`

Una vez compilado se pueden correr dos pruebas:
### Test 1.1 Operaciones Aleatorias
Consiste en 5000 transacciones aleatorias en el DUT. Para correrlo se utiliza el comando `./salida +UVM_TESTNAME=random_test +UVM_TIMEOUT=3000000 -cm tgl+cond+assert`. Es necesario agregar el UVM_TIMEOUT por un problema con la escala de tiempo que hace que las esperas sean en segundos y no en ns lo que supera facilmente el timeout por defecto de UVM.

### Test 2.1 Operandos especiales
Consiste en una serie de transacciones que buscan combinar operando especiales y verificar su funciomiento. Para correrlo se utiliza el comando `./salida +UVM_TESTNAME=test_especifico +UVM_TIMEOUT=3000000 -cm tgl+cond+assert`. Al igual que para el caso anterior es necesario agregar el uvmtimeout para evitar alcanzar el timeout de uvm.
## Visualización de la covertura
Una vez que se corren las pruebas con las switches antes mencionados se puede abrir verdi para observar la covertura obtenida. El comando para hacer esto es `verdi -cov -covdir salida.vdb&`.

## Visualización de los resultados
Cada prueba genera un csv llamado `report.csv` con todas operaciones efectuadas, incluyendo el tiempo de la transacción, los operandos, el resultado obtenido y el esperado. Este reporte es sobreescrito cada vez que se ejecuta una prueba nueva. 
