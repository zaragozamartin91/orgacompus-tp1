#include <mips/regdef.h>
#include <sys/syscall.h>

#define FRAME_SIZE 128
#define REG_RA 120
#define REG_FP 116
#define REG_GP 112

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

#define VAR_cr 64
#define VAR_ci 68
#define VAR_zr 72
#define VAR_zi 76
#define VAR_tr 80
#define VAR_ti 84
#define VAR_absz 88
#define VAR_x 92
#define VAR_y 96
#define VAR_c 100


#define VAR_fd 104

#define VAR_word_count 108

#define BUFFER_LIMIT 1024

#define WRITE_ERROR 9

#define STDOUT 1
#define STDERR 2




                .abicalls
                .text

                .macro write_syswrite_error
                    # ESCRIBO UN MENSAJE DE ERROR EN STDERR
                    li		a0, STDERR		            # a0 = STDERR
                    la      a1, $write_err_msg
                    li      a2, 11
                    li	    v0, SYS_write
                    syscall
                .endm

                .macro write_sysclose_error
                    # ESCRIBO UN MENSAJE DE ERROR EN STDERR
                    li		a0, STDERR		            # a0 = STDERR
                    la      a1, $close_err_msg
                    li      a2, 26
                    li	    v0, SYS_write
                    syscall
                .endm

                .macro write_new_line_to_buffer
                    li		t0, 10		                # t0 = \n
                    la		t1, BUFFER                  # t1 = BUFFER*
                    lw		t2, VAR_word_count($fp)     # t2 = word_count
                    add		t3, t2, t1                  # t3 = BUFFER[word_count]*
                    sb		t0, 0(t3)		            # BUFFER[word_count] = \n
                    addi	t2, t2, 1			        # t2 = word_count + 1
                    sw		t2, VAR_word_count($fp)		# word_count++
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
                

