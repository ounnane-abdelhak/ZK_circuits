pragma circom 2.2.3;

include "../node_modules/circomlib/circuits/multiplexer.circom";
include "../node_modules/circomlib/circuits/comparators.circom";

template fibonacci(n){

signal input in;
signal f[n];
signal output out;

assert(n>=2);
f[0] <== 0;
f[1] <== 1;

for(var i=2;i<n;i++){
    f[i] <== f[i-1]+f[i-2];
}
    signal inTR;
    inTR <== LessThan(252)([in,n]);
    inTR === 1;

    component mul = Multiplexer(1,n);
    mul.sel <== in;
    for(var i=0;i<n;i++){
        mul.inp[i][0] <== f[i];
    }
    out <== mul.out[0];
}

component main = fibonacci(5);