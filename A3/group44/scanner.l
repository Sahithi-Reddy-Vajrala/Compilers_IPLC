%{
// This part goes directly into the generated parser

#include "scanner.hh"
#include <string>
#include <algorithm>

// YY_DECL is bound to the type of the scanner. The default is 
// #define YY_DECL int Scanner::yylex()
// which is generated anyway.

//If you want the type of the generated scanner to be different, do this

#undef  YY_DECL
#define YY_DECL int IPL::Scanner::yylex( IPL::Parser::semantic_type * const lval, IPL::Parser::location_type *loc )

//We want these to be the first action after a token is recognized. 

#define YY_USER_ACTION loc->step(); loc->columns(yyleng);

// token_type is a short hand for IPL::Parser::token

using token_type = IPL::Parser::token;

%}


/* %option debug */
%option nodefault
%option yyclass="Scanner"
%option noyywrap
%option c++
%x COMMENT

%%

%{ /** Code executed at the beginning of yylex **/

      yylval = lval;

%}

<<EOF>>                            yyterminate();
[ \t]+                             //skip
[\n]                               loc->lines();

<INITIAL>{
"/*"                               BEGIN(COMMENT);
}
<COMMENT>{
[*]+"/"                             BEGIN(INITIAL);
[\n]                               loc->lines();
[^*\n]+                                //skip
[*]+                                  //skip
}
struct                                      {
       yylval->emplace< std::string >( YYText() );
       return token_type::STRUCT;
}
void                                        {
       yylval->emplace< std::string >( YYText() );
       return token_type::VOID;
}
int                                         {
       yylval->emplace< std::string >( YYText() );
       return token_type::INT;
}
if                                          {
       yylval->emplace< std::string >( YYText() );
       return token_type::IF;
}
else                                        {
       yylval->emplace< std::string >( YYText() );
       return token_type::ELSE;
}
while                                       {
       yylval->emplace< std::string >( YYText() );
       return token_type::WHILE;
}
for                                          {
       yylval->emplace< std::string >( YYText() );
       return token_type::FOR;
}
return                                      {
       yylval->emplace< std::string >( YYText() );
       return token_type::RETURN;
}
main                                        {
        yylval->emplace< std::string >( YYText() );
       return token_type::MAIN;
}
printf                                        {
        yylval->emplace< std::string >( YYText() );
       return token_type::PRINTF;
}                  
([1-9][0-9]*|0[bB][01]*|0[0-7]*|0[xX][0-9a-fA-F]*)  {
       yylval->emplace< std::string >( YYText() );
       return token_type::CONSTANT_INT;
}

\"((\\[tn\"\\])|([^\\\"\n]))*\"                          {
       yylval->emplace< std::string >( YYText() );
       return token_type::CONSTANT_STR;
}    
        
[_a-zA-Z][_0-9a-zA-Z]*                      {
       yylval->emplace< std::string >( YYText() );
       return token_type::IDENTIFIER;
}  
"++"                                        {
       yylval->emplace< std::string >( YYText() );
       return token_type::OP_INC;
}  
"->"                                        {
       yylval->emplace< std::string >( YYText() );
       return token_type::OP_PTR;
}  
"||"                                        {
       yylval->emplace< std::string >( YYText() );
       return token_type::OP_OR;
}  
"&&"                                        {
       yylval->emplace< std::string >( YYText() );
       return token_type::OP_AND;
}  
"=="                                        {
       yylval->emplace< std::string >( YYText() );
       return token_type::OP_EQ;
}  
"!="                                        {
       yylval->emplace< std::string >( YYText() );
       return token_type::OP_NEQ;
}  
"<="                                        {
       yylval->emplace< std::string >( YYText() );
       return token_type::OP_LTE;
}  
">="                                         {
       yylval->emplace< std::string >( YYText() );
       return token_type::OP_GTE;
}  
"{"                                       return '{';
"}"                                       return '}';
"("                                       return '(';
")"                                       return ')';
"["                                       return '[';
"]"                                       return ']';
";"                                       return ';';
","                                       return ',';
"."                                       return '.';
"!"                                       return '!';
"&"                                       return '&';
"="                                       return '=';
"<"                                       return '<';
">"                                       return '>';
"+"                                       return '+';
"-"                                       return '-';
"*"                                       return '*';
"/"                                       return '/';
.				              {
       yylval->emplace< std::string >( YYText() );
       return token_type::OTHERS;
}

%%

