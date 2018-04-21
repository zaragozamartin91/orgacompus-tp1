#include <mips/regdef.h>
#include <sys/syscall.h>
#define FRAME_SIZE 32
#define REG_RA 28
#define REG_FP 24
#define REG_GP 20
#define VAR_i 16

                .abicalls
                .text

                .macro print_string mystring
                    la      a0,\mystring
                    la      t9,printf
                    jal     ra,t9
                .endm


                .align  2

                .globl  mips32_plot
                .ent    mips32_plot
mips32_plot:
                .frame  $fp,FRAME_SIZE,ra        
                .set    noreorder
                .cpload t9
                .set    reorder
                subu    sp,sp,FRAME_SIZE
                .cprestore REG_GP
                sw		ra, REG_RA(sp)
                sw      $fp,REG_FP(sp)
                sw      gp,REG_GP(sp)
                move    $fp,sp
                sw      a0,FRAME_SIZE($fp)
                sw      zero,VAR_i($fp)         

$start:
                print_string $foo_str
                
$cleanup:        
                lw		ra, REG_RA(sp)
                lw		gp, REG_GP(sp)
                lw      $fp,REG_FP(sp)
                
                addu    sp,sp,FRAME_SIZE
                j       ra
                .end    mips32_plot

                .data
                .align 0
$foo_str:       .asciiz "Hello world\n"

