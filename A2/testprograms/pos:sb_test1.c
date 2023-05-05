
void main()
{
    int num[20];
    int div, i;
    printf("Give a list of 20 numbers from 100 to 200");
    for(i=0; i<20; i=i+1)
    {
        scanf("%d",&num[i]);
    }

    printf("Give a divisor:\n");
    scanf("%d",&div);

    for(i=0;i<20;i=i+1)
    {
        if(num[i]/div==0)
        {    
            num[i] = 1;
        }
        else
        {
            num[i] = 0;
        }
    }


    for(i=0; i<20; i=i+1)
    {
        printf("Final array: %d", num[i]);
    }
}