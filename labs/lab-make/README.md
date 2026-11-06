# Laboratorio: Make y Makefile

## VerificaciÃ³n y calificaciÃ³n

Desde la raÃ­z del repositorio ejecutÃ¡:

```bash
make grade LAB=lab-make
```

Si ya estÃ¡s dentro de esta carpeta tambiÃ©n podÃ©s usar `make test`. Ambos
comandos ejecutan los mismos checks y muestran el puntaje sin necesidad de hacer
push. La verificaciÃ³n oficial se ejecuta cuando cambia `labs/lab-make/`; la nota
queda en el resumen y en los artefactos de GitHub Actions.

No modifiques `.github/`, `scripts/` ni `test_local.sh`: son infraestructura
docente y el workflow restaura automÃ¡ticamente su versiÃ³n oficial. Los `Makefile` de los
ejercicios sÃ­ son parte de este laboratorio y deben completarse.

## Objetivo

Familiarizarse con la herramienta **Make** y la escritura de **Makefiles** para automatizar
la compilaciÃ³n de proyectos en C que usan `gcc`, `flex` y `bison`.

## Requisitos

- `make`
- `gcc`
- `flex`
- `bison`

En Ubuntu/Debian: `sudo apt-get install -y make gcc flex bison`

---

## Â¿QuÃ© problema resuelve Make?

Cuando el proyecto crece, compilar a mano se vuelve tedioso y propenso a errores.
Por ejemplo, para compilar un proyecto con Flex y Bison hay que recordar y ejecutar
tres comandos en el orden correcto cada vez que algo cambia:

```bash
bison -d parser.y
flex scanner.l
gcc lex.yy.c parser.tab.c -o mi_programa
```

Make automatiza esto: con un solo comando (`make`) ejecuta los pasos necesarios,
y ademÃ¡s es inteligente â€” si un archivo no cambiÃ³ desde la Ãºltima compilaciÃ³n,
**no lo recompila**. Eso ahorra tiempo en proyectos grandes.

---

## Conceptos clave

### El archivo Makefile

Make lee las instrucciones de un archivo llamado `Makefile` (con M mayÃºscula).
Ese archivo vive en la misma carpeta que el cÃ³digo fuente. Al ejecutar `make` en
esa carpeta, Make lee el Makefile y construye el proyecto.

### Estructura de una regla

La unidad bÃ¡sica de un Makefile es la **regla**:

```makefile
target : dependencia1 dependencia2
	comando1
	comando2
```

- **target**: el nombre del archivo que queremos generar, o el nombre lÃ³gico de una acciÃ³n.
- **dependencias**: los archivos (u otros targets) que deben existir y estar actualizados
  para que este target pueda construirse. Make compara las fechas de modificaciÃ³n: si alguna
  dependencia es mÃ¡s nueva que el target, re-ejecuta los comandos.
- **comandos**: las instrucciones de shell que producen el target. Pueden ser uno o varios.

> **Importante:** los comandos deben ir precedidos por un **tabulador** (`Tab`), no por espacios.
> Este es uno de los errores mÃ¡s frecuentes al escribir Makefiles por primera vez.

**Ejemplo concreto:**

```makefile
suma: suma.c
	gcc suma.c -o suma
```

Esto le dice a Make: _"para tener `suma`, necesito `suma.c`; si `suma.c` cambiÃ³ (o si
`suma` no existe), ejecutÃ¡ `gcc suma.c -o suma`"_.

### Variables

Las variables (tambiÃ©n llamadas macros) permiten definir un valor una sola vez
y reutilizarlo en varias reglas. Se declaran con `:=` y se usan con `$(NOMBRE)`:

```makefile
CC     := gcc
CFLAGS := -Wall

suma: suma.c
	$(CC) $(CFLAGS) suma.c -o suma
```

La ventaja es inmediata: si maÃ±ana queremos compilar con `clang` en lugar de `gcc`,
solo cambiamos una lÃ­nea (`CC := clang`) y todo el Makefile se actualiza solo.

Las variables mÃ¡s comunes en proyectos C son:

