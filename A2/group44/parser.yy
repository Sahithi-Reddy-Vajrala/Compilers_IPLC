%skeleton "lalr1.cc"
%require  "3.0.1"

%defines 
%define api.namespace {IPL}
%define api.parser.class {Parser}
%define parse.trace

%code requires{
   #include "ast_class.hh"
   #include "symbtab.hh"
   namespace IPL {
      class Scanner;
   }

  // # ifndef YY_NULLPTR
  // #  if defined __cplusplus && 201103L <= __cplusplus
  // #   define YY_NULLPTR nullptr
  // #  else
  // #   define YY_NULLPTR 0
  // #  endif
  // # endif

}

%printer { std::cerr << $$; } STRUCT
%printer { std::cerr << $$; } IDENTIFIER
%printer { std::cerr << $$; } VOID
%printer { std::cerr << $$; } INT
%printer { std::cerr << $$; } FLOAT
%printer { std::cerr << $$; } IF
%printer { std::cerr << $$; } ELSE
%printer { std::cerr << $$; } FOR
%printer { std::cerr << $$; } WHILE
%printer { std::cerr << $$; } STRING_LITERAL
%printer { std::cerr << $$; } INT_CONSTANT
%printer { std::cerr << $$; } FLOAT_CONSTANT
%printer { std::cerr << $$; } PTR_OP
%printer { std::cerr << $$; } INC_OP
%printer { std::cerr << $$; } OR_OP
%printer { std::cerr << $$; } AND_OP
%printer { std::cerr << $$; } EQ_OP
%printer { std::cerr << $$; } NE_OP
%printer { std::cerr << $$; } LE_OP
%printer { std::cerr << $$; } GE_OP
%printer { std::cerr << $$; } RETURN
%printer { std::cerr << $$; } OTHERS

%parse-param { Scanner  &scanner  }
%locations
%code{
   #include <iostream>
   #include <cstdlib>
   #include <fstream>
   #include <string>
   
   
   #include "scanner.hh"
   map<string,abstract_astnode*> ast;
   extern SymbTab gst;
   bool func_decl = false; // inside function declaration
   const int int_size = 4, float_size = 4;
   const int ptr_size = 4;
   int offset, size;
   string ret_type;
   vector<int> default_vec;
   //declaration_list_class *decl_list;
  // declaration_list_class *default_decl_list = new declaration_list_class();
   parameter_list_class *default_param_list = new parameter_list_class();
   fun_declarator_class *fn_decl;
   vector<type_specifier_class*> type_spec;
   type_specifier_class *type_chc_0 = new type_specifier_class("void",true);
   type_specifier_class *type_chc_1 = new type_specifier_class("int",true);
   type_specifier_class *type_chc_2 = new type_specifier_class("float",true);
   SymbTab *locl_st = new SymbTab();
   arr *default_ptr = new arr(NULL,true,0);

#undef yylex
#define yylex IPL::Parser::scanner.yylex

}




%define api.value.type variant
%define parse.assert

%start translation_unit



%token <std::string> STRUCT
%token <std::string> IDENTIFIER 
%token <std::string> VOID
%token <std::string> FLOAT
%token <std::string> INT
%token <std::string> IF
%token <std::string> ELSE
%token <std::string> WHILE
%token <std::string> FOR 
%token <std::string> STRING_LITERAL 
%token <std::string> INT_CONSTANT 
%token <std::string> FLOAT_CONSTANT
%token <std::string> RETURN
%token <std::string> PTR_OP
%token <std::string> INC_OP
%token <std::string> OR_OP
%token <std::string> AND_OP
%token <std::string> EQ_OP
%token <std::string> NE_OP
%token <std::string> LE_OP
%token <std::string> GE_OP
%token <std::string> OTHERS
%token '.' '+' '-' '!' '&' '{' '}' ';' '*' '/' '(' ')' ',' '[' ']' '=' '<' '>'  


%nterm <abstract_astnode*> translation_unit;
%nterm <abstract_astnode*> struct_specifier;
%nterm <abstract_astnode*> function_definition;
%nterm <type_specifier_class*> type_specifier;
%nterm <fun_declarator_class*> fun_declarator;
%nterm <parameter_list_class*> parameter_list;
%nterm <parameter_declaration_class*> parameter_declaration;
%nterm <declarator_class*> declarator_arr; 
%nterm <declarator_class*> declarator;
%nterm <abstract_astnode*> compound_statement;
%nterm <seq_astnode*> statement_list;
%nterm <statement_astnode*> statement;
%nterm <assignE_astnode*> assignment_expression;
%nterm <assignS_astnode*> assignment_statement;
%nterm <proccall_astnode*> procedure_call;
%nterm <exp_astnode*> expression;
%nterm <exp_astnode*> logical_and_expression;
%nterm <exp_astnode*> equality_expression;
%nterm <exp_astnode*> relational_expression;
%nterm <exp_astnode*> additive_expression;
%nterm <exp_astnode*> unary_expression;
%nterm <exp_astnode*> multiplicative_expression;
%nterm <exp_astnode*> postfix_expression;
%nterm <exp_astnode*> primary_expression;
%nterm <funcall_astnode*> expression_list;
%nterm <std::string> unary_operator;
%nterm <statement_astnode*> selection_statement;
%nterm <statement_astnode*>iteration_statement;
%nterm <declaration_list_class*> declaration_list;
%nterm <declaration_class*> declaration;
%nterm <declarator_list_class*> declarator_list;

%%

translation_unit:
     struct_specifier
     {         
          locl_st = new SymbTab();
          type_spec.clear();
     }
     | function_definition
     {
          locl_st = new SymbTab();
          type_spec.clear();
     }
     | translation_unit struct_specifier
     {
          locl_st = new SymbTab();
          type_spec.clear();
     }
     | translation_unit function_definition
     {
          locl_st = new SymbTab();
          type_spec.clear();
     }
     ;

