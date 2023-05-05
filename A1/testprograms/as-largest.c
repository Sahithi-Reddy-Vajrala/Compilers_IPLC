
int main() {
  int n;
  float arr[100];
  i = printf("Enter the number of elements (1 to 100): ");
  j = scanf("%d", &n);

  for (i = 0; i < n; i = i + 1) {
    i = printf("Enter number%d: ", i + 1);
    i = scanf("%lf", arr[i]);
  }

  
  for (i = 1; i < n; i = i + 1) {
    if (arr[0] < arr[i]) {
      arr[0] = arr[i];
    }
    else ;
  }

  printf("Largest element = %.2lf", arr[0]);

  return 0;
}
