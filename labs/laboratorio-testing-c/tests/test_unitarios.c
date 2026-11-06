#include <stdio.h>
#include "../src/carrito.h"
#include "minunit/minunit.h"

void test_carrito_nuevo(void) {
    printf("\n[carrito nuevo]\n");
    Carrito c;
    carrito_init(&c);
    ASSERT_IGUAL(0, carrito_contar(&c));
}

void test_agregar_uno(void) {
    printf("\n[agregar un producto]\n");
    Carrito c;
    carrito_init(&c);
    Producto p = {"Leche", 350, 1};
    ASSERT_IGUAL(1, carrito_agregar(&c, p));
    ASSERT_IGUAL(1, carrito_contar(&c));
}

/* PARTE A */
void test_total_precio_unitario(void) {
    printf("\n[total: un producto, cantidad 1]\n");
    Carrito c;
    carrito_init(&c);
    Producto p = {"Leche", 350, 1};
    carrito_agregar(&c, p);
    ASSERT_IGUAL(350, carrito_total(&c));
}

/* PARTE B */
void test_total_con_cantidad(void) {
    printf("\n[total: un producto, cantidad 2]\n");
    Carrito c;
    carrito_init(&c);
    Producto p = {"Leche", 350, 2};
    carrito_agregar(&c, p);
    ASSERT_IGUAL(700, carrito_total(&c));
}

/* PARTE C */
void test_carrito_lleno(void) {
    printf("\n[carrito lleno]\n");
    Carrito c;
    carrito_init(&c);
    Producto p = {"Leche", 350, 1};

    for (int i = 0; i < MAX_ITEMS; i++) {
        ASSERT_IGUAL(1, carrito_agregar(&c, p));
    }

    int resultado = carrito_agregar(&c, p);
    printf("  Resultado del quinto intento: %d\n", resultado);
    ASSERT_IGUAL(0, resultado);
    ASSERT_IGUAL(MAX_ITEMS, carrito_contar(&c));
}

/* PARTE D */
void test_descuento(void) {
    printf("\n[descuento]\n");
    ASSERT_IGUAL(1170, carrito_descuento(1300, 10));
}

int main(void) {
    printf("=== Tests unitarios ===");
    test_carrito_nuevo();
    test_agregar_uno();
    test_total_precio_unitario();
    test_total_con_cantidad();
    test_carrito_lleno();
    test_descuento();
    RESUMEN();
    return EXIT_CODE();
}


