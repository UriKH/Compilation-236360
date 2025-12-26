#include "output.hpp"
#include "nodes.hpp"
#include <iostream>

// Extern from the bison-generated parser
extern int yyparse();

extern std::shared_ptr<ast::Node> program;

int main() {
    // Parse the input. The result is stored in the global variable `program`
    yyparse();

    std::cout << "Abstract Syntax Tree (AST) constructed successfully." << std::endl;

    // Print the AST using the PrintVisitor
    output::MyVisitor visitor;
    program->accept(visitor);
}
