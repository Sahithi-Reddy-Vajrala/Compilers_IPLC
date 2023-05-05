#include "symbtab.hh"

void entry::print_det() {
    cout << "\"" << varfun << "\"" << ", " << "\"" << gl << "\"" << ", " << size << ", ";
    if(varfun == "struct") {
        cout << " \"-\" , \"-\" ";
    }
    else cout << offset << ", \"" << ret_type << "\" ";
}

void SymbTab::printgst() {
    cout << "[";
        for (auto it = Entries.begin(); it != Entries.end(); ++it) {
            cout << "[";
                cout << "\"" << it->first << "\"" << "," << endl;
                it->second.print_det();
            cout << "]\n";
            if (next(it,1) != Entries.end()) cout << "," << endl;
        }
    cout << "] ";
}

void SymbTab::print() {
    cout << "[";
        for (auto it = Entries.begin(); it != Entries.end(); ++it) {
            cout << "[";
                cout << "\"" << it->first << "\"" << "," << endl;
                it->second.print_det();
            cout << "]\n";
            if (next(it,1) != Entries.end()) cout << "," << endl;
        }
    cout << "]\n";
}










