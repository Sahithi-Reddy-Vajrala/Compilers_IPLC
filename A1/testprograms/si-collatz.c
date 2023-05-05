struct int_vector {
    int vector[100];
    int curr;
};

int is_even(int n){
    if (n / 2 == n / 2.0) return 1;
    else return 0;
}

int next_term(int n){
    if (is_even(n)) {
        return n/2;
    }
    else return 3 * n + 1;
}

struct int_vector collatz(int n) {
    struct int_vector seq;
    int term;

    seq.curr = 0;
    
    for (term = n; term != 1; term = next_term(term)) {
        seq.vector[seq.curr] = term;
        seq.curr = seq.cur + 1;
    }
    
    seq.vector[seq.curr] = term;
    seq.curr = seq.curr + 1;

    return seq;
}

int main(int argc) {
    int n;
    struct int_vector collatz_seq;
    int i;

    printf("Enter a number ");
    scanf("%d", n);
    collatz_seq = collatz(n);
    
    for(i = 0; i < collatz_seq.curr; i=i+1){
        printf("%d\n", collatz_seq.vector[i]);
    }

    return 0;
}

