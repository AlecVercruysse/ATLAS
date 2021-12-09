#include <stdio.h>

int main(){

    typedef int16_t newType;

    printf("Hello world \n");

     newType Data_r[32] = {
        0x3FF,
        0x3FF,
        0xfc01,
        0xfc01,

        0x3FF,
        0x3FF,
        0xfc01,
        0xfc01,

        0x3FF,
        0x3FF,
        0xfc01,
        0xfc01,

        0x3FF,
        0x3FF,
        0xfc01,
        0xfc01,

        0x3FF,
        0x3FF,
        0xfc01,
        0xfc01,

        0x3FF,
        0x3FF,
        0xfc01,
        0xfc01,

        0x3FF,
        0x3FF,
        0xfc01,
        0xfc01,

        0x3FF,
        0x3FF,
        0xfc01,
        0xfc01
    };

    //  newType Data_r[32] = {
    //     0x3FF,
    //     0x3FF,
    //     0x3FF,
    //     0x3FF,
    //     0x3FF,
    //     0x3FF,
    //     0x3FF,
    //     0x3FF,

    //     0xfc01,
    //     0xfc01,
    //     0xfc01,
    //     0xfc01,
    //     0xfc01,
    //     0xfc01,
    //     0xfc01,
    //     0xfc01,

    //     0x3FF,
    //     0x3FF,
    //     0x3FF,
    //     0x3FF,
    //     0x3FF,
    //     0x3FF,
    //     0x3FF,
    //     0x3FF,

    //     0xfc01,
    //     0xfc01,
    //     0xfc01,
    //     0xfc01,
    //     0xfc01,
    //     0xfc01,
    //     0xfc01,
    //     0xfc01
    // };

     newType Data_i[32] = {
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0
    };

    newType Tw_r[16] = {
        0x7fff,
        0x7d89,
        0x7641,
        0x6a6d,
        0x5a82,
        0x471c,
        0x30fb,
        0x18f9,
        0x0,
        0xe707,
        0xcf05,
        0xb8e4,
        0xa57e,
        0x9593,
        0x89bf,
        0x8277
    };

    newType Tw_i[16] = {
        0,
        0x1859,
        0x30fb,
        0x471c,
        0x5a82,
        0x6a6d,
        0x7641,
        0x7d89,
        0x7fff,
        0x7d89,
        0x7641,
        0x6a6d,
        0x5a82,
        0x471c,
        0x30fb,
        0x1859
    };


    for(newType i = 0; i < 5; i++){
        for(newType j = 0; j < 16; j++){
            newType ja=j<<1;
            newType jb=ja+1;
            ja = ((ja << i) | (ja >> (5-i))) & 0x1f; // Address A; 5 bit circular left shift
            jb = ((jb << i) | (jb >> (5-i))) & 0x1f ; // Address B; implemented using C statements
            newType TwAddr = ((0xfffffff0 >> i) & 0xf) & j; // Twiddle addresses

            newType temp_r = ((Data_r[jb] * Tw_r[TwAddr]) / 32768) - ((Data_i[jb] * Tw_i[TwAddr]) /32768);
            newType temp_i = ((Data_r[jb] * Tw_i[TwAddr]) / 32768) + ((Data_i[jb] * Tw_r[TwAddr]) / 32768); 
            //newType temp_r = ((Data_r[jb] * Tw_r[TwAddr]) >> 15) - ((Data_i[jb] * Tw_i[TwAddr]) >> 15);
            //newType temp_i = ((Data_r[jb] * Tw_i[TwAddr]) >> 15) + ((Data_i[jb] * Tw_r[TwAddr]) >> 15); 
            if(ja == 0 || jb == 0){
                printf("2nd val, ja: %d, jb: %d, realA: %x, realB %x, tempR: %x, tempI: %x, TwR: %x, TwI: %x, TwAddr: %d, \n",ja, jb, Data_r[ja], Data_r[jb],temp_r, temp_i, Tw_r[TwAddr], Tw_i[TwAddr], TwAddr);
            }
            Data_r[jb] = Data_r[ja] - temp_r;
            Data_i[jb] = Data_i[ja] - temp_i;
            Data_r[ja] += temp_r;
            Data_i[ja] += temp_i;
        }
        for(newType k = 0; k < 32; k++){
            printf("%d %x %x \n", k, Data_r[k], Data_i[k]);
        }

    }
}