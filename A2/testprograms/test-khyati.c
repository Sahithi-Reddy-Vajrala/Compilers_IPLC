
int func(int a, int b)
{
}
int main()
{
    func(1); 
}
/*The error message states that there are too few arguments for procedure call */
int func1(int a, int b)
{
}
int main1()
{
     func1();
}
/*in this code snippet the error message indicates that there "too many" arguments for procedure call.*/
/* struct b */  void func2(int a, int b)
{
}
int main2()
{
    func2(1, 2);
}
/*this code snippet does not give error given that the struct q is not defined anywhere.*/