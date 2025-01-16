%{
  #include <stdio.h>
  #include "parser.tab.h"
  #include "ts.h"
  extern YYSTYPE yylval;
  extern int nb_ligne;
  extern int col;
  extern int qc;
%}

lettre [A-Za-z]
chiffre [0-9]
idf {lettre}([a-z]|"_"|{chiffre})*
cst {chiffre}+|"("["+"-]{chiffre}+")"
reel {chiffre}+"."{chiffre}+|"("["+"-]{chiffre}+"."{chiffre}+")"
string \'[^']*\'


%x COMMENT



%%
"PROGRAMME" {yylval.str=strdup(yytext); rechercher(yytext,"Mot cles",0,0,1); col=col + strlen(yytext); printf("%s ",yytext); return mc_prog;}
"VAR"       {yylval.str=strdup(yytext); rechercher(yytext,"Mot cles",0,0,1); col=col + strlen(yytext); printf("%s",yytext); return mc_var;}
"INTEGER"   {yylval.str=strdup(yytext); rechercher(yytext,"Mot cles",0,0,1); col=col + strlen(yytext); printf("%s ",yytext); return mc_entier;}
"FLOAT"     {yylval.str=strdup(yytext); rechercher(yytext,"Mot cles",0,0,1); col=col + strlen(yytext); printf("%s ",yytext); return mc_reel;}
"CONST"     {yylval.str=strdup(yytext); rechercher(yytext,"Mot cles",0,0,1); col=col + strlen(yytext); printf("%s ",yytext); return mc_const;}
"BEGIN"     {yylval.str=strdup(yytext); rechercher(yytext,"Mot cles",0,0,1); col=col + strlen(yytext); printf("%s",yytext); return mc_beg;}
"IF"        {yylval.str=strdup(yytext); rechercher(yytext,"Mot cles",0,0,1); col=col + strlen(yytext); printf("%s",yytext); return mc_if;}
"ELSE"      {yylval.str=strdup(yytext); rechercher(yytext,"Mot cles",0,0,1); col=col + strlen(yytext); printf("%s",yytext); return mc_else;}
"FOR"       {yylval.str=strdup(yytext); rechercher(yytext,"Mot cles",0,0,1); col=col + strlen(yytext); printf("%s",yytext); return mc_for;}
"WHILE"     {yylval.str=strdup(yytext); rechercher(yytext,"Mot cles",0,0,1); col=col + strlen(yytext); printf("%s",yytext); return mc_while;}
"END."      {yylval.str=strdup(yytext); rechercher(yytext,"Mot cles",0,0,1); col=col + strlen(yytext); printf("%s\n",yytext); return mc_end;}

{idf} { if(strlen(yytext) > 7) {
          printf("Erreur Lexical: IDF trop long a la ligne %d a la colonne %d \n ",nb_ligne, col);
          return err;
        }
        yylval.str=strdup(yytext);
        rechercher(yytext,"IDF","",0,0);
        col = col + strlen(yytext);
        printf("%s",yytext);
        return idf;
      }
{cst} { 
  if((atof(yytext) > 32767 ) || (atof(yytext) < -32768)){
          printf("Erreur Lexical: Il faut que la valeur de cst est entre -32768 et 32767 a la ligne %d a la colonne %d \n ",nb_ligne, col);
          return err;
        }
        printf("%s",yytext);

        col = col + strlen(yytext);

  if (yytext[0] == '(' && yytext[strlen(yytext) - 1] == ')') {
        char b[256]; 
        int i, j = 0;
        for (i = 1; i < strlen(yytext) - 1; i++) {
            b[j++] = yytext[i];
        }
        b[j] = '\0';
        yylval.entier = atoi(b);
    } else {
        yylval.entier = atoi(yytext);
    }

        return entier;
      }
{reel} {
        col = col + strlen(yytext);
         printf("%s",yytext);
         if (yytext[0] == '(' && yytext[strlen(yytext) - 1] == ')') {
        char b[256]; 
        int i, j = 0;
        for (i = 1; i < strlen(yytext) - 1; i++) {
            b[j++] = yytext[i];
        }
        b[j] = '\0';
        yylval.reel = atof(b);
        } else {
        yylval.reel = atof(yytext);
        }

        return reel;
       }

