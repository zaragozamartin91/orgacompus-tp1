#!/bin/sh

gcc -c main.c debug.h defs.h param.h 
gcc -c generic_plot.c debug.h defs.h param.h
gcc -c mips32_plot.S 
gcc main.o generic_plot.o mips32_plot.S

