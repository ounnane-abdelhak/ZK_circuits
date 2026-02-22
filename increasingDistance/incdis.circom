pragma circom 2.2.3;

template IncreasingDistance(n) {
    signal input in1[n];
    signal input in2[n];
    signal input in3[n];

    for(var i=0;i<n;i++){
        in1[i]*in2[i] === in3[i]+i;
    }

}

component main = IncreasingDistance(4);