{string} { 
        col = col + strlen(yytext);
        printf("%s",yytext);
        yylval.str=strdup(yytext);
        return string;
}
"&&" {yylval.str=strdup(yytext); rechercher(yytext,"Sep",0,0,2); col = col + strlen(yytext); printf("%s",yytext); return et_logique;}
"||" {yylval.str=strdup(yytext); rechercher(yytext,"Sep",0,0,2); col = col + strlen(yytext); printf("%s",yytext); return ou_logique;}
">=" {yylval.str=strdup(yytext); rechercher(yytext,"Sep",0,0,2); col = col + strlen(yytext); printf("%s",yytext); return sup_eg;}
"<=" {yylval.str=strdup(yytext); rechercher(yytext,"Sep",0,0,2); col = col + strlen(yytext); printf("%s",yytext); return inf_eg;}
"==" {yylval.str=strdup(yytext); rechercher(yytext,"Sep",0,0,2); col = col + strlen(yytext); printf("%s",yytext); return eg;}
"!=" {yylval.str=strdup(yytext); rechercher(yytext,"Sep",0,0,2); col = col + strlen(yytext); printf("%s",yytext); return neg;}
">" {yylval.str=strdup(yytext); rechercher(yytext,"Sep",0,0,2); col = col + strlen(yytext); printf("%s",yytext); return sup;}
"<" {yylval.str=strdup(yytext); rechercher(yytext,"Sep",0,0,2); col = col + strlen(yytext); printf("%s",yytext); return inf;}
"!" {yylval.str=strdup(yytext); rechercher(yytext,"Sep",0,0,2); col = col + strlen(yytext); printf("%s",yytext); return negation;}
"," {yylval.str=strdup(yytext); rechercher(yytext,"Sep",0,0,2); col = col + strlen(yytext); printf("%s",yytext); return verg;}
";" {yylval.str=strdup(yytext); rechercher(yytext,"Sep",0,0,2); col = col + strlen(yytext); printf("%s",yytext); return pvg;}
"{" {yylval.str=strdup(yytext); rechercher(yytext,"Sep",0,0,2); col = col + strlen(yytext); printf("%s",yytext); return ac_open;}
"}" {yylval.str=strdup(yytext); rechercher(yytext,"Sep",0,0,2); col = col + strlen(yytext); printf("%s",yytext); return ac_close;}
"[" {yylval.str=strdup(yytext); rechercher(yytext,"Sep",0,0,2); col = col + strlen(yytext); printf("%s",yytext); return crochet_open;}
"]" {yylval.str=strdup(yytext); rechercher(yytext,"Sep",0,0,2); col = col + strlen(yytext); printf("%s",yytext); return crochet_close;}
"=" {yylval.str=strdup(yytext); rechercher(yytext,"Sep",0,0,2); col = col + strlen(yytext); printf("%s",yytext); return aff;}
"(" {yylval.str=strdup(yytext); rechercher(yytext,"Sep",0,0,2); col = col + strlen(yytext); printf("%s",yytext); return pr_open;}
")" {yylval.str=strdup(yytext); rechercher(yytext,"Sep",0,0,2); col = col + strlen(yytext); printf("%s",yytext); return pr_close;}
"+" {yylval.str=strdup(yytext); rechercher(yytext,"Sep",0,0,2); col = col + strlen(yytext); printf("%s",yytext); return addition;}
"-" {yylval.str=strdup(yytext); rechercher(yytext,"Sep",0,0,2); col = col + strlen(yytext); printf("%s",yytext); return sustraction;}
"*" {yylval.str=strdup(yytext); rechercher(yytext,"Sep",0,0,2); col = col + strlen(yytext); printf("%s",yytext); return mult;}
"/" {yylval.str=strdup(yytext); rechercher(yytext,"Sep",0,0,2); col = col + strlen(yytext); printf("%s",yytext); return division;}
":" {yylval.str=strdup(yytext); rechercher(yytext,"Sep",0,0,2); col = col + strlen(yytext); printf("%s",yytext); return deux_points;}
[ \t] {printf("%s",yytext); col = col + strlen(yytext);}
\n   {printf("%s",yytext);  col = 1; nb_ligne++;}



"/*"        { BEGIN(COMMENT); col += 2; }
<COMMENT>"*/" { BEGIN(INITIAL); col += 2; }
<COMMENT>\n   { nb_ligne++; col = 1; }
<COMMENT>.    { col++; }
"//".*      { col += strlen(yytext); }
<COMMENT><<EOF>> { 
    printf("Erreur Lexical: Commentaire non ferme à la ligne %d\n", nb_ligne);
    return err; 
}

. {
  printf("Entite lexicale non reconnue a ligne %d a la colonne %d \n", nb_ligne, col); 
  return err;
}
%%