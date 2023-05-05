
struct test{
    int s1;
    int s2;
};

void main()
{
    int s1, l1, d1, num;
    int num_arr[70];
    struct test *t1;


    printf("Enter lower limit");
    scanf("%d",&s1);
    printf("Enter upper limit");
    scanf("%d",&l1);

    printf("Enter divisor: ");
    scanf("%d",&d1);

    num = (l1-s1)/d1;
    printf("\n--\n%d number(s) are divisible by %d in the range: %d to %d", num, d1, s1, l1);

    for(i=69; i>=0; i=i-1)
    {
        num_arr[i] = num/(i+1);
        t1->s1 = i;
        t1->s2 = num_arr[i];
    }
    
}
