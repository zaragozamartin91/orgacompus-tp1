#include <mips/regdef.h>
#include <sys/syscall.h>

#define FRAME_SIZE 40
#define REG_ra 36
#define REG_fp 32
#define REG_gp 28

#define VAR_r 16
#define VAR_dname 20
#define VAR_fd 24


	.text			# segmento de texto del programa
	.abicalls
	.align 2		# alineacion 2^2

	.globl	print_dnames
	.ent	print_dnames
print_dnames:
	# debugging info: descripcion del stack frame
	.frame	$fp, FRAME_SIZE, ra	
	.set	noreorder				# apaga reordenamiento de instrucciones
	.cpload t9						# directiva usada para codigo PIC
	.set	reorder					# enciende reordenamiento de instrucciones

	# creo stack frame
	subu	sp, sp, FRAME_SIZE		# 4 (SRA) + 2 (LTA) + 4 (ABA)

	.cprestore REG_gp					
	sw	$fp, REG_fp(sp)
	sw	ra, REG_ra(sp)
	move	$fp, sp
	sw	a0, FRAME_SIZE($fp)
	sh	a1, VAR_fd($fp)

	# r = n % 10;
	remu	t0, a0, 10				# r: t0, sp+VAR_r	## remU
	sw		t0, VAR_r($fp)

	# n /= 10;
	lw	a0, FRAME_SIZE($fp)			# redundante
	divu	a0, a0, 10				# n /= 10
	sw	a0, FRAME_SIZE($fp)

	## if (n > 0) 
	lw	a0, FRAME_SIZE($fp)			## redundante
	beq	a0, zero, _write_name 		# n>0 equivale a n!=0 (n unsigned)
	
	#	print_dnames(n);
	lw	a0, FRAME_SIZE($fp)			## redundante
	la	t9, print_dnames
	jal	ra, t9

_write_name:

	lw	a0, VAR_r($fp)				# a0 = r
	sll	a0, a0, 2					# r*=4
	lw	a0, name(a0)				# name[r]: a0
	sw	a0, VAR_dname($fp)			# almaceno name[r] en LTA
	
	
	lh	a0, VAR_fd($fp)
	# li	a0, 1	
	lw	a1, VAR_dname($fp)			# name[r] ## (por que no hago move a1, a0?)
	li	a2, 1
	li	v0, SYS_write
	syscall

	# return;
	# restauro callee-saved regs
	lw	gp, REG_gp(sp)
	lw	$fp, REG_fp(sp)
	lw	ra, REG_ra(sp)
	# destruyo stack frame
	addu	sp, sp, FRAME_SIZE
	# vuelvo a funcion llamante
	jr	ra

	.end	print_dnames
	.size	print_dnames,.-print_dnames

	.rdata
	.align 2
name:	.word name_0, name_1, name_2, name_3, name_4, name_5, name_6, name_7, name_8, name_9
	.size name, 40

	.align 0
name_0: .ascii "0"
name_1: .ascii "1"
name_2: .ascii "2"
name_3: .ascii "3"
name_4: .ascii "4"
name_5: .ascii "5"
name_6: .ascii "6"
name_7: .ascii "7"
name_8: .ascii "8"
name_9: .ascii "9"