| Variable | Uso convencional |
|----------|-----------------|
| `CC` | El compilador de C a usar (normalmente `gcc`) |
| `CFLAGS` | Flags de compilaciÃ³n (p. ej. `-Wall`, `-g`, `-O2`) |
| `SRCS` | Lista de archivos fuente `.c` |
| `OBJS` | Lista de archivos objeto `.o` |

### El target `all`

Por convenciÃ³n, el primer target del Makefile es el que se ejecuta cuando
escribÃ­s simplemente `make` sin argumentos. Se suele llamar `all` y lista
como dependencias todo lo que se quiere construir:

```makefile
all: suma

suma: suma.c
	$(CC) suma.c -o suma
```

### El target `clean`

Por convenciÃ³n, el target `clean` elimina todos los archivos generados por la
compilaciÃ³n (ejecutables, objetos, archivos temporales de Flex/Bison), dejando
el directorio como si nunca hubiÃ©ramos compilado:

```makefile
clean:
	rm -f suma lex.yy.c
```

`clean` no tiene dependencias porque no necesita ningÃºn archivo para poder borrarlo.

### `.PHONY`

Make asume que los targets son nombres de archivos. Si existiera un archivo
llamado `clean` en el directorio, Make lo verÃ­a como "ya construido" y no
ejecutarÃ­a la regla. Para evitar ese problema, declaramos los targets que
**no son archivos reales** con `.PHONY`:

```makefile
.PHONY: all clean
```

AsÃ­ Make siempre ejecuta esos targets, independientemente de si existe un archivo
con ese nombre.

### Variables automÃ¡ticas

Cuando tenemos muchos archivos, serÃ­a engorroso escribir el nombre de cada uno
a mano en los comandos. Make provee variables automÃ¡ticas que se calculan en el
contexto de cada regla:

| Variable | Significado |
|----------|-------------|
| `$@` | El nombre del **target** de esta regla |
| `$<` | El **primer** prerequisito (primera dependencia) |
| `$^` | **Todos** los prerequisitos juntos |

Ejemplo: si la regla es `suma: main.o operaciones.o`, entonces dentro del comando:
- `$@` vale `suma`
- `$<` vale `main.o`
- `$^` vale `main.o operaciones.o`

### Reglas de patrÃ³n

Cuando tenemos varios archivos `.c` que queremos compilar a `.o`, en lugar de
escribir una regla por cada archivo podemos usar una **regla de patrÃ³n** con `%`
como comodÃ­n:

```makefile
%.o : %.c
	$(CC) $(CFLAGS) -c $< -o $@
```

El `%` hace matching con cualquier nombre. Si Make necesita construir `main.o`,
busca `main.c` y ejecuta el comando. Si necesita `operaciones.o`, busca `operaciones.c`
y ejecuta el mismo comando. Una sola regla cubre todos los casos.

La flag `-c` le indica a gcc que compile sin linkear (genera el `.o` pero no el ejecutable).

### SustituciÃ³n de variables

Para derivar la lista de `.o` a partir de la lista de `.c` automÃ¡ticamente
se usa la sustituciÃ³n de sufijos:

```makefile
SRCS := main.c operaciones.c
OBJS := $(SRCS:.c=.o)    # â†’ main.o operaciones.o
```

Esto reemplaza cada `.c` por `.o` en la lista. AsÃ­ si agregamos un archivo nuevo
a `SRCS`, `OBJS` se actualiza solo.

---

## Ejercicios

---

### Ejercicio 1 â€” Makefile bÃ¡sico con gcc (25 pts)

En este ejercicio vamos a escribir el Makefile mÃ¡s simple posible: compilar un
Ãºnico archivo `.c` con `gcc`. El programa `suma.c` ya estÃ¡ completo; tu tarea
es escribir las instrucciones de construcciÃ³n.

AbrÃ­ `ejercicio1/Makefile` y completÃ¡ los cuatro TODOs.

---

#### TODO 1 â€” Definir la variable `CC`

```makefile
CC :=
```

`CC` es la variable estÃ¡ndar de Make para el **compilador de C**. Por convenciÃ³n
se llama `CC` (_C Compiler_). Asignale el valor `gcc`.

Â¿Por quÃ© usar una variable en lugar de escribir `gcc` directamente? Porque si
en otro entorno necesitÃ¡s usar `clang` o un compilador cruzado, solo cambiÃ¡s
esta lÃ­nea y todo el Makefile sigue funcionando sin tocar nada mÃ¡s.