struct_specifier:
     STRUCT IDENTIFIER '{' declaration_list '}' ';'
     {
          string first($1 + " " + $2);
          if(gst.Entries.count(first) > 0) error(@$, string("\""+first+"\" has a previous definition"));
          
          offset = 0;
          for(auto decl_ptr : $4->decl) {
               ret_type = decl_ptr->ts->type;
               if(!(decl_ptr->ts->base)) { // struct_type declaration
                    if(gst.Entries.count(ret_type) == 0 && ret_type != first)
                         error(decl_ptr->lo, "\""+ret_type+"\" not declared");
               }

               for(auto ltrl : decl_ptr->dl->decl) {
                    ret_type = decl_ptr->ts->type;
                    size = 0;
                    if(ltrl->num_ptr > 0) { //pointer
                         size = ptr_size;
                         for(int i=0; i<ltrl->num_ptr; i++) ret_type += "*";
                    }
                    else { //not pointer
                         if(ret_type == "int") size = int_size;
                         else if(ret_type == "float") size = float_size;
                         else if(ret_type == "void") {// ERROR
                              if(ltrl->indices.empty())
                                   error(decl_ptr->lo, "Cannot declare variable of type \"void\"");
                              else {
                                   error(decl_ptr->lo, "Cannot declare \""+ltrl->iden+"\" as an array of voids");
                              }
                         }
                         else if(!(decl_ptr->ts->base)) { //not_base, struct_type
                              if(ret_type == first)  // recursive_struct
                                   error(decl_ptr->lo, "\""+ret_type+"\" is not defined");
                              else size = gst.Entries[ret_type].size;
                         }
                    }
                    if(!(ltrl->indices.empty())) { //array
                         for(const int &i : ltrl->indices) {
                              size *= i;
                              ret_type += "["+to_string(i)+"]";
                         }
                    }
                    if(locl_st->Entries.count(ltrl->iden) > 0) //PREVIOUS_DECL ERROR
                         error(decl_ptr->lo, "\""+ltrl->iden+"\" has a previous declaration");
                    entry e("var","local",size,offset,ret_type,NULL, ltrl->num_ptr,ltrl->indices,decl_ptr->ts->type);
                    locl_st->Entries.insert({ltrl->iden,e});
                    offset += size;   
               }                      
          }
          entry second("struct","global",offset,0,"",locl_st);
          gst.Entries.insert({first, second});
     }
     ;

function_definition: 
     type_specifier fun_declarator compound_statement
     {
          ret_type = $1->type;
          string first($2->iden);
          entry second("fun","global",0,0,ret_type,locl_st,$2->par_list);
          gst.Entries.insert({first, second});
          ast[first] = $3;
          func_decl = false;
     }
     ;

type_specifier:
     VOID 
     {
         $$ = type_chc_0;
         type_spec.push_back($$);
     }
     | INT
     {
         $$ = type_chc_1;
         type_spec.push_back($$);
     }
     | FLOAT
     {
         $$ = type_chc_2;
         type_spec.push_back($$);
     }
     | STRUCT IDENTIFIER
     {    
          string first($1+" "+$2);
          $$ = new type_specifier_class(first,false);
          type_spec.push_back($$);
     }
     ;
fun_declarator: 
     IDENTIFIER '(' parameter_list ')'
     {    
          if(!(type_spec.front()->base) && gst.Entries.count(type_spec.front()->type) == 0) //function_return_type is not declared
               error(@$, "\""+type_spec.front()->type+"\" not declared");
          if(gst.Entries.count($1) > 0) 
               error(@$, "The function \""+$1+"\" has a previous definition");

          map<string,int> prev_decl_err;
          string first;
     
          for(auto par_decln : $3->par_decl) {
               if(par_decln->ts->type == "void" && par_decln->decl->num_ptr == 0) {
                    error(@$,"Cannot declare the type of a parameter as \"void\"");
               }
               if(!(par_decln->ts->base) && gst.Entries.count(par_decln->ts->type) == 0)
                    error(@$, "\""+par_decln->ts->type+"\" not declared");
               first = par_decln->decl->iden;
               if(prev_decl_err.count(first) == 0) prev_decl_err.insert({first,0});
               else error(@$, "\""+first+"\"  has a previous declaration");
          }

          offset = 12;
          for(auto rit = $3->par_decl.rbegin(); rit != $3->par_decl.rend(); rit++) {
               size = 0;
               ret_type = (*rit)->ts->type;
               
               if((*rit)->decl->num_ptr > 0) { //pointer
                    size = ptr_size;
                    for(int i=0; i<(*rit)->decl->num_ptr; i++) ret_type += "*";
               }
               else { //not pointer
                    if(ret_type == "int") size = int_size;
                    else if(ret_type == "float") size = float_size;
                    //else if(ret_type == "void") ERROR
                    else if(!((*rit)->ts->base)) { //not_base, struct
                         size = gst.Entries[ret_type].size;
                    }
               }
               if(!((*rit)->decl->indices.empty())) { //array
                    for(const int &i : (*rit)->decl->indices) {
                         size *= i;
                         ret_type += "["+to_string(i)+"]";
                    }
               }
               first = (*rit)->decl->iden;
               entry e("var","param",size,offset,ret_type,NULL,(*rit)->decl->num_ptr,(*rit)->decl->indices,(*rit)->ts->type);
               locl_st->Entries.insert({first,e});
               offset += size;
          }

          $$ = new fun_declarator_class($1,$3);
          fn_decl = $$;
          func_decl = true; offset = 0;
     }
     | IDENTIFIER '(' ')'
     {
          if(!(type_spec.front()->base) && gst.Entries.count(type_spec.front()->type) == 0) //function_return_type is not declared
               error(@$, "\""+type_spec.front()->type+"\" not declared");
          if(gst.Entries.count($1) > 0) 
               error(@$, "The function \""+$1+"\" has a previous definition");
          $$ = new fun_declarator_class($1,default_param_list);
          fn_decl = $$;
          func_decl = true; offset = 0;
     }
     ;

