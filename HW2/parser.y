%{

#include "nodes.hpp"
#include "output.hpp"

// bison declarations
extern int yylineno;
extern int yylex();

void yyerror(const char*);

// root of the AST, set by the parser and used by other parts of the compiler
std::shared_ptr<ast::Node> program;

using namespace std;

// TODO: Place any additional declarations here
%}

// TODO: Define tokens here
%token VOID
%token INT
%token BYTE
%token BOOL
%token AND
%token OR
%token TRUE
%token FALSE
%token RETURN
%token IF
%token ELSE
%token WHILE
%token BREAK
%token CONTINUE
%token SC
%token COMMA
%token ASSIGN
%token LE GE LT GT
%token EQ NE
%token ADD SUB
%token MUL DIV
%token ID
%token NUM
%token NUM_B
%token STRING
%token NOT
%token LPAREN RPAREN
%token LBRACE RBRACE

// TODO: Define precedence and associativity here
%nonassoc NELSE
%nonassoc ELSE
%right ASSIGN
%left OR AND 
%left EQ NE
%left LE GE LT GT
%left ADD SUB
%left MUL DIV
%right CAST
%right NOT


%%

// While reducing the start variable, set the root of the AST
Program:  Funcs { program = dynamic_pointer_cast<ast::Funcs>($1); }
;

// TODO: Define grammar here
Funcs: /* empty */ { $$ = make_shared<ast::Funcs>(); }
    | FuncDecl Funcs { $$ = dynamic_pointer_cast<ast::Funcs>($2); dynamic_pointer_cast<ast::Funcs>($$)->push_front(dynamic_pointer_cast<ast::FuncDecl>($1)); }
;

FuncDecl: RetType ID LPAREN Formals RPAREN LBRACE Statements RBRACE
    { $$ = make_shared<ast::FuncDecl>(dynamic_pointer_cast<ast::ID>($2), dynamic_pointer_cast<ast::Type>($1), dynamic_pointer_cast<ast::Formals>($4), dynamic_pointer_cast<ast::Statements>($7)); }
;

RetType: VOID { $$ = make_shared<ast::Type>(ast::BuiltInType::VOID); }
    | Type { $$ = dynamic_pointer_cast<ast::Type>($1); }
;

Formals: /* empty */ { $$ = make_shared<ast::Formals>(); }
    | FormalsList { $$ = dynamic_pointer_cast<ast::Formals>($1); }
;

FormalsList: FormalDecl { $$ = make_shared<ast::Formals>(dynamic_pointer_cast<ast::Formal>($1)); }
    | FormalDecl COMMA FormalsList { $$ = dynamic_pointer_cast<ast::Formals>($3); dynamic_pointer_cast<ast::Formals>($$)->push_front(dynamic_pointer_cast<ast::Formal>($1)); }
;

FormalDecl: Type ID { $$ = make_shared<ast::Formal>(dynamic_pointer_cast<ast::ID>($2), dynamic_pointer_cast<ast::Type>($1)); }
;

Statements: Statement { $$ = make_shared<ast::Statements>(dynamic_pointer_cast<ast::Statement>($1)); }
    | Statements Statement { $$ = dynamic_pointer_cast<ast::Statements>($1); dynamic_pointer_cast<ast::Statements>($$)->push_back(dynamic_pointer_cast<ast::Statement>($2)); }
;

Statement: LBRACE Statements RBRACE { $$ = $2; }
    | Type ID SC { $$ = make_shared<ast::VarDecl>(dynamic_pointer_cast<ast::ID>($2), dynamic_pointer_cast<ast::Type>($1)); }
    | Type ID ASSIGN Exp SC { $$ = make_shared<ast::VarDecl>(dynamic_pointer_cast<ast::ID>($2), dynamic_pointer_cast<ast::Type>($1), dynamic_pointer_cast<ast::Exp>($4)); }
    | ID ASSIGN Exp SC { $$ = make_shared<ast::Assign>(dynamic_pointer_cast<ast::ID>($1), dynamic_pointer_cast<ast::Exp>($3)); }
    | Call SC { $$ = dynamic_pointer_cast<ast::Call>($1); }
    | RETURN SC { $$ = make_shared<ast::Return>(); }
    | RETURN Exp SC { $$ = make_shared<ast::Return>(dynamic_pointer_cast<ast::Exp>($2)); }
    | IF LPAREN Exp RPAREN Statement %prec NELSE { $$ = make_shared<ast::If>(dynamic_pointer_cast<ast::Exp>($3), dynamic_pointer_cast<ast::Statement>($5)); }
    | IF LPAREN Exp RPAREN Statement ELSE Statement { $$ = make_shared<ast::If>(dynamic_pointer_cast<ast::Exp>($3), dynamic_pointer_cast<ast::Statement>($5), dynamic_pointer_cast<ast::Statement>($7)); }
    | WHILE LPAREN Exp RPAREN Statement { $$ = make_shared<ast::While>(dynamic_pointer_cast<ast::Exp>($3), dynamic_pointer_cast<ast::Statement>($5)); }
    | BREAK SC { $$ = make_shared<ast::Break>(); }
    | CONTINUE SC { $$ = make_shared<ast::Continue>(); }