---

#### TODO 2 â€” Definir la variable `CFLAGS`

```makefile
CFLAGS :=
```

`CFLAGS` (_C Flags_) contiene las opciones que le pasamos al compilador.
Asignale el valor `-Wall`.

`-Wall` activa todos los **warnings** mÃ¡s importantes de gcc. Los warnings no
impiden la compilaciÃ³n, pero seÃ±alan cÃ³digo potencialmente problemÃ¡tico
(variables sin usar, comparaciones sospechosas, etc.). Trabajar siempre con
`-Wall` es una buena prÃ¡ctica.

---

#### TODO 3 â€” Comando de compilaciÃ³n

```makefile
$(PROGRAMA): suma.c
	# EscribÃ­ el comando aquÃ­
```

Este es el corazÃ³n del Makefile: el comando que convierte `suma.c` en el ejecutable.
EscribÃ­ una lÃ­nea (comenzando con Tab) que invoque al compilador usando las variables
que definiste, el archivo fuente `suma.c`, y el flag `-o $(PROGRAMA)` para que
el ejecutable tenga el nombre correcto.

El comando completo deberÃ­a verse asÃ­:

```
$(CC) $(CFLAGS) suma.c -o $(PROGRAMA)
```

`-o $(PROGRAMA)` le dice a gcc cÃ³mo llamar al archivo de salida. Sin este flag,
gcc generarÃ­a un ejecutable llamado `a.out` por defecto.

---

#### TODO 4 â€” Regla `clean`

```makefile
clean:
	# EscribÃ­ el comando aquÃ­
```

EscribÃ­ el comando que elimina el ejecutable generado. UsÃ¡ `rm -f $(PROGRAMA)`.

El flag `-f` (_force_) hace que `rm` no dÃ© error si el archivo no existe,
lo cual es conveniente: si nunca compilaste (o ya limpiaste), `make clean`
no falla.

---

**VerificaciÃ³n:**
```bash
cd ejercicio1
make                   # compila suma.c y genera el ejecutable
echo "3 4" | ./suma    # â†’ 3 + 4 = 7
echo "10 5" | ./suma   # â†’ 10 + 5 = 15
make clean             # elimina suma
make clean             # segunda vez: no da error gracias al -f
```

---

### Ejercicio 2 â€” Makefile con Flex (25 pts)

Hasta ahora tenÃ­amos un Ãºnico archivo `.c` y un paso de compilaciÃ³n. Cuando
usamos Flex, el proceso tiene **dos pasos**: primero Flex genera cÃ³digo C a
partir del scanner, y luego gcc compila ese cÃ³digo C.

El pipeline es:
```
scanner2.l  â†’[flex]â†’  lex.yy.c  â†’[gcc]â†’  scanner2
```

AbrÃ­ `ejercicio2/Makefile` y completÃ¡ los tres TODOs.

---

#### TODO 1 â€” Invocar Flex

```makefile
$(PROGRAMA): scanner2.l
	# TODO 1: flex ...
```

El primer paso es ejecutar Flex sobre el archivo `.l`. El comando es simplemente:

```
flex scanner2.l
```

Flex lee `scanner2.l` y genera un archivo llamado `lex.yy.c` con el scanner
en cÃ³digo C. Este archivo no existe antes de correr Flex; Make lo produce
como parte del proceso de construcciÃ³n.

NotÃ¡ que `scanner2.l` figura como dependencia del target. Eso significa que
Make solo va a re-ejecutar esta regla si `scanner2.l` fue modificado desde
la Ãºltima vez que se construyÃ³ el target. Si el archivo no cambiÃ³, Make
no hace nada.

---

#### TODO 2 â€” Compilar el cÃ³digo generado por Flex

```makefile
	# TODO 2: $(CC) ...
```

Una vez que Flex generÃ³ `lex.yy.c`, el segundo paso es compilarlo con gcc
para obtener el ejecutable. EscribÃ­ el comando usando `$(CC)`, el archivo
`lex.yy.c` y el flag `-o $(PROGRAMA)`.

ObservÃ¡ que ambos comandos (TODO 1 y TODO 2) estÃ¡n en la misma regla y se
ejecutan secuencialmente, de arriba a abajo. Eso garantiza que cuando gcc
intente compilar `lex.yy.c`, Flex ya lo habrÃ¡ generado.

