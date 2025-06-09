#ifndef VISITOR_HPP
#define VISITOR_HPP
#include <stack>
#include <map>
#include <memory>
#include <string>
#include <vector>
#include <list>

namespace ast {
    enum BuiltInType {
        VOID,
        BOOL,
        BYTE,
        INT,
        STRING
    };    
    class Num;
    class NumB;
    class String;
    class Bool;
    class ID;
    class BinOp;
    class RelOp;
    class Not;
    class And;
    class Or;
    // class Type;
    class Cast;
    class ExpList;
    class Call;
    class Statements;
    class Break;
    class Continue;
    class Return;
    class If;
    class While;
    class VarDecl;
    class Assign;
    class Formal;
    class Formals;
    class FuncDecl;
    class Funcs;
    class ArrayType;
    class PrimitiveType;
    class ArrayDereference;
    class ArrayAssign;
}

class Symbol_Table_Entry{
    public:
        std::string name;
        Symbol_Table_Entry(const std::string& name) : name(name) {}
    };
    class Var_Entry : public Symbol_Table_Entry {
        public:
        ast::BuiltInType type;
        int offset;
        Var_Entry(const std::string& name, int offset, ast::BuiltInType type) : 
        Symbol_Table_Entry(name), type(type), offset(offset) {}
    };
    class Array_Entry : public Symbol_Table_Entry {
        public:
        ast::BuiltInType var_type;
        int length;
        int offset;
        Array_Entry(const std::string& name, int offset, ast::BuiltInType var_type, int length) : 
        Symbol_Table_Entry(name), var_type(var_type), length(length), offset(offset) {}
    };
    class Func_Entry : public Symbol_Table_Entry {
        public:
        ast::BuiltInType ret_type;
        std::vector<ast::BuiltInType> parameter_types;
        Func_Entry(const std::string& name, ast::BuiltInType ret_type, std::vector<ast::BuiltInType> param_types) : 
        Symbol_Table_Entry(name), ret_type(ret_type), parameter_types(param_types) {}
    };

class Symbol_table{
public:
    Symbol_table* parent;
    std::map<std::string, std::shared_ptr<Symbol_Table_Entry>> table;
    Symbol_table(Symbol_table* parent = nullptr) : parent(parent), table() {}
};
    

class Visitor {
public:
    virtual void visit(ast::Num &node) = 0;

    virtual void visit(ast::NumB &node) = 0;

    virtual void visit(ast::String &node) = 0;

    virtual void visit(ast::Bool &node) = 0;

    virtual void visit(ast::ID &node) = 0;

    virtual void visit(ast::BinOp &node) = 0;

    virtual void visit(ast::RelOp &node) = 0;

    virtual void visit(ast::Not &node) = 0;

    virtual void visit(ast::And &node) = 0;

    virtual void visit(ast::Or &node) = 0;

    // virtual void visit(ast::Type &node) = 0;

    virtual void visit(ast::ArrayType &node) = 0;

    virtual void visit(ast::PrimitiveType &node) = 0;

    virtual void visit(ast::ArrayDereference &node) = 0;

    virtual void visit(ast::ArrayAssign &node) = 0;

    virtual void visit(ast::Cast &node) = 0;

    virtual void visit(ast::ExpList &node) = 0;

    virtual void visit(ast::Call &node) = 0;

    virtual void visit(ast::Statements &node) = 0;

    virtual void visit(ast::Break &node) = 0;

    virtual void visit(ast::Continue &node) = 0;

    virtual void visit(ast::Return &node) = 0;

    virtual void visit(ast::If &node) = 0;

    virtual void visit(ast::While &node) = 0;

    virtual void visit(ast::VarDecl &node) = 0;

    virtual void visit(ast::Assign &node) = 0;

    virtual void visit(ast::Formal &node) = 0;

    virtual void visit(ast::Formals &node) = 0;

    virtual void visit(ast::FuncDecl &node) = 0;

    virtual void visit(ast::Funcs &node) = 0;
};

#endif

