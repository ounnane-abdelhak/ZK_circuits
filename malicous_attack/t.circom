pragma circom 2.1.8;

template Mul3() {

    signal input a;
    signal input b;
    signal input c;

    signal output out;

    signal i;

    a * b === 1;
    i <-- a * b;
    out <== i * c; 
}

component main{public [a, b, c]} = Mul3();
