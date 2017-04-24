#include <cstdlib>
#include <cstdio>
#include <fstream>
#include <iostream>
#include <vector>
#include <map>
#include <algorithm>

//pchar_animation_lo_table:

struct sprite_t
{
    int x_off;
    int y_off;
    int pattern;
    int attributes;
};

std::uint32_t sprite_byte(sprite_t sprite)
{
    unsigned char const x = sprite.x_off;
    unsigned char const y = sprite.y_off;
    unsigned char const p = sprite.pattern;
    unsigned char const a = sprite.attributes;
    return x | (y << 8) | (p << 16) | (a << 24);
}

bool operator==(sprite_t lhs, sprite_t rhs)
{
    return sprite_byte(lhs) == sprite_byte(rhs);
}

bool operator<(sprite_t lhs, sprite_t rhs)
{
    return sprite_byte(lhs) < sprite_byte(rhs);
}

using metasprite_t = std::vector<sprite_t>;

struct animation_t
{
    char const* name;
    int width;
    int height;
    int flags;
    std::vector<metasprite_t> frames;
};

unsigned char HFLIP = 1 << 6;
unsigned char VFLIP = 1 << 7;

constexpr unsigned char PATTERN(unsigned char x)
{
    return x;
}

static std::vector<animation_t> const animations =
{
    { "explosion", 24, 24, 0, {
        { 
            {  0,  0, PATTERN(0x65), 0 },
            {  0,  8, PATTERN(0x75), 0 },
            {  0, 16, PATTERN(0x65), VFLIP },

            {  8,  0, PATTERN(0x66), 0 },
            {  8, 16, PATTERN(0x66), VFLIP },

            { 16,  0, PATTERN(0x65), HFLIP },
            { 16,  8, PATTERN(0x75), HFLIP },
            { 16, 16, PATTERN(0x65), HFLIP | VFLIP },
        },
        { 
            {  0,  0, PATTERN(0x63), 0 },
            {  0,  8, PATTERN(0x73), 0 },
            {  0, 16, PATTERN(0x63), VFLIP },

            {  8,  0, PATTERN(0x64), 0 },
            {  8, 16, PATTERN(0x64), VFLIP },

            { 16,  0, PATTERN(0x63), HFLIP },
            { 16,  8, PATTERN(0x73), HFLIP },
            { 16, 16, PATTERN(0x63), HFLIP | VFLIP },
        },
        { 
            {  0,  0, PATTERN(0x61), 0 },
            {  0,  8, PATTERN(0x71), 0 },
            {  0, 16, PATTERN(0x61), VFLIP },

            {  8,  0, PATTERN(0x62), 0 },
            {  8,  8, PATTERN(0x72), 0 },
            {  8, 16, PATTERN(0x62), VFLIP },

            { 16,  0, PATTERN(0x61), HFLIP },
            { 16,  8, PATTERN(0x71), HFLIP },
            { 16, 16, PATTERN(0x61), HFLIP | VFLIP },
        },
        { 
            {  4,  4, PATTERN(0x60), 0 },
            {  4, 12, PATTERN(0x70), 0 },
            { 12,  4, PATTERN(0x60), HFLIP },
            { 12, 12, PATTERN(0x70), HFLIP },
        },
    }},
};


int get_width(std::vector<sprite_t> const& sprites)
{
    int x_max = 0;
    for(sprite_t sprite : sprites)
        if(sprite.x_off > x_max)
            x_max = sprite.x_off;
    return x_max + 8;
}

int get_height(std::vector<sprite_t> const& sprites)
{
    int y_max = 0;
    for(sprite_t sprite : sprites)
        if(sprite.y_off > y_max)
            y_max = sprite.y_off;
    return y_max + 8;
}

std::vector<sprite_t> hmirror(std::vector<sprite_t> sprites, int width)
{
    for(sprite_t& sprite : sprites)
    {
        sprite.x_off = width - sprite.x_off - 8;
        sprite.attributes ^= HFLIP;
    }
    return sprites;
}

std::vector<sprite_t> hmirror(std::vector<sprite_t> sprites)
{
    return hmirror(sprites, get_width(sprites));
}

int main(int argc, char** argv)
{
    if(argc != 2)
    {
        std::fprintf(stderr, "usage: %s [outfile]\n", argv[0]);
        return EXIT_FAILURE;
    }

    FILE* fp = std::fopen(argv[1], "w");
    if(!fp)
    {
        std::fprintf(stderr, "can't open file %s\n", argv[1]);
        return EXIT_FAILURE;
    }

    std::fprintf(fp, ".scope metasprite\n");

    /*
    out << "metasprite_lo_table:\n";
    for(std::size_t i = 0; i != explosion_metasprites.frames.size(); ++i)
        out << ".byt .lobyte(metasprite_" << i << ")\n";
    out << "metasprite_hi_table:\n";
    for(std::size_t i = 0; i != explosion_metasprites.frames.size(); ++i)
        out << ".byt .hibyte(metasprite_" << i << ")\n";
    out << '\n';
    */

    std::map<metasprite_t, unsigned> frame_map;

    unsigned next_frame_id = 0;
    for(animation_t const& animation : animations)
    {
        std::fprintf(fp, "%s:\n", animation.name);
        for(metasprite_t frame : animation.frames)
        {
            auto it = frame_map.find(frame);
            if(it == frame_map.end())
                it = frame_map.emplace(frame, next_frame_id++).first;
            std::fprintf(fp, ".addr m%i\n", it->second);
            if(animation.flags & HFLIP)
            {
                frame = hmirror(frame, animation.width);
                auto it = frame_map.find(frame);
                if(it == frame_map.end())
                    it = frame_map.emplace(frame, next_frame_id++).first;
                std::fprintf(fp, ".addr m%i\n", it->second);
            }
        }
    }

    std::fprintf(fp, "\n");

    std::vector<std::pair<unsigned, metasprite_t> > sorted_frames;
    for(auto&& pair : frame_map)
        sorted_frames.push_back(std::make_pair(pair.second, pair.first));
    std::sort(sorted_frames.begin(), sorted_frames.end());
    for(auto&& pair : sorted_frames)
    {
        std::fprintf(fp, "m%i:\n", pair.first);
        std::fprintf(fp, ".byt %lu\n", pair.second.size() * 4);
        for(sprite_t sprite : pair.second)
        {
            std::fprintf(fp, ".byt $%02x, $%02x, $%02x, $%02x\n", 
                         sprite.attributes,
                         sprite.pattern,
                         (unsigned char)sprite.x_off,
                         (unsigned char)sprite.y_off);
        }
    }

    std::fprintf(fp, ".endscope\n");
    std::fclose(fp);

    /*
    for(std::size_t i = 0; i != explosion_metasprites.frames.size(); ++i)
    {
        auto const& metasprite = explosion_metasprites.frames[i];
        out << "metasprite_" << i << ":\n";
        if(metasprite.empty())
            continue;
        out << ".byt " << metasprite.size() * 4 << '\n';
        for(sprite_t sprite : metasprite)
        {
            out << ".byt ";
            out << (int)sprite.attributes << ", ";
            out << (int)sprite.pattern << ", ";
            out << (int)sprite.x_off << ", ";
            out << (int)sprite.y_off << '\n';
        }
    }
    */
}
