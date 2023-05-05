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

%printer { std::cerr << $$; }   STRUCT
%printer { std::cerr << $$; }   IDENTIFIER
%printer { std::cerr << $$; }   INT 
%printer { std::cerr << $$; }   MAIN
%printer { std::cerr << $$; }   VOID
%printer { std::cerr << $$; }   CONSTANT_INT
%printer { std::cerr << $$; }   RETURN
%printer { std::cerr << $$; }   OP_OR
%printer { std::cerr << $$; }   OP_AND
%printer { std::cerr << $$; }   OP_EQ
%printer { std::cerr << $$; }   OP_NEQ
%printer { std::cerr << $$; }   OP_LTE
%printer { std::cerr << $$; }   OP_GTE
%printer { std::cerr << $$; }   OP_INC
%printer { std::cerr << $$; }   OP_PTR
%printer { std::cerr << $$; }   IF 
%printer { std::cerr << $$; }   ELSE
%printer { std::cerr << $$; }   WHILE
%printer { std::cerr << $$; }   FOR
%printer { std::cerr << $$; }   PRINTF
%printer { std::cerr << $$; }   CONSTANT_STR
%printer { std::cerr << $$; }   OTHERS

%parse-param { Scanner  &scanner  }
%locations
%code{
   #include <iostream>
   #include <cstdlib>
   #include <fstream>
   #include <string>
   
   
   #include "scanner.hh"
   #include "globals.hh"
   map<string,abstract_astnode*> ast;
   

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

%start program

%token <std::string>    STRUCT
%token <std::string>    IDENTIFIER
%token <std::string>    INT 
%token <std::string>    MAIN
%token <std::string>    VOID
%token <std::string>    CONSTANT_INT
%token <std::string>    RETURN
%token <std::string>    OP_OR
%token <std::string>    OP_AND
%token <std::string>    OP_EQ
%token <std::string>    OP_NEQ
%token <std::string>    OP_LTE
%token <std::string>    OP_GTE
%token <std::string>    OP_INC
%token <std::string>    OP_PTR
%token <std::string>    IF 
%token <std::string>    ELSE
%token <std::string>    WHILE
%token <std::string>    FOR
%token <std::string>    PRINTF
%token <std::string>    CONSTANT_STR
%token <std::string>    OTHERS

%token '{' '}' '(' ')' '[' ']' ';' ',' '.' '!' '&' '=' '<' '>' '+' '-' '*' '/' 

%nterm <abstract_astnode*> program;
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
%nterm <printf_astnode*> printf_call;
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

program:
	main_definition
	{

	}
	| translation_unit main_definition
	{

	}

translation_unit:
	struct_specifier
	{
		locl_st = new SymbTab();
		type_spec.clear();
	}
	|	function_definition
	{
		locl_st = new SymbTab();
		type_spec.clear();
	}
	| 	translation_unit struct_specifier
	{
		locl_st = new SymbTab();
		type_spec.clear();
	}
	| 	translation_unit function_definition
	{
		locl_st = new SymbTab();
		type_spec.clear();
	}
	;

struct_specifier:
	STRUCT IDENTIFIER '{' declaration_list '}' ';'
	{
		string first($1 + " " + $2);

		offset = 0;
		for(auto decl_ptr : $4->decl) {
			ret_type = decl_ptr->ts->type;

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
					else if(!(decl_ptr->ts->base)) { //not_base, struct_type
						size = gst.get_entry(ret_type).size;
					}
				}
				if(!(ltrl->indices.empty())) { //array
					for(const int &i : ltrl->indices) {
						size *= i;
						ret_type += "["+to_string(i)+"]";
					}
				}
				entry e("var","local",size,offset,ret_type,NULL, ltrl->num_ptr,ltrl->indices,decl_ptr->ts->type);
				locl_st->Entries.push_back({ltrl->iden,e});
				offset += size;   
			}                      
		}
		entry second("struct","global",offset,0,"",locl_st);
		gst.Entries.push_back({first, second});
	}
	;

