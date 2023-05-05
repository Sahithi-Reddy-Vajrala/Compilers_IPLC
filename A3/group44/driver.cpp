#include "scanner.hh"
#include <fstream>
#include <iterator>
#include <map>
#include <algorithm>
#include <utility>
#include "globals.hh"
using namespace std;

bool cmp(pair<string,int> &a, pair<string,int> &b) {
	return a.second < b.second;
}

extern map<string,abstract_astnode*> ast;

string filename;

int main(int argc, char **argv)
{
	using namespace std;
	fstream in_file, out_file;

	in_file.open(argv[1], ios::in);
	IPL::Scanner scanner(in_file);
	IPL::Parser parser(scanner);

#ifdef YYDEBUG
	parser.set_debug_level(1);
#endif
parser.parse();

/* assembly file intro */
	cout << "\t" << ".file" << "\t" << "\"" << argv[1] << "\"" << "\n";
	cout << "\t" << ".text" << "\n";

	if(!lc_str.empty()) { //strings are there
		cout << "\t" << ".section" << "\t" << ".rodata" << "\n";
		vector<pair<string,int>> A;
		for(auto &it : lc_str) 
			A.push_back(it);
		sort(A.begin(),A.end(),cmp);
		for(auto &it : A) {
			cout << ".LC" << it.second << ":" << "\n";
			cout << "\t" << ".string" << "\t" << it.first << "\n";
		}
		cout << "\t" << ".text" << "\n";
	}

	label_cnt = 2;
	for (auto it = gst.Entries.begin(); it != gst.Entries.end(); ++it) {
		if (it->second.varfun == "fun") {
			cout << "\t" << ".globl" << "\t" << it->first << "\n";
			cout << "\t" << ".type" << "\t" << it->first << ", @function" << "\n";
			cout << it->first << ":" << "\n";

			//prolog
				cout << "\t" << "pushl" << "\t" << "%ebp" << "\n";
				cout << "\t" << "movl" << "\t" << "%esp, %ebp" << "\n";
			//ast code
				if(it->second.size > 0) {
					cout << "\t" << "subl	$" << it->second.size << ", %esp" << "\n";
				}
				ast[it->first]->gencode(it->second.symbtab);
			//epilogs
				cout << "\t" << "leave" << "\n";
				cout << "\t" << "ret" << "\n";
				cout << "\t" << ".size" << "\t" << it->first << ", .-" << it->first << "\n";
		}
	}

	cout << "\t" << ".section" << "\t" << ".note.GNU-stack,\"\",@progbits" << "\n";

	fclose(stdout);
}



