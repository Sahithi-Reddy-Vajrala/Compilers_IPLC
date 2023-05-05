
struct person {
   int id;
   float weight;
   int age;
};

int main()
{
  int n,i;
  struct person *ptr;
  struct person persons[30];
  
  
  printf("Enter the number of persons (<= 30): ");
  scanf("%d", &n);
  ptr = &persons[0];
  /* malloc skipped */
  
  for(i = 0; i < n; i = i + 1)
    {
      printf("Enter person's Id, weight and age respectively: ");
      scanf("%d %f %d", &(ptr+i)->id, &(ptr+i)->weight, &(ptr+i)->age);
    }
  
  printf("Displaying Information:\n");
  for(i = 0; i < n; i=i+1)
    printf("Id: %d\tWeight: %f\tAge: %d\n", (ptr+i)->id, (ptr+i)->weight, (ptr+i)->age);
  
  return 0;




}
