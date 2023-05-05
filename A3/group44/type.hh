#ifndef TYPE_HH
#define TYPE_HH


#include <string>
#include <vector>
#include <map>
#include "location.hh"
using namespace std;


class type_specifier_class {
    public:
        string type;
        bool base;
        type_specifier_class(string s, bool b) {type = s; base = b;}
};

class declarator_class {
    public:
        string iden;
        int num_ptr;
        vector<int> indices;

        declarator_class(string i, int n){
            iden = i; num_ptr = n;
        }
};

class declarator_list_class {
    public:
        vector<declarator_class*> decl;
};

class declaration_class {
    public:
        type_specifier_class  *ts;
        declarator_list_class *dl;
        IPL::location lo;

        declaration_class(type_specifier_class *t, declarator_list_class *d, IPL::location &l){
            ts = t; dl = d;
            lo = l;
        }
        void eval();
};

class declaration_list_class {
    public:
        vector<declaration_class*> decl;
};

class parameter_declaration_class {
    public:
        type_specifier_class *ts;
        declarator_class *decl;

        parameter_declaration_class(type_specifier_class *t, declarator_class *d){
            ts = t; decl = d;
        }
};

class parameter_list_class {
    public:
        vector<parameter_declaration_class*> par_decl;
};

class fun_declarator_class {
    public:
        string iden;
        parameter_list_class *par_list;

        fun_declarator_class(string i, parameter_list_class *p) {
            iden = i;
            par_list = p;
        }
};

#endif