%{
/*********************************************
将所有的词法分析功能均放在 yylex 函数内实现，为 +、-、*、\、(、 ) 每个运算符及整数分别定义一个单词类别，在 yylex 内实现代码，能
识别这些单词，并将单词类别返回给词法分析程序。
实现功能更强的词法分析程序，可识别并忽略空格、制表符、回车等
空白符，能识别多位十进制整数。
YACC file
**********************************************/
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include<map>
#include<string.h>
char IDstr[60];
char NumStr[60];
std::map<char*,double> symTab;
int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);
double strToNumber(char *NumberStr);
std::map<char*,double>::iterator symFind(char *Identifier);
%}

%union{
    double dbl;
    char* str;
}

//TODO:给每个符号定义一个单词类别

%token ASSIGN
%token ADD MINUS
%token MUL DIV
%token LEFTSM RIGHTSM
%token <str> NUMBER
%token <str> ID

%type <dbl> expr

%right ASSIGN
%left ADD MINUS
%left MUL DIV MOD
%right UMINUS         

%%

lines   :       lines expr ';' { printf("%f\n", $2); }
        |       lines stmt ';'
        |       lines ';'
        |
        ;
//TODO:完善表达式的规则
stmt    :       ID ASSIGN expr {auto iter=symFind($1);if(iter!=symTab.end()){free(iter->first);symTab.erase(iter);symTab[$1]=$3;}else{symTab[$1]=$3;}}
        ;
expr    :       expr ADD expr   { $$=$1+$3; }
        |       expr MINUS expr   { $$=$1-$3; }
        |       expr MUL expr   {$$=$1*$3;}
        |       expr DIV expr   {$$=$1/$3;}
        |       LEFTSM expr RIGHTSM {$$=$2;}
        |       MINUS expr %prec UMINUS   {$$=-$2;}
        |       NUMBER  {$$=strToNumber($1);}
        |       ID    {auto iter=symFind($1);if(iter!=symTab.end()){$$=symTab[iter->first];}else{symTab[$1]=0;$$=symTab[$1];}}
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
            yylval.str = strdup(NumStr);
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
        }else if(t=='='){
            return ASSIGN;
        }else if((t>='a'&&t<='z')||(t>='A'&&t<='Z')||(t=='_')){  //识别标识符
            int index=0;
            while((t>='a'&&t<='z')||(t>='A'&&t<='Z')||(t=='_')||(t>='0'&&t<='9')){
                IDstr[index] = t;
                index++;
                t=getchar();
            }
            IDstr[index]='\0';
            yylval.str = strdup(IDstr);
            ungetc(t,stdin);
            return ID;
        }
        else{
            return t;
        }
    }
}

double strToNumber(char *NumberStr){
    double numVal = 0;
    int index = 0;
    while(NumberStr[index]!='\0'){
        numVal = NumberStr[index]-'0'+numVal*10;
        index++;
    }
    return numVal;
}
std::map<char*,double>::iterator symFind(char *Identifier){
    for(auto iter=symTab.begin();iter!=symTab.end();iter++){
        if(!(strcmp(Identifier,iter->first))){
            return iter;
        }
    }
    return symTab.end();
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