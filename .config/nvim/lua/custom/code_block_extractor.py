import ast
import sys


def get_block_for_line(code: str, line_number: int) -> str:
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
                    ),
                ):
                    return ast.unparse(node)
                elif isinstance(node, (ast.Assign, ast.Expr, ast.Call)):
                    return ast.unparse(node)

    # If no specific block is found, return the line itself
    return code.split("\n")[line_number - 1]


if __name__ == "__main__":
    buffer_content = sys.stdin.read()
    line_number = int(sys.argv[1])
    result = get_block_for_line(buffer_content, line_number)
    print(result)
