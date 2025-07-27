
# Generate compile_commands.json for C/C++ Projects

When asked to "do the compile_commands.json thing" or similar:

1. Check the Makefile to identify:

   - Compiler (usually g++ or gcc)
   - Compilation flags (like -std=c++17, -ggdb, etc.)
   - Source files being compiled

2. Create a compile_commands.json file with entries for each source file:

   ```json
   [
     {
       "directory": "<full path to project directory>",
       "command": "<compiler> <flags> -c <source_file>",
       "file": "<source_file>"
     }
   ]
   ```

3. Include entries for ALL C/C++ files:

   - All .cpp files
   - All .c files
   - All .hpp files
   - All .h files
   - Generated files like lex.yy.c and parser.tab.c (if using flex/bison)
   - Any other header files (.hxx, .hh, etc.)

4. The .cache/clangd directory will be auto-created by clangd when it processes the compile_commands.json

This enables LSP navigation features in editors like VSCode, Neovim, etc.

# Yuval's Environment Notes

- The dotfiles repository at `/Users/yuvalspiegel/dotfiles` contains all .config files
- When looking for config files (like yazi, nvim, etc.), check `/Users/yuvalspiegel/dotfiles/.config/` first


