# orgacompus-tp1

## Generador de fractales

### Compilar codigo
correr __make clean; make__

### Correr codigo
correr __./tp1 [ Opciones ]__

### Opciones 
* -m, o --method: permite seleccionar dinámicamente la implementación a usar para generar la imagen de salida: 
generic para seleccionar la implementación genérica, en lenguaje C; mips32 para activar el soporte nativo para procesadores MIPS. Por defecto, el programa usa generic.
* -r, o --resolution, permite cambiar la resolución de la imagen generada. El valor por defecto será de 640x480 puntos.
* -c, o --center, para especificar las coordenadas correspondientes al punto central de la porción del plano complejo dibujada, expresado en forma binómica (i.e. a+bi). El valor por defecto es 0+0i.
* -w, o --width, especifica el ancho de la región del plano complejo que estamos por dibujar. Valor por defecto: 2.
* -H, o --height, sirve, en forma similar, para especificar el alto del rectángulo a dibujar. Valor por defecto: 2.
* -s, o --seed, para configurar el valor complejo de la semilla usada para generar el fractal. Valor por defecto: -0.7268953477091140+0.1888871290438459i.
* -o, o --output, permite colocar la imagen de salida, (en formato PGM) en el archivo pasado como argumento; o por salida estándar -cout- si el argumento es “-”.

### Ejemplos
* ./tp1 -m mips32 -c 0.3+0.3i -o out.pgm
* tp1 -m mips32 -c 0.282-0.007i -w 0.005 -H 0.005 -o dos.pgm

