import ast
import sys
from typing import Optional, Union

import astor


def find_node_for_line(tree: ast.AST, line_number: int) -> Optional[ast.AST]:
    """Find the innermost AST node containing the given line number."""

    class LineNodeFinder(ast.NodeVisitor):
        def __init__(self):
            self.result: Optional[ast.AST] = None

        def visit(self, node):
            if hasattr(node, "lineno"):
                if (
                    node.lineno
                    <= line_number
                    <= getattr(node, "end_lineno", node.lineno)
                ):
                    if self.result is None or node.lineno >= self.result.lineno:
                        self.result = node
            self.generic_visit(node)

    finder = LineNodeFinder()
    finder.visit(tree)
    return finder.result


def get_full_statement(code: str, start_line: int) -> str:
    """Get the full statement starting from the given line."""
    lines = code.split("\n")
    end_line = start_line
    paren_count = 0

    while end_line < len(lines):
        line = lines[end_line]
        paren_count += line.count("(") - line.count(")")
        if paren_count == 0 and not line.strip().endswith("\\"):
            break
        end_line += 1

    return "\n".join(lines[start_line : end_line + 1])


def get_block_for_line(code: str, line_number: int) -> str:
    """Get the code block containing the specified line number."""
    tree = ast.parse(code)
    node = find_node_for_line(tree, line_number)
    if node is None:
        return "No code block found for the given line number."

    # For assignments, expressions, and function calls, return the full statement
    if isinstance(node, (ast.Assign, ast.Expr, ast.Call)):
        return get_full_statement(code, node.lineno - 1)

    # Find the appropriate parent node that represents a block
    while not isinstance(
        node,
        (ast.FunctionDef, ast.ClassDef, ast.If, ast.For, ast.While, ast.Try, ast.With),
    ):
        if isinstance(node, ast.Module):
            # If we've reached the module level, return the full statement
            return get_full_statement(code, line_number - 1)
        parent = next(
            (
                parent
                for parent in ast.walk(tree)
                if node in ast.iter_child_nodes(parent)
            ),
            None,
        )
        if parent is None:
            return "Unable to find a containing block."
        node = parent

    # Convert the AST node back to source code
    return astor.to_source(node).strip()


if __name__ == "__main__":
    buffer_content = sys.stdin.read()
    line_number = int(sys.argv[1])
    result = get_block_for_line(buffer_content, line_number)
    print(result)

# Make sure to install astor in your Neovim Python environment:
# ~/.virtualenvs/neovim311/bin/pip install astor
