%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <math.h>

  #define DOUBLE_DECLARATION 0
  #define NON_DECLARE 1
  #define COMPATIBILITY 2
  #define CONSTANT_AFFECTATION 3
  #define TABLE_SIZE_INVALID 4
  #define FONCTION_NOT_EXIST 5
  #define DIVISION_PAR_ZERO 6

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

  typedef struct Controle_Pile
  {
    //int tab[20];
    int position;
    int cpt;
    int flag;
  }Controle_Pile;

  
  int yylex();
  int yyerror(char *msg);
  void afficher();
  void afficher_qdr();
  void Insert_Type(char entite[],char Type[]);
  int look_up_idf(char entite[]);
  int Aff_valide(float V, char entite[]);
  float get_valeur(char entite[]);
  int  isPrimitiveFunction(char funcName[]);
  int get_idf_type(char entite[]);
  Liste get_idf(char entite[]);
  int semantiqueError(int code,char*msg);
  void empiler(Liste *Pile,char nom[],char type[],float val);
  void depiler(Liste *Pile,element *e);
  void quadr(char opr[],char op1[],char op2[],char res[]);
  int type_number(char type[]);
  char* Creer_Tmp();
  void ajour_quad(int num_quad, int colon_quad, char val []);
  char* get_ops_comp(int num_qc);
  void ET_LOG(int Qc,int cpt,int c,char tmp[]);
  void OU_LOG(int Qc,int cpt);
  void WHILE(int Qc,int cpt,int c,char tmp[]);

  int nb_ligne = 1;
  int col =1;
  int qc = 0;
  int aff_flag = 0;
  
  int compatibility=0; //
  char sauv_type[20]={0};
  double sauv_valeur=NAN; //
  element e;
  Liste Pile = NULL;
  char comp[5]={0};
  int fin_if,deb_else;
  int ET_cpt=0;
  int OU_cpt=0;
  Controle_Pile if_pile[20];
  Controle_Pile while_pile[20];
  Controle_Pile for_pile[20];
  int fin_pile[20];
  int sommet_if=-1;
  int sommet_while=-1;
  int sommet_for=-1;
  int sommet_fin=-1;
%}

%union{int entier;
       float reel;
       char* str;
       }

%token <str>mc_prog <str>mc_var <str>mc_entier <str>mc_reel <str>mc_const <str>mc_beg <str>mc_if <str>mc_else <str>mc_for <str>mc_while <str>mc_end 
%token <str>idf <entier>entier <reel>reel <str> string
%token <str>ac_open <str>ac_close <str>crochet_open <str>crochet_close <str>pr_open <str>pr_close
%token <str>sup_eg <str>inf_eg <str>eg <str>inf <str>sup
%token <str>addition <str>sustraction <str>mult <str>division
%token <str>et_logique <str>ou_logique <str>negation 
%token <str>verg <str>pvg <str>deux_points <str>aff err 

%left ou_logique
%left et_logique
%left eg neg sup_eg inf_eg sup inf
%left addition sustraction
%left mult division
%nonassoc negation

%%
S:TITLE HEADER BODY
{
printf("\nSyntaxe Correcte \n"); 
YYACCEPT;
exit(0);
};

/*Global*/

TITLE : mc_prog idf

HEADER: mc_var ac_open DEC ac_close

BODY: mc_beg LIST_I mc_end





/*Header*/

DEC:TYPED LISTIDF pvg DEC | ;


TYPED:mc_const {strcpy(sauv_type,$1);}| 
      mc_entier {strcpy(sauv_type,$1);}|
      mc_reel {strcpy(sauv_type,$1);};


