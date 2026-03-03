pragma circom 2.2.3;

include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/gates.circom";

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
        xors[i]=XOR();
        xors[i].a <== n2ba.out[i];
        xors[i].b <== n2bb.out[i]; 
        xors[i].out ==> b2n.in[i];       
    }
    out <== b2n.out;
}

template LeftRotate(l){
    signal input in;
    signal output out;
    component b2n= Bits2Num(32),n2bin = Num2Bits(32);
    var s=0;
    n2bin.in <== in;
    for(var i=0;i<32;i++)
    {
        s=(i+l)%32;
        b2n.in[s] <== n2bin.out[i];
    }
    out <== b2n.out;
}

template func(i){
    signal input D,B,C;
    signal output out;
    component and[2],or,xor[2],not;
    if(i<= 16){
        not = bitwiseNOT32();
        not.a <== B;
        and[0] = bitwiseAND32();
        and[1] = bitwiseAND32();
        and[0].a <== B;
        and[0].b <== C;
        and[1].a <== not.out;
        and[1].b <== D;
        or = bitwiseOR32();
        or.a <== and[0].out;
        or.b <== and[1].out;
        out <== or.out;

    }else if(i > 16 && i <= 32){ 
        not = bitwiseNOT32();
        not.a <== D;
        and[0] = bitwiseAND32();
        and[1] = bitwiseAND32();
        and[0].a <== B;
        and[0].b <== D;
        and[1].a <== not.out;
        and[1].b <== C;
        or = bitwiseOR32();
        or.a <== and[0].out;
        or.b <== and[1].out;
        out <== or.out;

    }else if(i > 32 && i <= 48){
        xor[0] = bitwiseXOR32();
        xor[1] = bitwiseXOR32();
        xor[0].a <== B;
        xor[0].b <== C;
        xor[1].a <== D;
        xor[1].b <== xor[0].out;
        xor[1].out ==> out;

    }else if(i > 48 && i <= 64){
        not = bitwiseNOT32();
        xor[0] = bitwiseXOR32();
        not.a <== D;
        or = bitwiseOR32();
        or.a <== B;
        or.b <== not.out;
        xor[0].a <== C;  
        xor[0].b <== or.out;
        xor[0].out ==> out;
    }

}

template Overflow32() 
{
    signal input in;
    signal output out;
    component n2b = Num2Bits(252),b2n = Bits2Num(32);
    n2b.in <== in;
    for(var i=0;i<32;i++)
    {
        b2n.in[i] <==  n2b.out[i];
    }  
}


template ToBytes(n) {
    signal input in;
    signal output out[n];
    component  n2b = Num2Bits(8*n);
    n2b.in <== in;
    component b2n[n] ;
    for(var i=0;i<n;i++)
    {
        b2n[i] = Bits2Num(8);
        for(var j=0;j<8;j++)
        {
            b2n[i].in[j] <== n2b.out[8*i+j];
        } 
        out[i] <== b2n[i].out;
        
    } 

}


template Padding(n) {

    assert(n < 56);
    signal input in[n];
    signal output out[64];
    for (var i = 0; i < n; i++) {
        out[i] <== in[i];
    }
    out[n] <== 128;
    for (var i = n + 1; i < 56; i++) {
        out[i] <== 0;
    }

    var lowOrderBytes = (8*n) % 256;
    var highOrderBytes = (8*n) \ 256;
    out[56] <== lowOrderBytes;
    out[57] <== highOrderBytes;

    for (var i = 58; i < 64; i++) {
        out[i] <== 0;
    }
}

template MD5(n) {

    var s[64] = [7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,
     5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,
     4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,
    6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21];

    var K[64] = [0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
     0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
     0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
     0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
     0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
     0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
     0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
     0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
     0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
     0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
     0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
     0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
     0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
     0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
     0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
     0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391];

    var iter_to_index[64] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
     1, 6, 11, 0, 5, 10, 15, 4, 9, 14, 3, 8, 13, 2, 7, 12,
     5, 8, 11, 14, 1, 4, 7, 10, 13, 0, 3, 6, 9, 12, 15, 2,
    0, 7, 14, 5, 12, 3, 10, 1, 8, 15, 6, 13, 4, 11, 2, 9];

    signal output out;
    signal input in[n];
    signal inp[64];
    component pad = Padding(n);
    
    for(var i = 0 ; i < n ;i++)
    {
        pad.in[i] <== in[i];
    }
    for(var i = 0 ; i < 64 ;i++)
    {
        pad.out[i] ==> inp[i];
    }

    signal data[16];
    for(var i = 0 ; i < 16;i++)
    {
        data[i] <== pad.out[4*i]+ 2**8 *  pad.out[4*i+1]  +2**16 * pad.out[4*i+2]  +2**24 * pad.out[4*i+3];
    }

    signal buffer[65][4];
    var A=0,B=1,C=2,D=3;
    buffer[0][A] <== 1732584193;
    buffer[0][B] <== 4023233417;
    buffer[0][C] <== 2562383102;
    buffer[0][D] <== 271733878;

    component Funcs[64];
    signal toRotates[64];
    component LeftRotates[64];
    component Overflow32s[64];
    component Overflow32s2[64];


    for (var i = 0; i < 64; i++) {
    
        buffer[i+1][A] <== buffer[i][D];
        buffer[i+1][C] <== buffer[i][B];
        buffer[i+1][D] <== buffer[i][C];

        Funcs[i] = func(i);
        Funcs[i].B <== buffer[i][B];
        Funcs[i].C <== buffer[i][C];
        Funcs[i].D <== buffer[i][D];


        LeftRotates[i] = LeftRotate(s[i]);
        Overflow32s[i] = Overflow32();
        
        Overflow32s[i].in <== Funcs[i].out + K[i] + buffer[i][A] + data[iter_to_index[i]];


        LeftRotates[i].in <== Overflow32s[i].out;

        Overflow32s2[i] = Overflow32();
        Overflow32s2[i].in <== buffer[i][B] + LeftRotates[i].out;
        buffer[i + 1][B] <== Overflow32s2[i].out;
    }
    component addA=Overflow32(),addB=Overflow32(),addC=Overflow32(),addD=Overflow32();

    addA.in <== buffer[0][A] + buffer[64][A];
    addB.in <== buffer[0][B] + buffer[64][B];
    addC.in <== buffer[0][C] + buffer[64][C];
    addD.in <== buffer[0][D] + buffer[64][D];

    signal littleEndianMd5;
    littleEndianMd5 <== addA.out + addB.out * 2**32 + addC.out * 2**64 + addD.out * 2**96;
    component Tb = ToBytes(16);
    //big endian
    Tb.in <== littleEndianMd5;

    var acc;
    for (var i = 0; i < 16; i++) {
        acc += Tb.out[15 - i] * 2**(i * 8);
    }
    out <== acc;

}


component main = MD5(55);