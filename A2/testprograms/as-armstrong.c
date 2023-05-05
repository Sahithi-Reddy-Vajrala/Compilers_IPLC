struct person {
   int **id[2][3];
   float weight;
   int age;
};

int mod(int a, int b)
{

}
int main() {
    int num, originalNum, remainder, result;
    int arr [2];
    printf("Enter a three-digit integer");
    scanf("%d", &num);
    result = 0;
    num = 153;
    originalNum = num;

    while (originalNum != 0) {
      /* remainder contains the last digit*/
      remainder = mod(originalNum,10);
       result = result + remainder * remainder * remainder;
        
       /*removing last digit from the orignal number*/
       originalNum = originalNum / 10;
    }

    if (result == num)
        printf("%d is an Armstrong number.",
        num);
    else
        printf("%d is not an Armstrong number.", num);

    return 4.0;
}