parameter_list:
     parameter_declaration
     {
          $$ = new parameter_list_class();
          $$->par_decl.push_back($1);
     }
     | parameter_list ',' parameter_declaration
     {
          $1->par_decl.push_back($3);
          $$ = $1;
     }
     ;

parameter_declaration: 
     type_specifier declarator
     {
          $$ = new parameter_declaration_class($1,$2);
     }
     ;

declarator_arr: 
     IDENTIFIER
     {
          $$ = new declarator_class($1,0);
     }
     | declarator_arr '[' INT_CONSTANT ']'
     {
          $1->indices.push_back(stoi($3));
          $$ = $1;
     }
     ;

declarator: 
     declarator_arr
     {
          $$ = $1;
     }
     | '*' declarator
     {
         $2->num_ptr++;
         $$ = $2;
     }
     ;

compound_statement: 
     '{' '}'
     {
          $$ = new seq_astnode();
     }
     | '{' statement_list '}'
     {
          $$ = $2;
     }
     | '{' declaration_list '}'
     {
          $$ = new seq_astnode();
     }
     | '{' declaration_list statement_list '}'
     {
          $$ = $3;
     }
     ;

statement_list: 
     statement
     {
          $$ = new seq_astnode();
          if($1) $$->vec.push_back($1);
     }             
     | statement_list statement
     {
         if($2) $1->vec.push_back($2);
         $$ = $1;
     }
     ;

statement: 
     ';'
     {
         $$ = new empty_astnode();
     }        
     | '{' statement_list '}'
     {
          $$ = $2;
     }        
     | selection_statement
     {
         $$ = $1;
     }        
     | iteration_statement
     {
         $$ = $1;
     }        
     | assignment_statement
     {
         $$ = $1;
     }        
     | procedure_call
     {
         $$ = $1;
     }        
     | RETURN expression ';'
     {    
          string type = type_spec.front()->type;
          if(!$2->type_tree.empty()) //exp is ptr
               error(@2, "Incompatible type \""+$2->get_type()+"\" returned, expected \""+type+"\"");
          //objects
          if(both_num(type,$2->type)) { //int,float
               string op;
               if($2->type == "int" && type == "float") {
                    op = "TO_FLOAT";  $$ = new return_astnode(new op_unary_astnode(op,$2));
               }
               else if($2->type == "float" && type == "int") {
                    op = "TO_INT";    $$ = new return_astnode(new op_unary_astnode(op,$2));
               }
               else $$ = new return_astnode($2);
          }
          else { 
               if(type != $2->type) error(@2, "Incompatible type \""+$2->get_type()+"\" returned, expected \""+type+"\"");
               else {$$ = new return_astnode($2);} 
          }
     }
     ;

assignment_expression: 
     unary_expression '=' expression
     {
          $$ = new assignE_astnode($1,$3);
          if(!$1->lval) error(@$, "Left operand of assignment should have an lvalue");
          if(is_const_ptr($1)) 
               error(@$, "Incompatible assignment when assigning to type \""+$1->get_type()+"\" from type \""+$3->get_type()+"\"");
          // can be assigned
          if(!is_compatible($1,$3))
               error(@$, "Incompatible assignment when assigning to type \""+$1->get_type()+"\" from type \""+$3->get_type()+"\"");
          if(both_num($1->type,$3->type)) {
               string op;
               if($1->type == "int" && $3->type == "float") {
                    op = "TO_INT"; $$ = new assignE_astnode($1,new op_unary_astnode(op,$3));
               }
               if($1->type == "float" && $3->type == "int") {
                    op = "TO_FLOAT"; $$ = new assignE_astnode($1,new op_unary_astnode(op,$3));
               }
          }
     }
     ;

assignment_statement: 
     assignment_expression ';'
     {
         $$ = new assignS_astnode($1->left, $1->right);
     }
     ;

procedure_call: 
     IDENTIFIER '(' ')' ';'
     {
          $$ = new proccall_astnode();
          $$->fname = new identifier_astnode($1);

          if($1 != "printf" && $1 != "scanf") {
               vector<parameter_declaration_class*> par_decl = fn_decl->par_list->par_decl;
               if(fn_decl->iden != $1) { //not curr_func
                    if( gst.Entries.count($1) == 0 || gst.Entries[$1].varfun != "fun")
                         error(@$, "Procedure \""+$1+"\"  not declared");
                    entry e = gst.Entries[$1];
                    par_decl = e.param_order->par_decl;
               }
               if (par_decl.size() > 0) //curr_func
                    error(@$, "Procedure \""+$1+"\"  called with too few arguments");
          }
     }             
     | IDENTIFIER '(' expression_list ')' ';'
     {
          $$ = new proccall_astnode($3->vec);
          $$->fname = new identifier_astnode($1);
          string op;
          
          if($1 != "printf" && $1 != "scanf") {
               vector<parameter_declaration_class*> par_decl(fn_decl->par_list->par_decl);
               if(fn_decl->iden != $1) { //not curr_func
                    if( gst.Entries.count($1) == 0 || gst.Entries[$1].varfun != "fun")
                         error(@$, "Procedure \""+$1+"\"  not declared");
                    entry e = gst.Entries[$1];
                    par_decl = e.param_order->par_decl;                
               }
               if (par_decl.size() < $3->vec.size()) //curr_func
                    error(@$, "Procedure \""+$1+"\"  called with too many arguments");
               if (par_decl.size() > $3->vec.size())
                    error(@$, "Procedure \""+$1+"\"  called with too few arguments");
               for(int i=0; i<$3->vec.size(); i++) {
                    exp_astnode *temp = new my_par_exp_class(par_decl[i]);
                    if(  !is_compatible(temp,$3->vec[i]) ) {
                         error(@3, "Expected \""+temp->get_type()+"\" but argument is of type \""+$3->vec[i]->get_type()+"\"");
                    }
                    if(temp->type_tree.empty() && $3->vec[i]->type_tree.empty()) {
                         if(both_num(temp->type,$3->vec[i]->type)) { //type_cast
                              if(temp->type == "int" && $$->vec[i]->type == "float") {
                                   op = "TO_INT"; $$->vec[i] = new op_unary_astnode(op,$3->vec[i]);
                              }
                              if(temp->type == "float" && $$->vec[i]->type == "int") {
                                   op = "TO_FLOAT"; $$->vec[i] = new op_unary_astnode(op,$3->vec[i]);
                              }
                         }
                    }
               }
          }
     }
     ;

