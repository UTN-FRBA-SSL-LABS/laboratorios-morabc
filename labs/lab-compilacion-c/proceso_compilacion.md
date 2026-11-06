# Laboratorio: Proceso de compilación en C

## Etapa 1: Preprocesamiento

**P1. ¿Cuántas líneas tiene el archivo `programa.i`?**

El archivo generado tiene **821 líneas**. Se obtuvo ejecutando:

```bash
gcc -E programa.c -o programa.i
```

**P2. ¿Los comentarios del código fuente aparecen en `programa.i`?**

No. El preprocesador elimina los comentarios durante esta etapa.

**P3. ¿Qué sucede con la macro `CUADRADO(LIMITE)`?**

La macro se expande y su invocación desaparece. En el archivo aparece la expresión:

```c
((5) * (5))
```

Aunque la palabra `CUADRADO` sigue apareciendo dentro de un texto de `printf`, ya no aparece como invocación de macro.

**P4. ¿Qué macro se expande al valor `"1.0"`?**

La macro se llama `VERSION`. Su valor se reemplaza por `"1.0"` en el archivo preprocesado.

**P5. ¿Qué sucede con el código condicionado por `DEBUG`?**

Sin definir `DEBUG`, el código de depuración no aparece en la salida del preprocesador. Al ejecutar:

```bash
gcc -E -DDEBUG programa.c
```

aparece la línea:

```c
printf("[DEBUG] %s\n", ("Iniciando main"));
```

Por lo tanto, definir `DEBUG` activa el código de depuración.

**P6. ¿Qué indican las marcas de línea del archivo preprocesado?**

Las marcas con el formato `# número "archivo"` indican el archivo de origen y la línea correspondiente al código que sigue. Permiten identificar de dónde proviene cada fragmento incluido durante el preprocesamiento.

Por ejemplo, aparecen referencias a `stdio.h`, porque el archivo fuente incluye esa biblioteca mediante `#include <stdio.h>`.

## Etapa 2: Compilación a ensamblador

**P7. ¿Cómo aparece `area_circulo` en `programa.s`?**

Aparece como una llamada a una función externa, mediante la instrucción:

```asm
call _area_circulo
```

Su implementación no está en `programa.c`, sino en `matematica.c`.

**P8. ¿Cuáles son las primeras cuatro instrucciones de la función `sumar` y qué hacen?**

Las primeras cuatro instrucciones reales son:

```asm
pushl %ebp
movl %esp, %ebp
movl _llamadas, %eax
addl $1, %eax
```

- `pushl %ebp`: guarda el valor anterior del registro base.
- `movl %esp, %ebp`: establece el marco de pila de la función.
- `movl _llamadas, %eax`: carga el valor de la variable global `llamadas`.
- `addl $1, %eax`: incrementa ese valor en uno.

**P9. ¿La variable `llamadas` aparece en el ensamblador?**

Sí. Aparece como variable global y se utiliza dentro de la función `sumar` para contar sus llamadas.

## Etapa 3: Ensamblado y archivos objeto

**P10. ¿Qué significa que `area_circulo` aparezca con el símbolo `U` en `programa.o`?**

Significa que el símbolo está indefinido en ese archivo objeto. `programa.o` utiliza la función, pero no contiene su implementación. El enlazador deberá encontrarla en otro archivo objeto o biblioteca.

**P11. ¿Qué etapa resuelve los símbolos indefinidos?**

La etapa de enlazado. El enlazador combina los archivos objeto y resuelve las referencias a funciones y variables externas.

**P12. ¿Se puede ejecutar directamente un archivo `.o`?**

No. Un archivo `.o` es un archivo objeto que contiene código máquina reubicable, pero todavía no es un ejecutable completo. Primero debe pasar por la etapa de enlazado.

Al intentar abrir `programa.o` desde Windows, el sistema mostró una ventana para elegir una aplicación.

## Etapa 4: Enlazado y ejecución

**P13. ¿Qué tipo de símbolo tiene `area_circulo` en el ejecutable enlazado?**

Aparece con el tipo `T`, que indica que el símbolo está definido en la sección de código (`.text`).

**P14. ¿Por qué pueden quedar símbolos `U` en el ejecutable final?**

Porque el ejecutable puede mantener referencias a símbolos externos proporcionados por bibliotecas o componentes del entorno de ejecución. No todas las referencias externas tienen que quedar resueltas como símbolos definidos dentro del propio ejecutable.

**P15. ¿Cuál es el resultado de ejecutar el programa?**

El programa se ejecutó correctamente y produjo, entre otros, los siguientes resultados:

```text
sumar(3, 4)       = 7
CUADRADO(5)      = 25
MAX(7, 12)       = 12
area_circulo(5.0) = 78.5398
```

También calculó los factoriales desde `0!` hasta `5!`. El resultado de `5!` fue:

```text
5! = 120
```

Finalmente, mostró:

```text
Llamadas a sumar(): 1
```

## Etapa 5: Conceptos teóricos

**P16. ¿Cuál es la diferencia entre una macro y una función?**

Una macro se procesa durante el preprocesamiento. Es una sustitución textual: el preprocesador reemplaza el nombre de la macro por su contenido antes de que el compilador traduzca el programa.

Por ejemplo:

```c
#define CUADRADO(x) ((x) * (x))
```

En cambio, una función es una unidad de código que se compila y puede invocarse durante la ejecución.

Por ejemplo:

```c
int sumar(int a, int b)
```

Las funciones tienen una declaración y una definición, y el compilador puede verificar los tipos y argumentos según sus declaraciones. Las macros son sustituciones textuales y no tienen ese mismo control de tipos.

**P17. ¿Qué significan las letras `T`, `D` y `B` que muestra `nm`?**

- `T`: símbolo definido en la sección de código (`.text`).
- `D`: símbolo definido en la sección de datos inicializados (`.data`).
- `B`: símbolo definido en la sección de datos no inicializados o inicializados en cero (`.bss`).

La variable global `llamadas` aparece con `B` porque está inicializada en cero.

**P18. ¿Qué herramientas permiten inspeccionar las bibliotecas dinámicas?**

En Linux se puede utilizar `ldd` para consultar las bibliotecas compartidas que necesita un ejecutable. En macOS se puede utilizar `otool -L`.

En este laboratorio se trabajó en Windows con MinGW, por lo que no se ejecutaron esas herramientas específicas.

---

## Resumen de respuestas cerradas

```text
LINEAS_I=821
CUADRADO_EN_I=NO
NOMBRE_MACRO_VERSION=VERSION
COMENTARIOS_EN_I=NO
DEBUG_ACTIVA_CODIGO=SI
AREA_EN_S=LLAMADA
LLAMADAS_EN_S=SI
TIPO_AREA_EN_O=U
ETAPA_QUE_RESUELVE=ENLAZADO
EJECUTABLE_O=NO
TIPO_AREA_ENLAZADO=T
SIMBOLOS_U_FINAL=SI
FACTORIAL_5=120
```