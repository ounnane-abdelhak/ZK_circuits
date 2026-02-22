
pragma circom 2.2.3;
function sqrt(n) {

    if (n == 0) {
        return 0;
    }

    var res = n ** ((-1) >> 1);
    if (res!=1) return 0;

    var m = 28;
    var c = 19103219067921713944291392827692070036145651957329286315305642004821462161904;
    var t = n ** 81540058820840996586704275553141814055101440848469862132140264610111;
    var r = n ** ((81540058820840996586704275553141814055101440848469862132140264610111+1)>>1);
    var sq;
    var i;
    var b;
    var j;

    while ((r != 0)&&(t != 1)) {
        sq = t*t;
        i = 1;
        while (sq!=1) {
            i++;
            sq = sq*sq;
        }

        b = c;
        for (j=0; j< m-i-1; j ++) b = b*b;

        m = i;
        c = b*b;
        t = t*c;
        r = r*b;
    }

    if (r < 0 ) {
        r = -r;
    }

    return r;
}

function root(a,b,c){
    var delta = b*b-4*a*c;
    var sol = (-b+sqrt(delta))/(2*a);

return sol;
}

template polysol(){
    signal input in[3];
    signal output out;
    var a=in[0],b=in[1],c=in[2];
    out <-- root(a,b,c);
    signal v1,v2,v3 ;
    v1 <== out*out;
    v2 <== a*v1;
    v3 <== b*out;
    v2+v3+c === 0;



}

component main = polysol();