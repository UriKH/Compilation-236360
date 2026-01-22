#include "output.hpp"
#include <iostream>

#define I32 std::string(" i32")
#define I32ptr std::string(" i32*")
#define I8 std::string(" i8")
#define I8ptr std::string(" i8*")


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
        globalsBuffer << var << " = constant [" << str.length() + 1 << " x i8] c\"" << str << "\\00\"\n";
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
        printer(ScopePrinter()), last_type(ast::BuiltInType::VOID), last_func_id(""), table_stack(), offset_stack(), zero_div_error_var_name(){}

    void MyVisitor::visit(ast::ID& node){
        std::shared_ptr<SymbolData> data = check_exists_by_name(node.value);

        // Check if we tried to use identifier without him being declared.
        if (data == nullptr)
            errorUndef(node.line, node.value);

        // Check if we tried to use a function identifier as var
        if (data->is_func)
            errorDefAsFunc(node.line, node.value);

        this->last_type = data->type;

        // Load data from memory (from stack)
        std::string loaded_var = code_buffer.freshVar();
        code_buffer.emit(loaded_var + " = load" + I32 + "," + I32ptr + " " + data->llvm_var);

        node.var_name = loaded_var;
    }

    void MyVisitor::visit(ast::If& node){
        begin_scope(table_stack.top(), false);

        node.condition->accept(*this);
        // Check if condition isn't bool
        if (this->last_type != ast::BuiltInType::BOOL)
            errorMismatch(node.condition->line);

        // translate condition to i1 for branching
        std::string cond_i1 = code_buffer.freshVar();
        code_buffer.emit(cond_i1 + " = icmp ne i32 " + node.condition->var_name + ", 0");
        
        std::string if_label = code_buffer.freshLabel();
        std::string label_end = code_buffer.freshLabel();

        std::string else_label = (node.otherwise) ? code_buffer.freshLabel() : label_end;
        
        code_buffer.emit("\n; >>> if block");
        code_buffer.emit("br i1 " + cond_i1 + ", label " + if_label + ", label " + else_label);
        code_buffer.emitLabel(if_label);
        node.then->accept(*this);
        // Removing from scope stack
        end_scope();

        code_buffer.emit("br label " + label_end);

        // Starting scope for else
        // If there is an else and it is not null
        if (node.otherwise){
            code_buffer.emitLabel(else_label);
            code_buffer.emit("; >>> else block");
            begin_scope(table_stack.top(), false);
            is_func_body = true;
            node.otherwise->accept(*this);
            is_func_body = false;
            end_scope();

            code_buffer.emit("br label " + label_end);
        }
        code_buffer.emit("\n; >>> End if block");
        code_buffer.emitLabel(label_end);
    }

    void MyVisitor::visit(ast::Or& node){
        // Evaluate Left
        node.left->accept(*this);
        if (this->last_type != ast::BuiltInType::BOOL){
            errorMismatch(node.line);
        }
        std::string left_val = node.left->var_name;

        // translate to i1
        std::string left_i1 = code_buffer.freshVar();
        code_buffer.emit(left_i1 + " = icmp ne i32 " + left_val + ", 0");

        std::string label_eval_right = code_buffer.freshLabel();
        std::string label_end = code_buffer.freshLabel();

        // known label for left side
        std::string label_left_anchor = code_buffer.freshLabel();
        code_buffer.emit("br label " + label_left_anchor);
        code_buffer.emitLabel(label_left_anchor);

        // Branch: if true -> jump to end (Short Circuit), else -> evaluate right
        code_buffer.emit("br i1 " + left_i1 + ", label " + label_end + ", label " + label_eval_right);

        // Evaluate Right
        code_buffer.emitLabel(label_eval_right);
        node.right->accept(*this);
        if (this->last_type != ast::BuiltInType::BOOL){
            errorMismatch(node.line);
        }
        std::string right_val = node.right->var_name;
        
        std::string right_i1 = code_buffer.freshVar();
        code_buffer.emit(right_i1 + " = icmp ne i32 " + right_val + ", 0");

        // known label for right side
        std::string label_right_anchor = code_buffer.freshLabel();
        code_buffer.emit("br label " + label_right_anchor);
        code_buffer.emitLabel(label_right_anchor);
        
        code_buffer.emit("br label " + label_end);

        // Merge (Phi)
        code_buffer.emitLabel(label_end);
        std::string phi_res = code_buffer.freshVar();
        
        code_buffer.emit(phi_res + " = phi i1 [ 1, " + label_left_anchor + " ], [ " + right_i1 + ", " + label_right_anchor + " ]");
        
        node.var_name = code_buffer.freshVar();
        code_buffer.emit(node.var_name + " = zext i1 " + phi_res + " to i32");
    }

    void MyVisitor::visit(ast::And& node) {
        // Evaluate Left
        node.left->accept(*this);
        if (this->last_type != ast::BuiltInType::BOOL){
            errorMismatch(node.line);
        }
        std::string left_val = node.left->var_name;
        
        std::string left_i1 = code_buffer.freshVar();
        code_buffer.emit(left_i1 + " = icmp ne i32 " + left_val + ", 0");
        
        std::string label_eval_right = code_buffer.freshLabel();
        std::string label_end = code_buffer.freshLabel();

        // known label for left side
        std::string label_left_anchor = code_buffer.freshLabel();
        code_buffer.emit("br label " + label_left_anchor);
        code_buffer.emitLabel(label_left_anchor);
        
        // Branch: if true -> evaluate right, else -> jump to end (Short Circuit False)
        code_buffer.emit("br i1 " + left_i1 + ", label " + label_eval_right + ", label " + label_end);
        
        // Evaluate Right
        code_buffer.emitLabel(label_eval_right);
        node.right->accept(*this);
        if (this->last_type != ast::BuiltInType::BOOL){
            errorMismatch(node.line);
        }
        std::string right_val = node.right->var_name;

        std::string right_i1 = code_buffer.freshVar();
        code_buffer.emit(right_i1 + " = icmp ne i32 " + right_val + ", 0");
        
        // known label for right side
        std::string label_right_anchor = code_buffer.freshLabel();
        code_buffer.emit("br label " + label_right_anchor);
        code_buffer.emitLabel(label_right_anchor);

        code_buffer.emit("br label " + label_end);
        
        // Merge (Phi)
        code_buffer.emitLabel(label_end);
        std::string phi_res = code_buffer.freshVar();
        
        // Phi: [ 0, left_anchor ], [ right_val, right_anchor ]
        code_buffer.emit(phi_res + " = phi i1 [ 0, " + label_left_anchor + " ], [ " + right_i1 + ", " + label_right_anchor + " ]");
        
        node.var_name = code_buffer.freshVar();
        code_buffer.emit(node.var_name + " = zext i1 " + phi_res + " to i32");
    }

    void MyVisitor::visit(ast::Not& node){
        node.exp->accept(*this);

        // TODO: Type of not is always boolean?
        if (this->last_type != ast::BuiltInType::BOOL){
            errorMismatch(node.line);
        }

        node.var_name = this->code_buffer.freshVar();
        code_buffer.emit(node.var_name + " = xor" + I32 + " " + node.exp->var_name + ", 1");
    }

    void MyVisitor::visit(ast::Num& node){
        this->last_type = ast::BuiltInType::INT;

        node.var_name = std::to_string(node.value);
    }

    void MyVisitor::visit(ast::Bool& node){
        this->last_type = ast::BuiltInType::BOOL;

        node.var_name = std::to_string(node.value);
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

        // To later call func with args
        std::string args_str = "";

        // Check argument types
        for (size_t i = 0; i < args.size(); i++){
            args[i]->accept(*this);
            ast::BuiltInType arg_type = last_type;
            ast::BuiltInType expected = expected_types[i];

            // Check types
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

            // Code buffer emit for args
            if (i > 0) args_str += ", ";    // add comma between args

            // Check if i8
            std::string llvm_type_str = "i32";
            if (arg_type == ast::BuiltInType::STRING) {
                llvm_type_str = "i8*";
            }

            args_str += llvm_type_str + " " + args[i]->var_name;
        }

        // Set return type for the Call expression
        this->last_type = func_data->type;

        if (func_data->type != ast::BuiltInType::VOID){
            node.var_name = this->code_buffer.freshVar();
            code_buffer.emit(node.var_name + " = call" + I32 + " @" + node.func_id->value + "(" + args_str + ")");
        }
        else{ //calling function that returns void
            code_buffer.emit("call void @" + node.func_id->value + "(" + args_str + ")");
        } // ToDO: check if parameter is String, if so, change I32 to I8ptr?
    }

    void MyVisitor::visit(ast::Cast& node){
        node.exp->accept(*this);
        ast::BuiltInType exp_type = last_type;

        node.target_type->accept(*this);
        ast::BuiltInType target_type = last_type;

        if (!is_numeric_type(exp_type) || !is_numeric_type(target_type))
            errorMismatch(node.line);

        last_type = target_type;

        // code buffer emit
        node.var_name = this->code_buffer.freshVar();
        if (exp_type == ast::BuiltInType::INT && target_type == ast::BuiltInType::BYTE) {
            // int to byte - truncation
            code_buffer.emit(node.var_name + " = and" + I32 + " " + node.exp->var_name + ", 255");
        } 
        else { // Creating new var with same value for casting
            code_buffer.emit(node.var_name + " = add" + I32 + " " + node.exp->var_name + ", 0");
        }
    }

    void MyVisitor::visit(ast::NumB& node){
        last_type = ast::BuiltInType::BYTE;
        if (node.value > 255)
            errorByteTooLarge(node.line, node.value);

        node.var_name = std::to_string(node.value);
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

        

        // code buffer emit
        bool isIntOperation = (this->last_type == ast::BuiltInType::INT);

        node.var_name = this->code_buffer.freshVar();

        if (node.op == ast::BinOpType::DIV) {
            code_buffer.emit("\n; >>> check division by zero");
            std::string label_true = this->code_buffer.freshLabel();
            std::string label_false = this->code_buffer.freshLabel();

            std::string is_zero = code_buffer.freshVar();
            code_buffer.emit(is_zero + " = icmp eq" + I32 + " " + node.right->var_name + ", 0");
            code_buffer.emit("br i1 " + is_zero + ", label " + label_true + ", label " + label_false);

            code_buffer.emitLabel(label_true);
            
            std::string err_msg = "Error division by zero";
            std::string len = std::to_string(err_msg.size() + 1);
            if (zero_div_error_var_name.empty()) {
                zero_div_error_var_name = code_buffer.emitString(err_msg);
            }
            
            code_buffer.emit("call void @print(i8* getelementptr ([" + len + " x i8], [" + len + " x i8]* " + zero_div_error_var_name + ", i32 0, i32 0))");
            code_buffer.emit("call void @exit(i32 0)");
            code_buffer.emit("unreachable");
            
            code_buffer.emitLabel(label_false);
            code_buffer.emit("; >>> end check division by zero\n");
        }

        switch (node.op) {
            case (ast::BinOpType::ADD):
                code_buffer.emit(node.var_name + " = add" + I32 + " " + node.left->var_name + ", " + node.right->var_name);
                break;
            case (ast::BinOpType::SUB):
                code_buffer.emit(node.var_name + " = sub" + I32 + " " + node.left->var_name + ", " + node.right->var_name);
                break;
            case (ast::BinOpType::MUL):
                code_buffer.emit(node.var_name + " = mul" + I32 + " " + node.left->var_name + ", " + node.right->var_name);
                break;
            case (ast::BinOpType::DIV): //TODO: check
                if (isIntOperation) {
                    code_buffer.emit(node.var_name + " = sdiv i32 " + node.left->var_name + ", " + node.right->var_name);
                } else {
                    code_buffer.emit(node.var_name + " = udiv i32 " + node.left->var_name + ", " + node.right->var_name);
                }
                break;
        }

        // truncation for byte operations
        if (this->last_type == ast::BuiltInType::BYTE) {
            std::string truncated_val = code_buffer.freshVar();
            // I want to remain in currect range of byte after operation
            code_buffer.emit(truncated_val + " = and i32 " + node.var_name + ", 255");
            node.var_name = truncated_val; 
        }
    }

    void MyVisitor::visit(ast::Break& node){
        // Check if we are in a loop scope and throw error if not
        std::shared_ptr<SymbolTable> current_table = table_stack.top();
        while (current_table != nullptr && !current_table->is_loop_scope) {
            current_table = current_table->parent;
        }
        if (current_table == nullptr)
            errorUnexpectedBreak(node.line);

        code_buffer.emit("br label " + current_table->end_label);

        // dummy label to avoid LLVM error about empty block
        std::string dead_label = code_buffer.freshLabel();
        code_buffer.emitLabel(dead_label);
        return;
    }

    void MyVisitor::visit(ast::Funcs& node){
        // begin_scope(nullptr, false);
        table_stack.push(std::make_shared<SymbolTable>(nullptr, false));
        insert(std::make_shared<SymbolData>("print", ast::BuiltInType::VOID), true, { ast::BuiltInType::STRING });
        insert(std::make_shared<SymbolData>("printi", ast::BuiltInType::VOID), true, { ast::BuiltInType::INT });

        code_buffer.emit("declare i32 @scanf(i8*, ...)");
        code_buffer.emit("declare i32 @printf(i8*, ...)");
        code_buffer.emit("declare void @exit(i32)");
        code_buffer.emit("@.int_specifier_scan = constant [3 x i8] c\"%d\\00\"");
        code_buffer.emit("@.int_specifier = constant [4 x i8] c\"%d\\0A\\00\"");
        code_buffer.emit("@.str_specifier = constant [4 x i8] c\"%s\\0A\\00\"");

        code_buffer.emit("define i32 @readi(i32) {");
        code_buffer.emit("      %ret_val = alloca i32");
        code_buffer.emit("      %spec_ptr = getelementptr [3 x i8], [3 x i8]* @.int_specifier_scan, i32 0, i32 0");
        code_buffer.emit("      call i32 (i8*, ...) @scanf(i8* %spec_ptr, i32* %ret_val)");
        code_buffer.emit("      %val = load i32, i32* %ret_val");
        code_buffer.emit("      ret i32 %val");
        code_buffer.emit("}");

        code_buffer.emit("define void @printi(i32) {");
        code_buffer.emit("      %spec_ptr = getelementptr [4 x i8], [4 x i8]* @.int_specifier, i32 0, i32 0");
        code_buffer.emit("      call i32 (i8*, ...) @printf(i8* %spec_ptr, i32 %0)");
        code_buffer.emit("      ret void");
        code_buffer.emit("}");

        code_buffer.emit("define void @print(i8*) {");
        code_buffer.emit("      %spec_ptr = getelementptr [4 x i8], [4 x i8]* @.str_specifier, i32 0, i32 0");
        code_buffer.emit("      call i32 (i8*, ...) @printf(i8* %spec_ptr, i8* %0)");
        code_buffer.emit("      ret void");
        code_buffer.emit("}");

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
        //std::cout << printer;
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


        // code buffer emit
        node.var_name = this->code_buffer.freshVar();

        std::string op;
        switch (node.op) {
            case (ast::RelOpType::EQ):
                op = "eq";
                break;
            case (ast::RelOpType::NE):
                op = "ne";
                break;
            case (ast::RelOpType::LT):
                op = "slt";
                break;
            case (ast::RelOpType::GT):
                op = "sgt";
                break;
            case (ast::RelOpType::LE):
                op = "sle";
                break;
            case (ast::RelOpType::GE):
                op = "sge";
                break;
        }

        std::string i1_val = code_buffer.freshVar();
        code_buffer.emit(i1_val + " = icmp " + op + I32 + " " + node.left->var_name + ", " + node.right->var_name);
        node.var_name = code_buffer.freshVar(); // התוצאה הסופית שתישמר בעץ
        code_buffer.emit(node.var_name + " = zext i1 " + i1_val + " to i32");
    }

    void MyVisitor::visit(ast::While& node){
        begin_scope(table_stack.top(), false);
        code_buffer.emit("\n; >>> while block");

        std::string while_label = code_buffer.freshLabel();
        std::string cond_label = code_buffer.freshLabel();
        std::string final_label = code_buffer.freshLabel();

        code_buffer.emit("br label " + cond_label);
        // Doing condition check again
        code_buffer.emitLabel(cond_label);
        node.condition->accept(*this);

        // Check if condition isn't bool
        if (this->last_type != ast::BuiltInType::BOOL)
            errorMismatch(node.condition->line);

        // translate condition to i1 for branching
        std::string cond2_i1 = code_buffer.freshVar();
        code_buffer.emit(cond2_i1 + " = icmp ne i32 " + node.condition->var_name + ", 0");

        code_buffer.emit("br i1 " + cond2_i1 + ", label " + while_label + ", label " + final_label);

        begin_scope(table_stack.top(), true);

        // Saving for break and continue
        table_stack.top()->end_label = final_label;
        table_stack.top()->loop_label = cond_label;

        code_buffer.emitLabel(while_label);

        is_func_body = true;

        node.body->accept(*this);
        code_buffer.emit("br label " + cond_label);
        
        is_func_body = false;

        end_scope();

        code_buffer.emit("\n; >>> End while block");
        code_buffer.emitLabel(final_label);
        end_scope();
    }

    void MyVisitor::visit(ast::Assign& node){
        std::shared_ptr<SymbolData> data = check_exists_by_name(node.id->value);
        if (data == nullptr)
            errorUndef(node.line, node.id->value);
        std::string target_address = data->llvm_var;

        //node.id->accept(*this);
        ast::BuiltInType id_type = data->type;

        node.exp->accept(*this);
        ast::BuiltInType exp_type = this->last_type;

        if (id_type != exp_type){
            // Allow Byte -> Int assignment
            if (!(id_type == ast::BuiltInType::INT && exp_type == ast::BuiltInType::BYTE)){
                errorMismatch(node.line);
            }
        }

        if (node.exp != nullptr){
            if (std::dynamic_pointer_cast<ast::Bool>(node.exp) != nullptr ||
                std::dynamic_pointer_cast<ast::NumB>(node.exp) != nullptr){

                // temp var for zext
                std::string zext_res = code_buffer.freshVar();
                code_buffer.emit(zext_res + " = zext i8 " + node.exp->var_name + " to i32");
                code_buffer.emit("store i32 " + zext_res + ", i32* " + target_address);
            }
            else {
                code_buffer.emit("store" + I32 + " " + node.exp->var_name + "," + I32ptr + " " + target_address);
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

        if (last_type == ast::BuiltInType::VOID)
            code_buffer.emit("ret void");
        else
            code_buffer.emit("ret" + I32 + " " + node.exp->var_name);
        
        // dummy label to avoid LLVM error about empty block
        std::string dead_label = code_buffer.freshLabel();
        code_buffer.emitLabel(dead_label);  
    }

    void MyVisitor::visit(ast::String& node){
        last_type = ast::BuiltInType::STRING;

        // code buffer addings - Assuming no \n \t \\ \" etc. !!!
        std::string str = code_buffer.emitString(node.value);
        int len = node.value.length() + 1;

        node.var_name = code_buffer.freshVar();
        //TODO: not sure about i8 - maybe need i32
        code_buffer.emit(node.var_name + " = getelementptr [" + std::to_string(len) + " x i8], [" + std::to_string(len) + " x i8]* " + str + ", i32 0, i32 0");
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

        node.id->var_name = this->code_buffer.freshVar();
        code_buffer.emit(node.id->var_name + " = alloca" + I32);

        std::shared_ptr<SymbolData> new_data = std::make_shared<SymbolData>(node.id->value, node.type->type);
        // Saving variable's llvm name
        new_data->llvm_var = node.id->var_name;
        insert(new_data);


        if (node.init_exp != nullptr){
            if (std::dynamic_pointer_cast<ast::Bool>(node.init_exp) != nullptr ||
                std::dynamic_pointer_cast<ast::NumB>(node.init_exp) != nullptr){
                // temp var fore zext
                std::string zext_res = code_buffer.freshVar();
                code_buffer.emit(zext_res + " = zext" + I8 + " " + node.init_exp->var_name + " to" + I32);

                // saving to defined var
                code_buffer.emit("store i32 " + zext_res + ", i32* " + node.id->var_name);
            }
            else {
                code_buffer.emit("store" + I32 + " " + node.init_exp->var_name + "," + I32ptr + " " + node.id->var_name);

            }
        } else {
            // deafult initialization to 0
            code_buffer.emit("store i32 0, i32* " + node.id->var_name);
        }
    }

    void MyVisitor::visit(ast::Continue& node){
        // Check if we are in a loop scope and throw error if not
        std::shared_ptr<SymbolTable> current_table = table_stack.top();
        while (current_table != nullptr && !current_table->is_loop_scope)
            current_table = current_table->parent;
        if (current_table == nullptr)
            errorUnexpectedContinue(node.line);

        code_buffer.emit("br label " + current_table->loop_label);

        // dummy label to avoid LLVM error about empty block
        std::string dead_label = code_buffer.freshLabel();
        code_buffer.emitLabel(dead_label);
        return;
    }

    void MyVisitor::visit(ast::FuncDecl& node){

        std::string func_name = node.id->value;
        std::string ret_type;
        if (node.return_type->type == ast::BuiltInType::VOID) 
            ret_type = "void";
        else if (node.return_type->type == ast::BuiltInType::STRING) 
            ret_type = "i8*";
        else 
            ret_type = "i32";
    
        // Build Argument List for 'define'
        std::string args_str = "";
        auto& formals = node.formals->formals;
        for (size_t i = 0; i < formals.size(); ++i) {
            if (i > 0) args_str += ", ";
            if (formals[i]->type->type == ast::BuiltInType::STRING)
                args_str += "i8*";
            else if (formals[i]->type->type == ast::BuiltInType::VOID)
                args_str += "void";
            else
                args_str += "i32";
        }
    
        code_buffer.emit("define " + ret_type + " @" + func_name + "(" + args_str + ") {");
    
        // Prepare scope
        begin_scope(table_stack.top(), false);
        returns = false;
        is_func_body = true;
        return_type = node.return_type->type;
    
        // Allocate stack space for arguments
        // LLVM arguments come in registers %0, %1, ...
        // We need to store them in stack variables so we can modify them (since args are mutable in C/FanC)
        for (size_t i = 0; i < formals.size(); ++i) {
            auto formal = formals[i];
            std::string arg_llvm_type;
            if (formal->type->type == ast::BuiltInType::STRING)
                arg_llvm_type = "i8*";
            else if (formal->type->type == ast::BuiltInType::VOID)
                arg_llvm_type = "void";
            else
                arg_llvm_type = "i32";

            // Allocate stack slot
            std::string stack_loc = code_buffer.freshVar(); // %tX
            code_buffer.emit(stack_loc + " = alloca " + arg_llvm_type);

            // Store argument from register to stack
            // Note: CodeBuffer::freshVar() creates %t0, %t1... 
            // We need to refer to the function arguments which are implicit %0, %1...
            std::string arg_reg = "%" + std::to_string(i);
            code_buffer.emit("store " + arg_llvm_type + " " + arg_reg + ", " + arg_llvm_type + "* " + stack_loc);
        
            // Add to symbol table for variable lookup
            std::shared_ptr<SymbolData> new_data = std::make_shared<SymbolData>(formal->id->value, formal->type->type);
            new_data->llvm_var = stack_loc;
            insert(new_data);
        }
    
        node.body->accept(*this);
    
        // Handle implicit return for void functions or if user forgot return
        if (node.return_type->type == ast::BuiltInType::VOID) {
            code_buffer.emit("ret void");
        } else {
            // Adding a default return 0 if no return was encountered
            code_buffer.emit("ret i32 0"); 
        }
    
        code_buffer.emit("}");
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
