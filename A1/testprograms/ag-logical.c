int main()
{
	int a,b,c;
	a=10;
	b=20;
	c=a*b;
	a=-(b-c);
	printf("%d",(c<b)||((a>0)&&(2*a==b)));
	return 0;
}
