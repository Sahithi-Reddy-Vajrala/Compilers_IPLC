int main(){
   /* 2D array declaration*/
   int disp[2][3];
   /*Counter variables for the loop*/
   int i, j;
   for(i=0; i<2; i=i+1) {
      for(j=0;j<3;j=j+1) {
         printf("Enter value for disp[%d][%d]:", i, j);
         scanf("%d", &disp[i][j]);
      }
   }
   /* Displaying array elements */
   printf("Two Dimensional array elements:\n");
   for(i=0; i<2; i=i+1) {
      for(j=0;j<3;j=j+1) {
         printf("%d ", &disp[i][j]);
         if(j==2){
	   printf("\n");
         }
	 else ;
      }
   }
   return 0;
}
