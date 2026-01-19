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

    /* CodeBuffer class */

    CodeBuffer::CodeBuffer() : labelCount(0), varCount(0), stringCount(0) {}

    std::string CodeBuffer::freshLabel() {
        return "%label_" + std::to_string(labelCount++);
    }

    std::string CodeBuffer::freshVar() {
        return "%t" + std::to_string(varCount++);
    }

    std::string CodeBuffer::emitString(const std::string &str) {
        std::string var = "@.str" + std::to_string(stringCount++);
        globalsBuffer << var << " = constant [" << str.length() + 1 << " x i8] c\"" << str << "\\00\"";
        return var;
    }

    void CodeBuffer::emit(const std::string &str) {
        buffer << str << std::endl;
    }

    void CodeBuffer::emitLabel(const std::string &label) {
        buffer << label.substr(1) << ":" << std::endl;
    }

    CodeBuffer &CodeBuffer::operator<<(std::ostream &(*manip)(std::ostream &)) {
        buffer << manip;
        return *this;
    }

    std::ostream &operator<<(std::ostream &os, const CodeBuffer &buffer) {
        os << buffer.globalsBuffer.str() << std::endl << buffer.buffer.str();
        return os;
    }

    // ====================================================================================
    // ALL CODE FROM LAST HW (3)
    // ====================================================================================

    /* Helper functions */

    static std::string toString(ast::BuiltInType type){
        switch (type){
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

    static bool is_numeric_type(ast::BuiltInType type){
        return type == ast::BuiltInType::INT || type == ast::BuiltInType::BYTE;
    }

    static std::string toupper(std::string str){
        for (char& c : str){
            c = std::toupper(static_cast<unsigned char>(c));
        }
        return str;
    }

    /* SCOPE PRINTER */
    ScopePrinter::ScopePrinter() : indentLevel(0){}

    std::string ScopePrinter::indent() const{
        std::string result;
        for (int i = 0; i < indentLevel; ++i){
            result += "  ";
        }
        return result;
    }

    void ScopePrinter::beginScope(){
        indentLevel++;
        buffer << indent() << "---begin scope---" << std::endl;
    }

    void ScopePrinter::endScope(){
        buffer << indent() << "---end scope---" << std::endl;
        indentLevel--;
    }

    void ScopePrinter::emitVar(const std::string& id, const ast::BuiltInType& type, int offset){
        buffer << indent() << id << " " << toString(type) << " " << offset << std::endl;
    }

    void ScopePrinter::emitFunc(const std::string& id, const ast::BuiltInType& returnType,
        const std::vector<ast::BuiltInType>& paramTypes){
        globalsBuffer << id << " " << "(";

        for (int i = 0; i < paramTypes.size(); ++i){
            globalsBuffer << toString(paramTypes[i]);
            if (i != paramTypes.size() - 1)
                globalsBuffer << ",";
        }

        globalsBuffer << ")" << " -> " << toString(returnType) << std::endl;
    }

    std::ostream& operator<<(std::ostream& os, const ScopePrinter& printer){
        os << "---begin global scope---" << std::endl;
        os << printer.globalsBuffer.str();
        os << printer.buffer.str();
        os << "---end global scope---" << std::endl;
        return os;
    }

    MyVisitor::MyVisitor() :
        printer(ScopePrinter()), last_type(ast::BuiltInType::VOID), last_func_id(""), table_stack(), offset_stack(){}

    void MyVisitor::visit(ast::ID& node){
        std::shared_ptr<SymbolData> data = check_exists_by_name(node.value);

        // Check if we tried to use identifier without him being declared.
        if (data == nullptr)
            errorUndef(node.line, node.value);

        // Check if we tried to use a function identifier as var
        if (data->is_func)
            errorDefAsFunc(node.line, node.value);

        this->last_type = data->type;

        // Code buffer
        node.var_name = this->code_buffer.freshVar();
        code_buffer << "store" << node.var_name << ", " << node.value;

        code_buffer << node.var_name + " := " + node.value;
    }

    void MyVisitor::visit(ast::If& node){
        begin_scope(table_stack.top(), false);

        node.condition->accept(*this);
        // Check if condition isn't bool
        if (this->last_type != ast::BuiltInType::BOOL)
            errorMismatch(node.condition->line);

        node.then->accept(*this);
        // Removing from scope stack
        end_scope();

        // Starting scope for else
        // If there is an else and it is not null
        if (node.otherwise){
            begin_scope(table_stack.top(), false);
            is_func_body = true;
            node.otherwise->accept(*this);
            is_func_body = false;
            end_scope();
        }
    }

    void MyVisitor::visit(ast::Or& node){
        node.left->accept(*this);
        if (this->last_type != ast::BuiltInType::BOOL){
            errorMismatch(node.line);
        }

        node.right->accept(*this);
        if (this->last_type != ast::BuiltInType::BOOL){
            errorMismatch(node.line);
        }
    }

    void MyVisitor::visit(ast::And& node){
        node.left->accept(*this);
        if (this->last_type != ast::BuiltInType::BOOL){
            errorMismatch(node.line);
        }

        node.right->accept(*this);
        if (this->last_type != ast::BuiltInType::BOOL){
            errorMismatch(node.line);
        }
    }

    void MyVisitor::visit(ast::Not& node){
        node.exp->accept(*this);

        // TODO: Type of not is always boolean?
        if (this->last_type != ast::BuiltInType::BOOL){
            errorMismatch(node.line);
        }
    }

    void MyVisitor::visit(ast::Num& node){
        this->last_type = ast::BuiltInType::INT;
    }

    void MyVisitor::visit(ast::Bool& node){
        this->last_type = ast::BuiltInType::BOOL;
    }

    void MyVisitor::visit(ast::Call& node){
        std::shared_ptr<SymbolData> func_data = check_exists_by_name(node.func_id->value);
        if (func_data == nullptr)
            errorUndefFunc(node.line, node.func_id->value);
        if (!func_data->is_func)
            errorDefAsVar(node.line, node.func_id->value);

        // Check argument count
        std::vector<std::shared_ptr<ast::Exp>>& args = node.args->exps;
        std::vector<ast::BuiltInType>& expected_types = func_data->func_types;

        if (args.size() != expected_types.size()){
            std::vector<std::string> expected_str;
            for (auto t : expected_types)
                expected_str.push_back(toupper(toString(t)));
            errorPrototypeMismatch(node.line, node.func_id->value, expected_str);
        }

        // Check argument types
        for (size_t i = 0; i < args.size(); i++){
            args[i]->accept(*this);
            ast::BuiltInType arg_type = last_type;
            ast::BuiltInType expected = expected_types[i];

            bool typesMatch = (arg_type == expected);
            // Special case: Allow Byte -> Int
            if (expected == ast::BuiltInType::INT && arg_type == ast::BuiltInType::BYTE)
                typesMatch = true;

            if (!typesMatch){
                std::vector<std::string> expected_str;
                for (auto t : expected_types)
                    expected_str.push_back(toupper(toString(t)));
                errorPrototypeMismatch(node.line, node.func_id->value, expected_str);
            }
        }

        // Set return type for the Call expression
        this->last_type = func_data->type;
    }

    void MyVisitor::visit(ast::Cast& node){
        node.exp->accept(*this);
        ast::BuiltInType exp_type = last_type;

        node.target_type->accept(*this);
        ast::BuiltInType target_type = last_type;

        if (!is_numeric_type(exp_type) || !is_numeric_type(target_type))
            errorMismatch(node.line);

        last_type = target_type;
    }

    void MyVisitor::visit(ast::NumB& node){
        last_type = ast::BuiltInType::BYTE;
        if (node.value > 255)
            errorByteTooLarge(node.line, node.value);
    }

    void MyVisitor::visit(ast::Type& node){
        this->last_type = node.type;
    }

    void MyVisitor::visit(ast::BinOp& node){
        ast::BuiltInType left, right;

        node.left->accept(*this);
        left = this->last_type;

        node.right->accept(*this);
        right = this->last_type;

        bool isLeftNum = (left == ast::BuiltInType::INT || left == ast::BuiltInType::BYTE);
        bool isRightNum = (right == ast::BuiltInType::INT || right == ast::BuiltInType::BYTE);

        if (!isLeftNum || !isRightNum){
            errorMismatch(node.line);
        }

        // return type with bigger representation size
        if (left == ast::BuiltInType::INT || right == ast::BuiltInType::INT)
            this->last_type = ast::BuiltInType::INT;
        else
            this->last_type = ast::BuiltInType::BYTE;
    }

    void MyVisitor::visit(ast::Break& node){
        // Check if we are in a loop scope and throw error if not
        std::shared_ptr<SymbolTable> current_table = table_stack.top();
        while (current_table != nullptr && !current_table->is_loop_scope)
            current_table = current_table->parent;
        if (current_table == nullptr)
            errorUnexpectedBreak(node.line);
        return;
    }

    void MyVisitor::visit(ast::Funcs& node){
        // begin_scope(nullptr, false);
        table_stack.push(std::make_shared<SymbolTable>(nullptr, false));
        insert(std::make_shared<SymbolData>("print", ast::BuiltInType::VOID), true, { ast::BuiltInType::STRING });
        insert(std::make_shared<SymbolData>("printi", ast::BuiltInType::VOID), true, { ast::BuiltInType::INT });

        bool found_main = false;
        for (const auto& func : node.funcs){
            last_func_id = func->id->value;

            std::vector<ast::BuiltInType> param_types;
            for (const auto& formal : func->formals->formals)
                param_types.push_back(formal->type->type);

            if (check_exists_by_name(func->id->value) != nullptr)
                errorDef(func->id->line, func->id->value);

            insert(std::make_shared<SymbolData>(
                last_func_id, func->return_type->type), true, param_types
            );
        }

        auto main_func = check_exists_by_name("main");
        if (main_func == nullptr)
            errorMainMissing();
        if (main_func->type != ast::BuiltInType::VOID || main_func->func_types.size() != 0)
            errorMainMissing();


        for (const auto& func : node.funcs){
            last_func_id = func->id->value;
            func->accept(*this);
        }

        table_stack.pop();
        std::cout << printer;
    }

    void MyVisitor::visit(ast::RelOp& node){
        ast::BuiltInType left, right;

        node.left->accept(*this);
        left = last_type;

        node.right->accept(*this);
        right = last_type;

        if (!is_numeric_type(left) || !is_numeric_type(right)){
            errorMismatch(node.line);
        }

        last_type = ast::BuiltInType::BOOL;
    }

    void MyVisitor::visit(ast::While& node){
        begin_scope(table_stack.top(), false);

        node.condition->accept(*this);
        // Check if condition isn't bool
        if (this->last_type != ast::BuiltInType::BOOL)
            errorMismatch(node.condition->line);

        //TODO: do we need to do check if (table_stack.top() == nullptr)?
        begin_scope(table_stack.top(), true);
        is_func_body = true;
        node.body->accept(*this);
        is_func_body = false;

        end_scope();
        end_scope();
    }

    void MyVisitor::visit(ast::Assign& node){
        node.id->accept(*this);
        ast::BuiltInType id_type = this->last_type;

        node.exp->accept(*this);
        ast::BuiltInType exp_type = this->last_type;

        if (id_type != exp_type){
            // Allow Byte -> Int assignment
            if (!(id_type == ast::BuiltInType::INT && exp_type == ast::BuiltInType::BYTE)){
                errorMismatch(node.line);
            }
        }
    }

    void MyVisitor::visit(ast::Formal& node){
        std::shared_ptr<SymbolData> data = check_exists_by_name(node.id->value);

        // Check if we already declared this id (name)
        // We can't do shadowing! - that's why we don't check type
        if (data != nullptr)
            errorDef(node.line, node.id->value);

        std::shared_ptr<SymbolData> new_data = std::make_shared<SymbolData>(node.id->value, node.type->type, arg_offset);
        insert(new_data, false, {}, true);
    }

    void MyVisitor::visit(ast::Return& node){
        // last type remains the same from exp
        returns = true;

        if (node.exp == nullptr)
            last_type = ast::BuiltInType::VOID;
        else
            node.exp->accept(*this);

        if (return_type != last_type && !(last_type == ast::BuiltInType::BYTE && return_type == ast::BuiltInType::INT))
            errorMismatch(node.line);
    }

    void MyVisitor::visit(ast::String& node){
        last_type = ast::BuiltInType::STRING;
    }

    // we have ExpList only for function calls
    void MyVisitor::visit(ast::ExpList& node){
        auto& types = check_exists_by_name(last_func_id)->func_types;

        std::vector<std::string> str_types;
        for (const auto& t : types)
            str_types.push_back(toupper(toString(t)));

        size_t i = 0;
        for (; i < node.exps.size(); i++){
            node.exps[i]->accept(*this);
            if (i >= types.size() || types[i] != last_type || (types[i] == ast::BuiltInType::STRING && last_func_id != "print"))
                errorPrototypeMismatch(node.line, last_func_id, str_types);
        }
        if (i < types.size())
            errorPrototypeMismatch(node.line, last_func_id, str_types);
    }

    void MyVisitor::visit(ast::Formals& node){
        arg_offset = 0;

        for (const auto& formal : node.formals){
            arg_offset--;
            formal->accept(*this);
        }

        arg_offset = 0;
    }

    void MyVisitor::visit(ast::VarDecl& node){
        std::shared_ptr<SymbolData> data = check_exists_by_name(node.id->value);

        // Check if we already declared this id (name)
        // We can't do shadowing! - that's why we don't check type
        if (data != nullptr)
            errorDef(node.line, node.id->value);

        if (node.init_exp != nullptr){
            node.init_exp->accept(*this);
            ast::BuiltInType init_type = last_type;

            if (init_type != node.type->type){
                // Allow Byte -> Int assignment
                if (!(node.type->type == ast::BuiltInType::INT && init_type == ast::BuiltInType::BYTE)){
                    errorMismatch(node.line);
                }
            }
        }

        std::shared_ptr<SymbolData> new_data = std::make_shared<SymbolData>(node.id->value, node.type->type);
        insert(new_data);
    }

    void MyVisitor::visit(ast::Continue& node){
        // Check if we are in a loop scope and throw error if not
        std::shared_ptr<SymbolTable> current_table = table_stack.top();
        while (current_table != nullptr && !current_table->is_loop_scope)
            current_table = current_table->parent;
        if (current_table == nullptr)
            errorUnexpectedContinue(node.line);
        return;
    }

    void MyVisitor::visit(ast::FuncDecl& node){
        begin_scope(table_stack.top(), false);

        returns = false;
        is_func_body = true;

        return_type = node.return_type->type;

        node.return_type->accept(*this);
        node.formals->accept(*this);
        node.body->accept(*this);

        end_scope();
    }

    void MyVisitor::visit(ast::Statements& node){
        bool clean = !is_func_body;

        if (clean)
            begin_scope(table_stack.top(), false);

        is_func_body = false;
        for (const auto& stmt : node.statements)
            stmt->accept(*this);

        if (clean)
            end_scope();
    }
}
