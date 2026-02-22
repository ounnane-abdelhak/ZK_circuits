pragma circom 2.2.3;

template iszero(){
    signal input in;
    signal output out;

    signal inv <-- in != 0 ? 1/in : 0;
    out <== -in * inv + 1;
    in*out === 0;


}
template isequal(){
    signal input in[2];
    signal output out;

    component isz = iszero();
    isz.in <== in[0]-in[1];
    out <== isz.out;

}

component main = isequal();

