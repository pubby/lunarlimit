#include <cmath>
#include <iostream>
#include <fstream>

constexpr double pi = 3.14159265359;
constexpr double pi2 = 2.0 * 3.14159265359;

int roundc(double d)
{
    return (unsigned char)std::round(d);
}

int roundi(double d)
{
    return std::round(d);
}

int main(int argc, char** argv)
{
    if(argc != 2)
    {
        std::fprintf(stderr, "usage: %s [outfile]", argv[0]);
        return EXIT_FAILURE;
    }
    std::ofstream out(argv[1]);
    out << ".include \"globals.inc\"\n";
    out << ".segment \"RODATA\"\n";
    out << "sin_table:";
    int const sin_table_size = 64;
    for(int i = 0; i != sin_table_size; ++i)
    {
        double const d = i;
        if(i % 8 == 0)
            out << "\n.byt ";
        else
            out << ',';
        out << roundc(std::sin(d * pi / ((double)sin_table_size/1.0))*127.0);
    }
    out << ",0\n";

    out << "atan_table:";
    int const atan_table_size = 256;
    for(int i = 0; i != atan_table_size; ++i)
    {
        unsigned const y = (i & 0b11110000) >> 4;
        unsigned const x =  i & 0b00001111;

        double const d = i;
        if(i % 8 == 0)
            out << "\n.byt ";
        else
            out << ',';
        out << roundc(std::atan2(y, x) * 128 / pi);
    }

    out << "\nbullet_sin_table:";
    for(int i = 0; i != 256; ++i)
    {
        double const d = i;
        if(i % 8 == 0)
            out << "\n.byt ";
        else
            out << ',';
        out << roundc(std::sin(d * pi2 / 256.0) * 3.0);
    }

    out << "\nbullet_cos_table:";
    for(int i = 0; i != 256; ++i)
    {
        double const d = i;
        if(i % 8 == 0)
            out << "\n.byt ";
        else
            out << ',';
        out << roundc(std::cos(d * pi2 / 256.0) * 3.0);
    }

    out << "\nenemy_sin_table_sub:";
    for(int i = 0; i != 256; ++i)
    {
        double const d = i;
        if(i % 8 == 0)
            out << "\n.byt ";
        else
            out << ',';
        out << ".lobyte(" << roundi(std::sin(d * pi2 / 256.0) * 256.0) << ")";
    }

    out << "\nenemy_sin_table_lo:";
    for(int i = 0; i != 256; ++i)
    {
        double const d = i;
        if(i % 8 == 0)
            out << "\n.byt ";
        else
            out << ',';
        out << ".hibyte(" << roundi(std::sin(d * pi2 / 256.0) * 256.0) << ")";
    }

    out << "\nenemy_sin_table_hi:";
    for(int i = 0; i != 256; ++i)
    {
        double const d = i;
        if(i % 8 == 0)
            out << "\n.byt ";
        else
            out << ',';
        out << (roundi(std::sin(d * pi2 / 256.0) * 256.0) >= 0 ? 0 : 255);
    }

    out << "\nenemy_cos_table_sub:";
    for(int i = 0; i != 256; ++i)
    {
        double const d = i;
        if(i % 8 == 0)
            out << "\n.byt ";
        else
            out << ',';
        out << ".lobyte(" << roundi(std::cos(d * pi2 / 256.0) * 256.0) << ")";
    }

    out << "\nenemy_cos_table_lo:";
    for(int i = 0; i != 256; ++i)
    {
        double const d = i;
        if(i % 8 == 0)
            out << "\n.byt ";
        else
            out << ',';
        out << ".hibyte(" << roundi(std::cos(d * pi2 / 256.0) * 256.0) << ")";
    }

    out << "\nenemy_cos_table_hi:";
    for(int i = 0; i != 256; ++i)
    {
        double const d = i;
        if(i % 8 == 0)
            out << "\n.byt ";
        else
            out << ',';
        out << (roundi(std::cos(d * pi2 / 256.0) * 256.0) >= 0 ? 0 : 255);
    }



    // stars

    out << "\nlarge_star_sin_table_sub:";
    for(int i = 0; i != 256; ++i)
    {
        double const d = i;
        if(i % 8 == 0)
            out << "\n.byt ";
        else
            out << ',';
        out << ".lobyte(" << roundi(std::sin(d * pi2 / 256.0) * 192.0) << ")";
    }

    out << "\nlarge_star_sin_table_lo:";
    for(int i = 0; i != 256; ++i)
    {
        double const d = i;
        if(i % 8 == 0)
            out << "\n.byt ";
        else
            out << ',';
        out << ".hibyte(" << roundi(std::sin(d * pi2 / 256.0) * 192.0) << ")";
    }

    out << "\nlarge_star_cos_table_sub:";
    for(int i = 0; i != 256; ++i)
    {
        double const d = i;
        if(i % 8 == 0)
            out << "\n.byt ";
        else
            out << ',';
        out << ".lobyte(" << roundi(std::cos(d * pi2 / 256.0) * 192.0) << ")";
    }

    out << "\nlarge_star_cos_table_lo:";
    for(int i = 0; i != 256; ++i)
    {
        double const d = i;
        if(i % 8 == 0)
            out << "\n.byt ";
        else
            out << ',';
        out << ".hibyte(" << roundi(std::cos(d * pi2 / 256.0) * 192.0) << ")";
    }

    out << "\nmedium_star_sin_table_sub:";
    for(int i = 0; i != 256; ++i)
    {
        double const d = i;
        if(i % 8 == 0)
            out << "\n.byt ";
        else
            out << ',';
        out << ".lobyte(" << roundi(std::sin(d * pi2 / 256.0) * 128.0) << ")";
    }

    out << "\nmedium_star_sin_table_lo:";
    for(int i = 0; i != 256; ++i)
    {
        double const d = i;
        if(i % 8 == 0)
            out << "\n.byt ";
        else
            out << ',';
        out << ".hibyte(" << roundi(std::sin(d * pi2 / 256.0) * 128.0) << ")";
    }

    out << "\nmedium_star_cos_table_sub:";
    for(int i = 0; i != 256; ++i)
    {
        double const d = i;
        if(i % 8 == 0)
            out << "\n.byt ";
        else
            out << ',';
        out << ".lobyte(" << roundi(std::cos(d * pi2 / 256.0) * 128.0) << ")";
    }

    out << "\nmedium_star_cos_table_lo:";
    for(int i = 0; i != 256; ++i)
    {
        double const d = i;
        if(i % 8 == 0)
            out << "\n.byt ";
        else
            out << ',';
        out << ".hibyte(" << roundi(std::cos(d * pi2 / 256.0) * 128.0) << ")";
    }

    out << "\nsmall_star_sin_table_sub:";
    for(int i = 0; i != 256; ++i)
    {
        double const d = i;
        if(i % 8 == 0)
            out << "\n.byt ";
        else
            out << ',';
        out << ".lobyte(" << roundi(std::sin(d * pi2 / 256.0) * 64.0) << ")";
    }

    out << "\nsmall_star_sin_table_lo:";
    for(int i = 0; i != 256; ++i)
    {
        double const d = i;
        if(i % 8 == 0)
            out << "\n.byt ";
        else
            out << ',';
        out << ".hibyte(" << roundi(std::sin(d * pi2 / 256.0) * 64.0) << ")";
    }

    out << "\nsmall_star_cos_table_sub:";
    for(int i = 0; i != 256; ++i)
    {
        double const d = i;
        if(i % 8 == 0)
            out << "\n.byt ";
        else
            out << ',';
        out << ".lobyte(" << roundi(std::cos(d * pi2 / 256.0) * 64.0) << ")";
    }

    out << "\nsmall_star_cos_table_lo:";
    for(int i = 0; i != 256; ++i)
    {
        double const d = i;
        if(i % 8 == 0)
            out << "\n.byt ";
        else
            out << ',';
        out << ".hibyte(" << roundi(std::cos(d * pi2 / 256.0) * 64.0) << ")";
    }
}
