# Nombre del ejecutable final
PROGRAMA := programa

CC := gcc
CFLAGS := -Wall

SRCS := main.c operaciones.c
OBJS := $(SRCS:.c=.o)

all: $(PROGRAMA)

$(PROGRAMA): $(OBJS)
	$(CC) $^ -o $(PROGRAMA)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(PROGRAMA) $(OBJS)

.PHONY: all clean