---

#### TODO 3 â€” Limpiar los archivos generados

```makefile
clean:
	# TODO 3: rm -f ...
```

Ahora hay dos archivos generados que conviene limpiar: el ejecutable `$(PROGRAMA)`
y el cÃ³digo C intermedio `lex.yy.c` que generÃ³ Flex. EscribÃ­ el comando
`rm -f` con ambos nombres.

Es buena prÃ¡ctica limpiar tambiÃ©n los archivos intermedios (no solo el ejecutable)
para que `make` siempre reconstruya todo desde cero cuando se pide.

---

**VerificaciÃ³n:**
```bash
cd ejercicio2
make
echo "42" | ./scanner2     # â†’ Numero: 42
echo "7" | ./scanner2      # â†’ Numero: 7
make clean                 # elimina scanner2 y lex.yy.c
```

---

### Ejercicio 3 â€” Makefile con Flex + Bison (25 pts)

Este ejercicio reproduce el pipeline completo que usamos en los trabajos prÃ¡cticos:
Bison genera el parser, Flex genera el scanner, y gcc los compila juntos.

Los archivos `parser3.y` y `scanner3.l` ya estÃ¡n completos e implementan una
calculadora simple. Tu tarea es escribir el Makefile que orquesta todo el proceso.

El pipeline es:
```
parser3.y          â†’[bison -d]â†’  parser3.tab.c
                               + parser3.tab.h
scanner3.l         â†’[flex]â†’    lex.yy.c
parser3.tab.c
+ lex.yy.c         â†’[gcc]â†’     calc3
```

AbrÃ­ `ejercicio3/Makefile` y completÃ¡ los cuatro TODOs.

---

#### TODO 1 â€” Invocar Bison

```makefile
$(PROGRAMA): parser3.y scanner3.l
	# TODO 1: bison ...
```

El primer paso es procesar el archivo `.y` con Bison. El comando es:

```
bison -d parser3.y
```

La opciÃ³n **`-d`** (_define_) es clave: le indica a Bison que, ademÃ¡s del
archivo C con el parser (`parser3.tab.c`), genere tambiÃ©n un **archivo de
cabecera** (`parser3.tab.h`) con las definiciones de los tokens.

Â¿Por quÃ© hace falta ese header? Porque el scanner (generado por Flex) necesita
conocer los nÃºmeros de token que definiÃ³ Bison (como `NUM`, `SUMA`, etc.) para
poder retornarlos. El scanner incluye ese `.tab.h` para tener acceso a esas
definiciones. Si no usÃ¡ramos `-d`, no existirÃ­a ese archivo y la compilaciÃ³n fallarÃ­a.

---

#### TODO 2 â€” Invocar Flex

```makefile
	# TODO 2: flex ...
```

El segundo paso es procesar `scanner3.l` con Flex para generar `lex.yy.c`.
El scanner en `scanner3.l` tiene una lÃ­nea `#include "parser3.tab.h"` â€” por
eso este paso debe ir **despuÃ©s** del paso de Bison: cuando Flex procesa el
`.l`, el archivo `parser3.tab.h` ya debe existir.

---

#### TODO 3 â€” Compilar y linkear todo con gcc

```makefile
	# TODO 3: $(CC) ...
```

Ahora tenemos dos archivos C generados: `lex.yy.c` (el scanner) y `parser3.tab.c`
(el parser). Hay que compilarlos **juntos** en un solo comando de gcc para
generar el ejecutable `calc3`. EscribÃ­ el comando usando `$(CC)`, ambos archivos
`.c` y el flag `-o $(PROGRAMA)`.

Los dos archivos se compilan juntos porque se referencian mutuamente: el parser
llama a `yylex()` (funciÃ³n del scanner) y el scanner retorna tokens que el parser
definiÃ³. Separarlos en dos pasos requerirÃ­a compilar con `-c` y luego linkear,
lo cual veremos en el ejercicio 4.

---

#### TODO 4 â€” Limpiar todos los archivos generados

```makefile
clean:
	# TODO 4: rm -f ...
```

