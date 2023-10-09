%{
/*********************************************
将所有的词法分析功能均放在 yylex 函数内实现，为 +、-、*、\、(、 ) 每个运算符及整数分别定义一个单词类别，在 yylex 内实现代码，能
识别这些单词，并将单词类别返回给词法分析程序。
实现功能更强的词法分析程序，可识别并忽略空格、制表符、回车等
空白符，能识别多位十进制整数。
YACC file
**********************************************/

//本程序实现中缀表达式转后缀表达式

#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include<string.h>
#ifndef YYSTYPE
#define YYSTYPE char*
#endif
char IDstr[60];
char NumStr[40];
int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);
%}

//TODO:给每个符号定义一个单词类别

%token ASSIGN
%token ADD MINUS
%token MUL DIV
%token LEFTSM RIGHTSM
%token NUMBER
%token ID

%right ASSIGN
%left ADD MINUS
%left MUL DIV MOD
%right UMINUS         

%%


lines   :       lines expr ';' { printf("%s\n", $2); }
        |       lines ';'
        |
        ;
//TODO:完善表达式的规则
expr    :       expr ADD expr   {$$=(char*)malloc(100*sizeof(char));strcpy($$,$1);strcat($$,$3);strcat($$,"+ ");}
        |       expr MINUS expr {$$=(char*)malloc(100*sizeof(char));strcpy($$,$1);strcat($$,$3);strcat($$,"- ");}
        |       expr MUL expr   {$$=(char*)malloc(100*sizeof(char));strcpy($$,$1);strcat($$,$3);strcat($$,"* ");}
        |       expr DIV expr   {$$=(char*)malloc(100*sizeof(char));strcpy($$,$1);strcat($$,$3);strcat($$,"/ ");}
        |       LEFTSM expr RIGHTSM {$$=(char*)malloc(100*sizeof(char));strcpy($$,$2);strcat($$," ");}
        |       MINUS expr %prec UMINUS   {$$=(char*)malloc(100*sizeof(char));strcpy($$,$1);strcat($$,$2);strcat($$," ");}
        |       NUMBER  {$$=(char*)malloc(40*sizeof(char));strcpy($$,$1);strcat($$," ");}
        |       ID      {$$=(char*)malloc(60*sizeof(char));strcpy($$,$1);strcat($$," ");}
        ;

%%

// programs section

int yylex()
{
    int t;
    while(1){
        t=getchar();
        if(t==' '||t=='\t'||t=='\n'){
            //do noting
        }else if((t>='0' && t<='9')){//TODO:解析多位数字返回数字类型
            int index = 0;
            while((t>='0' && t<='9')){
                NumStr[index]=t;
                index++;
                t = getchar();
            }
            NumStr[index] = '\0';
            yylval = NumStr;
            ungetc(t,stdin);
            return NUMBER;
        }else if(t=='+'){
            return ADD;
        }else if(t=='-'){
            return MINUS; //TODO:识别其他符号
        }else if(t=='*'){
            return MUL;
        }else if(t=='/'){
            return DIV;
        }else if(t=='('){
            return LEFTSM;
        }else if(t==')'){
            return RIGHTSM;
        }else if((t>='a'&&t<='z')||(t>='A'&&t<='Z')||(t=='_')){  //识别标识符
            int index=0;
            while((t>='a'&&t<='z')||(t>='A'&&t<='Z')||(t=='_')||(t>='0'&&t<='9')){
                IDstr[index] = t;
                index++;
                t=getchar();
            }
            IDstr[index]='\0';
            yylval = IDstr;
            ungetc(t,stdin);
            return ID;
        }
        else{
            return t;
        }
    }
}

int main(void)
{
    yyin=stdin;
    do{
        yyparse();
    }while(!feof(yyin));
    return 0;
}
void yyerror(const char* s){
    fprintf(stderr,"Parse error: %s\n",s);
    exit(1);
}