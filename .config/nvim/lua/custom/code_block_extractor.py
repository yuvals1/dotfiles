import ast
import sys
from typing import Optional, Tuple


def get_block_info(code: str, line_number: int) -> Tuple[Optional[ast.AST], int, int]:
    tree = ast.parse(code)

    for node in ast.walk(tree):
        if hasattr(node, "lineno") and hasattr(node, "end_lineno"):
            if node.lineno <= line_number <= node.end_lineno:
                if isinstance(
                    node,
                    (
                        ast.FunctionDef,
                        ast.ClassDef,
                        ast.If,
                        ast.For,
                        ast.While,
                        ast.Try,
                        ast.With,
                        ast.Assign,
                        ast.Expr,
                        ast.Call,
                    ),
                ):
                    return node, node.lineno, node.end_lineno

    # If no specific block is found, return None and the line number itself
    return None, line_number, line_number


def get_block_for_line(code: str, line_number: int) -> str:
    node, start, end = get_block_info(code, line_number)
    if node:
        return ast.unparse(node)
    else:
        return code.split("\n")[line_number - 1]


def get_block_range(code: str, line_number: int) -> str:
    _, start, end = get_block_info(code, line_number)
    return f"{start},{end}"


if __name__ == "__main__":
    buffer_content = sys.stdin.read()
    line_number = int(sys.argv[1])
    command = sys.argv[2] if len(sys.argv) > 2 else "block"

    if command == "block":
        result = get_block_for_line(buffer_content, line_number)
    elif command == "range":
        result = get_block_range(buffer_content, line_number)
    else:
        result = f"Unknown command: {command}"

    print(result)