Ahora Bison y Flex generaron cuatro archivos intermedios: `parser3.tab.c`,
`parser3.tab.h`, `lex.yy.c`, y el ejecutable `calc3`. EscribÃ­ el comando
`rm -f` para eliminar todos ellos.

---

**VerificaciÃ³n:**
```bash
cd ejercicio3
make
printf '3 + 4\n'  | ./calc3    # â†’ = 7
printf '10 - 3\n' | ./calc3    # â†’ = 7
printf '2 * 5\n'  | ./calc3    # â†’ = 10
make clean
```

---

### Ejercicio 4 â€” Makefile avanzado: mÃºltiples archivos (15 pts)

En proyectos reales el cÃ³digo estÃ¡ dividido en varios archivos `.c`. La prÃ¡ctica
recomendada es compilar cada `.c` a un archivo objeto `.o` por separado, y luego
**linkear** todos los `.o` juntos en el ejecutable final.

Ventaja principal: si modificÃ¡s un solo archivo, solo se recompila ese `.c` y
luego se re-linkea. Los demÃ¡s `.o` se reusan tal cual. En proyectos grandes esto
ahorra mucho tiempo.

El pipeline es:
```
main.c        â†’[gcc -c]â†’  main.o
operaciones.c â†’[gcc -c]â†’  operaciones.o
main.o + operaciones.o  â†’[gcc]â†’  programa
```

AbrÃ­ `ejercicio4/Makefile` y completÃ¡ los cinco TODOs.

---

#### TODO 1 â€” Definir `SRCS`

```makefile
SRCS :=
```

`SRCS` (_sources_) es la variable que lista todos los archivos fuente `.c` del
proyecto. Asignale los dos archivos: `main.c` y `operaciones.c`.

Esta variable es el punto central de configuraciÃ³n: si el proyecto crece y
agregamos un tercer archivo, solo necesitamos sumarlo aquÃ­.

---

#### TODO 2 â€” Derivar `OBJS` a partir de `SRCS`

```makefile
OBJS :=
```

`OBJS` (_objects_) debe contener la lista de archivos `.o` correspondientes
a cada `.c` en `SRCS`. En lugar de escribirlos a mano, usÃ¡ la **sustituciÃ³n
de sufijos** de Make:

```makefile
OBJS := $(SRCS:.c=.o)
```

Esta sintaxis le dice a Make: _"tomÃ¡ `SRCS` y reemplazÃ¡ cada `.c` por `.o`"_.
El resultado es `main.o operaciones.o`. AsÃ­, si maÃ±ana `SRCS` tiene tres
archivos, `OBJS` se actualiza automÃ¡ticamente.

---

#### TODO 3 â€” Comando de linkeo

```makefile
$(PROGRAMA): $(OBJS)
	# EscribÃ­ el comando aquÃ­
```

Este target toma todos los archivos `.o` y los linkea en el ejecutable final.
UsÃ¡ la variable automÃ¡tica **`$^`**, que vale "todos los prerequisitos", es
decir, todos los `.o`. El comando deberÃ­a ser:

```
$(CC) $^ -o $(PROGRAMA)
```

Â¿Por quÃ© `$^` y no escribir `main.o operaciones.o` directamente? Porque si
agregamos un archivo a `SRCS`/`OBJS`, este comando sigue siendo correcto sin
modificarlo.

---

#### TODO 4 â€” Regla de patrÃ³n para compilar `.c` â†’ `.o`

```makefile
# EscribÃ­ la regla de patrÃ³n aquÃ­
```

Esta es la regla mÃ¡s poderosa del ejercicio. En lugar de escribir una regla
por cada archivo fuente, usamos el comodÃ­n `%`:

```makefile
%.o : %.c
	$(CC) $(CFLAGS) -c $< -o $@
```

Make interpreta esto como: _"para construir **cualquier** `.o`, buscÃ¡ el `.c`
del mismo nombre y ejecutÃ¡ este comando"_.

Desglose del comando:
- `$(CC) $(CFLAGS)` â€” el compilador con sus flags
- `-c` â€” compilar sin linkear (producir `.o`, no ejecutable)
- `$<` â€” el primer prerequisito, es decir, el archivo `.c` que hace match
- `-o $@` â€” nombrar la salida con el nombre del target, es decir, el `.o`

