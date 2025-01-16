/****************CREATION DE LA TABLE DES SYMBOLES ******************/
/***Step 1: Definition des structures de données ***/
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <math.h>

typedef struct element *Liste;
typedef struct element
{
    // int state;
    char name[20];
    char code[20];
    char type[20];
    float val;
    Liste svt;
} element;

typedef struct elt *ListeSM;
typedef struct elt
{
    // int state;
    char name[20];
    char type[20];
    ListeSM svt;
} elt;

// element tab[1000];
// elt tabs[40],tabm[40];
// extern char sav[20];
Liste T = NULL;
extern Liste Pile;
Liste P = NULL;
element e1;
ListeSM TS = NULL;
ListeSM PS = NULL;
ListeSM TM = NULL;
ListeSM PM = NULL;
elt e2;

int tmp = 0;

/***Step 2: initialisation de l'état des cases des tables des symbloles***/
/*0: la case est libre    1: la case est occupée*/

void ajouter_tete(Liste *T, element e)
{

    Liste nouv = NULL;
    nouv = (Liste)malloc(sizeof(element));
    if (nouv == NULL)
    {
        printf("error");
        exit(1);
    }
    strcpy(nouv->name, e.name);
    strcpy(nouv->code, e.code);
    strcpy(nouv->type, e.type);
    (nouv->val) = e.val;
    nouv->svt = *T;
    *T = nouv;
}

void ajouter_teteSM(ListeSM *T, elt e)
{

    ListeSM nouv = NULL;
    nouv = (ListeSM)malloc(sizeof(elt));
    if (nouv == NULL)
    {
        printf("error");
        exit(1);
    }
    strcpy(nouv->name, e.name);
    strcpy(nouv->type, e.type);
    nouv->svt = *T;
    *T = nouv;
}

void ajouter_apres(Liste *P, element e)
{

    Liste nouv = NULL;
    nouv = (Liste)malloc(sizeof(element));
    if (nouv == NULL)
    {
        printf("error");
        exit(1);
    }
    strcpy(nouv->name, e.name);
    strcpy(nouv->code, e.code);
    strcpy(nouv->type, e.type);
    (nouv->val) = e.val;
    nouv->svt = (*P)->svt;
    (*P)->svt = nouv;
    *P = nouv;
}

void ajouter_apresSM(ListeSM *P, elt e)
{

    ListeSM nouv = NULL;
    nouv = (ListeSM)malloc(sizeof(elt));
    if (nouv == NULL)
    {
        printf("error");
        exit(1);
    }
    strcpy(nouv->name, e.name);
    strcpy(nouv->type, e.type);
    nouv->svt = (*P)->svt;
    (*P)->svt = nouv;
    *P = nouv;
}

/***Step 3: insertion des entititées lexicales dans les tables des symboles ***/

void inserer(char entite[], char code[], char type[], float val, int y)
{
    switch (y)
    {
    case 0: /*insertion dans la table des IDF et CONST*/
        strcpy(e1.name, entite);
        strcpy(e1.code, code);
        strcpy(e1.type, type);
        e1.val = NAN;
        if (T == NULL)
        {
            ajouter_tete(&T, e1);
            P = T;
        }
        else
            ajouter_apres(&P, e1);
        break;

    case 1: /*insertion dans la table des mots clés*/
        strcpy(e2.name, entite);
        strcpy(e2.type, code);
        if (TM == NULL)
        {
            ajouter_teteSM(&TM, e2);
            PM = TM;
        }
        else
            ajouter_apresSM(&PM, e2);
        break;

    case 2: /*insertion dans la table des séparateurs*/
        strcpy(e2.name, entite);
        strcpy(e2.type, code);
        if (TS == NULL)
        {
            ajouter_teteSM(&TS, e2);
            PS = TS;
        }
        else
            ajouter_apresSM(&PS, e2);
        break;
    }
}

void destroy_L(Liste *T)
{

    Liste P;
    while (*T != NULL)
    {
        P = *T;
        *T = (*T)->svt;
        free(P);
    }
}

void destroy_LSM(ListeSM *T)
{

    ListeSM P;
    while (*T != NULL)
    {
        P = *T;
        *T = (*T)->svt;
        free(P);
    }
}

Liste get_idf(char entite[])
{
    Liste Z = T;
    while ((Z != NULL) && (strcmp(Z->name, entite) != 0))
    {
        Z = Z->svt;
    }

    return Z;
}

