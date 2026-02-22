pragma circom 2.2.3;

include "../node_modules/circomlib/circuits/multiplexer.circom";
include "../node_modules/circomlib/circuits/comparators.circom";

template factorial(n){
    signal input k;
    signal facs[n];
    signal output out;

    facs[0] <== 1;
    for(var i=1;i<n;i++){
        facs[i] <== i * facs[i-1];
    }
    signal inTR;
    inTR <== LessThan(252)([k,n]);
    inTR === 1;

    component mul = Multiplexer(1,n);
    mul.sel <== k;
    for(var i=0;i<n;i++){
        mul.inp[i][0] <== facs[i];
    }
    out <== mul.out[0];

}

component main = factorial(100);