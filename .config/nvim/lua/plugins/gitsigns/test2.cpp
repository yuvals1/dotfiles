#include "semantic_visitor.hpp"
#include "nodes.hpp"


#define NA 0

using namespace std;

// helpers
vector<string> types_to_strings(vector<ast::BuiltInType> vec) {
    vector<string> out;
    for (auto type: vec) {
        switch (type)
        {
        case ast::BuiltInType::INT:
            out.push_back("INT");
            break;

        case ast::BuiltInType::BOOL:
        out.push_back("BOOL");
        break;

        case ast::BuiltInType::BYTE:
        out.push_back("BYTE");
        break;
        
        case ast::BuiltInType::STRING:
        out.push_back("STRING");
        break;

        
        case ast::BuiltInType::VOID:
        out.push_back("VOID");
        break;
        
        default:
            break;
        }
    }
    return out;
}

bool assignable(ast::BuiltInType lvalue_type, ast::BuiltInType rvalue_type) {
    if (lvalue_type == rvalue_type)
        return true;
    if (lvalue_type == ast::BuiltInType::INT && rvalue_type == ast::BuiltInType::BYTE)
        return true;
    return false;
}

shared_ptr<Symbol_Table_Entry> Semantic_visitor::find_in_stack(string name) {
    Symbol_table* current = &stack.top();

    while(current != nullptr) {
        if (auto res = current->table.find(name); res != current->table.end())
            return res->second;
        current = current->parent;
    }
    return nullptr;
}

void Semantic_visitor::open_scope() {
    printer.beginScope();
    Symbol_table* current_parent = stack.empty() ? nullptr : &stack.top();
    stack.push(Symbol_table(current_parent));
    offsets.push(offsets.top());
}

void Semantic_visitor::close_scope() {
    printer.endScope();
    stack.pop();
    offsets.pop();
}

void Semantic_visitor::add_function_entry(const std::string& name, ast::BuiltInType ret_type, 
                                         const std::vector<ast::BuiltInType>& params) {
    auto func = std::make_shared<Func_Entry>(name, ret_type, params);
    stack.top().table[name] = func;
    printer.emitFunc(name, ret_type, params);
}

void Semantic_visitor::add_function_to_sym_tab(shared_ptr<ast::FuncDecl> func) {
    if (find_in_stack(func->id->value) != nullptr)
        output::errorDef(func->line, func->id->value);

    auto primitive_type = std::dynamic_pointer_cast<ast::PrimitiveType>(func->return_type);
    if (!primitive_type)
        output::errorMismatch(func->line);

    std::vector<ast::BuiltInType> params;
    for (auto param: func->formals->formals) {
        auto primitive_type = std::dynamic_pointer_cast<ast::PrimitiveType>(param->type);
        if (!primitive_type)
            output::errorMismatch(param->line);
        params.push_back(primitive_type->type);
    }

    add_function_entry(func->id->value, primitive_type->type, params);
}

void Semantic_visitor::handle_primitive_var_decl(ast::VarDecl &node, shared_ptr<ast::PrimitiveType> prim_type) {
    if (node.init_exp != nullptr) {
        node.init_exp->accept(*this);
        if (!assignable(prim_type->type, node.init_exp->type)) {
            output::errorMismatch(node.line);
        }
    }
    
    stack.top().table[node.id->value] = make_shared<Var_Entry>(
        node.id->value, offsets.top(), prim_type->type);
    printer.emitVar(node.id->value, prim_type->type, offsets.top());
    offsets.top()++;
}

void Semantic_visitor::handle_array_var_decl(ast::VarDecl &node, shared_ptr<ast::ArrayType> array_type) {
    if (node.init_exp != nullptr) {
        output::errorMismatch(node.line);
    }
    array_type->accept(*this);
    
    int array_size;
    if (auto num = dynamic_pointer_cast<ast::Num>(array_type->length)) {
        array_size = num->value;
    } else if (auto numB = dynamic_pointer_cast<ast::NumB>(array_type->length)) {
        array_size = numB->value;
    }
    
    stack.top().table[node.id->value] = make_shared<Array_Entry>(
        node.id->value, offsets.top(), array_type->type, array_size);
    printer.emitArr(node.id->value, array_type->type, array_size, offsets.top());
    offsets.top() += array_size; // Arrays take multiple offset units
}