$init_vars:
                lw	    a0, FRAME_SIZE($fp)          # a0 = *parms
                
                # EXTRAIGO LOS CAMPOS DEL STRUCT param Y LAS GUARDO EN VARIABLES LOCALES
                l.s		$f0, 0(a0)
                s.s		$f0, VAR_UL_re($fp)
                
                
                lw	    a0, FRAME_SIZE($fp)          # a0 = *parms
                l.s		$f0, 4(a0)
                s.s		$f0, VAR_UL_im($fp)
                
                
                lw	    a0, FRAME_SIZE($fp)          # a0 = *parms
                l.s		$f0, 8(a0)
                s.s		$f0, VAR_LR_re($fp)
                
                lw	    a0, FRAME_SIZE($fp)          # a0 = *parms
                l.s		$f0, 12(a0)
                s.s		$f0, VAR_LR_im($fp)
                
                lw	    a0, FRAME_SIZE($fp)          # a0 = *parms
                l.s		$f0, 16(a0)
                s.s		$f0, VAR_d_re($fp)
                
                lw	    a0, FRAME_SIZE($fp)          # a0 = *parms
                l.s		$f0, 20(a0)
                s.s		$f0, VAR_d_im($fp)
                
                lw	    a0, FRAME_SIZE($fp)          # a0 = *parms
                l.s		$f0, 24(a0)
                s.s		$f0, VAR_s_re($fp)
                
                lw	    a0, FRAME_SIZE($fp)          # a0 = *parms
                l.s		$f0, 28(a0)
                s.s		$f0, VAR_s_im($fp)

                lw	    a0, FRAME_SIZE($fp)          # a0 = *parms
                lw		t0, 32(a0)
                sw		t0, VAR_x_res($fp)

                lw	    a0, FRAME_SIZE($fp)          # a0 = *parms
                lw		t0, 36(a0)
                sw		t0, VAR_y_res($fp)	
                
                lw	    a0, FRAME_SIZE($fp)          # a0 = *parms
                lw		t0, 40(a0)
                sw		t0, VAR_shades($fp)

                lw	    a0, FRAME_SIZE($fp)          # a0 = *parms
                lw		t0, 44(a0)
                addi	t0, t0, 14			         # t0 = direccion del fd
                lh	    t1, 0(t0)		             # t1 = fd
                sh      t1, VAR_fd($fp)              


                # INICIALIZO LAS VARIABLES LOCALES DE LA FUNCION C 

                sw      zero , VAR_cr($fp)
                sw      zero , VAR_ci($fp)
                sw      zero , VAR_zr($fp)
                sw      zero , VAR_zi($fp)
                sw      zero , VAR_tr($fp)
                sw      zero , VAR_ti($fp)
                sw      zero , VAR_absz($fp)

                sw      zero, VAR_x($fp)
                sw      zero, VAR_y($fp)
                sw      zero, VAR_c($fp)

                # inicializo el contador de palabras a escribir
                sw		zero, VAR_word_count($fp)


                # COMIENZO DE ESCRITURA DE ENCABEZADO ----------------------------------------------
                # LA ESCRITURA PRIMERO SE HACE EN UN BUFFER Y LUEGO SE VUELCA EL BUFFER AL ARCHIVO

                la		t0, $P2_head                # t0 = P2_HEAD*
                lw		t1, 0(t0)                   # t1 = P2_HEAD
                lw		t2, VAR_word_count($fp)		# t2 = word_count
                la		t3, BUFFER                  # t3 = BUFFER*
                add		t4, t3, t2                  # t4 = BUFFER[word_count]
                sw		t1, 0(t4)
                add		t2, t2, 4
                sw		t2, VAR_word_count($fp)	    # word_count += 4 
                
                

                lw		a0, VAR_x_res($fp)
                la      a1, BUFFER
                lw		a2, VAR_word_count($fp)
                la	    t9, write_pgm_head
	            jal	    ra, t9
                sw		v0, VAR_word_count($fp)     
                write_new_line_to_buffer



                lw		a0, VAR_y_res($fp)
                la      a1, BUFFER
                lw		a2, VAR_word_count($fp)
                la	    t9, write_pgm_head
	            jal	    ra, t9
                sw		v0, VAR_word_count($fp)     
                write_new_line_to_buffer


                lw		a0, VAR_shades($fp)
                subu    a0,a0,1
                la      a1, BUFFER
                lw		a2, VAR_word_count($fp)
                la	    t9, write_pgm_head
	            jal	    ra, t9
                sw		v0, VAR_word_count($fp)     
                write_new_line_to_buffer


                # ESCRIBO EL ENCABEZADO DEL PGM EN EL ARCHIVO
                lh      a0, VAR_fd($fp)             # a0 = fd
                # CARGO UN FD INCORRECTO PARA PRUEBAS
                #li		a0, 555		                # a0 = 555
                la		a1, BUFFER		            # a1 = BUFFER* 
                lw		a2, VAR_word_count($fp)		# a2 = word_count
                li	    v0, SYS_write
                syscall

                # CHEQUEO UN ERROR DE ESCRITURA EN EL ARCHIVO
                li		t0, WRITE_ERROR		        # t0 = WRITE_ERROR
                bne		v0, t0, $write_ok_1	        # if v0 != WRITE_ERROR then $write_ok_1
                nop
                write_syswrite_error
                li		a0, 1		                # a0 = 1
                li		v0, SYS_exit		        # v0 = SYS_exit
                syscall
                

$write_ok_1:
                # RESETEO el contador de palabras a escribir
                sw		zero, VAR_word_count($fp)


                # INICIO DEL CICLO FOR ---------------------------------------------------

                # for (y = 0, ci = parms->UL_im; y < parms->y_res; ++y, ci -= parms->d_im)
                sw		zero, VAR_y($fp)        # y = 0
                l.s     $f0, VAR_UL_im($fp)     # f0 = parms->UL_im
                s.s     $f0, VAR_ci($fp)        # ci = parms->UL_im

