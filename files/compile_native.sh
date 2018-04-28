#!/bin/sh

gcc -c main.c debug.h defs.h param.h 
gcc -c generic_plot.c debug.h defs.h param.h
gcc -c mips32_plot.S 
gcc -c print_dnames.S
gcc main.o generic_plot.o mips32_plot.o print_dnames.o

