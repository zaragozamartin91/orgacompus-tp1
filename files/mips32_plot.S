#include <mips/regdef.h>
#include <sys/syscall.h>

#define FRAME_SIZE 80
#define REG_RA 72
#define REG_FP 68
#define REG_GP 64

#define VAR_UL_re 16
#define VAR_UL_im 20
#define VAR_LR_re 24
#define VAR_LR_im 28
#define VAR_d_re 32
#define VAR_d_im 36
#define VAR_s_re 40
#define VAR_s_im 44
#define VAR_x_res 48
#define VAR_y_res 52
#define VAR_shades 56
#define VAR_fp 60

# FRAME SIZE = 4 ARGS + 3 REGS + 12 VARS + 1 PADDING


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