float get_valeur(char entite[])
{
    Liste Z;
    Z = get_idf(entite);

    // Check if Z exists and has a value
    if (Z != NULL)
    {
        if (!isnan(Z->val))
        {                  // isnan returns non-zero if value IS NaN
            return Z->val; // Return value if it's not NaN
        }
    }
    return NAN; 
}

/***Step 4: La fonction Rechercher permet de verifier  si l'entité existe dèja dans la table des symboles */
void rechercher(char entite[], char code[], char type[], float val, int y)
{
    switch (y)
    {
    case 0:
    { /* Verify if the identifier/constant exists in the table */
        Liste Z = T;
        while ((Z != NULL) && (strcmp(entite, Z->name) != 0))
            Z = Z->svt;
        if (Z == NULL)
            inserer(entite, code, type, val, 0);
        // else printf("entité existe déjà\n");
        break;
    }
    case 1:
    { /* Verify if the keyword exists in the table */
        ListeSM ZM = TM;
        while ((ZM != NULL) && (strcmp(entite, ZM->name) != 0))
            ZM = ZM->svt;
        if (ZM == NULL)
            inserer(entite, code, type, val, 1);
        // else printf("entité existe déjà\n");
        break;
    }
    case 2:
    { /* Verify if the separator exists in the table */
        ListeSM ZS = TS;
        while ((ZS != NULL) && (strcmp(entite, ZS->name) != 0))
            ZS = ZS->svt;
        if (ZS == NULL)
            inserer(entite, code, type, val, 2);
        // else printf("entité existe déjà\n");
        break;
    }
    }
}

bool look_up_idf(char entite[])
{
    Liste Z = get_idf(entite);

    bool hasType = strcmp(Z->type, "") != 0;
    if (Z != NULL && hasType == 1)
    {
        return true;
    }
    else
    {
        return false;
    }
}

void Insert_Type(char entite[], char Type[])
{
    Liste Z = get_idf(entite);
    strcpy(Z->type, Type);
}

