#include <iostream>
#include <stdarg.h>
#include <string>
#include <vector>
#include "type.hh"
#include "symbtab.hh"
using namespace std;

class arr { // type-tree
    public:
        bool is_ptr;
        bool is_const;
        int data;
        arr(bool i, bool c, int d) {
            is_ptr = i; is_const = c; data = d; 
        }
};

void printAst(const char *astname, const char *fmt...);
enum typeExp {
    statement_type,
        empty_type, seq_type, assignS_type, return_type, if_type,
        while_type, for_type, proccall_type,
    exp_type,
        ref_type,
            identifier_type, arrayref_type, member_type, arrow_type,
        op_binary_type, op_unary_type, assignE_type, funcall_type, 
        intconst_type, floatconst_type, stringconst_type    
};

class abstract_astnode {
public:
    enum typeExp astnode_type;
    string id;
    virtual void print(int blanks) = 0;
    virtual void gencode(SymbTab*) = 0;
//protected:
};

class statement_astnode : public abstract_astnode {
    public:
        statement_astnode() {astnode_type = statement_type;}
};

class exp_astnode : public abstract_astnode {
    public:
        //bool rval;
        int node_label;
        bool lval;
        bool ct_val;
        vector<arr*> type_tree;
        int val;
        string type;
        //int num_ptr = 0;
        //vector<int> indices;
        exp_astnode() {astnode_type = exp_type;}
        int get_elem_size();
        string get_type() {
            string s;
            int n = type_tree.size();
            if(0<n) s = "*";
            //i = 1
            if(1<n) {
                if(type_tree[1]->is_ptr) s = "*"+s;
                else s = "("+s+")"+"["+to_string(type_tree[1]->data)+"]";
            }
            for(int i=2; i<n; i++) {
                if(type_tree[i]->is_ptr) s = "*"+s;
                if(type_tree[i-1]->is_ptr && !type_tree[i]->is_ptr)
                    s = "("+s+")"+"["+to_string(type_tree[i]->data)+"]";
                else if(!type_tree[i]->is_ptr) s += "["+to_string(type_tree[i]->data)+"]";
            }
            s = type + s;
            return s;
        }
        // exp_astnode(bool l, bool r, bool c, arr *ty, string v, string t) {
        //     astnode_type = exp_type;
        //     lval = l; rval = r; ct_val = c; type_tree = ty; 
        //     val = v; type = t;
        // }
};

class my_par_exp_class : public exp_astnode {
    public:
        int a;
        my_par_exp_class(parameter_declaration_class *par_decln) {
            lval = true; ct_val = false;
            type = par_decln->ts->type;
            vector<int> indices = par_decln->decl->indices;
            int num_ptr = par_decln->decl->num_ptr;

            if(!indices.empty()) { //takes first as *
                type_tree.push_back(new arr(true,false,indices[0])); //param
                for(int i=1; i<indices.size(); i++)
                    type_tree.push_back(new arr(false,true,indices[i]));
            }
            for(int i=0; i<num_ptr; i++) 
                type_tree.push_back(new arr(true,false,0));
        }
        void print(int blanks) {a=1;}
        void gencode(SymbTab *lst){}
};

class ref_astnode : public exp_astnode {
    public:
        ref_astnode() {astnode_type = ref_type;}
};

class identifier_astnode : public ref_astnode {
    public:
        string iden;
        identifier_astnode(string);
        void print(int blanks);
        void gencode(SymbTab *lst);
        int get_offset(SymbTab *lst);
};

class empty_astnode : public statement_astnode {
    public:
        empty_astnode() {astnode_type = empty_type;}
        void print(int blanks) {cout << "\"empty\"" << endl;}
        void gencode(SymbTab *lst){}
};

class seq_astnode : public statement_astnode {
    public:
        vector<statement_astnode*> vec;
        seq_astnode();
        void print(int blanks);
        void gencode(SymbTab *lst);
};