AFF_DEC: idf aff entier {
if(!look_up_idf($1)) {
  if(strcmp(sauv_type,"CONST")==0) {
    strcat(sauv_type," INTEGER");
    Insert_Type($1,sauv_type);
    strcpy(sauv_type,"CONST");

  } else  {
      Insert_Type($1,sauv_type);


    if(get_idf_type($1)!=1) {
      semantiqueError(
        COMPATIBILITY,
  "FLOAT <- INTEGER"
        
      );
    }
  }

  Aff_valide($3,$1);
  char ent[10]={0};
  sprintf(ent,"%d",$3);
  quadr("=",ent,"",$1);
  sauv_valeur = NAN;


} else {
  semantiqueError(DOUBLE_DECLARATION,$1);
}
} | idf aff reel {
if(!look_up_idf($1)) {
  if(strcmp(sauv_type,"CONST")==0) {
    strcat(sauv_type," FLOAT");
      Insert_Type($1,sauv_type);
      strcpy(sauv_type,"CONST");

  } else {
      Insert_Type($1,sauv_type);


    if(get_idf_type($1)!=2) {
      semantiqueError(
        COMPATIBILITY,
  "INTEGER <- FLOAT" 
        
      );
    }
  }

  Aff_valide($3,$1);
  char ent[10]={0};
  sprintf(ent,"%f",$3);
  quadr("=",ent,"",$1);
  sauv_valeur = NAN;


} else {
  semantiqueError(DOUBLE_DECLARATION,$1);
}


};


LISTIDF:LISTIDF verg idf {
          if(!look_up_idf($3)) Insert_Type($3,sauv_type);
          else {semantiqueError(DOUBLE_DECLARATION,$3);
          }
        } | 
        LISTIDF verg TABLEAU | 
        
        idf {
          if(!look_up_idf($1)) Insert_Type($1,sauv_type);
          else {semantiqueError(DOUBLE_DECLARATION,$1);}
        } |
        TABLEAU | 
        LISTIDF verg AFF_DEC |
        AFF_DEC;

TABLEAU:idf crochet_open entier crochet_close {
          if(!look_up_idf($1)) Insert_Type($1,sauv_type);
          else semantiqueError(DOUBLE_DECLARATION,$1);

          if($3<=0) semantiqueError(TABLE_SIZE_INVALID,$1);
        }
;

 

AFF:  idf aff EXPRESSION{
      if(!look_up_idf($1)){
        semantiqueError(NON_DECLARE,$1);
      }
      else{
        //printf("AFF\n");
        element res;
        depiler(&Pile,&res);
        //printf("\n%d",get_idf_type($1));
        if((get_idf_type($1)!=-1) && (get_idf_type($1)!=type_number(res.type))) semantiqueError(COMPATIBILITY,
                                                                   get_idf_type($1) == 2 ? "FLOAT <- INTEGER" : "INTEGER <- FLOAT");
        if(get_idf_type($1)==-1){
          //printf("\n%s",res.type);
          strcpy(sauv_type,"CONST");
          if(type_number(res.type)==2) strcat(sauv_type," FLOAT");
          else strcat(sauv_type," INTEGER");
          Insert_Type($1,sauv_type);
          strcpy(sauv_type,"");
        }
        if(!Aff_valide(res.val,$1)) semantiqueError(CONSTANT_AFFECTATION,$1);
        quadr("=",res.name,"",$1);
      }
};


IDF_TAB: idf crochet_open EXPRESSION crochet_close;




/*Body*/
LIST_I:LISTINSTRUCTION | /*vide*/;


LISTINSTRUCTION: INSTRUCTION LISTINSTRUCTION
               | INSTRUCTION



INSTRUCTION: SEMI_INSTRUCTION {/*ET_cpt = 0; OU_cpt = 0;*/}
           | CONTROL_INSTRUCTION;

SEMI_INSTRUCTION: EXPRESSION pvg {ET_cpt = 0; OU_cpt = 0;}| AFF pvg | FONCTION_CALL pvg;
CONTROL_INSTRUCTION: IF
                   | WHILE
                   | FOR;  

EXPRESSION: EXPRESSION ou_logique ET_LOGIQUE {
            /*char tmp[10];
            sprintf(tmp,"%d",qc);
            ajour_quad(qc-2, 1, tmp);
            char *ch = get_ops_comp(qc-1);
            ajour_quad(qc-1, 0, ch);*/
            OU_cpt++;
}|
            ET_LOGIQUE;
ET_LOGIQUE: ET_LOGIQUE et_logique COMPAR {
            /*ET_LOG++;
            char *ch = get_ops_comp(qc-2);
            ajour_quad(qc-2, 0, ch);
            ch = get_ops_comp(qc-1);
            ajour_quad(qc-1, 0, ch);*/
            //printf("\nET\n");
            ET_cpt++;
}|
            COMPAR;
