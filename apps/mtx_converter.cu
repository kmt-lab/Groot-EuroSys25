#include <groot.h>
#include <string>
#include <filesystem>

using namespace groot;

// Configuration for the converter application
struct ConverterConfig {
    std::string input_file;
    std::string output_file;
    std::string output_original_file;
    ReorderAlgo reorder = ReorderAlgo::Groot;
};

// Generate automatic filenames based on input file
void generate_automatic_filenames(ConverterConfig& config) {
    if (config.input_file.empty()) {
        return;
    }

    // Extract base name without extension
    std::string base_name;
    size_t last_dot = config.input_file.find_last_of(".");
    size_t last_slash = config.input_file.find_last_of("/\\");

    if (last_slash == std::string::npos) {
        // No path separator found
        base_name = config.input_file.substr(0, last_dot);
    } else {
        // Extract filename part after the path separator
        base_name = config.input_file.substr(last_slash + 1, last_dot - last_slash - 1);
        // Add directory path back
        base_name = config.input_file.substr(0, last_slash + 1) + base_name;
    }

    // If output files not specified, set default names
    if (config.output_original_file.empty()) {
        config.output_original_file = base_name + ".mtx";
    }

    if (config.output_file.empty()) {
        config.output_file = base_name + "_groot.mtx";
    }
}

// Parse command-line arguments for the converter
ConverterConfig converter_program_options(int argc, char* argv[])
{
    ConverterConfig config;
    int opt;
    if (argc == 1) {
        printf("Usage: %s ... \n%s", argv[0],
            "              [-i input_file] Input CSR file\n"
            "              [-o output_file] (Optional) Output MTX file after reordering\n"
            "              [-p output_original_file] (Optional) Output MTX file before reordering\n"
            "              [-r reorder_algorithm (0: none, 1: groot)]\n\n"
            "If output files are not specified, they will be derived from the input filename:\n"
            "For input 'file.csr', outputs will be 'file.mtx' and 'file_reordered.mtx'\n");
        std::exit(EXIT_FAILURE);
    }
    while ((opt = getopt(argc, argv, "i:o:p:r:")) != -1) {
        switch (opt) {
            case 'i':
                config.input_file = optarg;
                break;
            case 'o':
                config.output_file = optarg;
                break;
            case 'p':
                config.output_original_file = optarg;
                break;
            case 'r':
                config.reorder = static_cast<ReorderAlgo>(std::stoi(optarg));
                break;
            default:
                printf("Usage: %s ... \n%s", argv[0],
                    "              [-i input_file] Input CSR file\n"
                    "              [-o output_file] (Optional) Output MTX file after reordering\n"
                    "              [-p output_original_file] (Optional) Output MTX file before reordering\n"
                    "              [-r reorder_algorithm (0: none, 1: groot)]\n");
                exit(EXIT_FAILURE);
        }
    }

    // Generate automatic filenames if not specified
    generate_automatic_filenames(config);

    printf("--------experimental setting--------\n");
    if (!config.input_file.empty()) {
        printf("input path: %s\n", config.input_file.c_str());
    }
    printf("output original path: %s\n", config.output_original_file.c_str());
    printf("reorder algorithm: %s\n", reorder_algo_to_string(config.reorder));
    printf("output reordered path: %s\n", config.output_file.c_str());

    return config;
}

int main(int argc, char** argv)
{
    cudaSetDevice(0);

    CsrMatrix<int, float, device_memory> A_csr;

    ConverterConfig config = converter_program_options(argc, argv);

    // Read the input matrix
    read_matrix_file(A_csr, config.input_file);

    // Write the original matrix to a MTX file
    write_matrix_file(A_csr, config.output_original_file);

    // Reorder the graph
    reorder_graph(config, A_csr);

    // Write the reordered matrix to a MTX file
    write_matrix_file(A_csr, config.output_file);

    return 0;
}