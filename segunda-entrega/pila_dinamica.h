#ifndef PILADINAMICA_H_INCLUDED
#define PILADINAMICA_H_INCLUDED
#define PILA_LLENA 0
#define PILA_VACIA 0
#define TODO_BIEN 33

typedef struct s_nodo
{
    int dato;
    struct s_nodo *sig;
}t_nodo;

typedef t_nodo *t_pila;

void crear_pila(t_pila *p) {
    *p=NULL;
}

int apilar(t_pila *p ,const int *d) {
    t_nodo* nuevo;
    nuevo = (t_nodo*)malloc(sizeof(t_nodo));
    if(!nuevo)
        return 0;
    nuevo->dato= *d;
    nuevo->sig= *p;
    *p = nuevo;
    return 1;
}

int pila_vacia(const t_pila *p) {
    return *p == NULL;
}

int pila_llena(const t_pila *p) {
    void *nodo_aux=malloc(sizeof(t_nodo));
    free(nodo_aux);
    return nodo_aux == NULL;
}

int desapilar(t_pila *p, int *d) {
    t_nodo *a;
    if(*p==NULL)
        return PILA_VACIA;
    a = *p;
    *d = a->dato;
    *p = a->sig;
    free(a);
    return TODO_BIEN;
}

void vaciar_pila(t_pila *p) {
    t_nodo* a;
    while(*p)
    {
        a=*p;
        *p=a->sig;
        free(a);
    }
}

int ver_tope(t_pila *p, int *d) {
    if(*p == NULL)
        return PILA_VACIA;
    *d = (*p)->dato;
    return TODO_BIEN;
}

#endif // PILADINAMICA_H_INCLUDED