expression: 
     logical_and_expression
     {
         $$ = $1;
     }         
     | expression OR_OP logical_and_expression
     {    
          if($1->type_tree.empty() && $1->type != "int" && $1->type !="float" && $1->type != "string")
               error(@$, "Invalid operand of ||,  not scalar or pointer");
          if($3->type_tree.empty() && $3->type != "int" && $3->type !="float" && $3->type != "string")
               error(@$, "Invalid operand of ||,  not scalar or pointer");
          $$ = new op_binary_astnode(string("OR_OP"),$1,$3);
          $$->type = "int";
          $$->lval = false; $$->ct_val = false;
     }
     ;

logical_and_expression: 
     equality_expression
     {
         $$ = $1;
     }                     
     | logical_and_expression AND_OP equality_expression
     {
          if($1->type_tree.empty() && $1->type != "int" && $1->type !="float" && $1->type != "string")
               error(@$, "Invalid operand of &&,  not scalar or pointer");
          if($3->type_tree.empty() && $3->type != "int" && $3->type !="float" && $3->type != "string")
               error(@$, "Invalid operand of &&,  not scalar or pointer");
          $$ = new op_binary_astnode(string("AND_OP"),$1,$3);
          $$->type = "int";
          $$->lval = false; $$->ct_val = false;
     }
     ;

equality_expression: 
     relational_expression
     {
         $$ = $1;
     }                  
     | equality_expression EQ_OP relational_expression
     {
          if(!eq_compat($1,$3))
               error(@$,  "Invalid operand types for binary == , \""+$1->get_type()+"\" and \""+$3->get_type()+"\"");
          string op("EQ_OP_");
         op_binary_astnode *temp = new op_binary_astnode(op+"FLOAT",$1,$3);
          if(!($1->type_tree.empty() && $3->type_tree.empty())) {
               temp->op = op+"INT";
          }
          else { //typecast
               if($1->type == "int") {
                    if($3->type == "int") {temp->op = op+"INT";}
                    else temp->left = new op_unary_astnode("TO_FLOAT",$1); //type_cast c1
               }
               else if ($3->type == "int") temp->right = new op_unary_astnode("TO_FLOAT",$3); //type_cast c3
          }
         
          $$ = temp;
          $$->type = "int";
          $$->lval = false; $$->ct_val = false;      
     }                  
     | equality_expression NE_OP relational_expression
     {
          if(!eq_compat($1,$3))
               error(@$,  "Invalid operand types for binary != , \""+$1->get_type()+"\" and \""+$3->get_type()+"\"");
          string op("NE_OP_");
          op_binary_astnode *temp = new op_binary_astnode(op+"FLOAT",$1,$3);
          if(!($1->type_tree.empty() && $3->type_tree.empty())) {
               temp->op = op+"INT";
          }
          else { //typecast
               if($1->type == "int") {
                    if($3->type == "int") {temp->op = op+"INT";}
                    else temp->left = new op_unary_astnode("TO_FLOAT",$1); //type_cast c1
               }
               else if ($3->type == "int") temp->right = new op_unary_astnode("TO_FLOAT",$3); //type_cast c3
          }
         
          $$ = temp;
          $$->type = "int";
          $$->lval = false; $$->ct_val = false;     
     }
     ;

