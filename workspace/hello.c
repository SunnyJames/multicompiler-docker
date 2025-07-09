#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[]) {
    char buffer[100];

    if (argc < 2) {
        printf("Usage: %s <input>\n", argv[0]);
        return 1;
    }

    // Vulnerable usage: user input used directly as the format string
    strcpy(buffer, argv[1]);
    printf(buffer);  // Vulnerability: format string attack possible

    return 0;
}
