pragma circom 2.2.3;

template binary_num(n){
    signal input num;
    signal input in[n];

    for(var i=0;i<n;i++)
    {
        (1-in[i])*in[i]===0;
    }
    var v=0,pow=1;
    for(var i=0;i<n;i++)
    {
        v+=in[i]*pow;
        pow*=2;
    }

    v===num;

}
component main=binary_num(2);