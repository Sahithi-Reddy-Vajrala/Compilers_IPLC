
struct s1 {
        int a[3];
};

struct s1 f(){
        struct s1 tra;
        tra.a[0]=100;
        tra.a[1]=101;
        tra.a[2]=102;
        return tra;
}

int g(){
        int a, b,c,d,e;
        a=1234;b=23456;c=34567;d=45678;e=56789;
        return 1;
}

int main()
{
        int x;
        struct s1 mystr;
        printf("%d\n",f().a[g()]);
        x=f().a[g()];
}