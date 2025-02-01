#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// Fonction pour définir la couleur du texte dans la console
void setColor(int r, int g, int b) {
    // Codes ANSI pour les couleurs du texte
    // 38;2;#;#;# spécifie une couleur RGB pour le texte
    printf("\x1b[38;2;%d;%d;%dm", r, g, b);
}

//function to check the float range
int checkFloatRange(const char *input, char *fileName, int Line, int Col) {
    char *token;
    char *endptr;
    int e;
    

    // Duplicate the input string to avoid modifying the original
    char *inputCopy = strdup(input);

    // Tokenize the input string using the dot as a delimiter
    token = strtok(inputCopy, ".");
    // Convert the token to an integer
    long long intValue = strtoll(token, &endptr, 10);
	
	
    // Check if the whole part value is within the specified range
    if (intValue > 32767) 
    {
        setColor(255, 0, 0);
		printf("File \"%s\", Lexical Error - Line %d, Column %d: Float (Whole Part) out of the range \n", fileName, Line, Col);
		setColor(255, 255, 0);
		printf("<!> %s => %s > 32767\n\n", input, token);
		setColor(255, 0, 0);
        e = 1;
	}
        
	if (intValue < -32768) 
    {
		setColor(255, 0, 0);
       	printf("File \"%s\", Lexical Error - Line %d, Column %d: Float (wholePart) out of the range\n", fileName, Line, Col, input, token);
		setColor(255, 255, 0);
		printf("<!> %s => %s < -32768\n\n", input, token);
		setColor(255, 0, 0);
		e =  1;
	}
		
	// Get the next token
    token = strtok(NULL, ".");
    intValue = strtoll(token, &endptr, 10);
        
		if (intValue > 32767) 
        {
			setColor(255, 0, 0);
        	printf("File \"%s\", Lexical Error - Line %d, Column %d: Float (Decimal Part) out of the range \n", fileName, Line, Col, input, token);	
			setColor(255, 255, 0);
			printf("<!> %s => %s > 32767\n\n", input, token);
			setColor(255, 0, 0);
			
			e = 1;
		}
		
		
		if (e)
		{
			setColor(255, 255, 255);
			return 1;
		} 
		            
    

    free(inputCopy);
    setColor(255, 255, 255);
    return 0;
}

char* cleanedStr(char *str) {
    // Allocate memory for the cleaned string
    char *cleaned = (char *)malloc(strlen(str) + 1);

    if (cleaned == NULL) {
        fprintf(stderr, "Memory allocation error\n");
        exit(EXIT_FAILURE);
    }

    // Copy characters from str to cleaned, excluding '(' and ')'
    int j = 0; int i;
    for (i = 0; str[i] != '\0'; i++) {
        if (str[i] != '(' && str[i] != ')') {
            cleaned[j++] = str[i];
        }
    }

    // Null-terminate the cleaned string
    cleaned[j] = '\0';

    return cleaned;
}







