%{
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include"Color.h"
#include"syntaxique.tab.h"
#include"ts.h"
//#include"codeInter.tab.h"

extern Line;
extern Col;
extern YYSTYPE yylval;
char* fileName;
int yydebug = 1;  // Set yydebug to 1 for debugging

%}

NBR (\([+-]\))?[0-9]+(\.[0-9]+)?       
IDF [A-Za-z][A-Za-z0-9]*  
INT [0-9]+|\([+-][0-9]+\)      
COMMENT ^%.*
STRING_LITERAL \"(\\.|[^\"])*\"
%%  

".EQ." {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
	yylval.str = "==";
	
    return mc_EQ;
}

".NE." {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
	yylval.str = "!=";
    return mc_NE;
}

".LE." {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
	yylval.str = "<=";
    return mc_LE;
}

".LT." {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
	yylval.str = "<";
    return mc_LT;
}

".GE." {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
	yylval.str = ">=";
    return mc_GE;
}

".GT." {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
	yylval.str = ">";
    return mc_GT;
}

".AND." {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
	yylval.str = "&&";
    return mc_AND;
}

".OR." {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
	yylval.str = "||";
    return mc_OR;
}

"FALSE" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
	yylval.str = "0";
    return mc_FALSE;
}

"TRUE" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
	yylval.str = "1";
    return mc_TRUE;
}

"CHARACTER" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
    return mc_CHARACTER;
}

"INTEGER" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
    return mc_INTEGER;
}

"LOGICAL" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
    return mc_LOGICAL;
}

"REAL" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
    return mc_REAL;
}

"DIMENSION" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
    return mc_DIMENSION;
}

"DOWHILE" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
    return mc_DOWHILE;
}

"ENDDO" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
    return mc_ENDDO;
}

"IF" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
    return mc_IF;
}

"THEN" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
    return mc_THEN;
}

"ELSE" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
    return mc_ELSE;
}

"ENDIF" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
    return mc_ENDIF;
}

"ROUTINE" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
    return mc_ROUTINE;
}

"CALL" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
    return mc_CALL;
}

"ENDR" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
    return mc_ENDR;
}

"PROGRAM" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
    return mc_PROGRAM;
}

"END" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
    return mc_END;
}

"READ" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
    return mc_READ;
}

"WRITE" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
    return mc_WRITE;
}

"EQUIVALENCE" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(KEYWORDS_TABLE, yytext);
    return mc_EQUIVALENCE;
}

";" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(SEPARATORS_TABLE, yytext);
    return ';';
}

"=" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(SEPARATORS_TABLE, yytext);
    return '=';
}

"(" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(SEPARATORS_TABLE, yytext);
    return '(';
}

")" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(SEPARATORS_TABLE, yytext);
    return ')';
}

"*" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(SEPARATORS_TABLE, yytext);
    return '*';
}

"+" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(SEPARATORS_TABLE, yytext);
    return '+';
}

"-" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(SEPARATORS_TABLE, yytext);
    return '-';
}

"/" {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(SEPARATORS_TABLE, yytext);
    return '/';
}

"," {
    
    Col += strlen(yytext);
    ECHO;
	insertSM(SEPARATORS_TABLE, yytext);
    return ',';
}

{IDF} {
    yylval.str = strdup(yytext);  
    Col += strlen(yytext);
    if (yyleng > 10)
	{
		setColor(255, 165, 0);
		printf("File \"%s\", Lexical Warning - Line %d, Column %d: Identifier is too long \n", fileName, Line, Col);
		setColor(255, 255, 0);
		printf("<!> Length(\"%s\") > 10 characters\n\n", yytext);
		setColor(255, 255, 255);
	}
    ECHO;
    return IDF;
}

{INT} {
    // Matched an integer
    long long intValue = atoll(cleanedStr(yytext));
	
	//integer is too small
    if (intValue < -32768)
	{
		setColor(255, 0, 0);
		printf("File \"%s\", Lexical Error - Line %d, Column %d: Integer too small\n", fileName, Line, Col);   
		setColor(255, 255, 0);
		printf("<!> %s < -32768\n\n", yytext);
		setColor(255, 255, 255);
		//return err;
		yyterminate();  /* Terminate the lexer */
	}
    else 
	{
        // Integer is too big
        if (intValue > 32767)
		{
			setColor(255, 0, 0);
			printf("File \"%s\", Lexical Error - Line %d, Column %d: Integer too big\n", fileName, Line, Col);
			setColor(255, 255, 0);
			printf("<!> %s > 32767\n\n", yytext);
			setColor(255, 255, 255);
			//return err;
			yyterminate();  /* Terminate the lexer */
		}
		else 
		{	
			
			//Valid integer
			//yylval.entier = atoi(cleanedStr(yytext));
			yylval.str = cleanedStr(yytext);
			Col += strlen(yytext);
			ECHO;
			return INT;
		}
	}
}

{NBR} {
	
	setColor(255, 0, 0);
	if(checkFloatRange(yytext, fileName, Line, Col))
	{
		//return err;
		yyterminate();
	}
	else
	{
		//Valid float
		//yylval.reel = atof(cleanedStr(yytext));
		yylval.str = cleanedStr(yytext);
		Col = Col + strlen(yytext);
		ECHO;
		return NBR;
	}
}

{COMMENT} {
    Col = 1; 
	
    ECHO;
}

{STRING_LITERAL} {
    Col += strlen(yytext);
    ECHO;
	yylval.str = strdup(yytext); 
	return STRING_LITERAL;
    
}

[ \t]   {
		Col += strlen(yytext);
		ECHO;
}

\n  {
    Col = 1;
    Line ++;
	ECHO;
} 

.   {
	
	setColor(255, 0, 0);
	printf("File \"%s\", Lexical Error - Line %d, Column %d: Unrecognized character '%c'\n\n", fileName, Line, Col, yytext[0]);
	setColor(255, 255, 255);
	//return err;
	yyterminate();  /* Terminate the lexer */
    
}   
%%

int main(int argc, char** argv)
{	
	init_symbol_tables();
	
	if(argc > 1)
	{
		fileName = (char*)argv[1];
		FILE* file =  fopen(fileName, "r");

		//error handling
		if(!file)
			return 1;
		yyin = file;
	}
	
	
	yyparse();
	dumpIDF();
	afficher_qdr();
	//dumpSM(KEYWORDS_TABLE, "Keywords Table");
	//dumpSM(SEPARATORS_TABLE, "Separators Table");
	
	/* FILE *of = fopen("TS_output.txt", "a");
	if (of != NULL) 
	{
		// Your fprintf calls here
		fclose(of);
	} 
	else
	{
		// Handle file opening error
	} */

    return 0;
}





 
