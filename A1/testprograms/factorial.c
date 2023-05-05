int main()
{
 int n,i,j;
 j=1;
 printf("Enter value");
 scanf("%d",&n);
 for(i=2; i<=n; i=i+1)
 {
  j=j*i;
 }
 printf("%d",j);
 return 0;
}
