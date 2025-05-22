
#pragma once
#include <getopt.h>
#include <string>

namespace groot {

struct Config {
    std::string input_file;
    std::string output_file;
    unsigned i_k = 200;
    unsigned s_k = 250;
};

std::string option_hints = "              [-i input_file]\n"
                           "              [-o output_file]\n"
                           "              [-k i_k] (default: 200)\n"
                           "              [-s s_k] (default: 250)\n";


auto program_options(int argc, char* argv[])
{
    Config config;
    int    opt;
    if (argc == 1) {
        printf("Usage: %s ... \n%s", argv[0], option_hints.c_str());
        std::exit(EXIT_FAILURE);
    }
    while ((opt = getopt(argc, argv, "e:r:i:c:o:s:b:v:")) != -1) {
        switch (opt) {
            case 'i':
                config.input_file = optarg;
                break;
            case 'o':
                config.output_file = optarg;
                break;
            case 'k':
                config.i_k = std::stoul(optarg);
                break;
            case 's':
                config.s_k = std::stoul(optarg);
                break;
            default:
                printf("Usage: %s ... \n%s", argv[0], option_hints.c_str());
                exit(EXIT_FAILURE);
        }
    }

    printf("--------experimental setting--------\n");
    printf("reorder algorithm: Groot\n");

    if (!config.input_file.empty()) {
        printf("input path: %s\n", config.input_file.c_str());
    }

    if (!config.output_file.empty()) {
        printf("output path: %s\n", config.output_file.c_str());
    }

    return config;
}
}  // namespace groot