relational_expression: 
     additive_expression
     {
         $$ = $1;
     }                    
     | relational_expression '<' additive_expression
     {
          string op("LT_OP_");
          op_binary_astnode *temp = new op_binary_astnode(op+"FLOAT",$1,$3);
          if(!$1->type_tree.empty()) { // c1 is ptr
               if($1->get_type() != $3->get_type()) //not compatible
                    error(@$, "Invalid operand types for binary < , \""+$1->get_type()+"\" and \""+$3->get_type()+"\"");
               //ptrs
               temp->op = op+"INT";
          }
          else if(!$3->type_tree.empty()) //c1 is object c3 is ptr
               error(@$, "Invalid operand types for binary < , \""+$1->get_type()+"\" and \""+$3->get_type()+"\"");
          else { //both are OBJECTS
               if(!both_num($1->type,$3->type))
                    error(@$, "Invalid operand types for binary < , \""+$1->get_type()+"\" and \""+$3->get_type()+"\"");
               //numeric
               if($1->type == "int") {
                    if($3->type == "int") {temp->op = op+"INT";}
                    else temp->left = new op_unary_astnode("TO_FLOAT",$1); //type_cast c1
               }
               else if ($3->type == "int") temp->right = new op_unary_astnode("TO_FLOAT",$3); //type_cast c3
          }          
          $$ = temp;
          $$->type = "int";
          $$->lval = false; $$->ct_val = false;
     }                    
     | relational_expression '>' additive_expression
     {
          string op("GT_OP_");
          op_binary_astnode *temp = new op_binary_astnode(op+"FLOAT",$1,$3);
          if(!$1->type_tree.empty()) { // c1 is ptr
               if($1->get_type() != $3->get_type()) //not compatible
                    error(@$, "Invalid operand types for binary > , \""+$1->get_type()+"\" and \""+$3->get_type()+"\"");
               //ptrs
               temp->op = op+"INT";
          }
          else if(!$3->type_tree.empty()) //c1 is object c3 is ptr
               error(@$, "Invalid operand types for binary > , \""+$1->get_type()+"\" and \""+$3->get_type()+"\"");
          else { //both are OBJECTS
               if(!both_num($1->type,$3->type))
                    error(@$, "Invalid operand types for binary > , \""+$1->get_type()+"\" and \""+$3->get_type()+"\"");
               //numeric
               if($1->type == "int") {
                    if($3->type == "int") {temp->op = op+"INT";}
                    else temp->left = new op_unary_astnode("TO_FLOAT",$1); //type_cast c1
               }
               else if ($3->type == "int") temp->right = new op_unary_astnode("TO_FLOAT",$3); //type_cast c3
          }          
          $$ = temp;
          $$->type = "int";
          $$->lval = false; $$->ct_val = false;
     }                    
     | relational_expression LE_OP additive_expression
     {
          string op("LE_OP_");
          op_binary_astnode *temp = new op_binary_astnode(op+"FLOAT",$1,$3);
          if(!$1->type_tree.empty()) { // c1 is ptr
               if($1->get_type() != $3->get_type()) //not compatible
                    error(@$, "Invalid operand types for binary <= , \""+$1->get_type()+"\" and \""+$3->get_type()+"\"");
               //ptrs
               temp->op = op+"INT";
          }
          else if(!$3->type_tree.empty()) //c1 is object c3 is ptr
               error(@$, "Invalid operand types for binary <= , \""+$1->get_type()+"\" and \""+$3->get_type()+"\"");
          else { //both are OBJECTS
               if(!both_num($1->type,$3->type))
                    error(@$, "Invalid operand types for binary <= , \""+$1->get_type()+"\" and \""+$3->get_type()+"\"");
               //numeric
               if($1->type == "int") {
                    if($3->type == "int") {temp->op = op+"INT";}
                    else temp->left = new op_unary_astnode("TO_FLOAT",$1); //type_cast c1
               }
               else if ($3->type == "int") temp->right = new op_unary_astnode("TO_FLOAT",$3); //type_cast c3
          }          
          $$ = temp;
          $$->type = "int";
          $$->lval = false; $$->ct_val = false;
     }                    
     | relational_expression GE_OP additive_expression
     {
          string op("GE_OP_");
          op_binary_astnode *temp = new op_binary_astnode(op+"FLOAT",$1,$3);
          if(!$1->type_tree.empty()) { // c1 is ptr
               if($1->get_type() != $3->get_type()) //not compatible
                    error(@$, "Invalid operand types for binary >= , \""+$1->get_type()+"\" and \""+$3->get_type()+"\"");
               //ptrs
               temp->op = op+"INT";
          }
          else if(!$3->type_tree.empty()) //c1 is object c3 is ptr
               error(@$, "Invalid operand types for binary >= , \""+$1->get_type()+"\" and \""+$3->get_type()+"\"");
          else { //both are OBJECTS
               if(!both_num($1->type,$3->type))
                    error(@$, "Invalid operand types for binary >= , \""+$1->get_type()+"\" and \""+$3->get_type()+"\"");
               //numeric
               if($1->type == "int") {
                    if($3->type == "int") {temp->op = op+"INT";}
                    else temp->left = new op_unary_astnode("TO_FLOAT",$1); //type_cast c1
               }
               else if ($3->type == "int") temp->right = new op_unary_astnode("TO_FLOAT",$3); //type_cast c3
          }          
          $$ = temp;
          $$->type = "int";
          $$->lval = false; $$->ct_val = false;
     }
     ;

additive_expression: 
     multiplicative_expression
     {
         $$ = $1;
     }                  
     | additive_expression '+' multiplicative_expression
     {
          string op("PLUS_");
          if(!$1->type_tree.empty()) { //c1 is ptr
               if(!$3->type_tree.empty() || $3->type != "int") //both are pointers
                    error(@$, "Invalid operand types for binary + , \""+$1->get_type()+"\" and \""+$3->get_type()+"\"");
               else {// 1 is pointer, 3 is int
                    $$ = new op_binary_astnode(op+"INT",$1,$3);
                    $$->type = $1->type; $$->type_tree = $1->type_tree;
                    $$->lval = false; $$->ct_val = false;
               }
          }
          else if(!$3->type_tree.empty()) {//c1 is non-pointer and c3 is ptr
               if($1->type != "int") error(@$, "Invalid operand types for binary + , \""+$1->get_type()+"\" and \""+$3->get_type()+"\"");
               //c3 is ptr, c1 is int
               $$ = new op_binary_astnode(op+"INT",$1,$3);
               $$->type = $3->type; $$->type_tree = $3->type_tree;
               $$->lval = false; $$->ct_val = false;
          }
          // both are non-pointers
          else if( !($1->type == "int" || $1->type == "float") ||
               !($3->type == "int" || $3->type == "float") ) { //
                    error(@$, "Invalid operand types for binary + , \""+$1->get_type()+"\" and \""+$3->get_type()+"\"");
          }
          // both are int or float
          else {
               op_binary_astnode *temp = new op_binary_astnode(op+"FLOAT",$1,$3);
               temp->type = "float";
               if($1->type == "int") {
                    if($3->type == "int") {temp->op = op+"INT"; temp->type = "int";}
                    else temp->left = new op_unary_astnode("TO_FLOAT",$1); //type_cast c1
               }
               else if ($3->type == "int") temp->right = new op_unary_astnode("TO_FLOAT",$3); //type_cast c3
               $$ = temp;
               $$->lval = false; $$->ct_val = false;
          }
     }                  
     | additive_expression '-' multiplicative_expression
     {
          string op("MINUS_");
          if(!$1->type_tree.empty()) { //a-b, a is a pointer
               $$ = new op_binary_astnode(op+"INT",$1,$3);
               $$->lval = false; $$->ct_val = false;
               if(!$3->type_tree.empty()) { // a,b are pointers
                    if($1->get_type() != $3->get_type())  //incompatible
                         error(@$, "Invalid operand types for binary - , \""+$1->get_type()+"\" and \""+$3->get_type()+"\""); 
                    $$->type = "int";
               }
               else { // a is pointer, b is int
                    if($3->type != "int") error(@$, "Invalid operand types for binary - , \""+$1->get_type()+"\" and \""+$3->get_type()+"\"");
                    $$->type = $1->type;
                    $$->type_tree = $1->type_tree;
               }
          }
          else if (!$3->type_tree.empty())  //a-b, a is not pointer, b is pointer
               error(@$, "Invalid operand types for binary - , \""+$1->get_type()+"\" and \""+$3->get_type()+"\"");
          // both are non-pointers
          else if( !($1->type == "int" || $1->type == "float") ||
               !($3->type == "int" || $3->type == "float") ) { //
                    error(@$, "Invalid operand types for binary + , \""+$1->get_type()+"\" and \""+$3->get_type()+"\"");
          }
          // both are int or float
          else {
               op_binary_astnode *temp = new op_binary_astnode(op+"FLOAT",$1,$3);
               temp->type = "float";
               if($1->type == "int") {
                    if($3->type == "int") {temp->op = op+"INT"; temp->type = "int";}
                    else temp->left = new op_unary_astnode("TO_FLOAT",$1); //type_cast c1
               }
               else if ($3->type == "int") temp->right = new op_unary_astnode("TO_FLOAT",$3); //type_cast c3
               $$ = temp;
               $$->lval = false; $$->ct_val = false;
          }
     }
     ;