// visitor functions
void Semantic_visitor::visit(ast::Funcs &node) {
    stack.push(Symbol_table());
    offsets.push(0);
    add_function_entry("print", ast::BuiltInType::VOID, {ast::BuiltInType::STRING});
    add_function_entry("printi", ast::BuiltInType::VOID, {ast::BuiltInType::INT});
    for (auto func : node.funcs) 
        add_function_to_sym_tab(func);
    auto main = find_in_stack("main");
    if (main == nullptr)
        output::errorMainMissing();
    auto func_main = dynamic_pointer_cast<Func_Entry>(main);
    if (func_main->ret_type != ast::BuiltInType::VOID || func_main->parameter_types.size() > 0)
        output::errorMainMissing();
    for (auto func : node.funcs) 
        func->accept(*this);
    stack.pop();
    offsets.pop();
}

void Semantic_visitor::visit(ast::FuncDecl &node) {
    auto return_type = dynamic_pointer_cast<ast::PrimitiveType>(node.return_type);
    function_return_types.push(return_type->type);
    open_scope();
    auto& formals_vec = node.formals->formals;
    for (size_t i = 0; i < node.formals->formals.size(); i++)
    {
        auto type = dynamic_pointer_cast<ast::PrimitiveType>(formals_vec[i]->type);
        if (!type)
            output::errorMismatch(node.line);

        stack.top().table[formals_vec[i]->id->value] = make_shared<Var_Entry>(formals_vec[i]->id->value, -(i+1), type->type);
        printer.emitVar(formals_vec[i]->id->value, type->type, -(i+1));
    }
    
    node.body->accept(*this);
    close_scope();
    function_return_types.pop();
}

void Semantic_visitor::visit(ast::Formals &node) {}

void Semantic_visitor::visit(ast::Formal &node) {}

void Semantic_visitor::visit(ast::Assign &node){
    const auto& lvalue = find_in_stack(node.id->value);
    if (lvalue == nullptr) 
        output::errorUndef(node.line, node.id->value);
    auto lvalue_casted = dynamic_pointer_cast<Var_Entry>(lvalue);
    if (!lvalue_casted)
    {
        if (dynamic_pointer_cast<Func_Entry>(lvalue))
            output::errorDefAsFunc(node.line, node.id->value);
        
        else
            output::ErrorInvalidAssignArray(node.line, node.id->value);
    }
    node.exp->accept(*this);
    if (!assignable(lvalue_casted->type, node.exp->type))
        output::errorMismatch(node.line);
}

void Semantic_visitor::visit(ast::VarDecl &node) {
    if (find_in_stack(node.id->value) != nullptr) {
        output::errorDef(node.line, node.id->value);
    }
    
    if (auto prim_type = dynamic_pointer_cast<ast::PrimitiveType>(node.type)) {
        handle_primitive_var_decl(node, prim_type);
    } else if (auto array_type = dynamic_pointer_cast<ast::ArrayType>(node.type)) {
        handle_array_var_decl(node, array_type);
    } else {
        output::errorMismatch(node.line);
    }
}

void Semantic_visitor::visit(ast::If &node) {
    node.condition->accept(*this);
    if (node.condition->type != ast::BuiltInType::BOOL)
        output::errorMismatch(node.line);
    
    open_scope();
    open_scope();
    node.then->accept(*this);
    close_scope();
    close_scope();
    
    if (node.otherwise != nullptr) {
        open_scope();
        node.otherwise->accept(*this);
        close_scope();
    }
}

