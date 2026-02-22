
pragma circom 2.2.3;

include "../node_modules/circomlib/circuits/comparators.circom";

template max(n){
    signal input in[n];
    signal gte[n];
    signal eq[n];
    component s[n];
    signal output out;
    var maxx=in[0];
    for(var i=1;i<n;i++){
        if(in[i]>maxx){
            maxx = in[i];
        } 
    }
    out <-- maxx;
    for(var i=0;i<n;i++){
        gte[i] <== GreaterEqThan(252)([out,in[i]]);
        gte[i] === 1;
    }
    var sum = 0;
    for(var i=0;i<n;i++){
        s[i] = IsEqual();
        s[i].in[0] <== out;
        s[i].in[1] <== in[i];
        eq[i] <== s[i].out;
        sum += eq[i];
    }
    component s1 = IsZero();
    s1.in <== sum;
    s1.out === 0;



}

component main = max(2);

// more better solution
// pragma circom 2.2.3;

// include "../node_modules/circomlib/circuits/comparators.circom";
// include "../node_modules/circomlib/circuits/bitify.circom";

// // Max of two numbers within nbits
// template Max2(nbits) {
//     assert(nbits <= 252);

//     signal input in[2];
//     signal output out;

//     component gt = GreaterThan(nbits);
//     gt.in[0] <== in[0];
//     gt.in[1] <== in[1];

//     // out = in[0] if gt=1, else in[1]
//     out <== in[1] + gt.out * (in[0] - in[1]);
// }

// // Max of N numbers within nbits
// template MaxN(n, nbits) {
//     assert(n > 0);
//     assert(nbits <= 252);

//     signal input in[n];
//     signal output out;

//     // Range check inputs
//     component rc[n];
//     for (var i = 0; i < n; i++) {
//         rc[i] = Num2Bits(nbits);
//         rc[i].in <== in[i];
//     }

//     signal acc[n];
//     acc[0] <== in[0];

//     component m[n];
//     for (var i = 1; i < n; i++) {
//         m[i] = Max2(nbits);
//         m[i].in[0] <== acc[i - 1];
//         m[i].in[1] <== in[i];
//         acc[i] <== m[i].out;
//     }

//     out <== acc[n - 1];
// }

// component main = MaxN(2, 252);