unary_expression: 
     postfix_expression
     {
          $$ = $1;
     }               
     | unary_operator unary_expression
     {
          $$ = new op_unary_astnode($1,$2);
          $$->ct_val = false;
          if($1 == "ADDRESS") {
               if(!$2->lval) error(@$, "Operand of & should  have lvalue");
               $$->type = $2->type;
               $$->lval = false; 
               $$->type_tree.push_back(new arr(true,true,0));
               for(auto arr_elem: $2->type_tree)
                    $$->type_tree.push_back(arr_elem);
               // address assumed as const_pointer!!!!!!
          }
          if($1 == "DEREF") { // string case also comes here
               if($2->type_tree.empty())  //not pointer or array
                    error(@$, "Invalid operand type \""+$2->get_type()+"\" of unary *");
               if($2->type == "void" && $2->type_tree.size() == 1) 
                    error(@$, "dereferencing \"void *\" pointer");
               $$->type = $2->type; 
               $$->lval = true; $$->ct_val = false;
               if($2->type_tree.size() > 1) {
                    $$->type_tree.assign($2->type_tree.begin() + 1, $2->type_tree.end());
               }     
          }
          if($1 == "UMINUS") { //operand int or float
               if(!$2->type_tree.empty() || !($2->type == "int" || $2->type == "float")) 
                    error(@$, "Operand of unary - should be an int or float");
               $$->type = $2->type; 
               $$->lval = false; $$->ct_val = false;
          }
          if($1 == "NOT") {
               if($2->type_tree.empty() && !($2->type == "int" || $2->type == "float")) 
                    error(@$, "Operand of NOT should be an int or float or pointer");
               $$->type = "int";
               $$->lval = false; $$->ct_val = false;
          }
         // check errors
     }
     ;

multiplicative_expression: 
     unary_expression
     {
          $$ = $1;
     }                        
     | multiplicative_expression '*' unary_expression
     {
          if(!$1->type_tree.empty() || !$3->type_tree.empty() ||
               !($1->type == "int" || $1->type == "float") ||
                    !($3->type == "int" || $3->type == "float") ) {
               error(@$, "Invalid operand types for binary * , \""+$1->get_type()+"\" and \""+$3->get_type()+"\"");
          }
          string op("MULT_");
          op_binary_astnode *temp = new op_binary_astnode(op+"FLOAT",$1,$3);
          temp->type = "float";
          if($1->type == "int") {
               if($3->type == "int") {temp->op = op+"INT"; temp->type = "int";}
               else temp->left = new op_unary_astnode("TO_FLOAT",$1); //type_cast c1
          }
          else if ($3->type == "int") temp->right = new op_unary_astnode("TO_FLOAT",$3); //type_cast c3
          $$ = temp;
          $$->lval = false; $$->ct_val = false; 
     }                        
     | multiplicative_expression '/' unary_expression
     {
          if(!$1->type_tree.empty() || !$3->type_tree.empty() ||
               !($1->type == "int" || $1->type == "float") ||
                    !($3->type == "int" || $3->type == "float") ) {
               error(@$, "Invalid operand types for binary / , \""+$1->get_type()+"\" and \""+$3->get_type()+"\"");
          }
          string op("DIV_");
          op_binary_astnode *temp = new op_binary_astnode(op+"FLOAT",$1,$3);
          temp->type = "float";
          if($1->type == "int") {
               if($3->type == "int") {temp->op = op+"INT"; temp->type = "int";}
               else temp->left = new op_unary_astnode("TO_FLOAT",$1); //type_cast c1
          }
          else if ($3->type == "int") temp->right = new op_unary_astnode("TO_FLOAT",$3); //type_cast c3
          $$ = temp;
          $$->lval = false; $$->ct_val = false;
     }
     ;

