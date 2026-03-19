pragma circom 2.2.3;

include "../node_modules/circomlib/circuits/poseidon.circom";


template merkle_tree_proof(n){
    signal input root;
    signal input leaf;
    signal input siblings[n-1];
    signal input idx[n-1];

    signal path[n];

    component Hleaf= Poseidon(1);
    Hleaf.inputs[0] <== leaf;
    Hleaf.out ==> path[0];

    

    component Hashes[n-1];
    signal hold[n-1],hold2[n-1];

    for(var i = 0;i<n-1;i++){
        Hashes[i] = Poseidon(2);
        hold[i] <== path[i] * (1 - idx[i]);
        hold2[i] <== path[i] * idx[i];
        Hashes[i].inputs[0] <== hold[i] + idx[i] * siblings[i];
        Hashes[i].inputs[1] <== hold2[i] + (1 - idx[i]) * siblings[i];
        Hashes[i].out ==> path[i+1];

    }

    root === path[n-1];
}



template voting(n){
    signal input electionID;
    signal input root;

    signal input salt;
    signal input vote;
    signal input votersecret;
    signal input siblings[n-1];
    signal input idx[n-1];

    signal output nullifier;
    signal output commitment;

    signal hold;
    (vote-1)*vote ==> hold;
    hold*(vote-2) === 0;
    
    component Hleaf= Poseidon(1);
    Hleaf.inputs[0] <== votersecret;
    

    component tree = merkle_tree_proof(n);
    tree.leaf <== Hleaf.out;
    tree.root <== root;

    for(var i = 0;i<n-1;i++){
        tree.siblings[i] <== siblings[i];
        tree.idx[i] <== idx[i];
    }

    component Hnull = Poseidon(2);
    Hnull.inputs[0] <== votersecret;
    Hnull.inputs[1] <== electionID;
    nullifier <== Hnull.out;

    component Hcom = Poseidon(2);
    Hcom.inputs[0] <== vote;
    Hcom.inputs[1] <== salt;
    commitment <== Hcom.out;

}

component main {public[root,electionID]} = voting(3);

