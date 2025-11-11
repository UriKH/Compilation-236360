%{
    #include "tokens.hpp"
    #include <string.h>

    #define MAX_STRING_LEN 1024
    char string_buf[MAX_STRING_LEN + 1];
    int string_pos;
%}

%x COMMENT_
%x STRING_

letter  ([a-zA-Z])
digit   ([0-9])
nl      ([\n\r]|\r|\n)
num     (0|[1-9][0-9]*)
whitespace ([\t\r\n ])
printable_char ([\x20-\x7E])
escape_seq (\\([\\\"nrt0]|x[0-9A-Fa-f]{2}))
undef_es ()


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
[=!<>]"="|[<>]  { return RELOP; }
[+\-*/]             { return BINOP; }


"//"            { BEGIN(COMMENT_); return COMMENT; }
<COMMENT_>{nl}    { BEGIN(INITIAL); }
<COMMENT_>.     { }
{letter}({letter}|{digit})*  { return ID; }
{num}     { return NUM; }
{num}"b"  { return NUM_B; }


\"  { BEGIN(STRING_); string_pos = 0; }
<STRING_>\" { 
    BEGIN(INITIAL);
    string_buf[string_pos] = '\0';
    return STRING; 
}

/* Deal with escape sequences */
<STRING_>"\\n"              { string_buf[string_pos++] = '\n'; }
<STRING_>"\\t"              { string_buf[string_pos++] = '\t'; }
<STRING_>"\\r"              { string_buf[string_pos++] = '\r'; }
<STRING_>"\\0"              { string_buf[string_pos++] = '\0'; }
<STRING_>"\\\""             { string_buf[string_pos++] = '\"'; }
<STRING_>"\\\\"             { string_buf[string_pos++] = '\\'; }
<STRING_>("\\x"[0-9A-Fa-f]{2}) {
    unsigned int val;
    sscanf(yytext + 2, "%2x", &val);
    string_buf[string_pos++] = (char)val;
}

/* put valid printable char in string */
<STRING_>({printable_char}|[ \t])   { string_buf[string_pos++] = yytext; }


<STRING_>(^({printable_char})) {
    output::errorUnknownChar(yytext);
}


/*  */


<STRING_>({printable_char}|{escape_seq}|[ \t])     { }
<STRING_>[^\"]  { printf("bad"); }

{whitespace} { }

%%

int yywrap() { return 1; }

