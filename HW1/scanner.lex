%{
    #include "tokens.hpp"
%}

%x COMMENT_
%x STRING_

letter  ([a-zA-Z])
digit   ([0-9])
nl      ([\n\r] | \r | \n)
num     (0 | [1-9][0-9]*)

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
"["     { return LBRACK; }
"]"     { return RBRACK; }
"="     { return ASSIGN; }
[=!<>]"=" | [<>]   { return RELOP; }
[+-*/]             { return BINOP; }
"//"            { BEGIN(COMMENT_); }
<COMMENT_>nl    { BEGIN(INITIAL); }
<COMMENT_>.     { }
{letter}[{letter}{digit}]*  { return ID; }
num     { return NUM; }
num"b"  { return NUM_B; }


%%

int yywrap() { return 1; }
