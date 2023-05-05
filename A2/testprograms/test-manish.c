int g()
{
    int *y;
    int z[10][10];
    int c[10][10];
    float d;
    d = !z;             /* The result of a not is an integer*/
    *y = z - c;         /* allowed*/
    *y = z - (&(c[0])); /* allowed now */
}
int f(int x[20])
{
}
int main()
{
    int x[10];
    int *y;
    f(y); /* allowed now */
    f(x); /* allowed */
}

int h(int x[20][10][10]) {}
int main1()
{
    void *e[10];
    h(e); /* Error at line 26: Expected "int(*)[10][10]" but argument is of type "void**" */
}

int f1()
{
    int a[10];
    int x;
    int *y;
    int **z;
    int *b[20];
    x = y - a; /* Ref. Impl. passes this */
    x = z - b; /* Ref Impl.  passes this */
}

int f2(float i)
{
int x;
    void *e;
    int *y;
    x = e < y;  /* gives error: Invalid operands types for binary < , "void*" and "int*" */
    y = e;  /*Passes*/
    e = y;  /*Passes*/
}

int f3 ()
{
    int x;
    int b[20][10];
    int c[20][10];
    int a[10];
    x = f2(x);
    x = b > c;  /* Passes now */
    x = b  && c;/* Passes now */
    x = &a < b; /* Passes now */
}

void h1(void* x) {}

int main2()
{
  int *x;
  int *y;
  int d[2][2];
  int c;
  h1(d); /* Passes*/
  c = x && y; /* Passes*/
  c = x && d; /* Passes*/  
  c = x > y;/* Passes*/
  c = x - y;/* Passes*/
  c = x - d; /*Error at line 75: Invalid operand types for binary - , "int*" and "int[2][2]"*/
}
