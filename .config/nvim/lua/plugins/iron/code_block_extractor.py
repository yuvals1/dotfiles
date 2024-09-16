import ast
import sys
from typing import List, Optional, Tuple


class DecoratedNodeVisitor(ast.NodeVisitor):
    def __init__(self):
        self.decorated_nodes = []

    def visit_FunctionDef(self, node):
        if node.decorator_list:
            start_line = min(decorator.lineno for decorator in node.decorator_list)
            self.decorated_nodes.append((start_line, node.end_lineno, node))
        self.generic_visit(node)

    def visit_ClassDef(self, node):
        if node.decorator_list:
            start_line = min(decorator.lineno for decorator in node.decorator_list)
            self.decorated_nodes.append((start_line, node.end_lineno, node))
        self.generic_visit(node)


def find_decorated_node(
    decorated_nodes: List[Tuple[int, int, ast.AST]], line_number: int
) -> Optional[Tuple[int, int, ast.AST]]:
    for start, end, node in decorated_nodes:
        if start <= line_number <= end:
            return start, end, node
    return None


def get_block_info(code: str, line_number: int) -> Tuple[Optional[ast.AST], int, int]:
    tree = ast.parse(code)
    visitor = DecoratedNodeVisitor()
    visitor.visit(tree)

    decorated_node = find_decorated_node(visitor.decorated_nodes, line_number)
    if decorated_node:
        return decorated_node[2], decorated_node[0], decorated_node[1]

    for node in ast.walk(tree):
        if hasattr(node, "lineno") and hasattr(node, "end_lineno"):
            if node.lineno <= line_number <= node.end_lineno:
                if isinstance(node, (ast.FunctionDef, ast.ClassDef)):
                    start_line = node.lineno
                    if node.decorator_list:
                        start_line = min(
                            decorator.lineno for decorator in node.decorator_list
                        )
                    return node, start_line, node.end_lineno
                elif isinstance(
                    node,
                    (
                        ast.If,
                        ast.For,
                        ast.While,
                        ast.Try,
                        ast.With,
                        ast.Assign,
                        ast.Expr,
                        ast.Call,
                        ast.Import,
                        ast.ImportFrom,
                    ),
                ):
                    return node, node.lineno, node.end_lineno

    return None, line_number, line_number


def get_block_for_line(code: str, line_number: int) -> str:
    node, start, end = get_block_info(code, line_number)
    lines = code.split("\n")
    return "\n".join(lines[start - 1 : end])


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
