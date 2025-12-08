%{
    #include "nodes.hpp"
    #include "output.hpp"
    #include "parser.tab.h"
    #include <string.h>
%}

%option yylineno
%option noyywrap

%%

"void"  { return VOID; }
"int"   { return INT; }
"byte"  { return BYTE; }
"bool"  { return BOOL; }
"and"   { return AND; }
"or"    { return OR; }
"not"   { return NOT; }
"true"  { return TRUE; }
"false"     { return FALSE; }
"return"    { return RETURN; }
"if"    { return IF; }
"else"  { return ELSE; }
"while" { return WHILE; }
"break" { return BREAK; }
"continue"  { return CONTINUE; }
";"     { return SC; }
","     { return COMMA; }
"("     { return LPAREN; }
")"     { return RPAREN; }
"{"     { return LBRACE; }
"}"     { return RBRACE; }
"="     { return ASSIGN; }
(!=)      { return NE; }
(>=)      { return GE; }
(<=)      { return LE; }
(<)       { return LT; }
(>)       { return GT; }
(==)      { return EQ; }
\+        { return ADD; }
\-        { return SUB; }
\*        { return MUL; }
\/        { return DIV; }
[a-zA-Z][a-zA-Z0-9]*    { yylval = std::make_shared<ast::ID>(yytext);  return ID; }
(0|[1-9][0-9]*)     { yylval = std::make_shared<ast::Num>(yytext); return NUM; }
(0b|[1-9][0-9]*b)   { yylval = std::make_shared<ast::NumB>(yytext); return NUM_B; }
(\"([^\n\r\"\\]|\\[rnt\"\\])+\")     { yylval = std::make_shared<ast::String>(yytext); return STRING; }


\/\/[^\r\n]*[\r|\n|\r\n]?   { }  // single line comment ignore
\n      { /* ignore newline, but count it */ }
[ \t\r] { /* ignore whitespace */ }

. { output::errorLex(yylineno); }

%%