;

Call: ID LPAREN ExpList RPAREN { $$ = make_shared<ast::Call>(dynamic_pointer_cast<ast::ID>($1), dynamic_pointer_cast<ast::ExpList>($3)); }
    | ID LPAREN RPAREN { $$ = make_shared<ast::Call>(dynamic_pointer_cast<ast::ID>($1)); }
;

ExpList: Exp { $$ = make_shared<ast::ExpList>(dynamic_pointer_cast<ast::Exp>($1)); }
    | Exp COMMA ExpList { $$ = dynamic_pointer_cast<ast::ExpList>($3); dynamic_pointer_cast<ast::ExpList>($$)->push_front(dynamic_pointer_cast<ast::Exp>($1)); }
;

Type: INT { $$ = make_shared<ast::Type>(ast::BuiltInType::INT);; }
    | BYTE { $$ = make_shared<ast::Type>(ast::BuiltInType::BYTE);; }
    | BOOL { $$ = make_shared<ast::Type>(ast::BuiltInType::BOOL); }
;

Exp: LPAREN Exp RPAREN { $$ = dynamic_pointer_cast<ast::Exp>($2); }
    | Exp ADD Exp { $$ = make_shared<ast::BinOp>(dynamic_pointer_cast<ast::Exp>($1), dynamic_pointer_cast<ast::Exp>($3), ast::BinOpType::ADD);}
    | Exp SUB Exp { $$ = make_shared<ast::BinOp>(dynamic_pointer_cast<ast::Exp>($1), dynamic_pointer_cast<ast::Exp>($3), ast::BinOpType::SUB);}
    | Exp MUL Exp { $$ = make_shared<ast::BinOp>(dynamic_pointer_cast<ast::Exp>($1), dynamic_pointer_cast<ast::Exp>($3), ast::BinOpType::MUL);}
    | Exp DIV Exp { $$ = make_shared<ast::BinOp>(dynamic_pointer_cast<ast::Exp>($1), dynamic_pointer_cast<ast::Exp>($3), ast::BinOpType::DIV);}
    | ID { $$ = dynamic_pointer_cast<ast::ID>($1); }
    | Call { $$ = dynamic_pointer_cast<ast::Call>($1); }
    | NUM { $$ = dynamic_pointer_cast<ast::Num>($1); }
    | NUM_B { $$ = dynamic_pointer_cast<ast::NumB>($1); }
    | STRING { $$ = dynamic_pointer_cast<ast::String>($1); }
    | TRUE { $$ = make_shared<ast::Bool>(true); }
    | FALSE { $$ = make_shared<ast::Bool>(false); }
    | NOT Exp { $$ = make_shared<ast::Not>(dynamic_pointer_cast<ast::Exp>($2)); }
    | Exp AND Exp { $$ = make_shared<ast::And>(dynamic_pointer_cast<ast::Exp>($1), dynamic_pointer_cast<ast::Exp>($3)); }
    | Exp OR Exp { $$ = make_shared<ast::Or>(dynamic_pointer_cast<ast::Exp>($1), dynamic_pointer_cast<ast::Exp>($3)); }
    | Exp EQ Exp { $$ = make_shared<ast::RelOp>(dynamic_pointer_cast<ast::Exp>($1), dynamic_pointer_cast<ast::Exp>($3), ast::RelOpType::EQ); }
    | Exp NE Exp { $$ = make_shared<ast::RelOp>(dynamic_pointer_cast<ast::Exp>($1), dynamic_pointer_cast<ast::Exp>($3), ast::RelOpType::NE); }
    | Exp LE Exp { $$ = make_shared<ast::RelOp>(dynamic_pointer_cast<ast::Exp>($1), dynamic_pointer_cast<ast::Exp>($3), ast::RelOpType::LE); }
    | Exp GE Exp { $$ = make_shared<ast::RelOp>(dynamic_pointer_cast<ast::Exp>($1), dynamic_pointer_cast<ast::Exp>($3), ast::RelOpType::GE); }
    | Exp LT Exp { $$ = make_shared<ast::RelOp>(dynamic_pointer_cast<ast::Exp>($1), dynamic_pointer_cast<ast::Exp>($3), ast::RelOpType::LT); }
    | Exp GT Exp { $$ = make_shared<ast::RelOp>(dynamic_pointer_cast<ast::Exp>($1), dynamic_pointer_cast<ast::Exp>($3), ast::RelOpType::GT); }
    | LPAREN Type RPAREN Exp %prec CAST { $$ = make_shared<ast::Cast>(dynamic_pointer_cast<ast::Exp>($4), dynamic_pointer_cast<ast::Type>($2)); }
;

%%

// TODO: Place any additional code here
void yyerror(const char* msg) {
    output::errorSyn(yylineno);
}