---

#### TODO 5 â€” Declarar `.PHONY`

```makefile
# Declarar targets que no son archivos
```

AgregÃ¡ la declaraciÃ³n `.PHONY` para los targets `all` y `clean`. Si existiera
un archivo llamado `all` o `clean` en el directorio, Make pensarÃ­a que esos
targets ya estÃ¡n construidos y no ejecutarÃ­a sus reglas. `.PHONY` previene
ese problema indicando explÃ­citamente que son nombres lÃ³gicos, no archivos.

---

**VerificaciÃ³n:**
```bash
cd ejercicio4
make
# DeberÃ­as ver que compila main.c y operaciones.c por separado, y luego los linkea
echo "5 3" | ./programa
# â†’ Suma: 8
# â†’ Resta: 2
# â†’ Producto: 15

# ModificÃ¡ operaciones.c (aunque sea agregando un comentario) y volvÃ© a compilar:
# make solo recompilarÃ¡ operaciones.o, no main.o
make clean
```

---

## Preguntas de reflexiÃ³n

RespondÃ© en este `README.md` reemplazando cada `???` con la opciÃ³n correcta.

**P1.** Si ejecutÃ¡s `make` dos veces seguidas sin modificar ningÃºn archivo entre una
ejecuciÃ³n y la otra, Â¿quÃ© hace Make en la segunda ejecuciÃ³n?

> PensÃ¡ en cÃ³mo Make decide si debe recompilar: compara las **fechas de modificaciÃ³n**
> del target con las de sus dependencias. Si el target es mÃ¡s nuevo que todas sus
> dependencias, ya estÃ¡ actualizado.

Opciones: `RECOMPILA` / `NO_RECOMPILA` / `DA_ERROR`

```
P1=NO_RECOMPILA
```

---

**P2.** El target `clean` en los Makefiles de este laboratorio, Â¿genera un archivo
llamado `clean`?

> RevisÃ¡ las reglas `clean` que escribiste: Â¿el comando `rm -f` crea algÃºn archivo,
> o solo elimina? Â¿Existe algÃºn archivo `clean` despuÃ©s de ejecutar `make clean`?

Opciones: `SI` / `NO`

```
P2=NO
```

---

**P3.** Â¿Para quÃ© sirve declarar un target como `.PHONY`?

> ImaginÃ¡ que en tu carpeta existe un archivo llamado `clean`. Â¿QuÃ© pasarÃ­a si
> ejecutÃ¡s `make clean` sin tener `.PHONY`? Â¿Y con `.PHONY`?

Opciones: `PARA_CREAR_ARCHIVOS` / `PARA_EVITAR_CONFLICTOS_DE_NOMBRES` / `PARA_COMPILAR_MAS_RAPIDO`

```
P3=PARA_EVITAR_CONFLICTOS_DE_NOMBRES
```

---

## Entrega

### Checklist

- [ ] Todos los `TODO` completados en los archivos `Makefile`
- [ ] Preguntas P1, P2 y P3 respondidas en este `README.md`
- [ ] `make test` pasa localmente
- [ ] Todo pusheado a `main`

### VerificaciÃ³n local

Antes de hacer push, verificÃ¡ tu puntaje con:

```bash
make test
```

**Flujo recomendado:** hacÃ© commits frecuentes mientras avanzÃ¡s, usÃ¡ `make test` para verificar tu progreso, y dejÃ¡ el push para cuando una parte estÃ© realmente lista.

### IntegraciÃ³n continua

Cuando pusheÃ¡s cambios dentro de `labs/lab-make/`, el workflow central del monorepo ejecuta los mismos checks y valida el puntaje mÃ­nimo.

> âš ï¸ **EvitÃ¡ pushes innecesarios.** Cada ejecuciÃ³n consume cÃ³mputo en servidores de GitHub â€” un recurso compartido. `make test` te da el mismo resultado en tu terminal sin costo.

Para ver los resultados:

1. EntrÃ¡ a tu repositorio en GitHub
2. HacÃ© click en la pestaÃ±a **Actions**
3. HacÃ© click en la ejecuciÃ³n mÃ¡s reciente â†’ job **Grading Â· lab-make**
4. Al final del job vas a ver la tabla con el resultado de cada check y el puntaje total

