
int main() {
    int num, originalNum, remainder, result;
    printf("Enter a three-digit integer");
    /*scanf("%d", &num);*/
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
        printf("%d is an Armstrong number.", num);
    else
        printf("%d is not an Armstrong number.", num);

    return 0;
}
