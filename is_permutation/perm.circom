pragma circom 2.2.3;
include "../node_modules/circomlib/circuits/poseidon.circom";

template IsPermutation(n) {
    signal input a[n];
    signal input b[n];
    signal prodA[n],prodB[n];

    component hash = Poseidon(2*n);
    for(var i=0;i<n;i++)
    {   
        hash.inputs[i] <== a[i];
        hash.inputs[i+n] <== b[i];
    }
    prodA[0] <== hash.out - a[0];
    prodB[0] <== hash.out - b[0];

    for(var i=1;i<n;i++)
    {   
        prodA[i] <== (hash.out - a[i])*prodA[i-1];
        prodB[i] <== (hash.out - b[i])*prodB[i-1];
    }
    prodA[n-1] === prodB[n-1];
}

component main = IsPermutation(8);