class return_astnode : public statement_astnode {
    public:
        exp_astnode *child;
        return_astnode(exp_astnode*);
        void print(int blanks);
        void gencode(SymbTab *lst);
};

class if_astnode : public statement_astnode {
    public:
        exp_astnode *cond;
        statement_astnode *then, *else_child;
        if_astnode(exp_astnode*,statement_astnode*,statement_astnode*);
        void print(int blanks);
        void gencode(SymbTab *lst);
};

class while_astnode : public statement_astnode {
    public:
        exp_astnode *cond;
        statement_astnode *stmt;
        while_astnode(exp_astnode*, statement_astnode*);
        void print(int blanks);
        void gencode(SymbTab *lst);
};

class for_astnode : public statement_astnode {
    public:
        exp_astnode *init, *guard, *step;
        statement_astnode *body;
        for_astnode(exp_astnode*,exp_astnode*,exp_astnode*,statement_astnode*);
        void print(int blanks);
        void gencode(SymbTab *lst);
};

class printf_astnode : public statement_astnode {
    public:
        string c_str;
        vector<exp_astnode*> vec;
        printf_astnode();
        printf_astnode(string s);
        printf_astnode(string s, vector<exp_astnode*> &vec1);
        void print(int blanks){}
        void gencode(SymbTab *lst);
};

class proccall_astnode : public statement_astnode {
    public:
        identifier_astnode *fname;
        vector<exp_astnode*> vec;
        proccall_astnode(vector<exp_astnode*> &vec1);
        proccall_astnode();
        void print(int blanks);
        void gencode(SymbTab* lst);
};

class op_binary_astnode : public exp_astnode {
    public:
        string op;
        exp_astnode *left, *right;
        op_binary_astnode(string,exp_astnode*,exp_astnode*);
        void print(int blanks);
        void gencode(SymbTab *lst);
};

class op_unary_astnode : public exp_astnode {
    public:
        string op;
        exp_astnode *child;
        op_unary_astnode(string,exp_astnode*);
        void print(int blanks);
        void gencode(SymbTab *lst);
};

class assignE_astnode : public exp_astnode {
    public:
        exp_astnode *left, *right;
        assignE_astnode(exp_astnode*,exp_astnode*);
        void print(int blanks);
        void gencode(SymbTab *lst);
};

class assignS_astnode : public statement_astnode {
    public:
        assignE_astnode *asgn_exp;
        assignS_astnode(assignE_astnode*);
        void print(int blanks){}
        void gencode(SymbTab *lst);
};

class funcall_astnode : public exp_astnode {
    public:
        identifier_astnode *fname;
        vector<exp_astnode*> vec;
        funcall_astnode();
        funcall_astnode(identifier_astnode*);
        void print(int blanks);
        void gencode(SymbTab *lst);
};

class intconst_astnode : public exp_astnode {
    public:
        int literal;
        intconst_astnode(int);
        void print(int blanks);
        void gencode(SymbTab *lst);
};

class arrayref_astnode : public ref_astnode {
    public:
        exp_astnode *array, *index;
        arrayref_astnode(exp_astnode*,exp_astnode*);
        void print(int blanks);
        void gencode(SymbTab *lst);
};

class member_astnode : public ref_astnode {
    public:
        exp_astnode *st;
        identifier_astnode *field;
        member_astnode(exp_astnode*,identifier_astnode*);
        void print(int blanks);
        void gencode(SymbTab *lst);
};

class arrow_astnode : public ref_astnode {
    public:
        exp_astnode *pointer;
        identifier_astnode *field;
        arrow_astnode(exp_astnode*,identifier_astnode*);
        void print(int blanks);
        void gencode(SymbTab *lst);
};

//custom functions
bool is_const_ptr(exp_astnode*);
bool is_compatible(exp_astnode*, exp_astnode*);
bool both_num(string,string);
bool eq_compat(exp_astnode*, exp_astnode*);

