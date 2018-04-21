#!/bin/sh

gcc -c main.c debug.h defs.h param.h 
gcc -c generic_plot.c debug.h defs.h param.h
gcc main.o generic_plot.o 


