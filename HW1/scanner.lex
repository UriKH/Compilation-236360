%{
    #include "tokens.hpp"

}%

letter [a-zA-Z]
digit  [0-9]

%%

void { return VOID; }
/* TODO: insert all other stuff */

%%