pragma circom 2.2.3;

template sig_mul(n){
    signal input in[n];
    signal s[n];
    signal input k;
    s[0] <== in[0];
    for(var i=1;i<n;i++){
        s[i] <== s[i-1] * in[i];
    }
    s[n-1] === k;

}

component main = sig_mul(5);