$for_y:         
                
                # for (x = 0, cr = parms->UL_re; x < parms->x_res; ++x, cr += parms->d_re)
                sw		zero, VAR_x($fp)        # x = 0
                l.s     $f0, VAR_UL_re($fp)     # f0 = parms->UL_re
                s.s     $f0, VAR_cr($fp)        # cr = parms->UL_re
                
$for_x:         

                l.s $f0,VAR_cr($fp)             # f0 = cr
                s.s $f0,VAR_zr($fp)             # zr = cr
                l.s $f2,VAR_ci($fp)             # f2 = ci
                s.s $f2,VAR_zi($fp)             # zi = ci

                      
                # for (c = 0; c < parms->shades; ++c)
                sw		zero, VAR_c($fp)		# c = 0
                sw		zero, VAR_absz($fp)		# absz = 0

$for_c:

                # __if ((absz = zr * zr + zi * zi) >= 4.0f) break;
                l.s     $f0 , VAR_zr($fp)       # f0 = zr
                l.s     $f2 , VAR_zi($fp)       # f2 = zi
                mul.s   $f0 , $f0 , $f0         # f0 = zr * zr                
                mul.s   $f2 , $f2 , $f2         # f2 = zi * zi
                add.s   $f4 , $f2 , $f0         # f4 = zr * zr + zi * zi
                s.s     $f4 , VAR_absz($fp)     # absz = zr * zr + zi * zi
                

                l.s     $f2 , VAR_absz($fp)     # f2 = absz
                l.s     $f0 , $float_four       # f0 = 4.0
                c.lt.s  $f0,$f2                 # si f0 < f2 entonces SET TRUE
                bc1t    $for_c_end
                nop
                

                # tr = parms->s_re + zr * zr - zi * zi;
                l.s     $f0 , VAR_zr($fp)       # f0 = zr
                l.s     $f2 , VAR_zi($fp)       # f2 = zi
                mul.s   $f0 , $f0 , $f0         # f0 = zr * zr                
                mul.s   $f2 , $f2 , $f2         # f2 = zi * zi
                l.s     $f4 , VAR_s_re($fp)     # f4 = parms->s_re
                add.s   $f6 , $f4 , $f0         # f6 = parms->s_re + zr * zr
                sub.s   $f8 , $f6 , $f2         # f8 = parms->s_re + zr * zr - zi * zi
                s.s     $f8 , VAR_tr($fp)       # tr = parms->s_re + zr * zr - zi * zi

                # ti = parms->s_im + zr * zi * 2.0f;
                l.s     $f0 , VAR_zr($fp)       # f0 = zr
                l.s     $f2 , VAR_zi($fp)       # f2 = zi
                l.s     $f4 , VAR_s_im($fp)     # f4 = parms->s_im
                l.s     $f6 , $float_two        # f6 = 2.0f
                mul.s   $f0 , $f0 , $f2         # f0 = zr * zi
                mul.s   $f0 , $f0 , $f6         # f0 = zr * zi * 2.0f
                add.s   $f0 , $f0 , $f4         # f0 = parms->s_im + zr * zi * 2.0f
                s.s     $f0 , VAR_ti($fp)       # ti = parms->s_im + zr * zi * 2.0f

                s.s     $f8 , VAR_zr($fp)       # zr = tr
                s.s     $f0 , VAR_zi($fp)       # zi = ti


                lw		t0 , VAR_c($fp)         # t0 = c
                addi	t0, t0, 1   			# t0 = c + 1
                sw		t0, VAR_c($fp)  		# ++c
                lw		t1, VAR_shades($fp)		# t1 = parms->shades
                blt		t0, t1, $for_c	        # if c < parms->shades then $for_c
                nop

