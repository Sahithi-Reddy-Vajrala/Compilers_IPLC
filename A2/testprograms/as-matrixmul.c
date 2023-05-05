
int main()
{
    int a[3][3], b[3][3], c[3][3];
    int i, j, k;
    printf("Enter first array elements");
    for (i = 0; i < 3; i = i + 1)
    {
        for (j = 0; j < 3; j = j + 1)
        {
            scanf("%d", &a[i][j]);
            c[i][j] = 0;
        }
    }
    printf("Enter second array elements");
    for (i = 0; i < 3; i = i + 1)
    {
        for (j = 0; j < 3; j = j + 1)
        {
            scanf("%d", &b[i][j]);
        }
    }
    for (i = 0; i < 3; i = i + 1)
    {
        for (j = 0; j < 3; j = j + 1)
        {
            for (k = 0; k < 3; k = k + 1)
            {
                c[i][j] = c[i][j] + (a[i][k] * b[k][j]);
            }
        }
    }
    for (i = 0; i < 3; i = i + 1)
    {
        for (j = 0; j < 3; j = j + 1)
        {
            printf("%d ", c[i][j]);
        }
        printf("\n");
    }
    return 0;
}
