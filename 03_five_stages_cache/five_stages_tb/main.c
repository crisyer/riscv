void fun(int *x) {
    *x += 10;
    return;
}

int main() {
    int x = 1;
    fun(&x);

    if (x == 11)
    {
        x++;
    }else{
        x--;
    }
    
    return 0;
}