$for_c_end:                

                # fprintf(parms->fp, "%u\n", (unsigned)c)
                lw		t0, VAR_c($fp)		    # t0 = c
                sll     t0 , t0 , 2             # t0 = c * 4
                la		t2, $dnames		        # t2 = $dnames
                add		t3, t0, t2      		# t3 = $dnames[c]
                lw		t4, 0(t3)               # t4 = direccion de palabra a escribir
                
                # GUARDO UNA PALABRA EN EL BUFFER
                lw		t5, 0(t4)		        # t5 = palabra a guardar en buffer
                lw      t6, VAR_word_count($fp) # t6 = word_count
                sll     t7, t6, 2               # t7 = word_count * 4
                la		t8, BUFFER		        # t8 = BUFFER*
                add		t8, t7, t8		        # t8 = BUFFER[word_count]
                sw		t5, 0(t8)		        # guardo una palabra en el buffer
                li		t0, BUFFER_LIMIT		# t0 = BUFFER_LIMIT
                addi	t6, t6, 1			    # t6 = t6 + 1
                sw		t6, VAR_word_count($fp)	# word_count++
                blt		t6, t0, $augment_x	    # if t6 < t0 then $augment_x 
                nop
                

                # VACIO TODO EL CONTENIDO DEL BUFFER Y LO ESCRIBO EN EL ARCHIVO
                lh      a0, VAR_fd($fp)             # a0 = fd
                la		a1, BUFFER		            # a1 = BUFFER 
                lw		a2, VAR_word_count($fp)		# a2 = word_count
                sll     a2, a2, 2                   # a2 = word_count * 4
                li	    v0, SYS_write
                syscall

                # CHEQUEO UN ERROR DE ESCRITURA EN EL ARCHIVO
                li		t0, WRITE_ERROR		        # t0 = WRITE_ERROR
                bne		v0, t0, $write_ok_2	        # if v0 != WRITE_ERROR then $write_ok_2
                nop
                write_syswrite_error
                li		a0, 1		                # a0 = 1
                li		v0, SYS_exit		        # v0 = SYS_exit
                syscall

$write_ok_2:
                # RESETEO EL CONTADOR DE PALABRAS DEL BUFFER
                sw		zero, VAR_word_count($fp)   # word_count = 0

$augment_x:

                l.s     $f0, VAR_cr($fp)        # f0 = cr
                l.s     $f2, VAR_d_re($fp)      # f2 = parms->d_re
                add.s   $f4, $f0, $f2           # f4 = cr + parms->d_re
                s.s     $f4, VAR_cr($fp)        # cr += parms->d_re

                lw		t0, VAR_x($fp)		    # t0 = x
                addi	t0, t0, 1			    # t0 = x + 1
                sw		t0, VAR_x($fp)  		# ++x 
                lw		t1, VAR_x_res($fp)		# t1 = parms->x_res
$for_x_end:     blt		t0, t1, $for_x      	# if t0 < t1 then $for_x
                nop
                

                l.s     $f0, VAR_ci($fp)        # f0 = ci
                l.s     $f2, VAR_d_im($fp)      # f2 = params->d_im
                sub.s   $f4, $f0 , $f2          # f4 = ci - params->d_im
                s.s     $f4 , VAR_ci($fp)       # ci -= parms->d_im

                lw		t0, VAR_y($fp)          # t0 = y
                addi	t0, t0, 1               # t0 = y + 1
                sw		t0, VAR_y($fp)          # y++
                lw		t1, VAR_y_res($fp)      # t1 = y_res
