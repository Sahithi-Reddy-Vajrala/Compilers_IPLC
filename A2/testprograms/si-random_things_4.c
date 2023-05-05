struct abc {
    int _qw, qw;
    float __er;
    /*void ntg;*/
};


struct abc init_abc(int *p1, int *p2, float p3) {
    struct abc *ABC;
    ABC -> _qw = *p1 + *p2;
    ABC -> qw = (*p1)++ + (*p2)++;
    ABC -> __er = p3 + .897e-19;

    return *ABC;
}  

int main (int argc) {
    struct abc ABC;
    int *p1, *p2;
    scanf("%d", p1);
    scanf("%d", p2);

    if (*p1 > 5 || *p2 < 5 ) {
        ABC = init_abc(&p1, &p2, -12.80e0);
    }
    else {
        if (*p1 != *p2) {
            ABC = init_abc(&p2, &p1, 12.80e0);
        }
        else {
            *p1 = *p1 + *p2;
        }
    }

    return 0;

}
