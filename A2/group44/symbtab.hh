#include <iterator>
#include <iostream>
#include "type.hh"
using namespace std;

class SymbTab;

class entry {
    public:
        string varfun;      // var, fun, struct
        string gl;          // global, local, param
        int size;           // for fun(0)
        int offset;         // for fun(0), for struct("-")
        string ret_type;    // ret_type or type of variable
        SymbTab *symbtab;   // null for variable
        parameter_list_class *param_order;  // order of (parameter entries) for function
        int num_ptr;
        vector<int> indices;
        string base_type;

        entry(string v, string g, int s, int o, string r, SymbTab *sy){
            varfun = v; gl = g; size = s; offset = o; ret_type = r;
            symbtab = sy;
        }
        entry(string v, string g, int s, int o, string r, SymbTab *sy, parameter_list_class *p) {
            varfun = v; gl = g; size = s; offset = o; ret_type = r;
            symbtab = sy; param_order = p;
        }
        entry(string v, string g, int s, int o, string r, SymbTab *sy, int n, vector<int> &i, string b){
            varfun = v; gl = g; size = s; offset = o; ret_type = r;
            symbtab = sy;
            num_ptr = n; indices = i; base_type = b;
        }
        entry() {}
        void print_det(); //prints varfun, gl, size, offset, ret_type
};

class SymbTab {        
    public:
        map<string,entry>  Entries;

        void printgst();
        void print();
};