int isPrimitiveFunction(char funcName[])
{
    if (strcmp(funcName, "readln") == 0)
    {
        return 1;
    }
    else if (strcmp(funcName, "writeln") == 0)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

int Aff_valide(float V, char entite[])
{

    Liste Z = get_idf(entite);

    if (Z == NULL)
        return 1;

    bool isConstINT = (strcmp(Z->type, "CONST INTEGER") == 0);
    bool isConstFLOAT = (strcmp(Z->type, "CONST FLOAT") == 0);
    bool INAN = (isnan(Z->val) == 1);

    if ((isConstINT || isConstFLOAT) && (!INAN))
    {
        return 0;
    }
    else
    {
        Z->val = V;
        return 1;
    }
}

int get_idf_type(char entite[])
{
    Liste Z = get_idf(entite);
    if (Z == NULL)
        return 0;

    if (strcmp(Z->type, "CONST") == 0)
    {
        return -1;
    }

    if ((strcmp(Z->type, "CONST INTEGER") == 0) || (strcmp(Z->type, "INTEGER") == 0))
    {
        return 1;
    }

    if ((strcmp(Z->type, "CONST FLOAT") == 0) || (strcmp(Z->type, "FLOAT") == 0))
    {
        return 2;
    }
}

/***Step 5 L'affichage du contenue de la table des symboles ***/

void afficher()
{
    int i;

    printf("/***************Table des symboles IDF*************/\n");
    printf("____________________________________________________________________\n");
    printf("\t| Nom_Entite |  Code_Entite | Type_Entite | Val_Entite\n");
    printf("____________________________________________________________________\n");

    Liste Z = T;
    while (Z != NULL)
    {
        if (isnan(Z->val) == 0)
            printf("\t|%10s |%15s | %12s | %12f\n", Z->name, Z->code, Z->type, Z->val);
        else
            printf("\t|%10s |%15s | %12s | Not Assigned\n", Z->name, Z->code, Z->type);
        Z = Z->svt;
    }

    printf("\n/***************Table des symboles mots cles*************/\n");

    printf("_____________________________________\n");
    printf("\t| NomEntite |  CodeEntite | \n");
    printf("_____________________________________\n");

    /*for(i=0;i<40;i++)
        if(tabm[i].state==1)
          {
            printf("\t|%10s |%12s | \n",tabm[i].name, tabm[i].type);

          }
    */

    ListeSM ZM = TM;
    while (ZM != NULL)
    {
        printf("\t|%10s |%15s |\n", ZM->name, ZM->type);
        ZM = ZM->svt;
    }

    printf("\n/***************Table des symboles separateurs*************/\n");

    printf("_____________________________________\n");
    printf("\t| NomEntite |  CodeEntite | \n");
    printf("_____________________________________\n");

    ListeSM ZS = TS;
    while (ZS != NULL)
    {
        printf("\t|%10s |%15s |\n", ZS->name, ZS->type);
        ZS = ZS->svt;
    }
}

typedef struct qdr
{

    char oper[100];
    char op1[100];
    char op2[100];
    char res[100];

} qdr;
qdr quad[1000];
extern int qc;

void quadr(char opr[], char op1[], char op2[], char res[])
{

    strcpy(quad[qc].oper, opr);
    strcpy(quad[qc].op1, op1);
    strcpy(quad[qc].op2, op2);
    strcpy(quad[qc].res, res);

    qc++;
}

void ajour_quad(int num_quad, int colon_quad, char val[])
{
    if (colon_quad == 0)
        strcpy(quad[num_quad].oper, val);
    else if (colon_quad == 1)
        strcpy(quad[num_quad].op1, val);
    else if (colon_quad == 2)
        strcpy(quad[num_quad].op2, val);
    else if (colon_quad == 3)
        strcpy(quad[num_quad].res, val);
}

void afficher_qdr()
{
    printf("*********************Les Quadruplets***********************\n");

    int i;

    for (i = 0; i < qc; i++)
    {

        printf("\n %d - ( %s  ,  %s  ,  %s  ,  %s )", i, quad[i].oper, quad[i].op1, quad[i].op2, quad[i].res);
        printf("\n--------------------------------------------------------\n");
    }
}

void empiler(Liste *Pile, char nom[], char type[], float val)
{

    strcpy(e1.name, nom);
    strcpy(e1.type, type);
    if (!isnan(val))
        e1.val = val;
    ajouter_tete(Pile, e1);
}

void depiler(Liste *Pile, element *e)
{

    Liste P = (*Pile);
    (*Pile) = (*Pile)->svt;
    strcpy((*e).name, P->name);
    strcpy((*e).type, P->type);
    if (!isnan(P->val))
        (*e).val = P->val;
    free(P);
}

char *Creer_Tmp()
{
    tmp++;
    // printf("Tmp = %d\n",tmp);
    char ch[100];
    sprintf(ch, "%d", tmp);
    // printf("%s\n",ch);
    char *ch2 = strdup("Res");
    // printf("%s\n",ch2);
    return strcat(ch2, ch);
}

int type_number(char type[])
{

    if ((strcmp(type, "INTEGER") == 0) || (strcmp(type, "CONST INTRGER")) == 0)
        return 1;
    if ((strcmp(type, "FLOAT") == 0) || (strcmp(type, "CONST FLOAT")) == 0)
        return 2;
    return 0;
}

char *get_ops_comp(int num_qc)
{

    // printf("\n%s\n",quad[num_qc].oper);
    if (strcmp(quad[num_qc].oper, "BL") == 0)
        return "BGE";
    if (strcmp(quad[num_qc].oper, "BG") == 0)
        return "BLE";
    if (strcmp(quad[num_qc].oper, "BE") == 0)
        return "BNE";
    if (strcmp(quad[num_qc].oper, "BNE") == 0)
        return "BE";
    if (strcmp(quad[num_qc].oper, "BLE") == 0)
        return "BG";
    if (strcmp(quad[num_qc].oper, "BGE") == 0)
        return "BL";
    return "error";
}

void ET_LOG(int Qc, int cpt, int c, char tmp[])
{

    switch (c)
    {
    case 0:
        for (int i = 1; i <= cpt; i++)
        {
            char *op = get_ops_comp(Qc - i);
            ajour_quad(Qc - i, 0, op);
        }
        break;
    case 1:
        for (int i = 1; i <= cpt; i++)
        {
            // char *op = get_ops_comp(qc-i);
            ajour_quad(Qc - i, 1, tmp);
        }
        break;
    }
}

void OU_LOG(int Qc, int cpt)
{

    char ch[10] = {0};
    sprintf(ch, "%d", Qc);
    for (int i = 2; i <= cpt; i++)
    {
        // char *op = get_ops_comp(qc-i);
        ajour_quad(Qc - i, 1, ch);
    }
}

void WHILE(int Qc, int cpt, int c, char tmp[])
{

    switch (c)
    {
    case 0:
        for (int i = 0; i < cpt; i++)
        {
            char *op = get_ops_comp(Qc + i);
            ajour_quad(Qc + i, 0, op);
        }
        break;
    case 1:
        for (int i = 0; i < cpt; i++)
        {
            // char *op = get_ops_comp(qc-i);
            ajour_quad(Qc + i, 1, tmp);
        }
        break;
    }
}