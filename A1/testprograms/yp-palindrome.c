int main() {
    int n, reversed, remainder, original;
    reversed = 0;
    n = 123321;
    original = n;
    while (n != 0) {
        remainder = mod(n, 10);
        reversed = reversed * 10 + remainder;
        n = n / 10;
    }
    if (original == reversed)
        printf("%d is a palindrome.", original);
    else
        printf("%d is not a palindrome.", original);

    return 0;
}
