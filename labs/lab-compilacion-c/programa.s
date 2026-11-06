	.file	"programa.c"
	.globl	_llamadas
	.bss
	.align 4
_llamadas:
	.space 4
	.text
	.globl	_sumar
	.def	_sumar;	.scl	2;	.type	32;	.endef
_sumar:
LFB14:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	movl	_llamadas, %eax
	addl	$1, %eax
	movl	%eax, _llamadas
	movl	8(%ebp), %edx
	movl	12(%ebp), %eax
	addl	%edx, %eax
	popl	%ebp
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
LFE14:
	.def	___main;	.scl	2;	.type	32;	.endef
	.section .rdata,"dr"
LC1:
	.ascii "1.0\0"
	.align 4
LC2:
	.ascii "=== Laboratorio de Compilacion en C (v%s) ===\12\12\0"
LC3:
	.ascii "sumar(3, 4)       = %d\12\0"
LC4:
	.ascii "CUADRADO(%d)      = %d\12\0"
LC5:
	.ascii "MAX(7, 12)        = %d\12\0"
LC6:
	.ascii "area_circulo(%.1f) = %.4f\12\0"
LC7:
	.ascii "Factoriales:\0"
LC8:
	.ascii "  %d! = %d\12\0"
LC9:
	.ascii "Llamadas a sumar(): %d\12\0"
	.text
	.globl	_main
	.def	_main;	.scl	2;	.type	32;	.endef
_main:
LFB15:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	andl	$-16, %esp
	subl	$64, %esp
	call	___main
	fldl	LC0
	fstpl	48(%esp)
	movl	$LC1, 4(%esp)
	movl	$LC2, (%esp)
	call	_printf
	movl	$4, 4(%esp)
	movl	$3, (%esp)
	call	_sumar
	movl	%eax, 44(%esp)
	movl	44(%esp), %eax
	movl	%eax, 4(%esp)
	movl	$LC3, (%esp)
	call	_printf
	movl	$25, 8(%esp)
	movl	$5, 4(%esp)
	movl	$LC4, (%esp)
	call	_printf
	movl	$12, 4(%esp)
	movl	$LC5, (%esp)
	call	_printf
	call	_imprimir_separador
	fldl	48(%esp)
	fstpl	(%esp)
	call	_area_circulo
	fstpl	12(%esp)
	fldl	48(%esp)
	fstpl	4(%esp)
	movl	$LC6, (%esp)
	call	_printf
	movl	$LC7, (%esp)
	call	_puts
	movl	$0, 60(%esp)
	jmp	L4
L5:
	movl	60(%esp), %eax
	movl	%eax, (%esp)
	call	_factorial
	movl	%eax, 8(%esp)
	movl	60(%esp), %eax
	movl	%eax, 4(%esp)
	movl	$LC8, (%esp)
	call	_printf
	addl	$1, 60(%esp)
L4:
	cmpl	$5, 60(%esp)
	jle	L5
	call	_imprimir_separador
	movl	_llamadas, %eax
	movl	%eax, 4(%esp)
	movl	$LC9, (%esp)
	call	_printf
	movl	$0, %eax
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
LFE15:
	.section .rdata,"dr"
	.align 4
LC11:
	.ascii "----------------------------------------\0"
	.text
	.globl	_imprimir_separador
	.def	_imprimir_separador;	.scl	2;	.type	32;	.endef
_imprimir_separador:
LFB16:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	subl	$24, %esp
	movl	$LC11, (%esp)
	call	_puts
	nop
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
LFE16:
	.section .rdata,"dr"
	.align 8
LC0:
	.long	0
	.long	1075052544
	.ident	"GCC: (MinGW.org GCC-6.3.0-1) 6.3.0"
	.def	_printf;	.scl	2;	.type	32;	.endef
	.def	_area_circulo;	.scl	2;	.type	32;	.endef
	.def	_puts;	.scl	2;	.type	32;	.endef
	.def	_factorial;	.scl	2;	.type	32;	.endef
