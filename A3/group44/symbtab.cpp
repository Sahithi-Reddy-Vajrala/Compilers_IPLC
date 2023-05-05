#include "symbtab.hh"
#include <map>

entry SymbTab::get_entry(string s) {
    for(auto &it: Entries) {
        if(it.first == s) return it.second;
    }
    // if doesn't exist
    entry e;
    e.varfun = "";
    return e;
}

SymbTab gst;
map<string,int> lc_str;
int label_cnt = 2;