function_definition:
	type_specifier IDENTIFIER '(' ')' {
		fn_decl = new fun_declarator_class($2,default_param_list);
		func_decl = true; offset = 0;
	} 
	compound_statement
	{
		ret_type = $1->type;
        string first($2);
        entry second("fun","global",-offset,0,ret_type,locl_st,fn_decl->par_list);
        gst.Entries.push_back({first, second});
        ast[first] = $6;
        func_decl = false;
	}
	|	type_specifier IDENTIFIER '(' parameter_list ')' {
        string first;
        offset = 8;
        for(auto rit = $4->par_decl.rbegin(); rit != $4->par_decl.rend(); rit++) {
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
					size = gst.get_entry(ret_type).size;
                }
            }
            if(!((*rit)->decl->indices.empty())) { 
                //array (in parameter, array means pointer (no pointer const)
                size = ptr_size;
                for(const int &i : (*rit)->decl->indices) {
                    ret_type += "["+to_string(i)+"]";
                }
            }
            first = (*rit)->decl->iden;
            entry e("var","param",size,offset,ret_type,NULL,(*rit)->decl->num_ptr,(*rit)->decl->indices,(*rit)->ts->type);
            locl_st->Entries.push_back({first,e});
            offset += size;
        }
        fn_decl = new fun_declarator_class($2,$4);
        func_decl = true; offset = 0;
	}
	compound_statement
	{
		ret_type = $1->type;
        string first($2);
        entry second("fun","global",-offset,0,ret_type,locl_st,fn_decl->par_list);
        gst.Entries.push_back({first, second});
        ast[first] = $7;
        func_decl = false;
	}
	;

main_definition:
	INT MAIN '(' ')' {
		fn_decl = new fun_declarator_class("main",default_param_list);
		func_decl = true; offset = 0;
	} 
	compound_statement
	{
		ret_type = "int";
        string first("main");
        entry second("fun","global",-offset,0,ret_type,locl_st,fn_decl->par_list);
        gst.Entries.push_back({first, second});
        ast[first] = $6;
        func_decl = false;
	}
	;

type_specifier:
    VOID 
    {
        $$ = type_chc_0;
        type_spec.push_back($$);
    }
    |	INT
    {
        $$ = type_chc_1;
        type_spec.push_back($$);
    }
    |	STRUCT IDENTIFIER
    {    
        string first($1+" "+$2);
        $$ = new type_specifier_class(first,false);
        type_spec.push_back($$);
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
                    //else if(ret_type == "void") {// ERROR
                    else if(!($1->base)) { //not_base, struct_type
						size = gst.get_entry(ret_type).size;
                    }
                }
                if(!(ltrl->indices.empty())) { //array
                    for(const int &i : ltrl->indices) {
                        size *= i;
                        ret_type += "["+to_string(i)+"]";
					}
                }
                offset -= size;
                entry e("var","local",size,offset,ret_type,NULL,ltrl->num_ptr,ltrl->indices,$1->type);
                locl_st->Entries.push_back({ltrl->iden,e});
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

