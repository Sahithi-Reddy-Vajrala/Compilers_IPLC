struct b
{
    int x;
};

void f(float p)
{
    int a[20], b[20];
    int x;
    x = a < b;  /*works*/
    x = a == b; /* doesn't work, should work*/
    x = a != b; /* doesn't work, should work*/
}

int main()
{
    struct b q[20];
    int k;
    k = q->x;
    f(k);
}

/* Sent by Molina*/
int g (){
    int x;
    int **a;
    int *b[2];
    if (a==b){
        x = 1;
    }
    else {
        x =2;
    }
    return 0;
    }