$for_y_end:     blt		t0, t1, $for_y	        # if y < y_res then $for_y
                nop

                # SI NO QUEDAN PALABRAS EN EL BUFFER PROCEDO A CERRAR EL ARCHIVO
                lw		t0, VAR_word_count($fp)		# t0 = word_count
                beq		t0, zero, $close_file	    # if t0 == zero then $close_file
                nop
                
                # SI QUEDAN PALABRAS EN EL BUFFER PROCEDO A ESCRIBIR LO QUE FALTA
                lh      a0, VAR_fd($fp)             # a0 = fd
                la		a1, BUFFER		            # a1 = BUFFER 
                lw		a2, VAR_word_count($fp)		# a2 = word_count
                sll     a2, a2, 2                   # a2 = word_count * 4
                li	    v0, SYS_write
                syscall

                # CHEQUEO UN ERROR DE ESCRITURA EN EL ARCHIVO
                li		t0, WRITE_ERROR		        # t0 = WRITE_ERROR
                bne		v0, t0, $close_file	        # if v0 != WRITE_ERROR then $close_file
                nop
                write_syswrite_error
                li		a0, 1		                # a0 = 1
                li		v0, SYS_exit		        # v0 = SYS_exit
                syscall


$close_file:
                
                # CIERRO EL ARCHIVO                
                lh      a0 , VAR_fd($fp)
                # MARCO UN fd incorrecto para pruebas
                #li		a0, 555		                # a0 = 555
                li		v0, SYS_close
                syscall
                

                # CHEQUEO UN ERROR DE CIERRE DEL ARCHIVO
                li		t0, WRITE_ERROR		        # t0 = WRITE_ERROR
                bne		v0, t0, $cleanup	        # if v0 != WRITE_ERROR then $cleanup
                nop
                write_sysclose_error
                li		a0, 1		                # a0 = 1
                li		v0, SYS_exit		        # v0 = SYS_exit
                syscall


$cleanup:        
                lw		ra, REG_RA(sp)
                lw		gp, REG_GP(sp)
                lw      $fp,REG_FP(sp)
                
                addu    sp,sp,FRAME_SIZE
                j       ra
                .end    mips32_plot

                .data
                .align 2
$dnames:        .word $d0 , $d1 , $d2 , $d3 , $d4 , $d5 , $d6 , $d7 , $d8 , $d9 , $d10 , $d11 , $d12 , $d13 , $d14 , $d15 , $d16 , $d17 , $d18 , $d19 , $d20 , $d21 , $d22 , $d23 , $d24 , $d25 , $d26 , $d27 , $d28 , $d29 , $d30 , $d31 , $d32 , $d33 , $d34 , $d35 , $d36 , $d37 , $d38 , $d39 , $d40 , $d41 , $d42 , $d43 , $d44 , $d45 , $d46 , $d47 , $d48 , $d49 , $d50 , $d51 , $d52 , $d53 , $d54 , $d55 , $d56 , $d57 , $d58 , $d59 , $d60 , $d61 , $d62 , $d63 , $d64 , $d65 , $d66 , $d67 , $d68 , $d69 , $d70 , $d71 , $d72 , $d73 , $d74 , $d75 , $d76 , $d77 , $d78 , $d79 , $d80 , $d81 , $d82 , $d83 , $d84 , $d85 , $d86 , $d87 , $d88 , $d89 , $d90 , $d91 , $d92 , $d93 , $d94 , $d95 , $d96 , $d97 , $d98 , $d99 , $d100 , $d101 , $d102 , $d103 , $d104 , $d105 , $d106 , $d107 , $d108 , $d109 , $d110 , $d111 , $d112 , $d113 , $d114 , $d115 , $d116 , $d117 , $d118 , $d119 , $d120 , $d121 , $d122 , $d123 , $d124 , $d125 , $d126 , $d127 , $d128 , $d129 , $d130 , $d131 , $d132 , $d133 , $d134 , $d135 , $d136 , $d137 , $d138 , $d139 , $d140 , $d141 , $d142 , $d143 , $d144 , $d145 , $d146 , $d147 , $d148 , $d149 , $d150 , $d151 , $d152 , $d153 , $d154 , $d155 , $d156 , $d157 , $d158 , $d159 , $d160 , $d161 , $d162 , $d163 , $d164 , $d165 , $d166 , $d167 , $d168 , $d169 , $d170 , $d171 , $d172 , $d173 , $d174 , $d175 , $d176 , $d177 , $d178 , $d179 , $d180 , $d181 , $d182 , $d183 , $d184 , $d185 , $d186 , $d187 , $d188 , $d189 , $d190 , $d191 , $d192 , $d193 , $d194 , $d195 , $d196 , $d197 , $d198 , $d199 , $d200 , $d201 , $d202 , $d203 , $d204 , $d205 , $d206 , $d207 , $d208 , $d209 , $d210 , $d211 , $d212 , $d213 , $d214 , $d215 , $d216 , $d217 , $d218 , $d219 , $d220 , $d221 , $d222 , $d223 , $d224 , $d225 , $d226 , $d227 , $d228 , $d229 , $d230 , $d231 , $d232 , $d233 , $d234 , $d235 , $d236 , $d237 , $d238 , $d239 , $d240 , $d241 , $d242 , $d243 , $d244 , $d245 , $d246 , $d247 , $d248 , $d249 , $d250 , $d251 , $d252 , $d253 , $d254 , $d255 , $d256

