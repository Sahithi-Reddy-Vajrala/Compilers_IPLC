
struct s1{
	int a;
	float b;
	int* c;
};

struct s2{
	float* a[12][2];
	struct s1 b[8];
	struct s2* c;
};

struct s1 foo(int w){
	struct s1 temp;
	temp.a=23;
	temp.b=89.98;
	temp.c = &temp.a;
	return temp;
}

int main(){
	int a, b,c;
	struct s1 _a,_b;
	struct s2 _c; 

	_a = foo(2);

	_c.b[3+4] =_a;

	printf("%d, %f, %p\n", _c.b[7].a, _c.b[7].b, _c.b[7].c);

}