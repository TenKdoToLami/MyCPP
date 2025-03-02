#!/bin/bash

uMyCPP() {
    sudo gedit /usr/local/share/man/man1/MyCPP.1
}

uMyCPPsh() {
    sudo gedit /usr/local/bin/MyCPP.sh
}


MyCPP() {
    echo -e "\e[34mAvailable MyCPP Commands:\e[0m"
    echo -e "\e[32muMyCPP\e[0m                  - Opens man page in gedit for adjusting"
    echo -e "\e[32muMyCPPsh\e[0m                - Opens script in gedit for adjusting"
    echo -e "\e[32mMakeCPP <file.cpp> [f|g]\e[0m  - Compile C++ file (-f for sanitization, -g for debugging)"
    echo -e "\e[32mRunCPP [valgrind]\e[0m        - Run last compiled program (valgrind requires -g)"
    echo -e "\e[32mMakeRunCPP <file.cpp> [f|g] [valgrind]\e[0m - Compile and run in one step"
    echo -e "\e[32mTimeRunCPP\e[0m              - Run last compiled program and print execution time"
    echo -e "\e[32mListCPP\e[0m                 - List all .cpp files and compiled executables"
}


# Store last compiled file in a session variable
MakeCPP() {
    if [ $# -lt 1 ] || [ $# -gt 2 ]; then
        echo -e "\e[31mUsage: MakeCPP <source_file.cpp> [f|g]\e[0m"
        return 1
    fi

    source_file="$1"
    executable_name="${source_file%.*}.out"

    # Store the last compiled executable in a session variable
    export LAST_COMPILED_CPP="$executable_name"
    export LAST_COMPILED_WITH_G=0  # Reset debug flag

    # Define C++ standard version
    CPP_VERSION="-std=c++20"

    # Define compilation flags as an array
    COMPILER_FLAGS=(
        -Wall -Wextra -Wpedantic -Wshadow -Wformat=2
        -Wsign-conversion -Wnull-dereference -Wdouble-promotion
        -Werror -O2
    )

    # Variable to store extra flag description
    EXTRA_FLAG=""

    # Check optional second argument
    if [ $# -eq 2 ]; then
        case "$2" in
            f) COMPILER_FLAGS+=("-fsanitize=address") EXTRA_FLAG="fsanitize=address" ;;
            g) COMPILER_FLAGS+=("-g") EXTRA_FLAG="debugging (-g)" export LAST_COMPILED_WITH_G=1 ;;  # Mark debug flag
            *) echo -e "\e[31mInvalid option. Use 'f' for -fsanitize=address or 'g' for -g\e[0m" && return 1 ;;
        esac
    fi

    # Compile the program
    g++ $CPP_VERSION "${COMPILER_FLAGS[@]}" "$source_file" -o "$executable_name"

    if [ $? -eq 0 ]; then
        if [ -n "$EXTRA_FLAG" ]; then
            echo -e "\e[32mCompilation with $EXTRA_FLAG successful. Executable saved as $executable_name\e[0m"
        else
            echo -e "\e[32mCompilation successful. Executable saved as $executable_name\e[0m"
        fi
    else
        echo -e "\e[31mCompilation failed.\e[0m"
        return 1
    fi
}

RunCPP() {
    if [ -n "$LAST_COMPILED_CPP" ] && [ -f "$LAST_COMPILED_CPP" ]; then
        if [ "$1" = "valgrind" ]; then  
            if [ "$LAST_COMPILED_WITH_G" -eq 0 ]; then
                echo -e "\e[31mError: Valgrind requires the program to be compiled with -g (debugging symbols).\e[0m"
                return 1
            fi
            echo -e "\e[33mRunning with Valgrind: $LAST_COMPILED_CPP\e[0m"
            valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes ./"$LAST_COMPILED_CPP"
        else
            echo -e "\e[32mRunning: $LAST_COMPILED_CPP\e[0m"
            ./"$LAST_COMPILED_CPP"
        fi
        return $?
    else
        echo -e "\e[31mError: No compiled file found. Compile a file first.\e[0m"
        return 1
    fi
}

ListCPP() {
    echo -e "\e[36mC++ Source Files:\e[0m"
    ls *.cpp 2>/dev/null || echo "No C++ source files found."
    
    echo -e "\e[36mCompiled Executables:\e[0m"
    ls *.out 2>/dev/null || echo "No compiled executables found."
}

MakeRunCPP() {
    MakeCPP "$1" "$2" && RunCPP "$3"
}

TimeRunCPP() {
    if [ -n "$LAST_COMPILED_CPP" ] && [ -f "$LAST_COMPILED_CPP" ]; then
        /usr/bin/time -f "%e" ./"$LAST_COMPILED_CPP" 2>&1
    else
        echo "No compiled file found."
    fi
}

export -f MakeCPP RunCPP ListCPP MakeRunCPP TimeRunCPP MyCPP uMyCPP uMyCPPsh
