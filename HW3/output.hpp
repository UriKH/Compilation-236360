#ifndef OUTPUT_HPP
#define OUTPUT_HPP

#include <utility>
#include <vector>
#include <string>
#include <map>
#include <sstream>
#include <stack>
#include "visitor.hpp"
#include "nodes.hpp"


namespace output{
    /* Error handling functions */

    void errorLex(int lineno);

    void errorSyn(int lineno);

    void errorUndef(int lineno, const std::string &id);

    void errorDefAsFunc(int lineno, const std::string &id);

    void errorUndefFunc(int lineno, const std::string &id);

    void errorDefAsVar(int lineno, const std::string &id);

    void errorDef(int lineno, const std::string &id);

    void errorPrototypeMismatch(int lineno, const std::string &id, std::vector<std::string> &paramTypes);

    void errorMismatch(int lineno);

    void errorUnexpectedBreak(int lineno);

    void errorUnexpectedContinue(int lineno);

    void errorMainMissing();

    void errorByteTooLarge(int lineno, int value);

    /* ScopePrinter class
     * This class is used to print scopes in a human-readable format.
     */
    class ScopePrinter {
    private:
        std::stringstream globalsBuffer;
        std::stringstream buffer;
        int indentLevel;

        std::string indent() const;

    public:
        ScopePrinter();

        void beginScope();

        void endScope();

        void emitVar(const std::string &id, const ast::BuiltInType &type, int offset);

        void emitFunc(const std::string &id, const ast::BuiltInType &returnType,
                      const std::vector<ast::BuiltInType> &paramTypes);

        friend std::ostream &operator<<(std::ostream &os, const ScopePrinter &printer);
    };

    class MyVisitor : public Visitor {
    private:
        struct SymbolData {
            std::string name;
            ast::BuiltInType type;
            int offset;
            bool is_func;
            std::vector<ast::BuiltInType> func_types;

            SymbolData(std::string name, ast::BuiltInType type, int offset = 0,
                       bool is_func = false, std::vector<ast::BuiltInType> func_types = {}) :
            name(std::move(name)), type(type) {}
        };

        struct SymbolTable{
            std::shared_ptr<SymbolTable> parent;
            bool is_loop_scope;
            std::map<std::string, std::shared_ptr<SymbolData>> table;
            int vars_count; // Add a counter for variables only - to handle offset for funcs and vars

            SymbolTable(const std::shared_ptr<SymbolTable>& parent, bool is_loop_scope):
                parent(parent), is_loop_scope(is_loop_scope), vars_count(0) {}

            void insert(const std::shared_ptr<SymbolData>& sym_data){
                table[sym_data->name] = sym_data;
            }

            static std::shared_ptr<SymbolData> validate_existence(
                    const std::shared_ptr<SymbolTable>& sym_tab, const std::string& id){
                auto lookup = sym_tab->table.find(id);
                if (lookup != sym_tab->table.end())
                    return lookup->second;
                if (sym_tab->parent == nullptr)
                    return nullptr;
                return validate_existence(sym_tab->parent, id);
            }
        };

        ScopePrinter printer;

        ast::BuiltInType last_type;
        std::string last_func_id;

        std::stack<std::shared_ptr<SymbolTable>> table_stack;
        std::stack<int> offset_stack;
        int arg_offset = 0;
        bool returns = false;
        bool is_func_body = false;
        ast::BuiltInType return_type;

        void begin_scope(const std::shared_ptr<SymbolTable>& parent, bool is_loop_scope){
            printer.beginScope();
            table_stack.push(std::make_shared<SymbolTable>(parent, is_loop_scope));
        }

        void end_scope(){
            int vars_to_pop = table_stack.top()->vars_count;

            for (size_t i = 0; i < vars_to_pop; i++)
                offset_stack.pop();

            table_stack.pop();
            printer.endScope();
        }

        void insert(const std::shared_ptr<SymbolData>& sym_data, bool is_func = false,
            std::vector<ast::BuiltInType> func_types = {}, bool is_arg = false){
            table_stack.top()->insert(sym_data);

            if (is_func){   //TODO: not sure, a function doesn't have an offset
                sym_data->is_func = true;
                sym_data->func_types = std::move(func_types);
                printer.emitFunc(sym_data->name, sym_data->type, sym_data->func_types);
            }
            else{
                table_stack.top()->vars_count++;

                int offset;
                if (is_arg){
                    offset = arg_offset;
                }
                else{
                    if (offset_stack.empty())
                        offset = 0;
                    else{
                        int top = offset_stack.top();
                        offset = (top >= 0) ? top + 1 : 0;
                    }
                        
                }
                // int offset = (is_arg) ? arg_offset : (offset_stack.empty() ? 0 : offset_stack.top() + 1);
                sym_data->offset = offset;
                offset_stack.push(offset);
                printer.emitVar(sym_data->name, sym_data->type, sym_data->offset);
            }
        }

        std::shared_ptr<SymbolData> check_exists_by_name(const std::string& id) {
            if (table_stack.empty())
                return nullptr;
            return SymbolTable::validate_existence(table_stack.top(), id);
        }

    public:
        MyVisitor();

        void visit(ast::Num &node) override;

        void visit(ast::NumB &node) override;

        void visit(ast::String &node) override;

        void visit(ast::Bool &node) override;

        void visit(ast::ID &node) override;

        void visit(ast::BinOp &node) override;

        void visit(ast::RelOp &node) override;

        void visit(ast::Not &node) override;

        void visit(ast::And &node) override;

        void visit(ast::Or &node) override;

        void visit(ast::Type &node) override;

        void visit(ast::Cast &node) override;

        void visit(ast::ExpList &node) override;

        void visit(ast::Call &node) override;

        void visit(ast::Statements &node) override;

        void visit(ast::Break &node) override;

        void visit(ast::Continue &node) override;

        void visit(ast::Return &node) override;

        void visit(ast::If &node) override;

        void visit(ast::While &node) override;

        void visit(ast::VarDecl &node) override;

        void visit(ast::Assign &node) override;

        void visit(ast::Formal &node) override;

        void visit(ast::Formals &node) override;

        void visit(ast::FuncDecl &node) override;

        void visit(ast::Funcs &node) override;
    };
}

#endif //OUTPUT_HPP