void Semantic_visitor::visit(ast::While &node) {
    node.condition->accept(*this);
    if (node.condition->type != ast::BuiltInType::BOOL)
        output::errorMismatch(node.line);
    
    inside_while_stack.push(true);
    
    open_scope();
    open_scope();
    node.body->accept(*this);
    close_scope();
    close_scope();
    
    inside_while_stack.pop();
}

void Semantic_visitor::visit(ast::Return &node) {
    if (node.exp != nullptr) {
        node.exp->accept(*this);
        auto expected_return_type = function_return_types.top();
        if(!assignable(expected_return_type, node.exp->type))
            output::errorMismatch(node.line);
    }
    else {
        if (function_return_types.top() != ast::BuiltInType::VOID)
            output::errorMismatch(node.line);
    }
}

void Semantic_visitor::visit(ast::Continue &node) {
    if (inside_while_stack.empty())
        output::errorUnexpectedContinue(node.line);
}

void Semantic_visitor::visit(ast::Break &node) {
    if (inside_while_stack.empty())
        output::errorUnexpectedBreak(node.line);
}

void Semantic_visitor::visit(ast::Statements &node) {
    for (auto statement : node.statements) {
        statement->accept(*this);
    }
}

void Semantic_visitor::visit(ast::Call &node) {
    string func_name = node.func_id->value;
    auto sym_tab_entry = find_in_stack(func_name);
    if (sym_tab_entry == nullptr)
        output::errorUndefFunc(node.line, func_name);
    auto func_entry = dynamic_pointer_cast<Func_Entry>(sym_tab_entry);
    if (func_entry == nullptr)
        output::errorDefAsVar(node.line, func_name);
    
    auto expected_args = types_to_strings(func_entry->parameter_types);
    if (func_entry->parameter_types.size() != node.args->exps.size())
        output::errorPrototypeMismatch(node.line, func_name, expected_args);
    for (size_t i = 0; i < func_entry->parameter_types.size(); i++)
    {
	auto id = dynamic_pointer_cast<ast::ID>(node.args->exps[i]);
        if (id) {
            auto id_entry = find_in_stack(id->value);
            if (dynamic_pointer_cast<Array_Entry>(id_entry)) {
                // Arrays in function calls get function-specific error message
                output::errorPrototypeMismatch(node.line, func_name, expected_args);
            }
        }
    node.args->exps[i]->accept(*this);
        if (!assignable(func_entry->parameter_types[i], node.args->exps[i]->type))
            output::errorPrototypeMismatch(node.line, func_name, expected_args);
    }

    node.type = func_entry->ret_type;
}

void Semantic_visitor::visit(ast::Cast &node) {
    node.exp->accept(*this);
    if (node.exp->type != ast::BuiltInType::INT && node.exp->type != ast::BuiltInType::BYTE)
        output::errorMismatch(node.line);
    if (node.target_type->type!= ast::BuiltInType::INT && node.target_type->type != ast::BuiltInType::BYTE)
        output::errorMismatch(node.line);
    node.type = node.target_type->type;
}

void Semantic_visitor::visit(ast::ExpList &node) {}
//

void Semantic_visitor::visit(ast::Num &node) {
    node.type = ast::BuiltInType::INT;
}

void Semantic_visitor::visit(ast::NumB &node) {
    if (node.value > 255) {
        output::errorByteTooLarge(node.line, node.value);
    }
    node.type = ast::BuiltInType::BYTE;
}

void Semantic_visitor::visit(ast::String &node) {
    node.type = ast::BuiltInType::STRING;
}

void Semantic_visitor::visit(ast::Bool &node) {
    node.type = ast::BuiltInType::BOOL;
}

void Semantic_visitor::visit(ast::ID &node) {
    auto entry = find_in_stack(node.value);
    if (entry == nullptr) {
        output::errorUndef(node.line, node.value);
    }
    
    if (auto var_entry = dynamic_pointer_cast<Var_Entry>(entry)) {
        node.type = var_entry->type;
    } else if (auto array_entry = dynamic_pointer_cast<Array_Entry>(entry)) {
        output::errorMismatch(node.line);
    } else {
        output::errorDefAsFunc(node.line, node.value);
    }
}

