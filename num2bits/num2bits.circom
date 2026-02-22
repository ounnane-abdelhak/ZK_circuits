pragma circom 2.2.3;

template num2bit(n){
    signal input in;
    signal output out[n];
    var res=0;
    var bs=1;
    for(var i=0;i<n;i++)
    {
        out[i] <-- (in >> i) & 1;
        out[i] * (out[i]-1) === 0;
    res += bs*out[i];
    bs *= 2;
    }
    in === res;
}

component main = num2bit(5);