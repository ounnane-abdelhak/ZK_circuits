pragma circom 2.2.3;

include "../node_modules/circomlib/circuits/comparators.circom";

/*
    Given a 4x4 sudoku board with array signal input "question" and "solution", check if the solution is correct.

    "question" is a 16 length array. Example: [0,4,0,0,0,0,1,0,0,0,0,3,2,0,0,0] == [0, 4, 0, 0]
                                                                                   [0, 0, 1, 0]
                                                                                   [0, 0, 0, 3]
                                                                                   [2, 0, 0, 0]

    "solution" is a 16 length array. Example: [1,4,3,2,3,2,1,4,4,1,2,3,2,3,4,1] == [1, 4, 3, 2]
                                                                                   [3, 2, 1, 4]
                                                                                   [4, 1, 2, 3]
                                                                                   [2, 3, 4, 1]

    "out" is the signal output of the circuit. "out" is 1 if the solution is correct, otherwise 0.                                                                               
*/


template Sudoku () {

    signal input  question[16];
    signal input solution[16];
    signal output out;
    

    for(var v = 0; v < 16; v++){
        log(solution[v],question[v]);
        assert(question[v] == solution[v] || question[v] == 0);
    }
    
    var m = 0 ;
    component row1[4];
    for(var q = 0; q < 4; q++){
        row1[m] = IsEqual();
        row1[m].in[0]  <== question[q];
        row1[m].in[1] <== 0;
        m++;
    }
    3 === row1[3].out + row1[2].out + row1[1].out + row1[0].out;

    m = 0;
    component row2[4];
    for(var q = 4; q < 8; q++){
        row2[m] = IsEqual();
        row2[m].in[0]  <== question[q];
        row2[m].in[1] <== 0;
        m++;
    }
    3 === row2[3].out + row2[2].out + row2[1].out + row2[0].out; 

    m = 0;
    component row3[4];
    for(var q = 8; q < 12; q++){
        row3[m] = IsEqual();
        row3[m].in[0]  <== question[q];
        row3[m].in[1] <== 0;
        m++;
    }
    3 === row3[3].out + row3[2].out + row3[1].out + row3[0].out; 

    m = 0;
    component row4[4];
    for(var q = 12; q < 16; q++){
        row4[m] = IsEqual();
        row4[m].in[0]  <== question[q];
        row4[m].in[1] <== 0;
        m++;
    }
    3 === row4[3].out + row4[2].out + row4[1].out + row4[0].out; 

    component cols[24];
    component rows[24];
    var clsum=0;
    var rwsum=0;
    var dgsum=0;
    var idxr=0,idxc=0,idxd=0;
    for(var i=0;i<3;i++){
        for(var j=0;j<4;j++){
            for(var s=1;s<4-i;s++){
                cols[idxc]=IsEqual();
                cols[idxc].in[0] <== solution[4*i+j];
                cols[idxc].in[1] <== solution[4*i+j+4*s];
                clsum += cols[idxc].out;
                idxc++;
            }
            for(var s=1;s<4-j;s++){
                rows[idxr]=IsEqual();
                rows[idxr].in[0] <== solution[i+4*j];
                rows[idxr].in[1] <== solution[i+4*j+s];
                rwsum += rows[idxr].out;
                idxr++;
            }
        }   

    }
    component diag[8];
    for(var i=0;i<2;i++){
        for(var s=0;s<2;s++){
            diag[idxd]=IsEqual();
            diag[idxd].in[0] <== solution[i*8+s*2];
            diag[idxd].in[1] <== solution[i*8+s*2+5];
            dgsum += diag[idxd].out;
            idxd++;
        }
        for(var s=0;s<2;s++){
            diag[idxd]=IsEqual();
            diag[idxd].in[0] <== solution[i*8+s*2+1];
            diag[idxd].in[1] <== solution[i*8+s*2+3];
            dgsum += diag[idxd].out;
            idxd++;
        }
    }

    clsum  + rwsum  + dgsum  ==> out;
    out === 0;
}
component main = Sudoku();