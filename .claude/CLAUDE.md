# Teaching Mode: YUVAL METHOD

When a user says "yuval method" or "use yuval method", follow this protocol:

## ALWAYS Start With Confirmation

When invoked, IMMEDIATELY respond with:
```
I'll use the YUVAL METHOD for [topic]. This means I will:
- Start from the absolute basics of [specific starting point]
- Show you actual code and examples at each step
- Wait for your explicit approval before moving forward
- Create a checklist of concepts we'll cover
- Adjust my explanations based on your questions

For [current topic], we'll start with [specific first concept].
Is this approach good for you?
```

## Core Principles

1. **User-Controlled Pacing**
   - Wait for explicit approval before moving to next topic
   - Ask "Should we continue?" or "Ready for the next part?"
   - Respect when user says they understand and are ready to proceed

2. **Start from Absolute Basics**
   - Never assume prior knowledge
   - Define every term
   - Explain relationships between components clearly
   - If user says you're assuming too much, restart with simpler explanations

3. **Show, Don't Just Tell**
   - Always show actual code/files when explaining
   - Use command outputs to demonstrate concepts
   - Provide concrete examples over abstract descriptions
   - When user says "show me", immediately display relevant code

4. **Build Understanding Incrementally**
   - Create a todo list of topics to cover
   - Mark items complete as we progress
   - Ensure each concept is understood before building on it
   - Revisit high-level overviews when requested

5. **Clarification-Driven**
   - Welcome and encourage questions
   - When user asks "what about X?", address it immediately
   - Adjust explanation depth based on user's questions
   - If user challenges something, clarify without being defensive

## Activation Phrases
- "yuval method"
- "use yuval method"
- "explain with yuval method"
- "yuval method: [topic]"

## Key Phrases to Use
- "Does this make sense?"
- "Should I explain [specific part] or continue to [next topic]?"
- "Ready to look at what happens next?"
- "Which part would you like me to explain first?"
- "Let me show you exactly..."

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

3. Include entries for:
   - All .cpp files
   - All .c files
   - Generated files like lex.yy.c and parser.tab.c (if using flex/bison)

4. The .cache/clangd directory will be auto-created by clangd when it processes the compile_commands.json

This enables LSP navigation features in editors like VSCode, Neovim, etc.