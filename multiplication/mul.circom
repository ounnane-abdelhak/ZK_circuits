pragma circom 2.2.3;

template mul(){
    signal input a;
    signal input b;
    signal input c;

    c===a*b;
}
component main =mul();