# VALOR 4.0f
$float_four:    .word   1082130432
# VALOR 2.0f
$float_two:     .word   1073741824


                .align 0
$write_err_msg: .ascii "i/o error.\n"
$close_err_msg: .ascii "cannot flush output file.\n"

                .align 2
$P2_head:       .ascii "P2 \n"
$d0:            .ascii "0  \n"
$d1:            .ascii "1  \n"
$d2:            .ascii "2  \n"
$d3:            .ascii "3  \n"
$d4:            .ascii "4  \n"
$d5:            .ascii "5  \n"
$d6:            .ascii "6  \n"
$d7:            .ascii "7  \n"
$d8:            .ascii "8  \n"
$d9:            .ascii "9  \n"
$d10:           .ascii "10 \n"
$d11:           .ascii "11 \n"
$d12:           .ascii "12 \n"
$d13:           .ascii "13 \n"
$d14:           .ascii "14 \n"
$d15:           .ascii "15 \n"
$d16:           .ascii "16 \n"
$d17:           .ascii "17 \n"
$d18:           .ascii "18 \n"
$d19:           .ascii "19 \n"
$d20:           .ascii "20 \n"
$d21:           .ascii "21 \n"
$d22:           .ascii "22 \n"
$d23:           .ascii "23 \n"
$d24:           .ascii "24 \n"
$d25:           .ascii "25 \n"
$d26:           .ascii "26 \n"
$d27:           .ascii "27 \n"
$d28:           .ascii "28 \n"
$d29:           .ascii "29 \n"
$d30:           .ascii "30 \n"
$d31:           .ascii "31 \n"
$d32:           .ascii "32 \n"
$d33:           .ascii "33 \n"
$d34:           .ascii "34 \n"
$d35:           .ascii "35 \n"
$d36:           .ascii "36 \n"
$d37:           .ascii "37 \n"
$d38:           .ascii "38 \n"
$d39:           .ascii "39 \n"
$d40:           .ascii "40 \n"
$d41:           .ascii "41 \n"
$d42:           .ascii "42 \n"
$d43:           .ascii "43 \n"
$d44:           .ascii "44 \n"
$d45:           .ascii "45 \n"
$d46:           .ascii "46 \n"
$d47:           .ascii "47 \n"
$d48:           .ascii "48 \n"
$d49:           .ascii "49 \n"
$d50:           .ascii "50 \n"
$d51:           .ascii "51 \n"
$d52:           .ascii "52 \n"
$d53:           .ascii "53 \n"
$d54:           .ascii "54 \n"
$d55:           .ascii "55 \n"
$d56:           .ascii "56 \n"
$d57:           .ascii "57 \n"
$d58:           .ascii "58 \n"
$d59:           .ascii "59 \n"
$d60:           .ascii "60 \n"
$d61:           .ascii "61 \n"
$d62:           .ascii "62 \n"
$d63:           .ascii "63 \n"
$d64:           .ascii "64 \n"
$d65:           .ascii "65 \n"
$d66:           .ascii "66 \n"
$d67:           .ascii "67 \n"
$d68:           .ascii "68 \n"
$d69:           .ascii "69 \n"
$d70:           .ascii "70 \n"
$d71:           .ascii "71 \n"
$d72:           .ascii "72 \n"
$d73:           .ascii "73 \n"
$d74:           .ascii "74 \n"
$d75:           .ascii "75 \n"
$d76:           .ascii "76 \n"
$d77:           .ascii "77 \n"
$d78:           .ascii "78 \n"
$d79:           .ascii "79 \n"
$d80:           .ascii "80 \n"
$d81:           .ascii "81 \n"
$d82:           .ascii "82 \n"
$d83:           .ascii "83 \n"
$d84:           .ascii "84 \n"
$d85:           .ascii "85 \n"
$d86:           .ascii "86 \n"
$d87:           .ascii "87 \n"
$d88:           .ascii "88 \n"
$d89:           .ascii "89 \n"
$d90:           .ascii "90 \n"
$d91:           .ascii "91 \n"
$d92:           .ascii "92 \n"
$d93:           .ascii "93 \n"
$d94:           .ascii "94 \n"
$d95:           .ascii "95 \n"
$d96:           .ascii "96 \n"
$d97:           .ascii "97 \n"
$d98:           .ascii "98 \n"
$d99:           .ascii "99 \n"
$d100:          .ascii "100\n"
$d101:          .ascii "101\n"
$d102:          .ascii "102\n"
$d103:          .ascii "103\n"
$d104:          .ascii "104\n"
$d105:          .ascii "105\n"
$d106:          .ascii "106\n"
$d107:          .ascii "107\n"
$d108:          .ascii "108\n"
$d109:          .ascii "109\n"
$d110:          .ascii "110\n"
$d111:          .ascii "111\n"
$d112:          .ascii "112\n"
$d113:          .ascii "113\n"
$d114:          .ascii "114\n"
$d115:          .ascii "115\n"
$d116:          .ascii "116\n"
$d117:          .ascii "117\n"
$d118:          .ascii "118\n"
$d119:          .ascii "119\n"
$d120:          .ascii "120\n"
$d121:          .ascii "121\n"
$d122:          .ascii "122\n"
$d123:          .ascii "123\n"
$d124:          .ascii "124\n"
$d125:          .ascii "125\n"
$d126:          .ascii "126\n"
$d127:          .ascii "127\n"
$d128:          .ascii "128\n"
$d129:          .ascii "129\n"
$d130:          .ascii "130\n"
$d131:          .ascii "131\n"
$d132:          .ascii "132\n"
$d133:          .ascii "133\n"
$d134:          .ascii "134\n"
$d135:          .ascii "135\n"
$d136:          .ascii "136\n"
$d137:          .ascii "137\n"
$d138:          .ascii "138\n"
$d139:          .ascii "139\n"
$d140:          .ascii "140\n"
$d141:          .ascii "141\n"
$d142:          .ascii "142\n"
$d143:          .ascii "143\n"
$d144:          .ascii "144\n"
$d145:          .ascii "145\n"
$d146:          .ascii "146\n"
$d147:          .ascii "147\n"
$d148:          .ascii "148\n"
$d149:          .ascii "149\n"
$d150:          .ascii "150\n"
$d151:          .ascii "151\n"
$d152:          .ascii "152\n"
$d153:          .ascii "153\n"
$d154:          .ascii "154\n"
$d155:          .ascii "155\n"
$d156:          .ascii "156\n"
$d157:          .ascii "157\n"
$d158:          .ascii "158\n"
$d159:          .ascii "159\n"
$d160:          .ascii "160\n"
$d161:          .ascii "161\n"
$d162:          .ascii "162\n"
$d163:          .ascii "163\n"
$d164:          .ascii "164\n"
$d165:          .ascii "165\n"
$d166:          .ascii "166\n"
$d167:          .ascii "167\n"
$d168:          .ascii "168\n"
$d169:          .ascii "169\n"
$d170:          .ascii "170\n"
$d171:          .ascii "171\n"
$d172:          .ascii "172\n"
$d173:          .ascii "173\n"
$d174:          .ascii "174\n"
$d175:          .ascii "175\n"
$d176:          .ascii "176\n"
$d177:          .ascii "177\n"
$d178:          .ascii "178\n"
$d179:          .ascii "179\n"
$d180:          .ascii "180\n"
$d181:          .ascii "181\n"
$d182:          .ascii "182\n"
$d183:          .ascii "183\n"
$d184:          .ascii "184\n"
$d185:          .ascii "185\n"
$d186:          .ascii "186\n"
$d187:          .ascii "187\n"
$d188:          .ascii "188\n"
$d189:          .ascii "189\n"
$d190:          .ascii "190\n"
$d191:          .ascii "191\n"
$d192:          .ascii "192\n"
$d193:          .ascii "193\n"
$d194:          .ascii "194\n"
$d195:          .ascii "195\n"
$d196:          .ascii "196\n"
$d197:          .ascii "197\n"
$d198:          .ascii "198\n"
$d199:          .ascii "199\n"
$d200:          .ascii "200\n"
$d201:          .ascii "201\n"
$d202:          .ascii "202\n"
$d203:          .ascii "203\n"
$d204:          .ascii "204\n"
$d205:          .ascii "205\n"
$d206:          .ascii "206\n"
$d207:          .ascii "207\n"
$d208:          .ascii "208\n"
$d209:          .ascii "209\n"
$d210:          .ascii "210\n"
$d211:          .ascii "211\n"
$d212:          .ascii "212\n"
$d213:          .ascii "213\n"
$d214:          .ascii "214\n"
$d215:          .ascii "215\n"
$d216:          .ascii "216\n"
$d217:          .ascii "217\n"
$d218:          .ascii "218\n"
$d219:          .ascii "219\n"
$d220:          .ascii "220\n"
$d221:          .ascii "221\n"
$d222:          .ascii "222\n"
$d223:          .ascii "223\n"
$d224:          .ascii "224\n"
$d225:          .ascii "225\n"
$d226:          .ascii "226\n"
$d227:          .ascii "227\n"
$d228:          .ascii "228\n"
$d229:          .ascii "229\n"
$d230:          .ascii "230\n"
$d231:          .ascii "231\n"
$d232:          .ascii "232\n"
$d233:          .ascii "233\n"
$d234:          .ascii "234\n"
$d235:          .ascii "235\n"
$d236:          .ascii "236\n"
$d237:          .ascii "237\n"
$d238:          .ascii "238\n"
$d239:          .ascii "239\n"
$d240:          .ascii "240\n"
$d241:          .ascii "241\n"
$d242:          .ascii "242\n"
$d243:          .ascii "243\n"
$d244:          .ascii "244\n"
$d245:          .ascii "245\n"
$d246:          .ascii "246\n"
$d247:          .ascii "247\n"
$d248:          .ascii "248\n"
$d249:          .ascii "249\n"
$d250:          .ascii "250\n"
$d251:          .ascii "251\n"
$d252:          .ascii "252\n"
$d253:          .ascii "253\n"
$d254:          .ascii "254\n"
$d255:          .ascii "255\n"
$d256:          .ascii "256\n"

# DEFINO UN BUFFER DE 4KB PARA LUEGO ESCRIBIR SOBRE EL ARCHIVO
                .align 2
BUFFER:         .space 4096



