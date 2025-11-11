%{
    #include "tokens.hpp"
%}

letter [a-zA-Z]
digit [0-9]

%%

"void" { return VOID; }

%%

int yywrap() { return 1; }
