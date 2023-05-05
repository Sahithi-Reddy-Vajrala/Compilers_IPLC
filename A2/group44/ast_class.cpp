#include "ast_class.hh"

arrow_astnode::arrow_astnode(exp_astnode *p, identifier_astnode *f) {
    astnode_type = arrow_type;
    pointer = p; field = f;
    id = "arrow";
}

void arrow_astnode::print(int blanks) {
    printAst("arrow", "aa",
             "pointer", pointer,
             "field", field);
}

member_astnode::member_astnode(exp_astnode *s, identifier_astnode *f) {
    astnode_type = member_type;
    st = s; field = f;
    id = "member";
}

void member_astnode::print(int blanks) {
    printAst("member", "aa",
             "struct", st,
             "field", field);
}

arrayref_astnode::arrayref_astnode(exp_astnode *a, exp_astnode *i) {
    astnode_type = arrayref_type;
    array = a; index = i;
    id = "arrayref";
}

void arrayref_astnode::print(int blanks) {
    printAst("arrayref", "aa",
             "array", array,
             "index", index);
}

identifier_astnode::identifier_astnode(string i) {
    astnode_type = identifier_type;
    iden = i;
    id = "identifier";
}

void identifier_astnode::print(int blanks) {
    cout << "{ \"identifier\": \"" << iden << "\" }";
}

stringconst_astnode::stringconst_astnode(string l) {
    astnode_type = stringconst_type;
    literal = l;
    id = "stringconst";
}

void stringconst_astnode::print(int blanks) {
    cout << "{ \"stringconst\": " << literal << " }";
}

floatconst_astnode::floatconst_astnode(float l) {
    astnode_type = floatconst_type;
    literal = l;
    id = "floatconst";
}

void floatconst_astnode::print(int blanks) {
    cout << "{ \"floatconst\": " << literal << " }";
}

intconst_astnode::intconst_astnode(int l) {
    astnode_type = intconst_type;
    literal = l;
    id = "intconst";
}

void intconst_astnode::print(int blanks) {
    cout << "{ \"intconst\": " << literal << " }";
}

funcall_astnode::funcall_astnode() {
    astnode_type = funcall_type;
    id = "funcall";
}

funcall_astnode::funcall_astnode(identifier_astnode *ide) {
    astnode_type = funcall_type;
    fname = ide;
    id = "funcall";
}

void funcall_astnode::print(int blanks) {
    /*
    int n = vec.size();
    cout << "{ \"funcall\": {" << endl;
        cout << "\"fname\": ";
        vec.back()->print(0);
        cout << ", ";
        cout << "\"params\": [";
            for(int i=0; i<n-1; i++) {
                if(i != 0) cout << "," << endl;
                vec[i]->print(0);
            }
        cout << "] ";
    cout << "}}";
    */

    printAst("funcall","al",
             "fname", fname,
             "params", vec);
}

assignE_astnode::assignE_astnode(exp_astnode *l, exp_astnode *r) {
    astnode_type = assignE_type;
    left = l; right = r;
    id = "assignE";
}

void assignE_astnode::print(int blanks) {
    printAst("assignE", "aa",
             "left", left,
             "right", right);
}

op_unary_astnode::op_unary_astnode(string o, exp_astnode *c) {
    astnode_type = op_unary_type;
    op = o; child = c;
    id = "op_unary";
}

void op_unary_astnode::print(int blanks) {
    printAst("op_unary", "sa",
             "op", op,
             "child", child);
}

op_binary_astnode::op_binary_astnode(string o, exp_astnode *l, exp_astnode *r) {
    astnode_type = op_binary_type;
    op = o; left = l; right = r;
    id = "op_binary";
}

void op_binary_astnode::print(int blanks) {
    printAst("op_binary", "saa",
             "op", op,
             "left", left,
             "right", right);
}

proccall_astnode::proccall_astnode() {
    astnode_type = proccall_type;
    id = "proccall";
}

proccall_astnode::proccall_astnode(vector<exp_astnode*> &vec1) {
    astnode_type = proccall_type;
    vec = vec1;
    id = "proccall";
}

void proccall_astnode::print(int blanks) {
    /*
    int n = vec.size();
    cout << "{ \"proccall\": {" << endl;
        cout << "\"fname\": ";
        vec.back()->print(0);
        cout << ", ";
        cout << "\"params\": [";
            for(int i=0; i<n-1; i++) {
                if(i != 0) cout << "," << endl;
                vec[i]->print(0);
            }
        cout << "] ";
    cout << "}}";
    */

    printAst("proccall","al",
             "fname", fname,
             "params", vec);
}

for_astnode::for_astnode(exp_astnode *i, exp_astnode *g, exp_astnode *s, statement_astnode *b) {
    astnode_type = for_type;
    init = i; guard = g; step = s; body = b;
    id = "for";
}

void for_astnode::print(int blanks) {
    printAst("for", "aaaa",
             "init", init,
             "guard", guard,
             "step", step,
             "body", body);
}

while_astnode::while_astnode(exp_astnode *c, statement_astnode *s) {
    astnode_type = while_type;
    cond = c; stmt = s;
    id = "while";
}

void while_astnode::print(int blanks) {
    printAst("while", "aa",
            "cond", cond,
            "stmt", stmt);
}

if_astnode::if_astnode(exp_astnode *c, statement_astnode *t, statement_astnode *e) {
    astnode_type = if_type;
    cond = c; then = t; else_child = e;
    id = "if";
}

void if_astnode::print(int blanks) {
    printAst("if", "aaa",
             "cond", cond,
             "then", then,
             "else", else_child);
}

return_astnode::return_astnode(exp_astnode *ch) {
    astnode_type = return_type;
    child = ch;
    id = "return";
}

