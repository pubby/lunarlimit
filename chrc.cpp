#include <cstdio>
#include <cstdlib>
#include <array>

using tile_t = std::array<unsigned char, 16>;

// dcdcbaba

tile_t make_tile(unsigned char i)
{
    unsigned char const nw = ((i >> 5) & 1) | ((i >> 6) & 2);
    unsigned char const ne = ((i >> 4) & 1) | ((i >> 5) & 2);
    unsigned char const sw = ((i >> 1) & 1) | ((i >> 2) & 2);
    unsigned char const se = ((i >> 0) & 1) | ((i >> 1) & 2);

    unsigned char p[2][2] = {};

    switch(nw)
    {
    case 3: p[0][0] |= 0b11110000; p[1][0] |= 0b11110000; break;
    case 2: p[1][0] |= 0b11110000; break;
    case 1: p[0][0] |= 0b11110000; break;
    default: break;
    }

    switch(ne)
    {
    case 3: p[0][0] |= 0b00001111; p[1][0] |= 0b00001111; break;
    case 2: p[1][0] |= 0b00001111; break;
    case 1: p[0][0] |= 0b00001111; break;
    default: break;
    }

    switch(sw)
    {
    case 3: p[0][1] |= 0b11110000; p[1][1] |= 0b11110000; break;
    case 2: p[1][1] |= 0b11110000; break;
    case 1: p[0][1] |= 0b11110000; break;
    default: break;
    }

    switch(se)
    {
    case 3: p[0][1] |= 0b00001111; p[1][1] |= 0b00001111; break;
    case 2: p[1][1] |= 0b00001111; break;
    case 1: p[0][1] |= 0b00001111; break;
    default: break;
    }

    return 
    {{
        p[0][0], p[0][0], p[0][0], p[0][0],
        p[0][1], p[0][1], p[0][1], p[0][1],
        p[1][0], p[1][0], p[1][0], p[1][0],
        p[1][1], p[1][1], p[1][1], p[1][1],
    }};
}

int main(int argc, char** argv)
{
    if(argc != 2)
    {
        std::fprintf(stderr, "usage: %s [outfile]\n", argv[0]);
        return EXIT_FAILURE;
    }
    
    FILE* fp = std::fopen(argv[1], "wb");
    if(!fp)
    {
        std::fprintf(stderr, "can't open file %s\n", argv[1]);
        return EXIT_FAILURE;
    }

    for(unsigned i = 0; i != 256; ++i)
        for(unsigned char byte : make_tile(i))
            std::fputc(byte, fp);

    std::fclose(fp);
}