COMPAR: COMPAR COMP NEGATION {
        element operande2;
        element operande1;
        depiler(&Pile,&operande2);
        //printf("\n%s %s %f\n",operande2.name,operande2.type,operande2.val);
        depiler(&Pile,&operande1);
        //printf("\n%s %s %f\n",operande1.name,operande1.type,operande1.val);
        if(type_number(operande1.type)==type_number(operande2.type)){
          //printf("avant qc=%d\n",qc);
          //char *tmp = Creer_Tmp();
          quadr(comp,"",operande1.name,operande2.name);

          //printf("apres qc=%d\n",qc);
          //empiler(&Pile,tmp,operande1.type,operande1.val+operande2.val);
       }
}|
        NEGATION;
NEGATION: negation ARTHEXP |
          ARTHEXP{
            //depiler(&Pile,&e);
            //empiler(&Pile,e.name,e.type,e.val);
          };

ARTHEXP: ARTHEXP addition MULT {
         //printf("routine 7\n");
         element operande2;
         element operande1;
         depiler(&Pile,&operande2);
         //printf("\n%s %s %f\n",operande2.name,operande2.type,operande2.val);
         depiler(&Pile,&operande1);
         //printf("\n%s %s %f\n",operande1.name,operande1.type,operande1.val);
         if(type_number(operande1.type)==type_number(operande2.type)){
           //printf("avant qc=%d\n",qc);
           char *tmp = Creer_Tmp();
           quadr("+",operande1.name,operande2.name,tmp);
           //printf("apres qc=%d\n",qc);
           empiler(&Pile,tmp,operande1.type,operande1.val+operande2.val);
         }
         else semantiqueError(COMPATIBILITY,"FLOAT + INTEGER");
      }| ARTHEXP sustraction MULT {
         //printf("routine 6\n");
         element operande2;
         element operande1;
         depiler(&Pile,&operande2);
         //printf("\n%s %s %f\n",operande2.name,operande2.type,operande2.val);
         depiler(&Pile,&operande1);
         //printf("\n%s %s %f\n",operande1.name,operande1.type,operande1.val);
         if(type_number(operande1.type)==type_number(operande2.type)){
           //printf("avant qc=%d\n",qc);
           char *tmp = Creer_Tmp();
           quadr("-",operande1.name,operande2.name,tmp);
           //printf("avant qc=%d\n",qc);
           empiler(&Pile,tmp,operande1.type,operande1.val-operande2.val);
         }
         else semantiqueError(COMPATIBILITY,"FLOAT - INTEGER");
          
      }| MULT{
         //printf("routine 5\n");
         //depiler(&Pile,&e);
         //empiler(&Pile,e.name,e.type,e.val);
      };
MULT: MULT mult OPERAND {
      //printf("routine 4\n");
      element operande2;
      element operande1;
      depiler(&Pile,&operande2);
      //printf("\n%s %s %f\n",operande2.name,operande2.type,operande2.val);
      depiler(&Pile,&operande1);
      //printf("\n%s %s %f\n",operande1.name,operande1.type,operande1.val);
      if(type_number(operande1.type)==type_number(operande2.type)){
        //printf("avant qc=%d\n",qc);
        char *tmp = Creer_Tmp();
        quadr("*",operande1.name,operande2.name,tmp);
        //printf("apres qc=%d\n",qc);
        empiler(&Pile,tmp,operande1.type,operande1.val*operande2.val);
      }
      else semantiqueError(COMPATIBILITY,"FLOAT * INTEGER");
   }| MULT division OPERAND {
      //printf("routine 3\n");
      element operande2;
      element operande1;
      //printf("Dans MULT 2\n");
      depiler(&Pile,&operande2);
      //printf("\n\n");
      //afficher_qdr();
      if(operande2.val==0) semantiqueError(DIVISION_PAR_ZERO,"");
      //printf("\n%s %s %f\n",operande2.name,operande2.type,operande2.val);
      depiler(&Pile,&operande1);
      //printf("\n%s %s %f\n",operande1.name,operande1.type,operande1.val);
      if(type_number(operande1.type)==type_number(operande2.type)){
        //printf("avant qc=%d\n",qc);
        char *tmp = Creer_Tmp();
        quadr("/",operande1.name,operande2.name,tmp);
        //printf("apres qc=%d\n",qc);
        empiler(&Pile,tmp,"FLOAT",operande1.val/operande2.val);
      }
      else semantiqueError(COMPATIBILITY,"FLOAT / INTEGER");

   }| OPERAND{
      //printf("routine 2\n");
      //depiler(&Pile,&e);
      //empiler(&Pile,e.name,e.type,e.val);
   };
