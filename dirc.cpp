#include <cstdio>
#include <cstdlib>

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

    std::fprintf(fp, ".include\"globals.inc\"\n");
    std::fprintf(fp, ".segment \"RODATA\"\n");
    std::fprintf(fp, "dx:\n");
    for(unsigned i = 0; i != 256; ++i)
    {
        int x = (i & 0b00001111) - 8;
        if(x >= 0)
            ++x;
        std::fprintf(fp, ".byt .lobyte(%i)\n", x*1);
    }
    std::fprintf(fp, "dy:\n");
    for(unsigned i = 0; i != 256; ++i)
    {
        int y = ((i & 0b11110000) >> 4) - 8;
        if(y >= 0)
            ++y;
        std::fprintf(fp, ".byt .lobyte(%i)\n", y*1);
    }

    std::fclose(fp);
}

