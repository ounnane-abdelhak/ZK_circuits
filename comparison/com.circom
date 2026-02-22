pragma circom 2.2.3;
include "node_modules/circomlib/circuits/gates.circom";
include "../node_modules/circomlib/circuits/comparators.circom";

template compare(){
    signal input x;
    component or= OR();
    or.a <== GreaterThan(252)([x,17]);
    or.b <== LessThan(252)([x,5]);
    1  === or.out; 
}

component main = compare();