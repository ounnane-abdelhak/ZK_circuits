pragma circom 2.2.3;

template binaryN(n){

    signal input in[n];
    for(var i=0;i<n;i++)
    {
        (in[i]-1)*in[i]===0;
    }
}

component main = binaryN(2);