postfix_expression: 
     primary_expression
     {
          $$ = $1;
     }                 
     | postfix_expression '[' expression ']'
     {    
          if($1->type_tree.empty()) { //not pointer or array
               error(@$, "Subscripted value is neither array nor pointer");
          }
          if($1->type == "void" && $1->type_tree.size() <= 1) {
               error(@$, "dereferencing \"void *\" pointer");
          }
          // $3 is of type integer
          if($3->type != "int" || !($3->type_tree.empty()))
               error(@$, "Array subscript is not an integer");
          $$ = new arrayref_astnode($1,$3);
          $$->type = $1->type; 
          $$->lval = true; $$->ct_val = false;
          if($1->type_tree.size() > 1) {
               $$->type_tree.assign($1->type_tree.begin() + 1, $1->type_tree.end());
          }
     }                 
     | IDENTIFIER '(' ')'
     {    
          // case lval=true SKIPPED
          $$ = new funcall_astnode(new identifier_astnode($1));
          string type;
          if(!($1 == "printf" || $1 == "scanf")) {
               vector<parameter_declaration_class*> par_decl = fn_decl->par_list->par_decl;
               type = type_spec.front()->type;

               if(fn_decl->iden != $1) { //not curr_func
                    if( gst.Entries.count($1) == 0 || gst.Entries[$1].varfun != "fun")
                         error(@$, "Function \""+$1+"\"  not declared");
                    entry e = gst.Entries[$1];
                    par_decl = e.param_order->par_decl;
                    type = e.ret_type;
               }
               if (par_decl.size() > 0) //curr_func
                    error(@$, "Function \""+$1+"\"  called with too few arguments");
          }
          else {type = "void";}
          $$->type = type;
          $$->lval = false; $$->ct_val = false;
     }                 
     | IDENTIFIER '(' expression_list ')'
     {    
          // case lval=true SKIPPED
          $3->fname = new identifier_astnode($1);
          string type;
          
          if($1 != "printf" && $1 != "scanf") {
               vector<parameter_declaration_class*> par_decl(fn_decl->par_list->par_decl);
               type = type_spec.front()->type;
               if(fn_decl->iden != $1) { //not curr_func
                    if( gst.Entries.count($1) == 0 || gst.Entries[$1].varfun != "fun")
                         error(@$, "Function \""+$1+"\"  not declared");
                    entry e = gst.Entries[$1];
                    par_decl = e.param_order->par_decl;
                    type = e.ret_type;                
               }
               if (par_decl.size() < $3->vec.size()) //curr_func
                    error(@$, "Function \""+$1+"\"  called with too many arguments");
               if (par_decl.size() > $3->vec.size())
                    error(@$, "Function \""+$1+"\"  called with too few arguments");
               for(int i=0; i<$3->vec.size(); i++) {
                    exp_astnode *temp = new my_par_exp_class(par_decl[i]);
                    if(  !is_compatible(temp,$3->vec[i]) ) {
                         error(@3, "Expected \""+temp->get_type()+"\" but argument is of type \""+$3->vec[i]->get_type()+"\"");
                    }
                    if(temp->type_tree.empty() && $3->vec[i]->type_tree.empty()) {
                         if(both_num(temp->type,$3->vec[i]->type)) { //type_cast
                              string op;
                              if(temp->type == "int" && $3->vec[i]->type == "float") {
                                   op = "TO_INT"; $3->vec[i] = new op_unary_astnode(op,$3->vec[i]);
                              }
                              if(temp->type == "float" && $3->vec[i]->type == "int") {
                                   op = "TO_FLOAT"; $3->vec[i] = new op_unary_astnode(op,$3->vec[i]);
                              }
                         }
                    }
               }
          }
          else {type = "void";}
          $$ = $3;
          $$->type = type;
          $$->lval = false; $$->ct_val = false;
     }                 
     | postfix_expression '.' IDENTIFIER
     {
          SymbTab *lst; entry e;
          if(gst.Entries.count($1->type) == 0  || gst.Entries[$1->type].varfun != "struct") 
               error(@$, "Left operand of \".\" is not a structure");
          if(!$1->type_tree.empty()) 
               error(@$, "Left operand of \".\" is not a structure");
          e = gst.Entries[$1->type];
          lst = e.symbtab;
          if(lst->Entries.count($3) == 0)
               error(@$, "Struct \""+$1->type+"\" has no member named \""+$3+"\"");
          e = lst->Entries[$3];
          
          $$ = new member_astnode($1,new identifier_astnode($3));
          $$->type = e.base_type; 
          $$->lval = true; $$->ct_val = false; 
          if(!e.indices.empty()) {
               for(int i=0; i<e.indices.size(); i++)
                    $$->type_tree.push_back(new arr(false,true,e.indices[i]));
          }
          for(int i=0; i<e.num_ptr; i++) $$->type_tree.push_back(new arr(true,false,0));
     }                 
     | postfix_expression PTR_OP IDENTIFIER
     {
          SymbTab *lst; entry e;
          if(gst.Entries.count($1->type) == 0  || gst.Entries[$1->type].varfun != "struct")  
               error(@$, "Left operand of \"->\" is not a pointer to structure");
          if($1->type_tree.size() != 1)
               error(@$, "Left operand of \"->\" is not a pointer to structure");
          e = gst.Entries[$1->type];
          lst = e.symbtab;
          if(lst->Entries.count($3) == 0)
               error(@$, "Struct \""+$1->type+"\" has no member named \""+$3+"\"");
          
          e = lst->Entries[$3];
          $$ = new arrow_astnode($1,new identifier_astnode($3));
          $$->type = e.base_type;
          $$->lval = true; $$->ct_val = false; 
          if(!e.indices.empty()) {
               for(int i=0; i<e.indices.size(); i++)
                    $$->type_tree.push_back(new arr(false,true,e.indices[i]));
          }
          for(int i=0; i<e.num_ptr; i++) $$->type_tree.push_back(new arr(true,false,0));
     }                 
     | postfix_expression INC_OP
     {
          if(!($1->lval)) 
               error(@$, "Operand of \"++\" should have lvalue");
          if(is_const_ptr($1)) //const ptr
               error(@$, "Operand of \"++\" should have lvalue");
          if($1->type_tree.empty() && $1->type != "int" && $1->type != "float")
               error(@$, "Operand of \"++\" should be a int, float or pointer");
          $$ = new op_unary_astnode(string("PP"),$1);
          $$->type = $1->type;
          $$->lval = false; $$->ct_val = false;
          $$->type_tree = $1->type_tree;
     }
     ;

