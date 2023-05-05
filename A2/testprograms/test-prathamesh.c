
int main()
{
    int x[20];
    int *y;
    y = x + 1;
    y = y++;
    y = 0;
    y = &x;
}
int f()
{
    int a;
    int b[2][4];
    int c[3][4];
    a = b - c;
}

int g()
{
    int a;
    int b[2][4];
    int c[3][4];
}