void return_astnode::print(int blanks) {
    cout << "{ \"return\": ";
        child->print(0);
    cout << "}";
}

assignS_astnode::assignS_astnode(exp_astnode *l, exp_astnode *r) {
    astnode_type = assignS_type;
    left = l; right = r;
    id = "assignS";
}

void assignS_astnode::print(int blanks) {
    printAst("assignS", "aa",
             "left", left,
             "right", right);
}

seq_astnode::seq_astnode() {
    astnode_type = seq_type;
    id = "seq";
}

void seq_astnode::print(int blanks) {
    
    int n = vec.size();
    cout << "{ \"seq\": [" << endl;
        for(int i=0; i<n; i++) {
            if(i != 0) cout << "," << endl;
            vec[i]->print(0);
        }
    cout << "]}";
    
    //printAst("seq", "l",vec);
}


//-----------------------------------
// printAst
void printAst(const char *astname, const char *fmt...) // fmt is a format string that tells about the type of the arguments.
{   
	typedef vector<abstract_astnode *>* pv;
	va_list args;
	va_start(args, fmt);
	if ((astname != NULL) && (astname[0] != '\0'))
	{
		cout << "{ ";
		cout << "\"" << astname << "\"" << ": ";
	}
	cout << "{" << endl;
	while (*fmt != '\0')
	{
		if (*fmt == 'a')
		{
			char * field = va_arg(args, char *);
			abstract_astnode *a = va_arg(args, abstract_astnode *);
			cout << "\"" << field << "\": " << endl;
			
			a->print(0);
		}
		else if (*fmt == 's')
		{
			char * field = va_arg(args, char *);
			string str = va_arg(args, string);
			cout << "\"" << field << "\": ";

			cout << "\""+str+"\"" << endl;
		}
		else if (*fmt == 'i')
		{
			char * field = va_arg(args, char *);
			int i = va_arg(args, int);
			cout << "\"" << field << "\": ";

			cout << i;
		}
		else if (*fmt == 'f')
		{
			char * field = va_arg(args, char *);
			double f = va_arg(args, double);
			cout << "\"" << field << "\": ";
			cout << f;
		}
		else if (*fmt == 'l')
		{
			char * field = va_arg(args, char *);
			pv f =  va_arg(args, pv);
			cout << "\"" << field << "\": ";
			cout << "[" << endl;
			for (int i = 0; i < (int)f->size(); ++i)
			{
				(*f)[i]->print(0);
				if (i < (int)f->size() - 1)
					cout << "," << endl;
				else
					cout << endl;
			}
			cout << endl;
			cout << "]" << endl;
		}
		++fmt;
		if (*fmt != '\0')
			cout << "," << endl;
	}
	cout << "}" << endl;
	if ((astname != NULL) && (astname[0] != '\0'))
		cout << "}" << endl;
	va_end(args);
}

//custom function implementation
bool both_num(string a,string b) {
    if(   (a == "int" || a == "float") && (b == "int" || b == "float") ) return true;
    return false;
}
bool is_const_ptr(exp_astnode *d) {
    if(!d->type_tree.empty() && d->type_tree[0]->is_const) return true;
    return false;
}

// string get_str_type_tree(vector<arr*> &type_tree) {
//     string s;
//     int n = type_tree.size();
//     for(int i=0; i<n; i++) {
//         if(type_tree[i]->is_ptr) s = "*"+s;
//         if(i>0 && type_tree[i-1]->is_ptr && !type_tree[i]->is_ptr)
//             s = "("+s+")"+"["+to_string(type_tree[i]->data)+"]";
//         else if(!type_tree[i]->is_ptr) s += "["+to_string(type_tree[i]->data)+"]";
//     }
//     return s;
// }

bool is_compatible(exp_astnode *l, exp_astnode *r) {
    //if(is_const_ptr(l)) return false;
    // is_assignable
    if(l->type_tree.empty()) { // l is an object
        if(r->type_tree.empty()) { // r is an object
            if( (l->type == "int" || l->type == "float") && (r->type == "int" || r->type == "float")) return true;
            if(l->type != "int" && l->type != "float" && l->type != "string") { // l can only be a struct
                if(r->type == l->type) return true;
            }
        }
    }
    else{ // l is a ptr
        //(PTR,0)
        if(r->ct_val) return true; 
        //(ptr,void*)
        if(r->type == "void" && r->type_tree.size() == 1) return true;
        //(void*,ptr)
        if(l->type == "void" && l->type_tree.size() == 1 && !r->type_tree.empty()) return true;
        //COMPATIBLE TYPES
        if(l->get_type() == r->get_type()) return true;
    }
    return false;
}

bool eq_compat(exp_astnode*l, exp_astnode*r) {
//if(is_const_ptr(l)) return false;
    // is_assignable
    if(l->type_tree.empty()) { // l is an object
        if(r->type_tree.empty()) { // r is an object
            if( (l->type == "int" || l->type == "float") && (r->type == "int" || r->type == "float")) return true;
            // if(l->type != "int" && l->type != "float" && l->type != "string") { // l can only be a struct
            //     if(r->type == l->type) return true;
            // }
        }
        //(0,PTR)
        else if (l->ct_val) return true;
    }
    else{ // l is a ptr
        //(PTR,0)
        if(r->ct_val) return true; 
        //(ptr,void*)
        if(r->type == "void" && r->type_tree.size() == 1) return true;
        //(void*,ptr)
        if(l->type == "void" && l->type_tree.size() == 1 && !r->type_tree.empty()) return true;
        //COMPATIBLE TYPES
        if(l->get_type() == r->get_type()) return true;
    }
    return false;
}