OPERAND:pr_open EXPRESSION pr_close{
        //depiler(&Pile,&e);
        //empiler(&Pile,e.name,e.type,e.val);
}| 
        idf {
          //printf("routine 1\n");
          if(!look_up_idf($1)) {semantiqueError(NON_DECLARE,$1);}
          else {
            Liste temp = get_idf($1);
            //printf("%s %s %f\n",temp->name,temp->type,temp->val);
            //if(Pile == NULL) printf("Pile est vide\n");
            empiler(&Pile,temp->name,temp->type,temp->val);
            //if(Pile != NULL) printf("Pile n'est pas vide\n");
          }
         }| 
        entier {
          char ch[10];
          sprintf(ch,"%d",$1);
          empiler(&Pile,ch,"INTEGER",$1); 
        }| 
        reel{
          char ch[10];
          sprintf(ch,"%f",$1);
          empiler(&Pile,ch,"FLOAT",$1);
        }|
        IDF_TAB ;

COMP:eg {strcpy(comp,"BE");}|
     neg {strcpy(comp,"BNE");}|
     sup_eg {strcpy(comp,"BGE");}|
     inf_eg {strcpy(comp,"BLE");}|
     sup {strcpy(comp,"BG");}|
     inf {strcpy(comp,"BL");};



BLOC: ac_open LIST_I ac_close



IF: A ELSE;
A: B BLOC {
  sommet_fin++;
  fin_pile[sommet_fin] = qc;
  quadr("BR","","","");
  char tmp[10];
  sprintf(tmp,"%d",qc);
  //printf("\nif_pile[%d].cpt:%d\n",sommet_if,if_pile[sommet_if].cpt);
  if(if_pile[sommet_if].flag){
    //printf("\nET2:%d\n",ET_cpt);
    ET_LOG(if_pile[sommet_if].position,
           if_pile[sommet_if].cpt,
           1,
           tmp);
    //if_pile[sommet_if].cpt = 0;
  }else{
      ajour_quad(if_pile[sommet_if].position-1, 1, tmp);
      OU_LOG(if_pile[sommet_if].position,if_pile[sommet_if].cpt);
      //OU_cpt = 0;
  }

  sommet_if--;

  /*ajour_quad(deb_else, 1, tmp);
  if(ET_LOG) {
    ajour_quad(deb_else-1, 1, tmp);
    ET_LOG = 0;
  }*/
}
B: mc_if pr_open EXPRESSION pr_close {
  sommet_if++;
  if_pile[sommet_if].position = qc;
  //printf("\nET:%d\n",ET_cpt);
  if(ET_cpt){
    if_pile[sommet_if].cpt = ET_cpt+1;
    if_pile[sommet_if].flag = 1;
    ET_LOG(if_pile[sommet_if].position,
           if_pile[sommet_if].cpt,
           0,
           "");
    ET_cpt = 0;
  }else{
    if(OU_cpt || (sommet_if >= 0)){
      if_pile[sommet_if].cpt = OU_cpt+1;
      if_pile[sommet_if].flag = 0;
      char *ch = get_ops_comp(qc-1);
      ajour_quad(qc-1, 0, ch);
      OU_cpt = 0;
    }else{
      if_pile[sommet_if].cpt = ET_cpt+1;
      ET_LOG(if_pile[sommet_if].position,
             if_pile[sommet_if].cpt,
             0,
             "");
    }
  }
  //afficher_qdr();
}

