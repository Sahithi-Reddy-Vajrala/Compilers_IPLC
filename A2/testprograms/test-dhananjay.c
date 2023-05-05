int main()
{
    int *a, *b;
    float c;
    int d;
    d = -c;
    a = 0; /* No error */
    a = 1; /* Gives error, expected behaviour*/
    a = a < b;  /* Gives error now */
    c = !a; 
    c = -a; /*Gives error*/
}