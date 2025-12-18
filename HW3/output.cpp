#include "output.hpp"
#include <iostream>

namespace output {
    /* Helper functions */

    static std::string toString(ast::BuiltInType type) {
        switch (type) {
            case ast::BuiltInType::INT:
                return "int";
            case ast::BuiltInType::BOOL:
                return "bool";
            case ast::BuiltInType::BYTE:
                return "byte";
            case ast::BuiltInType::VOID:
                return "void";
            case ast::BuiltInType::STRING:
                return "string";
            default:
                return "unknown";
        }
    }

    /* Error handling functions */

    void errorLex(int lineno) {
        std::cout << "line " << lineno << ": lexical error\n";
        exit(0);
    }

    void errorSyn(int lineno) {
        std::cout << "line " << lineno << ": syntax error\n";
        exit(0);
    }

    void errorUndef(int lineno, const std::string &id) {
        std::cout << "line " << lineno << ":" << " variable " << id << " is not defined" << std::endl;
        exit(0);
    }

    void errorDefAsFunc(int lineno, const std::string &id) {
        std::cout << "line " << lineno << ":" << " symbol " << id << " is a function" << std::endl;
        exit(0);
    }

    void errorDefAsVar(int lineno, const std::string &id) {
        std::cout << "line " << lineno << ":" << " symbol " << id << " is a variable" << std::endl;
        exit(0);
    }

    void errorDef(int lineno, const std::string &id) {
        std::cout << "line " << lineno << ":" << " symbol " << id << " is already defined" << std::endl;
        exit(0);
    }

    void errorUndefFunc(int lineno, const std::string &id) {
        std::cout << "line " << lineno << ":" << " function " << id << " is not defined" << std::endl;
        exit(0);
    }

    void errorMismatch(int lineno) {
        std::cout << "line " << lineno << ":" << " type mismatch" << std::endl;
        exit(0);
    }

    void errorPrototypeMismatch(int lineno, const std::string &id, std::vector<std::string> &paramTypes) {
        std::cout << "line " << lineno << ": prototype mismatch, function " << id << " expects parameters (";

        for (int i = 0; i < paramTypes.size(); ++i) {
            std::cout << paramTypes[i];
            if (i != paramTypes.size() - 1)
                std::cout << ",";
        }

        std::cout << ")" << std::endl;
        exit(0);
    }

    void errorUnexpectedBreak(int lineno) {
        std::cout << "line " << lineno << ":" << " unexpected break statement" << std::endl;
        exit(0);
    }

    void errorUnexpectedContinue(int lineno) {
        std::cout << "line " << lineno << ":" << " unexpected continue statement" << std::endl;
        exit(0);
    }

    void errorMainMissing() {
        std::cout << "Program has no 'void main()' function" << std::endl;
        exit(0);
    }

    void errorByteTooLarge(int lineno, const int value) {
        std::cout << "line " << lineno << ": byte value " << value << " out of range" << std::endl;
        exit(0);
    }

    /* ScopePrinter class */

    ScopePrinter::ScopePrinter() : indentLevel(0) {}

    std::string ScopePrinter::indent() const {
        std::string result;
        for (int i = 0; i < indentLevel; ++i) {
            result += "  ";
        }
        return result;
    }

    void ScopePrinter::beginScope() {
        indentLevel++;
        buffer << indent() << "---begin scope---" << std::endl;
    }

    void ScopePrinter::endScope() {
        buffer << indent() << "---end scope---" << std::endl;
        indentLevel--;
    }

    void ScopePrinter::emitVar(const std::string &id, const ast::BuiltInType &type, int offset) {
        buffer << indent() << id << " " << toString(type) << " " << offset << std::endl;
    }

    void ScopePrinter::emitFunc(const std::string &id, const ast::BuiltInType &returnType,
                                const std::vector<ast::BuiltInType> &paramTypes) {
        globalsBuffer << id << " " << "(";

        for (int i = 0; i < paramTypes.size(); ++i) {
            globalsBuffer << toString(paramTypes[i]);
            if (i != paramTypes.size() - 1)
                globalsBuffer << ",";
        }

        globalsBuffer << ")" << " -> " << toString(returnType) << std::endl;
    }

    std::ostream &operator<<(std::ostream &os, const ScopePrinter &printer) {
        os << "---begin global scope---" << std::endl;
        os << printer.globalsBuffer.str();
        os << printer.buffer.str();
        os << "---end global scope---" << std::endl;
        return os;
    }

    MyVisitor::MyVisitor() {}

    void MyVisitor::visit(ast::ID &node) {
        std::shared_ptr<SymbolData> data = validate_existence_by_name(node.value);

        // Check if we tried to use identifier without him being declared.
        if (data == nullptr)
            errorUndef(node.line, node.value);

        // Check if we tried to use a function identifier as var
        if (data->is_func)
            errorDefAsFunc(node.line, node.value);

    }

    void MyVisitor::visit(ast::If &node) {
//        // Adding to scope stack
//        if (table_stack.top() == nullptr)
//
//        else
//            begin_scope(table_stack.top(), false);
//
//        node.condition->accept()
//
//        end_scope();
    }

    void MyVisitor::visit(ast::Or &node) {}

    void MyVisitor::visit(ast::And &node) {}

    void MyVisitor::visit(ast::Not &node) {}

    void MyVisitor::visit(ast::Num &node) {}

    void MyVisitor::visit(ast::Bool &node) {}

    void MyVisitor::visit(ast::Call &node) {
        std::shared_ptr<SymbolData> func_data = validate_existence_by_name(node.func_id->value);

        // Func isn't declared
        if (func_data == nullptr)
            errorUndefFunc(node.line, node.func_id->value);

        // We try to use func but it's a var
        if (!func_data->is_func)
            errorDefAsVar(node.line, node.func_id->value);

        // TODO: check func_types if matching

        node.args->accept(*this);

        node.args->accept(*this);
    }

    void MyVisitor::visit(ast::Cast &node) {}

    void MyVisitor::visit(ast::NumB &node) {}

    void MyVisitor::visit(ast::Type &node) {}

    void MyVisitor::visit(ast::BinOp &node) {}

    void MyVisitor::visit(ast::Break &node) {}

    void MyVisitor::visit(ast::Funcs &node) {}

    void MyVisitor::visit(ast::RelOp &node) {}

    void MyVisitor::visit(ast::While &node) {

    }

    void MyVisitor::visit(ast::Assign &node) {}

    void MyVisitor::visit(ast::Formal &node) {}

    void MyVisitor::visit(ast::Return &node) {}

    void MyVisitor::visit(ast::String &node) {}

    // we have ExpList only for function calls
    void MyVisitor::visit(ast::ExpList &node) {

    }

    void MyVisitor::visit(ast::Formals &node) {}

    void MyVisitor::visit(ast::VarDecl &node) {

        std::shared_ptr<SymbolData> data = validate_existence_by_name(node.id->value);

        // Check if we already declared this id (name & type)
        if (data != nullptr && data->type == node.type->type) {
            errorDef(node.line, node.id->value);
        } else {
            std::shared_ptr<SymbolData> new_data = std::make_shared<SymbolData>(node.id->value, node.type->type);
            insert(new_data);
        }
    }

    void MyVisitor::visit(ast::Continue &node) {}

    void MyVisitor::visit(ast::FuncDecl &node) {

    }

    void MyVisitor::visit(ast::Statements &node) {}
}
