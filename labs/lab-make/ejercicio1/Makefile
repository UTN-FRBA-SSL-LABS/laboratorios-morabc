# Nombre del programa final
PROGRAMA := suma

CC := gcc
CFLAGS := -Wall

all: $(PROGRAMA)

$(PROGRAMA): suma.c
	$(CC) $(CFLAGS) suma.c -o $(PROGRAMA)

clean:
	rm -f $(PROGRAMA)

.PHONY: all clean
