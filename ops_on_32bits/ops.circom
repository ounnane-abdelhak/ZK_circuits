pragma circom 2.2.3;

include "../node_modules/circomlib/circuits/comparators.circom";
include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/gates.circom";

template rangecheck(bits){
    signal input in;
    component numtob = Num2Bits(bits);
    numtob.in <== in;
}

template Add32(){
    var bits = 32;
    signal input x;
    signal input y;
    signal output out;
    component check[2],checksum;
    check[0] = rangecheck(bits);
    check[0].in <== x;
    check[1] = rangecheck(bits);
    check[1].in <== y;
    checksum = Num2Bits(bits+1);
    checksum.in <== x + y;

    component  conv = Bits2Num(bits);
    for(var j=0;j<bits;j++){
        conv.in[j] <== checksum.out[j];
    }
    out <== conv.out;

}


template Mul32(){
    var bits = 32;
    signal input x;
    signal input y;
    signal output out;
    component check[2],checksum;
    check[0] = rangecheck(bits);
    check[0].in <== x;
    check[1] = rangecheck(bits);
    check[1].in <== y;
    checksum = Num2Bits(2*bits);
    checksum.in <== x * y;

    component  conv = Bits2Num(bits);
    for(var j=0;j<bits;j++){
        conv.in[j] <== checksum.out[j];
    }
    out <== conv.out;

}

template ModDiv(wordsize)

{
    assert(wordsize<125);
    signal input numerator,denominator;
    signal output remainder, quotient;

    remainder <-- numerator % denominator;
    quotient <-- numerator \ denominator;

    component check[4];
    for(var i=0;i<4;i++){
        check[i]=Num2Bits(wordsize);
    }
    check[0].in <== numerator;
    check[1].in <== denominator;
    check[2].in <== quotient;
    check[3].in <== remainder;
    numerator === remainder + quotient * denominator ;

}


template bitwiseAND32(){
    signal input a,b;
    signal output out;
    component n2ba=Num2Bits(32),n2bb=Num2Bits(32);
    n2ba.in <== a;
    n2bb.in <== b;
    component b2n = Bits2Num(32);
    component ands[32];
    for(var i=0;i<32;i++){
        ands[i]=AND();
        ands[i].a <== n2ba.out[i];
        ands[i].b <== n2bb.out[i]; 
        ands[i].out ==> b2n.in[i];       
    }
    out <== b2n.out;
}

template bitwiseOR32(){
    signal input a,b;
    signal output out;
    component n2ba=Num2Bits(32),n2bb=Num2Bits(32);
    n2ba.in <== a;
    n2bb.in <== b;
    component b2n = Bits2Num(32);
    component ors[32];
    for(var i=0;i<32;i++){
        ors[i]=OR();
        ors[i].a <== n2ba.out[i];
        ors[i].b <== n2bb.out[i]; 
        ors[i].out ==> b2n.in[i];       
    }
    out <== b2n.out;
}

template bitwiseNOT32(){
    signal input a;
    signal output out;
    component n2ba=Num2Bits(32);
    n2ba.in <== a;
    component b2n = Bits2Num(32);
    for(var i=0;i<32;i++){
        1 - n2ba.out[i] ==> b2n.in[i];       
    }
    out <== b2n.out;
}

template bitwiseXOR32(){
    signal input a,b;
    signal output out;
    component n2ba=Num2Bits(32),n2bb=Num2Bits(32);
    n2ba.in <== a;
    n2bb.in <== b;
    component b2n = Bits2Num(32);
    component xors[32];
    for(var i=0;i<32;i++){
        xors[i]=OR();
        xors[i].a <== n2ba.out[i];
        xors[i].b <== n2bb.out[i]; 
       1 - xors[i].out ==> b2n.in[i];       
    }
    out <== b2n.out;
}


component main = bitwiseNOT32();