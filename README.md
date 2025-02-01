# Mini-Compiler Project

This project is a mini-compiler that performs lexical analysis, syntax and semantic analysis, intermediate code generation, and symbol table management. It uses **FLEX** for lexical analysis and **BISON** for syntax and semantic analysis.

## Project Files

- **`lexicale.l`**: FLEX file for lexical analysis.
- **`syntaxique.y`**: BISON file for syntax and semantic analysis.
- **`ts.c`**: Implementation of the symbol table.
- **`ts.h`**: Header file for the symbol table.
- **`codeinter.c`**: Intermediate code generation.
- **`codeinter.h`**: Header file for intermediate code generation.
- **`Exemple.txt`**: Example input file for testing.
- **`Exp2.txt`**: Another example input file.
- **`commande.txt`**: Commands or instructions for running the compiler.
- **`Color.h`**: Header file for color management (e.g., error messages).
- **`screenshot.png`**: Screenshot of the compiler's output or interface.

## How to Build and Run

1. **Install Dependencies**:
   - Ensure you have `flex` and `bison` installed.
   - On Ubuntu, run:
     ```bash
     sudo apt-get install flex bison
     ```

2. **Build the Compiler**:
   - Run the following commands:
     ```bash
     flex lexicale.l
     bison -d syntaxique.y
     gcc lex.yy.c syntaxique.tab.c ts.c codeinter.c -o compiler
     ```

3. **Run the Compiler**:
   - Execute the compiler with an input file:
     ```bash
     ./compiler Exemple.txt
     ```

## Testing

Use the provided test files (`Exemple.txt` and `Exp2.txt`) to test the compiler. You can also create your own test files.

## Error Handling

The compiler provides detailed error messages in the following format:
    File "Test", line 4, character 56: syntax error