declarator_arr:
	IDENTIFIER
	{
		$$ = new declarator_class($1,0);
	}
	| declarator_arr '[' CONSTANT_INT ']'
	{
		$1->indices.push_back(stoi($3));
        $$ = $1;
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

compound_statement:
	'{' '}'
	{
		$$ = new seq_astnode();
	}
	| '{' statement_list '}'
	{
		$$ = $2;
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

statement:
	';'
    {
        $$ = new empty_astnode();
    }        
    | '{' statement_list '}'
    {
        $$ = $2;
    }
	| assignment_expression ';'
	{
		$$ = new assignS_astnode($1);
	}
	| selection_statement
	{
		$$ = $1;
	}
	| iteration_statement
	{
		$$ = $1;
	}
	| procedure_call
	{
		$$ = $1;
	}
	| printf_call
	{
		$$ = $1;
	}
	| RETURN expression ';'
	{
        $$ = new return_astnode($2);
	}
	;

assignment_expression:
	unary_expression '=' expression
	{
		$$ = new assignE_astnode($1,$3);
	}

expression:
	logical_and_expression
	{
		$$ = $1;
	}
	| expression OP_OR logical_and_expression
	{
        $$ = new op_binary_astnode(string("OP_OR"),$1,$3);
        $$->type = "int";
        $$->lval = false; $$->ct_val = false;
	}
	;

logical_and_expression:
	equality_expression
	{
		$$ = $1;
	}
	| logical_and_expression OP_AND equality_expression
	{
        $$ = new op_binary_astnode(string("OP_AND"),$1,$3);
        $$->type = "int";
        $$->lval = false; $$->ct_val = false;
	}
	;

equality_expression:
	relational_expression
	{
		$$ = $1;
	}
	| equality_expression OP_EQ relational_expression
	{
        string op("OP_EQ");
        $$ = new op_binary_astnode(op,$1,$3);
        $$->type = "int";
        $$->lval = false; $$->ct_val = false;      
	}
	| equality_expression OP_NEQ relational_expression
	{
        string op("OP_NEQ");
        $$ = new op_binary_astnode(op,$1,$3);
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
		string op("OP_LT");
        $$ = new op_binary_astnode(op,$1,$3);
        $$->type = "int";
        $$->lval = false; $$->ct_val = false;
	}
	| relational_expression '>' additive_expression
	{
		string op("OP_GT");
        $$ = new op_binary_astnode(op,$1,$3);
        $$->type = "int";
        $$->lval = false; $$->ct_val = false;
	}
	| relational_expression OP_LTE additive_expression
	{
		string op("OP_LTE");
        $$ = new op_binary_astnode(op,$1,$3);
        $$->type = "int";
        $$->lval = false; $$->ct_val = false;
	}
	| relational_expression OP_GTE additive_expression
	{
		string op("OP_GTE");
        $$ = new op_binary_astnode(op,$1,$3);
        $$->type = "int";
        $$->lval = false; $$->ct_val = false;
	}

additive_expression: 
    multiplicative_expression
    {
        $$ = $1;
    }                  
    | additive_expression '+' multiplicative_expression
    {
        string op("PLUS");
        $$ = new op_binary_astnode(op,$1,$3);
        $$->lval = false; $$->ct_val = false;
        if(!$1->type_tree.empty()) { //c1 is ptr
            // 1 is pointer, 3 is int
            $$->type = $1->type; $$->type_tree = $1->type_tree;
        }
        else if(!$3->type_tree.empty()) {//c1 is non-pointer and c3 is ptr
            //c3 is ptr, c1 is int
            $$->type = $3->type; $$->type_tree = $3->type_tree;
        }
        // both are int
        else {
			$$->type = "int";
        }
    }                  
    | additive_expression '-' multiplicative_expression
    {
        string op("MINUS");
        $$ = new op_binary_astnode(op,$1,$3);
        $$->lval = false; $$->ct_val = false;
        if(!$1->type_tree.empty()) { //a-b, a is a pointer
            if(!$3->type_tree.empty()) { // a,b are pointers
                $$->type = "int";
            }
            else { // a is pointer, b is int
                $$->type = $1->type;
                $$->type_tree = $1->type_tree;
            }
        }
        // both are int
        else {
            $$->type = "int";  
        }
    }
    ;

multiplicative_expression:
	unary_expression
    {
        $$ = $1;
    }                        
    | multiplicative_expression '*' unary_expression
    {
        string op("MULT");
        $$ = new op_binary_astnode(op,$1,$3);
		$$->type = "int";
        $$->lval = false; $$->ct_val = false; 
    }                        
    | multiplicative_expression '/' unary_expression
    {
        string op("DIV");
        $$ = new op_binary_astnode(op,$1,$3);
		$$->type = "int";
        $$->lval = false; $$->ct_val = false;
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
		$$->type = $2->type;
        $$->lval = false;  $$->ct_val = false;
        if($1 == "ADDRESS") {
            $$->type_tree.push_back(new arr(true,true,0));
            for(auto arr_elem: $2->type_tree)
                $$->type_tree.push_back(arr_elem);
            // address assumed as const_pointer!!!!!!
        }
        if($1 == "DEREF") { // string case also comes here
            $$->lval = true; 
            if($2->type_tree.size() > 1) {
                $$->type_tree.assign($2->type_tree.begin() + 1, $2->type_tree.end());
            }     
        }
        if($1 == "NOT") {
            $$->type = "int";
        }
        //UMINUS
        // check errors
	}
	;

postfix_expression:
	primary_expression
	{
		$$ = $1;
	}
	| postfix_expression OP_INC
	{
        $$ = new op_unary_astnode(string("PP"),$1);
        $$->type = $1->type;
        $$->lval = false; $$->ct_val = false;
        $$->type_tree = $1->type_tree;
	}
	| IDENTIFIER '(' ')'
	{
		// case lval=true SKIPPED
        $$ = new funcall_astnode(new identifier_astnode($1));
        string type;
        vector<parameter_declaration_class*> par_decl = fn_decl->par_list->par_decl;
        type = type_spec.front()->type;
        if(fn_decl->iden != $1) { //not curr_func
			entry e = gst.get_entry($1);
            par_decl = e.param_order->par_decl;
            type = e.ret_type;
        }
        $$->type = type;
        $$->lval = false; $$->ct_val = false;
	}
	| IDENTIFIER '(' expression_list ')'
	{
		// case lval=true SKIPPED
        $3->fname = new identifier_astnode($1);
        string type;
        vector<parameter_declaration_class*> par_decl(fn_decl->par_list->par_decl);
        type = type_spec.front()->type;
        if(fn_decl->iden != $1) { //not curr_func
			entry e = gst.get_entry($1);
            par_decl = e.param_order->par_decl;
            type = e.ret_type;                
        }
        $$ = $3;
        $$->type = type;
        $$->lval = false; $$->ct_val = false;
	}
	| postfix_expression '.' IDENTIFIER
	{
		SymbTab *lst; entry e;
		e = gst.get_entry($1->type);
        lst = e.symbtab;
		e = lst->get_entry($3);

        $$ = new member_astnode($1,new identifier_astnode($3));
        $$->type = e.base_type; 
        $$->lval = true; $$->ct_val = false; 
        if(!e.indices.empty()) {
            for(int i=0; i<e.indices.size(); i++)
                $$->type_tree.push_back(new arr(false,true,e.indices[i]));
        }
        for(int i=0; i<e.num_ptr; i++) $$->type_tree.push_back(new arr(true,false,0));
	}
	| postfix_expression OP_PTR IDENTIFIER
	{
		SymbTab *lst; entry e;
		e = gst.get_entry($1->type);
        lst = e.symbtab;
		e = lst->get_entry($3);

        $$ = new arrow_astnode($1,new identifier_astnode($3));
        $$->type = e.base_type;
        $$->lval = true; $$->ct_val = false; 
        if(!e.indices.empty()) {
            for(int i=0; i<e.indices.size(); i++)
                $$->type_tree.push_back(new arr(false,true,e.indices[i]));
        }
        for(int i=0; i<e.num_ptr; i++) $$->type_tree.push_back(new arr(true,false,0));
	}
	| postfix_expression '[' expression ']'
	{
        $$ = new arrayref_astnode($1,$3);
        $$->type = $1->type; 
        $$->lval = true; $$->ct_val = false;
        if($1->type_tree.size() > 1) {
            $$->type_tree.assign($1->type_tree.begin() + 1, $1->type_tree.end());
        }
	}

primary_expression:
	IDENTIFIER
	{
		entry e;
		e = locl_st->get_entry($1);
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
	| CONSTANT_INT
	{
		$$ = new intconst_astnode(stoi($1));
        $$->type = "int";
        $$->lval = false; $$->ct_val = false; $$->val = stoi($1);
        if($$->val == 0) $$->ct_val = true;
	}
	| '(' expression ')'
	{
		$$ = $2;
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
        $$ = new if_astnode($3,$5,$7);
	}

iteration_statement:
	WHILE '(' expression ')' statement
	{
		$$ = new while_astnode($3,$5);
	}
	| FOR '(' assignment_expression ';' expression ';' assignment_expression ')' statement
	{
		$$ = new for_astnode($3,$5,$7,$9);
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

procedure_call:
	IDENTIFIER '(' ')' ';'
	{
		$$ = new proccall_astnode();
        $$->fname = new identifier_astnode($1);
	}
	| IDENTIFIER '(' expression_list ')' ';'
	{
		$$ = new proccall_astnode($3->vec);
        $$->fname = new identifier_astnode($1);
	}
	;

printf_call:
    PRINTF '(' CONSTANT_STR ')' ';'
    {
       $$ = new printf_astnode($3);
       int n = lc_str.size();
	   if(lc_str.count($3) == 0) lc_str[$3] = n;
    }
    | PRINTF '(' CONSTANT_STR ',' expression_list ')' ';'
    {
		$$ = new printf_astnode($3,$5->vec);
        int n = lc_str.size();
		if(lc_str.count($3) == 0) lc_str[$3] = n;
    }
    ;

%%
void IPL::Parser::error( const location_type &l, const std::string &err_message )
{
   std::cout << "Error at line " << l.begin.line << ": " << err_message << "\n";
   exit(1);
}


