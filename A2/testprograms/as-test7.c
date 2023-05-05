
int main(){
	float a,b,f,g,h,i,j,k[10];
	float c;
	int* d;
	float* e;
	c=-34;
	a=-7.5;
	b=-a;
	b=-c;
	b=!(-0.0*2.3);
	e = &a;
	c = *e;
	b=*e;
	j=9.0;
	k[3] = 3.3;
	k[4] = 4.3;
	k[5] = 5.3;
	k[6] = 6.3;
	*e = 10.23;
	printf("%d%f\n",b==*(&(*(&(*(&(k[4])))))),c);
}