#include <mips/regdef.h>
#include <sys/syscall.h>


#define FRAME_SIZE 32
#define REG_ra 28
#define REG_fp 24
#define REG_gp 20

#define VAR_r 16

#define VAR_n 32
#define VAR_buffer 36
#define VAR_wcount 40


	.text			
	.abicalls
	.align 2		

	.globl	write_pgm_head
	.ent	write_pgm_head
write_pgm_head:
	
	.frame	$fp, FRAME_SIZE, ra	
	.set	noreorder				
	.cpload t9						
	.set	reorder					

	
	subu	sp, sp, FRAME_SIZE			# 3 (SRA) + 1 (LTA) + 4 (ABA)

	.cprestore REG_gp					
	sw		$fp, REG_fp(sp)
	sw		ra, REG_ra(sp)
	move	$fp, sp
	sw		a0, VAR_n($fp)
	sw		a1, VAR_buffer($fp)
	sw		a2, VAR_wcount($fp)
	

	
	remu	t0, a0, 10					# t0 = n % 10
	sw		t0, VAR_r($fp)				# r = n % 10

	
	lw		a0, VAR_n($fp)				# a0 = n
	divu	a0, a0, 10					# a0 = n/10
	sw		a0, VAR_n($fp)				# n/=10

	
	beq		a0, zero, _write_name 		# if n==0 then _write_name
	
	
	lw		a0, VAR_n($fp)			
	lw  	a1, VAR_buffer($fp)
	lw 		a2, VAR_wcount($fp)
	la		t9, write_pgm_head
	jal		ra, t9
	sw		v0, VAR_wcount($fp)			# word_count = write_pgm_head(n)
	

_write_name:

	lb		t4, VAR_r($fp)				# t4 = r
	addi	t4, t4, 48					# t4 = r + 48 (inicio en ascii del '0')
	
	lw		t0, VAR_buffer($fp)			# t0 = buffer*
	lw		t5, VAR_wcount($fp)			# t5 = word_count
	add		t0, t0, t5					# t0 = buffer[word_count]*
	sb		t4, 0(t0)					# buffer[word_count] = (char)(r+48)
	addi	t5, t5, 1					# t5 = word_count + 1
	sw		t5, VAR_wcount($fp)			# word_count++
	

$cleanup:
	lw		t2, VAR_wcount($fp)
	move 	v0, t2						# return word_count

	lw		gp, REG_gp(sp)
	lw		$fp, REG_fp(sp)
	lw		ra, REG_ra(sp)
	addu	sp, sp, FRAME_SIZE
	jr		ra

	.end	write_pgm_head
	.size	write_pgm_head,.-write_pgm_head