void Semantic_visitor::visit(ast::BinOp &node) {
    node.left->accept(*this);
    node.right->accept(*this);
    
    if ((node.left->type != ast::BuiltInType::INT && node.left->type != ast::BuiltInType::BYTE) ||
        (node.right->type != ast::BuiltInType::INT && node.right->type != ast::BuiltInType::BYTE)) {
        output::errorMismatch(node.line);
    }
    
    if (node.left->type == ast::BuiltInType::INT || node.right->type == ast::BuiltInType::INT) {
        node.type = ast::BuiltInType::INT;
    } else {
        node.type = ast::BuiltInType::BYTE;
    }
}

void Semantic_visitor::visit(ast::RelOp &node) {
    node.left->accept(*this);
    node.right->accept(*this);
    
    if ((node.left->type != ast::BuiltInType::INT && node.left->type != ast::BuiltInType::BYTE) ||
        (node.right->type != ast::BuiltInType::INT && node.right->type != ast::BuiltInType::BYTE)) {
        output::errorMismatch(node.line);
    }
    
    node.type = ast::BuiltInType::BOOL;
}

void Semantic_visitor::visit(ast::Not &node) {
    node.exp->accept(*this);
    
    if (node.exp->type != ast::BuiltInType::BOOL) {
        output::errorMismatch(node.line);
    }
    
    node.type = ast::BuiltInType::BOOL;
}

void Semantic_visitor::visit(ast::And &node) {
    node.left->accept(*this);
    node.right->accept(*this);
    
    if (node.left->type != ast::BuiltInType::BOOL || node.right->type != ast::BuiltInType::BOOL) {
        output::errorMismatch(node.line);
    }
    
    node.type = ast::BuiltInType::BOOL;
}

void Semantic_visitor::visit(ast::Or &node) {
    node.left->accept(*this);
    node.right->accept(*this);
    
    if (node.left->type != ast::BuiltInType::BOOL || node.right->type != ast::BuiltInType::BOOL) {
        output::errorMismatch(node.line);
    }
    
    node.type = ast::BuiltInType::BOOL;
}

void Semantic_visitor::visit(ast::ArrayType &node) {
    node.length->accept(*this);
    
    auto num = dynamic_pointer_cast<ast::Num>(node.length);
    auto numB = dynamic_pointer_cast<ast::NumB>(node.length);
    
    if (!num && !numB) {
        output::errorMismatch(node.line);
    }
}

void Semantic_visitor::visit(ast::PrimitiveType &node) {}

std::shared_ptr<Array_Entry> Semantic_visitor::validate_array_access(std::shared_ptr<ast::ID> id, std::shared_ptr<ast::Exp> index, int line) {
    auto array_entry = dynamic_pointer_cast<Array_Entry>(find_in_stack(id->value));
    if (array_entry == nullptr) {
        auto entry = find_in_stack(id->value);
        if (entry == nullptr) {
            output::errorUndef(line, id->value);
        } else {
            output::errorMismatch(line);
        }
    }
    
    index->accept(*this);
    if (index->type != ast::BuiltInType::INT && index->type != ast::BuiltInType::BYTE) {
        output::errorMismatch(line);
    }
    
    return array_entry;
}

void Semantic_visitor::visit(ast::ArrayDereference &node) {
    auto array_entry = validate_array_access(node.id, node.index, node.line);
    node.type = array_entry->var_type;
}

void Semantic_visitor::visit(ast::ArrayAssign &node) {
    auto array_entry = validate_array_access(node.id, node.index, node.line);
    node.exp->accept(*this);
    if (!assignable(array_entry->var_type, node.exp->type)) {
        output::errorMismatch(node.line);
    }
}
