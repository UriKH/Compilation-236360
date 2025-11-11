%{
    #include "tokens.hpp"
%}

letter  ([a-zA-Z])
digit   ([0-9])

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
"return"    { return RETRUN; }
"if"    { return IF; }
"else"  { return ELSE; }
"while" { return WHILE; }
"break" { return BREAK; }
"continue"  { return CONTINUE; }
";"     { return SC; }

%%

int yywrap() { return 1; }
