
struct s1{
	int a[10];
	float b[20];
	int* c;
};

struct s2{
	float* a[12][2];
	struct s1 b[8];
	struct s2* c;
};

void foo(int mode, struct s1* demo){
    int i;
for(i=0;i<10;i=i+1){
		if(mode){
			demo->a[i] = i*2;
		} else {
			demo->a[i] = i*3;
		}
	}
	for(i=0;i<20;i=i+1){
		if(mode){
			demo->b[i] = i*1.5;
		} else {
			demo->b[i] = i*2.5;
		}	
	}
}

int main(){
	struct s1 a,b;
	int x;
	foo(1, &a);
	foo(0, &b);
	x=1;
	a.b[x++] = b.b[x];
	printf("%f, %f, %d\n", a.b[1], b.b[2], x);
}