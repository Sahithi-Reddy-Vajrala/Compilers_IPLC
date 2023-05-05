#include "ast_class.hh"
#include "symbtab.hh"
#include "globals.hh"

arrow_astnode::arrow_astnode(exp_astnode *p, identifier_astnode *f) {
    astnode_type = arrow_type;
    pointer = p; field = f;
    id = "arrow";
}

void arrow_astnode::gencode(SymbTab *lst) {
    entry e = gst.get_entry(pointer->type).symbtab->get_entry(field->iden);
    int offset = e.offset;

    pointer->gencode(lst);    
    // eax lo str_addr    
    cout << "\t" << "addl" << "\t" << "$" << offset << ", %eax" << "\n";
    // eax contains iden_addr
    if(!e.indices.empty()) {
        //array
        cout << "\t" << "movl" << "\t" << "%eax, %ebx" << "\n";
    }
    else {
        cout << "\t" << "movl" << "\t" << "%eax, %ebx" << "\n";
        cout << "\t" << "movl" << "\t" << "(%ebx), %eax" << "\n";
    }
    // ebx: iden_addr, eax: iden
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

void member_astnode::gencode(SymbTab *lst) {
    st->gencode(lst);
    // eax lo st_firstchild, ebx lo str_addr
    entry e = gst.get_entry(st->type).symbtab->get_entry(field->iden);
    int offset = e.offset;

    cout << "\t" << "addl" << "\t" << "$" << offset << ", %ebx" << "\n";
    if(!e.indices.empty()) {
        //array
        cout << "\t" << "movl" << "\t" << "%ebx, %eax" << "\n";
    }
    else {
        cout << "\t" << "movl" << "\t" << "(%ebx), %eax" << "\n";
    }
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

void arrayref_astnode::gencode(SymbTab *lst) {
    // a[i]  *(a+i)
    bool rgt_intconst = (index->astnode_type == intconst_type);

    int mul_fac = array->get_elem_size();

    if(rgt_intconst) {
        intconst_astnode *r = (intconst_astnode*)index;
        mul_fac *= r->literal;
        //mul_fac has mul_fac*i
        array->gencode(lst);
        cout << "\t" << "addl" << "\t" << "$" << mul_fac << ", %eax" << "\n";
    }
    else {
        index->gencode(lst);
        cout << "\t" << "imull" << "\t" << "$" << mul_fac << ", %eax" << "\n";
        cout << "\t" << "pushl" << "\t" << "%eax" << "\n";
        array->gencode(lst);
        cout << "\t" << "addl" << "\t" << "(%esp), %eax" << "\n";
        cout << "\t" << "addl" << "\t" << "$4, %esp" << "\n";                    
    }

    //eax has final ptr_val
    //DEREFERENCING
    cout << "\t" << "movl" << "\t" << "%eax, %ebx" << "\n";
    //ebx has addr
    if(type_tree.empty() || type_tree[0]->is_ptr) {
        //not array
        cout << "\t" << "movl" << "\t" << "(%ebx), %eax" << "\n";
    }
    return;
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

void identifier_astnode::gencode(SymbTab *lst) {
    if(!type_tree.empty() && !type_tree[0]->is_ptr) {
        cout << "\t" << "leal" << "\t" << get_offset(lst) << "(%ebp), %ebx" << "\n";
        cout << "\t" << "movl" << "\t" << "%ebx, %eax" << "\n";
    }
    else {
        cout << "\t" << "leal" << "\t" << get_offset(lst) << "(%ebp), %ebx" << "\n";
        cout << "\t" << "movl" << "\t" << "(%ebx), %eax" << "\n";
    }    
}

int identifier_astnode::get_offset(SymbTab *lst) {
    return lst->get_entry(iden).offset;
}

void identifier_astnode::print(int blanks) {
    cout << "{ \"identifier\": \"" << iden << "\" }";
}

intconst_astnode::intconst_astnode(int l) {
    astnode_type = intconst_type;
    literal = l;
    id = "intconst";
}

void intconst_astnode::gencode(SymbTab *lst) {
    cout << "\t" << "movl" << "\t" << "$" << literal << ", %eax" << "\n";
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

void funcall_astnode::gencode(SymbTab *lst) {
    int tot_param_size = 0;
    for(auto it = vec.begin(); it != vec.end(); it++) {
        (*it)->gencode(lst);
        if((*it)->type_tree.empty() && (*it)->type != "int") {
            //struct object,  
            int n = gst.get_entry((*it)->type).size;

            if(n < 1) continue; //SIZE = 0 of STORAGE
            tot_param_size += n;
            
            cout << "\t" << "subl" << "\t" << "$" << n <<", %esp" << "\n";
            //made space on stack for STRUCT OBJ

            cout << "\t" << "movl" << "\t" << "%esp, %edi" << "\n";
            //ebx lo  source, edi lo destination

            cout << "\t" << "movl" << "\t" << "%ebx, %edx" << "\n";
            cout << "\t" << "addl" << "\t" << "$" << n <<", %edx" << "\n";
            //ebx lo source, edx lo source+max

            int label = label_cnt;
            label_cnt++;
            
            cout << ".L" << label << ":" << "\n";
            //ebx lo source, edi lo destination
            cout << "\t" << "movl" << "\t" << "(%ebx), %eax" << "\n";
            cout << "\t" << "movl" << "\t" << "%eax, (%edi)" << "\n";
            cout << "\t" << "addl" << "\t" << "$4, %ebx" << "\n";
            cout << "\t" << "addl" << "\t" << "$4, %edi" << "\n";

            cout << "\t" << "cmpl" << "\t" << "%ebx, %edx" << "\n";
            cout << "\t" << "jg .L" << label << "\n";

        }
        else {
            tot_param_size += 4;
            cout << "\t" << "pushl" << "\t" << "%eax" << "\n"; //parameter of size 4
        }
    }
    cout << "\t" << "call" << "\t" << fname->iden << "\n";
    cout << "\t" << "addl" << "\t" << "$" << tot_param_size << ", %esp" << "\n";
}

void funcall_astnode::print(int blanks) {
    printAst("funcall","al",
             "fname", fname,
             "params", vec);
}

assignE_astnode::assignE_astnode(exp_astnode *l, exp_astnode *r) {
    astnode_type = assignE_type;
    left = l; right = r;
    id = "assignE";
}

void assignE_astnode::gencode(SymbTab *lst) {
    // no work with EAX,EBX after ASSIGNMENT EXPRESSION
    bool left_iden = (left->astnode_type == identifier_type);
    bool rgt_intconst = (right->astnode_type == intconst_type);
    identifier_astnode *l = (identifier_astnode*)left;
    intconst_astnode *r = (intconst_astnode*)right;

    //right is intconst
    if(rgt_intconst) {
        if(left_iden) {
            cout << "\t" << "movl" << "\t";
            cout << "$" << r->literal << ", " << l->get_offset(lst) << "(%ebp)" << "\n";
        }
        else {
            left->gencode(lst);
            cout << "\t" << "movl" << "\t";
            cout << "$" << r->literal << ", " << "(%ebx)" << "\n";
        }
        return; //RETURN!!!
    }

    //pointer or INT object : don't care
    // struct OBJ : recursive copy
    if(!left->type_tree.empty() || left->type == "int") {
        right->gencode(lst);
        // left is pointer
        if(left_iden) {
            cout << "\t" << "movl" << "\t" << "%eax, " << l->get_offset(lst) << "(%ebp)" << "\n";
        }
        else {
            cout << "\t" << "pushl" << "\t" << "%eax" << "\n";
            left->gencode(lst);
            cout << "\t" << "popl" << "\t" << "%eax" << "\n";
            cout << "\t" << "movl" << "\t" << "%eax, (%ebx)" << "\n";
        }
    }
    //struct OBJECT
    else {
        int n = gst.get_entry(left->type).size;
        if(n < 1) return; //SIZE = 0 of STORAGE
        left->gencode(lst);
        //cout << "\t" << "movl" << "\t" << "%ebx, %edi" << "\n";
        cout << "\t" << "pushl" << "\t" << "%ebx" << "\n";
        right->gencode(lst);
        cout << "\t" << "popl" << "\t" << "%edi" << "\n";
        //ebx lo  source, edi lo destination
        cout << "\t" << "movl" << "\t" << "%ebx, %edx" << "\n";
        cout << "\t" << "addl" << "\t" << "$" << n <<", %edx" << "\n";
        //ebx lo source, edx lo source+max

        int label = label_cnt;
        label_cnt++;
        
        cout << ".L" << label << ":" << "\n";
        //ebx lo source, edi lo destination
        cout << "\t" << "movl" << "\t" << "(%ebx), %eax" << "\n";
        cout << "\t" << "movl" << "\t" << "%eax, (%edi)" << "\n";
        cout << "\t" << "addl" << "\t" << "$4, %ebx" << "\n";
        cout << "\t" << "addl" << "\t" << "$4, %edi" << "\n";

        cout << "\t" << "cmpl" << "\t" << "%ebx, %edx" << "\n";
        cout << "\t" << "jg .L" << label << "\n";
    }
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

void op_unary_astnode::gencode(SymbTab *lst) {
    child->gencode(lst);
    if(op == "PP") {
        if(!child->type_tree.empty()) {
            //ptr++
            int mul_fac = child->get_elem_size();
            cout << "\t" << "addl" << "\t" << "$" << mul_fac << ", %eax" << "\n";
            cout << "\t" << "movl" << "\t" << "%eax, (%ebx)" << "\n";
            cout << "\t" << "subl" << "\t" << "$" << mul_fac << ", %eax" << "\n";
            return;
        }
        cout << "\t" << "incl" << "\t" << "%eax" << "\n";
        cout << "\t" << "movl" << "\t" << "%eax, (%ebx)" << "\n";
        cout << "\t" << "decl" << "\t" << "%eax" << "\n";
    }
    if(op == "UMINUS") {
        cout << "\t" << "negl" << "\t" << "%eax" << "\n";
    }
    if(op == "NOT") {
        cout << "\t" << "cmpl" << "\t" << "$0, %eax" << "\n";
        cout << "\t" << "sete" << "\t" << "%al" << "\n";
        cout << "\t" << "movzbl" << "\t" << "%al, %eax" << "\n";
    }
    if(op == "ADDRESS") {
        cout << "\t" << "movl" << "\t" << "%ebx, %eax" << "\n";
    }
    if(op == "DEREF") {
        cout << "\t" << "movl" << "\t" << "%eax, %ebx" << "\n";
        cout << "\t" << "movl" << "\t" << "(%ebx), %eax" << "\n";
    }

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

void op_binary_astnode::gencode(SymbTab *lst) {
    string op1 = "(%esp)";
    bool pushed = false;
    bool rgt_intconst = (right->astnode_type == intconst_type);
    bool lft_intconst = (left->astnode_type == intconst_type);
    
    //for ptr arith
    if(op == "PLUS" || op == "MINUS") {
        int mul_fac;
        string cmd("addl");
        if(op == "MINUS") cmd = "subl";
        if(!left->type_tree.empty()) {
            //left is ptr
            if(right->type_tree.empty()) {
                //left is ptr, right is int
                mul_fac = left->get_elem_size();
                if(rgt_intconst) {
                    intconst_astnode *r = (intconst_astnode*)right;
                    mul_fac *= r->literal;
                    //mul_fac has mul_fac*i
                    left->gencode(lst);
                    cout << "\t" << cmd << "\t" << "$" << mul_fac << ", %eax" << "\n";
                }
                else {
                    right->gencode(lst);
                    cout << "\t" << "imull" << "\t" << "$" << mul_fac << ", %eax" << "\n";
                    cout << "\t" << "pushl" << "\t" << "%eax" << "\n";
                    left->gencode(lst);
                    cout << "\t" << cmd << "\t" << "(%esp), %eax" << "\n";
                    cout << "\t" << "addl" << "\t" << "$4, %esp" << "\n";                    
                }
                return;
            }
        }
        else if(!right->type_tree.empty()) {
            //left is int, right is pointer (only addition)
            mul_fac = right->get_elem_size();
            if(lft_intconst){
                intconst_astnode *l = (intconst_astnode*)left;
                mul_fac *= l->literal;
                right->gencode(lst);
                cout << "\t" << cmd << "\t" << "$" << mul_fac << ", %eax" << "\n";
            }
            else{
                left->gencode(lst);
                cout << "\t" << "imull" << "\t" << "$" << mul_fac << ", %eax" << "\n";
                cout << "\t" << "pushl" << "\t" << "%eax" << "\n";
                right->gencode(lst);
                cout << "\t" << cmd << "\t" << "(%esp), %eax" << "\n";
                cout << "\t" << "addl" << "\t" << "$4, %esp" << "\n"; 
            }
            return;
        }
    }

    if(rgt_intconst && !(op == "DIV" || op == "OP_OR")) {
        intconst_astnode *r = (intconst_astnode*)right;
        left->gencode(lst);
        op1 = "$" + to_string(r->literal);
    }
    else {
        right->gencode(lst);
        cout << "\t" << "pushl" << "\t" << "%eax" << "\n";
        left->gencode(lst);
        pushed = true;
    }

    if(op == "MULT") {
        cout << "\t" << "imull" << "\t" << op1+", %eax" << "\n";
    }
    if(op == "DIV") {
        cout << "\t" << "cltd" << "\n";
        cout << "\t" << "idivl" << "\t" << op1 << "\n";
    }
    if(op == "PLUS") {
        cout << "\t" << "addl" << "\t" << op1+", %eax" << "\n";
    }
    if(op == "MINUS") {
        cout << "\t" << "subl" << "\t" << op1+", %eax" << "\n";
    }
    if(op == "OP_LT") {
        cout << "\t" << "cmpl" << "\t" << op1+", %eax" << "\n";
        cout << "\t" << "setl" << "\t" << "%al" << "\n";
        cout << "\t" << "movzbl" << "\t" << "%al, %eax" << "\n";
    }
    if(op == "OP_GT") {
        cout << "\t" << "cmpl" << "\t" << op1+", %eax" << "\n";
        cout << "\t" << "setg" << "\t" << "%al" << "\n";
        cout << "\t" << "movzbl" << "\t" << "%al, %eax" << "\n";
    }
    if(op == "OP_LTE") {
        cout << "\t" << "cmpl" << "\t" << op1+", %eax" << "\n";
        cout << "\t" << "setle" << "\t" << "%al" << "\n";
        cout << "\t" << "movzbl" << "\t" << "%al, %eax" << "\n";
    }
    if(op == "OP_GTE") {
        cout << "\t" << "cmpl" << "\t" << op1+", %eax" << "\n";
        cout << "\t" << "setge" << "\t" << "%al" << "\n";
        cout << "\t" << "movzbl" << "\t" << "%al, %eax" << "\n";
    }
    if(op == "OP_EQ") {
        cout << "\t" << "cmpl" << "\t" << op1+", %eax" << "\n";
        cout << "\t" << "sete" << "\t" << "%al" << "\n";
        cout << "\t" << "movzbl" << "\t" << "%al, %eax" << "\n";
    }
    if(op == "OP_NEQ") {
        cout << "\t" << "cmpl" << "\t" << op1+", %eax" << "\n";
        cout << "\t" << "setne" << "\t" << "%al" << "\n";
        cout << "\t" << "movzbl" << "\t" << "%al, %eax" << "\n";
    }
    if(op == "OP_AND") {
        cout << "\t" << "cmpl" << "\t" << "$0, %eax" << "\n";
        cout << "\t" << "setne" << "\t" << "%al" << "\n";
        cout << "\t" << "movzbl" << "\t" << "%al, %eax" << "\n";

        cout << "\t" << "imull" << "\t" << op1+", %eax" << "\n";
        cout << "\t" << "cmpl" << "\t" << "$0, %eax" << "\n";
        cout << "\t" << "setne" << "\t" << "%al" << "\n";
        cout << "\t" << "movzbl" << "\t" << "%al, %eax" << "\n";
    }
    if(op == "OP_OR") {
        cout << "\t" << "orl" << "\t" << op1+", %eax" << "\n";
        cout << "\t" << "cmpl" << "\t" << "$0, %eax" << "\n";
        cout << "\t" << "setne" << "\t" << "%al" << "\n";
        cout << "\t" << "movzbl" << "\t" << "%al, %eax" << "\n";
    }
    
    if(pushed) cout << "\t" << "addl" << "\t" << "$4, %esp" << "\n";
}

void op_binary_astnode::print(int blanks) {
    printAst("op_binary", "saa",
             "op", op,
             "left", left,
             "right", right);
}

printf_astnode::printf_astnode(string s) {
    c_str = s;
}

printf_astnode::printf_astnode(string s, vector<exp_astnode*> &vec1) {
    c_str = s;
    vec = vec1;
}

void printf_astnode::gencode(SymbTab *lst) {
    for(auto rit = vec.rbegin(); rit != vec.rend(); rit++) {
        (*rit)->gencode(lst);
        cout << "\t" << "pushl" << "\t" << "%eax" << "\n";
    }
    cout << "\t" << "pushl" << "\t" << "$.LC" << lc_str[c_str] << "\n";
    cout << "\t" << "call" << "\t" << "printf" << "\n";
    cout << "\t" << "addl" << "\t" << "$" << (vec.size() + 1)*4 << ", %esp" << "\n"; 
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

void proccall_astnode::gencode(SymbTab *lst) {
    int tot_param_size = 0;
    for(auto it = vec.begin(); it != vec.end(); it++) {
        (*it)->gencode(lst);
        if((*it)->type_tree.empty() && (*it)->type != "int") {
            //struct object,  
            int n = gst.get_entry((*it)->type).size;

            if(n < 1) continue; //SIZE = 0 of STORAGE
            tot_param_size += n;
            
            cout << "\t" << "subl" << "\t" << "$" << n <<", %esp" << "\n";
            //made space on stack for STRUCT OBJ

            cout << "\t" << "movl" << "\t" << "%esp, %edi" << "\n";
            //ebx lo  source, edi lo destination

            cout << "\t" << "movl" << "\t" << "%ebx, %edx" << "\n";
            cout << "\t" << "addl" << "\t" << "$" << n <<", %edx" << "\n";
            //ebx lo source, edx lo source+max

            int label = label_cnt;
            label_cnt++;
            
            cout << ".L" << label << ":" << "\n";
            //ebx lo source, edi lo destination
            cout << "\t" << "movl" << "\t" << "(%ebx), %eax" << "\n";
            cout << "\t" << "movl" << "\t" << "%eax, (%edi)" << "\n";
            cout << "\t" << "addl" << "\t" << "$4, %ebx" << "\n";
            cout << "\t" << "addl" << "\t" << "$4, %edi" << "\n";

            cout << "\t" << "cmpl" << "\t" << "%ebx, %edx" << "\n";
            cout << "\t" << "jg .L" << label << "\n";

        }
        else {
            tot_param_size += 4;
            cout << "\t" << "pushl" << "\t" << "%eax" << "\n"; //parameter of size 4
        }
    }
    cout << "\t" << "call" << "\t" << fname->iden << "\n";
    cout << "\t" << "addl" << "\t" << "$" << tot_param_size << ", %esp" << "\n";
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

void for_astnode::gencode(SymbTab *lst) {
    int label1 = label_cnt, label2;
    label2 = label1 + 1;
    label_cnt += 2;

    init->gencode(lst);

    cout << ".L" << label1 << ":" << "\n";
    guard->gencode(lst);
    cout << "\t" << "cmpl" << "\t" << "$0, %eax" << "\n";
    cout << "\t" << "je" << " .L" << label2 << "\n";

    body->gencode(lst);
    step->gencode(lst);
    cout << "\t" << "jmp" << " .L" << label1 << "\n";

    cout << ".L" << label2 << ":" << "\n";
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

void while_astnode::gencode(SymbTab *lst) {
    int label1 = label_cnt;
    int label2 = label1 + 1;
    label_cnt += 2;

    cout << ".L" << label1 << ":" << "\n";
    cond->gencode(lst);
    cout << "\t" << "cmpl" << "\t" << "$0, %eax" << "\n";
    cout << "\t" << "je" << " .L" << label2 << "\n";

    stmt->gencode(lst);
    cout << "\t" << "jmp" << " .L" << label1 << "\n";

    cout << ".L" << label2 << ":" << "\n";
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

void if_astnode::gencode(SymbTab *lst) {
    int label1 = label_cnt;
    int label2 = label1 + 1;
    label_cnt += 2;

    cond->gencode(lst);
    cout << "\t" << "cmpl" << "\t" << "$0, %eax" << "\n";
    cout << "\t" << "je" << " .L" << label1 << "\n";

    then->gencode(lst);
    cout << "\t" << "jmp" << " .L" << label2 << "\n";

    cout << ".L" << label1 << ":" << "\n";
    else_child->gencode(lst);

    cout << ".L" << label2 << ":" << "\n";
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

void return_astnode::gencode(SymbTab *lst) { 
    child->gencode(lst);
    cout << "\t" << "leave" << "\n";
	cout << "\t" << "ret" << "\n";
}

void return_astnode::print(int blanks) {
    cout << "{ \"return\": ";
        child->print(0);
    cout << "}";
}

assignS_astnode::assignS_astnode(assignE_astnode *exp) {
    astnode_type = assignS_type;
    asgn_exp = exp;
    id = "assignS";
}

void assignS_astnode::gencode(SymbTab *lst) {
    asgn_exp->gencode(lst);
}

seq_astnode::seq_astnode() {
    astnode_type = seq_type;
    id = "seq";
}

void seq_astnode::gencode(SymbTab *lst) {
    int n = vec.size();
    for(int i=0; i<n; i++) {
        vec[i]->gencode(lst);
    }
}

void seq_astnode::print(int blanks) {
    int n = vec.size();
    cout << "{ \"seq\": [" << endl;
        for(int i=0; i<n; i++) {
            if(i != 0) cout << "," << endl;
            vec[i]->print(0);
        }
    cout << "]}";
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

int exp_astnode::get_elem_size() {
    if(type_tree.empty()) return 0;

    int mul_fac = 1, obj_size = 0;
    if(type == "int") obj_size = 4; //int_size
    else obj_size = gst.get_entry(type).size;

    //array_typetree is non-empty
    if(type_tree.size() == 1) mul_fac = obj_size;

    if(type_tree.size() > 1) { //type_tree size > 1
        if(type_tree[1]->is_ptr) mul_fac = 4; //ptr_size
        else {
            mul_fac = 1;
            for(int i=1; i<type_tree.size(); i++) {
                if(!type_tree[i]->is_ptr) mul_fac *= type_tree[i]->data;
                else {obj_size = 4; break;} //obj_size = ptr_size
            }
            mul_fac *= obj_size; //if ptr is at end, obj_size = ptr_size
        }
    }
    return mul_fac;
}

bool both_num(string a,string b) {
    if(   (a == "int" || a == "float") && (b == "int" || b == "float") ) return true;
    return false;
}
bool is_const_ptr(exp_astnode *d) {
    if(!d->type_tree.empty() && d->type_tree[0]->is_const) return true;
    return false;
}

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