ELSE: mc_else BLOC {
  char tmp[10];
  sprintf(tmp,"%d",qc);
  ajour_quad(fin_pile[sommet_fin], 1, tmp);
  sommet_fin--;
}| /*vide*/ {
  qc--;
  sommet_fin--;
  char tmp[10];
  sprintf(tmp,"%d",qc);
  printf("\nFIN_PILE:%d\n",fin_pile[sommet_fin]);
  if(sommet_fin >= 0) ajour_quad(fin_pile[sommet_fin], 1, tmp);
  ET_LOG(if_pile[sommet_if+1].position,
         if_pile[sommet_if+1].cpt,
         1,
         tmp);
};
////
WHILE: WA BLOC{
  char tmp[10];
  sprintf(tmp,"%d",while_pile[sommet_while].position);
  quadr("BR",tmp,"","");
  sprintf(tmp,"%d",qc);
  if(while_pile[sommet_while].flag){
    //printf("\nET2:%d\n",ET_cpt);
    WHILE(while_pile[sommet_while].position,
           while_pile[sommet_while].cpt,
           1,
           tmp);
    while_pile[sommet_while].cpt = 0;
  }else{
    ajour_quad(while_pile[sommet_while].position+while_pile[sommet_while].cpt-1, 1, tmp);
    //OU_LOG(if_pile[sommet_if],OU_cpt);
    OU_cpt = 0;
  }
  sommet_while--;
};
WA: WB pr_open EXPRESSION pr_close{
  if(ET_cpt){
    while_pile[sommet_while].cpt = ET_cpt+1;
    while_pile[sommet_while].flag = 1;
    WHILE(while_pile[sommet_while].position,
           while_pile[sommet_while].cpt,
           0,
           "");
    ET_cpt = 0;
  }else{
    if(OU_cpt || (sommet_while >= 0)){
      while_pile[sommet_while].cpt = OU_cpt+1;
      while_pile[sommet_while].flag = 0;
      char *ch = get_ops_comp(qc-1);
      ajour_quad(qc-1, 0, ch);
      OU_cpt = 0;
      OU_LOG(qc,while_pile[sommet_while].cpt);
    }else{
      if_pile[sommet_if].cpt = ET_cpt+1;
      WHILE(if_pile[sommet_if].position,
             if_pile[sommet_if].cpt,
             0,
             "");
    }
  }
};
WB: mc_while {
  sommet_while++;
  while_pile[sommet_while].position = qc;
}
////


COND_FOR:idf deux_points EXPRESSION deux_points EXPRESSION deux_points EXPRESSION {
  if(!look_up_idf($1)) {
  semantiqueError(NON_DECLARE,$1);
  }

};

FOR: mc_for pr_open COND_FOR pr_close BLOC 


FONCTION_CALL: idf pr_open LISTARG pr_close {
  if(!isPrimitiveFunction($1)) {
    semantiqueError(FONCTION_NOT_EXIST,$1);
  }
}

LISTARG: ARGUMENT LISTARG | ARGUMENT;

ARGUMENT: string;


%%
int main(){
  yyparse();
  afficher();
  afficher_qdr();
  return 0;
}
int yywrap(){
  return 1;
}
int yyerror(char *msg){
  printf("\n\n%s line %d column %d\n",msg,nb_ligne,col);
  exit(1);
  return 1;
}



int semantiqueError(int code,char*msg){
  switch(code){
    case DOUBLE_DECLARATION:/*double declaration*/
    printf("\n\nErreur Sementique ligne %d column %d : double declaration de IDF %s\n",nb_ligne,col,msg);
      break;

    case NON_DECLARE: /*variable non declare*/
    printf("\n\nErreur semantique ligne %d column %d: IDF %s non declare\n",nb_ligne,col,msg);

    break;

    case COMPATIBILITY:/* Compatibility Error*/ 

    printf("\n\nErreur semantique ligne %d column %d: compatibility %s\n",nb_ligne,col,msg);
    break;

    case CONSTANT_AFFECTATION: /*Constant Re-Affectation*/
    printf("\n\nErreur semantique ligne %d column %d: affectation de la constant %s\n",nb_ligne,col,msg);
    break;

    case TABLE_SIZE_INVALID: /*Table Size Invalid*/
    printf("\n\nErreur semantique ligne %d column %d: taille de tableau invalide %s\n",nb_ligne,col,msg);

    break;

    case FONCTION_NOT_EXIST: /*Fonction not exist*/
    printf("\n\nErreur semantique ligne %d column %d: fonction %s n'existe pas\n",nb_ligne,col,msg);

    break;

    case DIVISION_PAR_ZERO:
    printf("\n\nErreur semantique ligne %d column %d: division par une expression egale a zero\n",nb_ligne,col);



  }

  exit(code);

}