primary_expression: 
     IDENTIFIER
     {
          entry e;
          if(locl_st->Entries.count($1) == 0) // not in locl_st,  NOTE: NO GLOBAL VARIABLES
               error(@$,"Variable \""+$1+"\" not declared");
          e = locl_st->Entries[$1];
          $$ = new identifier_astnode($1);
          $$->type = e.base_type; 
          $$->ct_val = false; $$->lval = true;
          if(!e.indices.empty()) {
               if(e.gl == "param") {
                    $$->type_tree.push_back(new arr(true,false,e.indices[0]));
                    for(int i=1; i<e.indices.size(); i++)
                         $$->type_tree.push_back(new arr(false,true,e.indices[i]));
               }
               else {
                    for(int i=0; i<e.indices.size(); i++)
                         $$->type_tree.push_back(new arr(false,true,e.indices[i]));
               }
          }
          for(int i=0; i<e.num_ptr; i++) $$->type_tree.push_back(new arr(true,false,0));
     }                 
     | INT_CONSTANT
     {
          $$ = new intconst_astnode(stoi($1));
          $$->type = "int";
          $$->lval = false; $$->ct_val = false; $$->val = stoi($1);
          if($$->val == 0) $$->ct_val = true;
     }                 
     | FLOAT_CONSTANT
     {
         $$ = new floatconst_astnode(stof($1));
         $$->type = "float";
          $$->lval = false; $$->ct_val = false;
     }                 
     | STRING_LITERAL
     {
         $$ = new stringconst_astnode($1);
         $$->type = "string";
          $$->lval = false; $$->ct_val = false;
     }                 
     | '(' expression ')'
     {
          $$ = $2;
     }
     ;

expression_list: 
     expression
     {
          $$ = new funcall_astnode();
          $$->vec.push_back($1);
     }              
     | expression_list ',' expression
     {
         $1->vec.push_back($3);
         $$ = $1;
     }
     ;

unary_operator: 
     '-'
     {
        $$ = "UMINUS";
     }             
     | '!'
     {
         $$ = "NOT";
     }             
     | '&'
     {
         $$ = "ADDRESS";
     }             
     | '*'
     {
         $$ = "DEREF";
     }
     ;

selection_statement: 
     IF '(' expression ')' statement ELSE statement
     {
          if($3->type_tree.empty() && $3->type != "int" && 
               $3->type != "float" && $3->type != "string") {
               error(@$, "Used struct type value where scalar is required");
          }
          $$ = new if_astnode($3,$5,$7);
     }
     ;

iteration_statement: 
     WHILE '(' expression ')' statement
     {    
          if($3->type_tree.empty() && $3->type != "int" && 
               $3->type != "float" && $3->type != "string") {
               error(@$, "Used struct type value where scalar is required");
          }
         $$ = new while_astnode($3,$5);
     }                  
     | FOR '(' assignment_expression ';' expression ';' assignment_expression ')' statement
     {
          if($5->type_tree.empty() && $5->type != "int" && 
               $5->type != "float" && $5->type != "string") {
               error(@$, "Used struct type value where scalar is required");
          }
          $$ = new for_astnode($3,$5,$7,$9);
     }
     ;

declaration_list: 
     declaration
     {    
          $$ = new declaration_list_class();
          $$->decl.push_back($1);
     }               
     | declaration_list declaration
     {
          $1->decl.push_back($2);
          $$ = $1;
     }
     ;

declaration: 
     type_specifier declarator_list ';'
     {
          $$ = new declaration_class($1,$2,@$);

          if(func_decl) {
               ret_type = $1->type;
               if(!($1->base) && gst.Entries.count(ret_type) == 0) // struct_type decln
                    error(@$, "\""+ret_type+"\" not declared");
               for(auto ltrl : $2->decl) { //ltrl : literal
                    ret_type = $1->type;
                    size = 0;
                    if(ltrl->num_ptr > 0) { //pointer
                         size = ptr_size;
                         for(int i=0; i<ltrl->num_ptr; i++) ret_type += "*";
                    }
                    else { //not pointer
                         if(ret_type == "int") size = int_size;
                         else if(ret_type == "float") size = float_size;
                         else if(ret_type == "void") {// ERROR
                              if(ltrl->indices.empty())
                                   error(@$, "Cannot declare variable of type \"void\"");
                              else {
                                   error(@$, "Cannot declare \""+ltrl->iden+"\" as an array of voids");
                              }
                         }
                         else if(!($1->base)) { //not_base, struct_type
                              size = gst.Entries[ret_type].size;
                         }
                    }
                    if(!(ltrl->indices.empty())) { //array
                         for(const int &i : ltrl->indices) {
                              size *= i;
                              ret_type += "["+to_string(i)+"]";
                         }
                    }

                    offset -= size;
                    if(locl_st->Entries.count(ltrl->iden) > 0) //PREVIOUS_DECL ERROR
                         error(@$, "\""+ltrl->iden+"\" has a previous declaration");
                    entry e("var","local",size,offset,ret_type,NULL,ltrl->num_ptr,ltrl->indices,$1->type);
                    locl_st->Entries.insert({ltrl->iden,e});
               }      
          }
     }
     ;

declarator_list: 
     declarator
     {
          $$ = new declarator_list_class();
          $$->decl.push_back($1);
     }               
     | declarator_list ',' declarator
     {
          $1->decl.push_back($3);
          $$ = $1;
     }
     ;

%%
void IPL::Parser::error( const location_type &l, const std::string &err_message )
{
   std::cout << "Error at line " << l.begin.line << ": " << err_message << "\n";
   exit(1);
}


