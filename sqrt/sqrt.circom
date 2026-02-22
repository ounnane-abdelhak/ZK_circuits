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

template checksqrt(){
    signal input in;
    signal output out;
    signal output out2;
    out <-- sqrt(in);
    out * out === in;
    out2 <-- -1*out;
    out2 * out2 === in;

}

component main = checksqrt();