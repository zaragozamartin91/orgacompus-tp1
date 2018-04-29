process.stdout.write('.word ')

/* Imprime los labels de digitos a guardar */
process.stdout.write( `$d0 ` );
for(let i=1; i< 256; i++) {
    process.stdout.write( `, $d${i} ` );
}

for(let i=0; i<256; i++) { 
    //process.stdout.write(`$d${i}:    .ascii "${i}"\n`);
}