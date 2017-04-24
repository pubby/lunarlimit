#include <cmath>
#include <iostream>
#include <fstream>
#include <cstdlib>

#include <glm/glm.hpp>
#include <glm/gtx/matrix_transform_2d.hpp>

constexpr float pi = 3.14159265359;
constexpr float pi2 = 2.0 * 3.14159265359;

int roundc(float d)
{
    return (unsigned char)std::round(d);
}

int roundi(float d)
{
    return std::round(d);
}

void write_wave(std::ostream& out, int w, int h, unsigned char angle)
{
    out << ".byt " << int(angle) << '\n';
    out << ".byt " << (w * h) << '\n';
    float dw = w * 16;
    float dh = h * 16;
    int q = 128.5f * 256.0f;
    for(int y = 0; y < h; ++y)
    for(int x = 0; x < w; ++x)
    {
        float dx = x * 16;
        float dy = y * 16;
        //glm::vec3 v(dx - dw / 2.0f, dy + 200.0f, 0.0f);
        glm::vec3 v(-dx - 240.0f, dy - dy / 2.0f, 0.0f);
        v = v * glm::rotate(glm::mat3(1.0f), (256 - angle) * pi / 128.0f);
        out << ".byt .lobyte(" << int(v.x) + q << ")";
        out <<    ", .hibyte(" << int(v.x) + q << ")";
        out <<    ", .lobyte(" << int(v.y) + q << ")";
        out <<    ", .hibyte(" << int(v.y) + q << ")";
        out << '\n';
    }
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

    out << "wave_lo:\n";
    for(int i = 0; i < 64; ++i)
        out << ".byt .lobyte(wave" << i << ")\n";
    out << "wave_hi:\n";
    for(int i = 0; i < 64; ++i)
        out << ".byt .hibyte(wave" << i << ")\n";

    out << "wave:\n";
    std::srand(0);
    unsigned char r = 0;
    for(int i = 0; i < 64; ++i)
    {
        out << "wave" << i << ":\n";
        int n = std::min(std::max(rand() % (i + 5), 2), 28);
        int x = (rand() % n / 2) + 1;
        int y = n / x;
        r += (rand() % 128u) + 64;
        write_wave(out, x, y, r);
    }
}
