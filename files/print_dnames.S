#include <mips/regdef.h>
#include <sys/syscall.h>


#define FRAME_SIZE 40
#define REG_ra 36
#define REG_fp 32
#define REG_gp 28

#define VAR_r 16
#define VAR_dname 20
#define VAR_buffer 44
#define VAR_wcount 48


	.text			
	.abicalls
	.align 2		

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
	sw	a1, VAR_buffer($fp)
	sw	a2, VAR_wcount($fp)
	

	# r = n % 10;
	remu	t0, a0, 10					# r: t0, sp+VAR_r	## remU
	sw		t0, VAR_r($fp)

	# n /= 10;
	lw		a0, FRAME_SIZE($fp)			# redundante
	divu	a0, a0, 10					# n /= 10
	sw		a0, FRAME_SIZE($fp)

	# __if (n > 0) 
	beq	a0, zero, _write_name 			# n>0 equivale a n!=0 (n unsigned)
	
	#	print_dnames(n);
	lw	a0, FRAME_SIZE($fp)			
	lw  a1, VAR_buffer($fp)
	lw 	a2, VAR_wcount($fp)
	la	t9, print_dnames
	jal	ra, t9
	sw	v0, VAR_wcount($fp)			# word_count = print_dnames(n)
	

_write_name:

	lb		t4, VAR_r($fp)			# t4 = r
	addi	t4, t4, 48				# t4 = r + 48 (inicio en ascii del '0')
	
	lw		t0, VAR_buffer($fp)		# t0 = buffer*
	lw		t5, VAR_wcount($fp)		# t5 = word_count
	add		t0, t0, t5				# t0 = buffer[word_count]*
	sb		t4, 0(t0)				# buffer[word_count] = (char)(r+48)
	addi	t5, t5, 1				# t5 = word_count + 1
	sw		t5, VAR_wcount($fp)		# word_count++
	

$cleanup:
	lw		t2, VAR_wcount($fp)
	move 	v0, t2					# return word_count

	lw	gp, REG_gp(sp)
	lw	$fp, REG_fp(sp)
	lw	ra, REG_ra(sp)
	addu	sp, sp, FRAME_SIZE
	jr	ra

	.end	print_dnames
	.size	print_dnames,.-print_dnames

