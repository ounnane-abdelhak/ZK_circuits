pragma circom 2.2.3;

include "../node_modules/circomlib/circuits/poseidon.circom";


template merkle(n){
    signal input root;
    signal  path[n];
    signal input leaf;
    signal input siblings[n-1];
    signal input index[n-1];


    component Hleaf= Poseidon(1);


    Hleaf.inputs[0] <== leaf;
    Hleaf.out ==> path[0];


    component Hashes[n-1];
    signal hold[n-1],hold2[n-1];

    for(var i = 0;i<n-1;i++){
        Hashes[i] = Poseidon(2);
        hold[i] <== path[i] * (1 - index[i]);
        hold2[i] <== path[i] * index[i];
        Hashes[i].inputs[0] <== hold[i] + index[i] * siblings[i];
        Hashes[i].inputs[1] <== hold2[i] + (1 - index[i]) * siblings[i];
        Hashes[i].out ==> path[i+1];

    }
    root === path[n-1];
}

component main {public[root]} = merkle(10);


