pragma circom 2.2.3;

include "../node_modules/circomlib/circuits/babyjub.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/compconstant.circom";
include "../node_modules/circomlib/circuits/escalarmulany.circom";

template SchnorrVerify() {
    signal input r;
    signal input x;

    signal input V[2];
    signal input T[2];
    signal input c;
    signal input s;

    component hash = Poseidon(4);
    hash.inputs[0] <== V[0];
    hash.inputs[1] <== V[1];
    hash.inputs[2] <== T[0];
    hash.inputs[3] <== T[1];
    c === hash.out;


    component commit = BabyPbk();
    commit.in <== r;
    commit.Ax === T[0];
    commit.Ay === T[1];

    component pub = BabyPbk();
    pub.in <== x;
    pub.Ax === V[0];
    pub.Ay === V[1];

    component sBits = Num2Bits(253);
    sBits.in <== s;

    component sLtSubgroupOrder = CompConstant(2736030358979909402780800718157159386076813972158567259200215660948447373040);
    for (var i = 0; i < 253; i++) {
        sBits.out[i] ==> sLtSubgroupOrder.in[i];
    }
    sLtSubgroupOrder.in[253] <== 0;
    sLtSubgroupOrder.out === 0;

    component cBits = Num2Bits_strict();
    cBits.in <== c;

    component cMulV = EscalarMulAny(254);
    for (var j = 0; j < 254; j++) {
        cMulV.e[j] <== cBits.out[j];
    }
    cMulV.p[0] <== V[0];
    cMulV.p[1] <== V[1];

    component rhs = BabyAdd();
    rhs.x1 <== T[0];
    rhs.y1 <== T[1];
    rhs.x2 <== cMulV.out[0];
    rhs.y2 <== cMulV.out[1];

    component sMulBase = BabyPbk();
    sMulBase.in <== s;

    sMulBase.Ax === rhs.xout;
    sMulBase.Ay === rhs.yout;

}

component main = SchnorrVerify();
