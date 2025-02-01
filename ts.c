#include <stdio.h>
#include <stdlib.h>
#include<string.h>
#include"ts.h"



/* current scope */
static int cur_scope = 0;

// Symbol Table Functions

void init_symbol_tables() {
    int i;
    
    idf_table = malloc(MAX_LENGTH * sizeof(SymbolInfo**)); 
	for(i = 0; i < MAX_LENGTH; i++) idf_table[i] = NULL;

    keywords_table = malloc(MAX_LENGTH * sizeof(SymbolInfo_SM**));
    for (i = 0; i < MAX_LENGTH; i++) keywords_table[i] = NULL;
		
    separators_table = malloc(MAX_LENGTH * sizeof(SymbolInfo_SM**));
    for (i = 0; i < MAX_LENGTH; i++) separators_table[i] = NULL;
		
}


//Daniel J. Bernstein, it is the second hash function he designed
int djb2_hash(char *key) {
	
	// Initial hash value (choosed experimentaly)   
    int hash = 5381;                                      

    while (*key != '\0') {
    	// The '33' is a magic number that helps with distribution + it's a primary number
    	//Left Shift by 5 (hash * 33 is equivalent to hash * 32 + hash)
    	//The XOR operation combines bits in a way that introduces further mixing
        hash = (hash * 33) ^ (*key);  
        key++;
    }

	if (hash <  0) hash = -hash;
	
	
	
    return hash % MAX_LENGTH;
}

void insertIdf(char *name, int smb_type, int lineno, int declare) {
    // get the position of the symbol
    int hashval = djb2_hash(name);

    // get the pointer to the list which contains the symbol (in the hash table)
    SymbolInfo *currentSymbol = idf_table[hashval];

    // searching the symbol in the list
    while ((currentSymbol != NULL) && (strcmp(name, currentSymbol->smb_name) != 0)) {
        currentSymbol = currentSymbol->next;
    }

    /* variable not yet in the table */
    if (currentSymbol == NULL) {
        /* check if we are in declaration part */
        if (declare == 1) {
            /* set up entry */
            SymbolInfo *newSymbol = (SymbolInfo *)malloc(sizeof(SymbolInfo));
            newSymbol->smb_name = strdup(name);  // Allocate and copy the name
            newSymbol->smb_type = smb_type;
			newSymbol->smb_dim = 0;
			
            //printf("currentSymbol: %s ", newSymbol->smb_name);

            newSymbol->scope = cur_scope;
            newSymbol->lines = (RefList *)malloc(sizeof(RefList));
            newSymbol->lines->line_nbr = lineno;
            newSymbol->lines->next = NULL;

            /* link the new entry to the hash table */
            newSymbol->next = idf_table[hashval];
            idf_table[hashval] = newSymbol;

            //printf("Inserted %s for the first time with linenumber %d!\n", name, lineno);
        } else {
			setColor(255, 0, 0);
            printf("\'%s\' : Undeclared at line %d \n", name, lineno);
			setColor(255, 255, 255);
        }
    } else {
        // found in the table
        // just add line number

        if (declare == 0) // instruction
        {
            /* find the last reference */
            RefList *t = currentSymbol->lines;
            while (t->next != NULL)
                t = t->next;

            /* add linenumber to the reference list */
            t->next = (RefList *)malloc(sizeof(RefList));
            t->next->line_nbr = lineno;
            t->next->next = NULL;
            //printf("Found %s again at line %d!\n", name, lineno);
        } else {
            /* new entry */
            /* same scope - multiple declaration error! */
            if (currentSymbol->scope == cur_scope) {
				setColor(255, 0, 0);
                printf("A multiple declaration of variable %s at line %d\n", name, lineno);
				setColor(255, 255, 255);
                //exit(0);
            } else {
                /* create a new entry for a different scope */
                /* set up entry */
                SymbolInfo *newSymbol = (SymbolInfo *)malloc(sizeof(SymbolInfo));
                newSymbol->smb_name = strdup(name);  // Allocate and copy the name
                newSymbol->smb_type = smb_type;
				
                newSymbol->scope = cur_scope;
                newSymbol->lines = (RefList *)malloc(sizeof(RefList));
                newSymbol->lines->line_nbr = lineno;
                newSymbol->lines->next = NULL;

                /* link the new entry to the hash table */
                newSymbol->next = idf_table[hashval];
                idf_table[hashval] = newSymbol;

                //printf("Inserted %s for a new scope with linenumber %d!\n", name, lineno);
            }
        }
    }
}


void insertSM(int table, char *name) {
    // get the position of the symbol
    int hashval = djb2_hash(name);

    // get the pointer to the list which contains the symbol (in the hash table)
    SymbolInfo_SM *currentSymbol = NULL;
	
	if (table == KEYWORDS_TABLE)
		currentSymbol = (SymbolInfo_SM *)keywords_table[hashval];
	else 
		currentSymbol = (SymbolInfo_SM *)separators_table[hashval];
	
	
	while ((currentSymbol != NULL) && (strcmp(name, currentSymbol->smb_name) != 0)) {
        currentSymbol = currentSymbol->next;
    }

    if (currentSymbol == NULL) {
        // Symbol not found, insert a new one
        SymbolInfo_SM *newSymbol_SM = (SymbolInfo_SM *)malloc(sizeof(SymbolInfo_SM));
        if (newSymbol_SM == NULL) {
            printf("Memory allocation error\n");
            exit(1);
        }

        newSymbol_SM->smb_name = strdup(name);
		
		if (table == KEYWORDS_TABLE)
		{
			newSymbol_SM->next = (SymbolInfo_SM *)keywords_table[hashval];
			keywords_table[hashval] = (SymbolInfo_SM*)newSymbol_SM;
		}
		else 
		{
			newSymbol_SM->next = (SymbolInfo_SM *)separators_table[hashval];
			separators_table[hashval] = newSymbol_SM;
		}
        
        //printf("Inserted %s for the first time!\n", name);
    } else {
        // Symbol found again, you may want to update something here if needed
        //printf("Found %s again!\n", name);
    }
}




int dumpSM(int table, const char *title) {
    SymbolInfo_SM **currentTable = NULL;

    if (table == KEYWORDS_TABLE)
        currentTable = (SymbolInfo_SM **)keywords_table;
    else if (table == SEPARATORS_TABLE)
        currentTable = (SymbolInfo_SM **)separators_table;
    else {
        printf("Invalid table type\n");
        return -1;
    }

	printf("Dumping %s:\n", title);
    printf("+========================================+\n");
    printf("| %-15s | %-20s |\n", "Index", "Symbol");
    printf("+========================================+\n");

    int i;
    for (i = 0; i < MAX_LENGTH; i++) {
        SymbolInfo_SM *currentSymbol = currentTable[i];
        while (currentSymbol != NULL) {
            printf("| %-15d | %-20s |\n", i, currentSymbol->smb_name);
            currentSymbol = currentSymbol->next;
        }
    }

    printf("+========================================+\n");
	printf("\n\n");
	return 0;
}



SymbolInfo *lookup(char *name){  /* return symbol if found or NULL if not found */

	int hashval = djb2_hash(name);
	SymbolInfo *currentSymbol = idf_table[hashval];
	while ((currentSymbol != NULL) && (strcmp(name,currentSymbol->smb_name) != 0)) currentSymbol = currentSymbol->next;
	return currentSymbol;
}

void dumpIDF() {
    printf("+===================================================================================================================================================================================================+\n");
    printf("| %-5s | %-20s | %-5s | %-12s | %-12s | %-15s | %-12s | %-9s | %-11s | %-41s | %-21s |\n",
           "Index", "Name", "Scope", "Type", "Info Type", "Value", "Array Size", "Array Dim", "Num of Pars", "Parameters", "Line Numbers");
    printf("+===================================================================================================================================================================================================+\n");

    int i;
    for (i = 0; i < MAX_LENGTH; ++i)
	{
        if (idf_table[i] != NULL)
		{
            SymbolInfo *symbol = idf_table[i];
            while (symbol != NULL)
			{
                printf("| %-5d | %-20s |", i, symbol->smb_name);
				
				// Print Scope and Line Numbers
                printf(" %-5d |", symbol->scope);

                // Print smb_type as a string
                switch (symbol->smb_type) {
                    case INT_TYPE:
                        printf(" %-12s |", "INTEGER");
                        break;
                    case REAL_TYPE:
                        printf(" %-12s |", "REAL");
                        break;
                    case LOGC_TYPE:
                        printf(" %-12s |", "LOGICAL");
                        break;
                    case CHAR_TYPE:
                        printf(" %-12s |", "CHARACTER");
                        break;
					case ARRAY_TYPE:
                        printf(" %-12s |", "ARRAY");
                        break;
					case FUNCTION_TYPE:
                        printf(" %-12s |", "FUNCTION");
                        break;
                    default:
                        printf(" %-12s |", "UNDEFINED");
                        break;
                }
				
                // Print inf_type or smb_type as a string (Modify as needed based on your type enum values)
				if (symbol->inf_type == INT_TYPE || symbol->smb_type == INT_TYPE) {
					printf(" %-12s |", "INTEGER");
					if (symbol->smb_type != ARRAY_TYPE && symbol->smb_type != FUNCTION_TYPE)
					{
						printf(" %-15s |", symbol->val);
					}
						
					else
						printf(" %-15s |", "NoN");
				} else if (symbol->inf_type == REAL_TYPE || symbol->smb_type == REAL_TYPE) {
					printf(" %-12s |", "REAL");
					if (symbol->smb_type != ARRAY_TYPE && symbol->smb_type != FUNCTION_TYPE) 
						printf(" %-15s |", symbol->val);
					else
						printf(" %-15s |", "NoN");
				} else if (symbol->inf_type == LOGC_TYPE || symbol->smb_type == LOGC_TYPE) {
					printf(" %-12s |", "LOGICAL");
					if (symbol->smb_type != ARRAY_TYPE && symbol->smb_type != FUNCTION_TYPE){
						if (strcmp(symbol->val, "1") == 0 ) {
							printf(" %-15s |", "TRUE");
						} else {
							printf(" %-15s |", "FALSE");
						}
					} 				
					else
						printf(" %-15s |", "NoN");
					
				} else if (symbol->inf_type == CHAR_TYPE || symbol->smb_type == CHAR_TYPE) {
					printf(" %-12s |", "CHARACTER");
						
					if (symbol->smb_type != ARRAY_TYPE && symbol->smb_type != FUNCTION_TYPE) 	
						printf(" %-15s |", symbol->val);
					else
						printf(" %-15s |", "NoN");
				} else {
					printf(" %-12s | %-15s |", "UNDEFINED", "NoN");
				}

                if (symbol->smb_type == ARRAY_TYPE) 
				{
                    if (symbol->smb_dim == 1 || symbol->smb_dim == 0) 
					{
                        printf(" %-12d | %-9d |", symbol->array_size.x, symbol->smb_dim);
                    } else if (symbol->smb_dim == 2)
					{
                        printf(" (%-2d, %-2d)    | %-9d |", symbol->array_size.x, symbol->array_size.y, symbol->smb_dim);
					} else 
					{
                        printf(" %-12s | %-9s |", "NoN", "NoN" );
                    }
				}
				else if (symbol->smb_type == 0)
				{
					printf(" %-12s | %-9s |", "NoN", "NoN");
				}
				else if (symbol->smb_type == 4 && symbol->smb_dim == 1 )
				{
					printf(" %-12d | %-9d |", symbol->array_size.x, 1);
                    
                }else
				{
					printf(" %-12d | %-9d |", 1, 0);	
				}

                if (symbol->smb_type == FUNCTION_TYPE) 
				{
                    printf(" %-11d |", symbol->num_of_pars);
					
                    if (symbol->parameters != NULL) 
					{
                        int j;
						
                        for (j = 0; j < (symbol->num_of_pars); j++)
						{
							
							
                            switch (symbol->parameters[j].par_type)
							{
                                case INT_TYPE:
                                    printf(" %s", "INTEGER :");
                                    break;
                                case CHAR_TYPE:
                                    printf(" %s", "CHARACTER :");
                                    break;
                                case LOGC_TYPE:
                                    printf("%s", "LOGICAL :");
                                    break;
                                case REAL_TYPE:
                                    printf(" %s", "REAL :");
                                    break;
                                default:
                                    printf(" %s", "UNDEF:");
                                    break;
                            } 
							
                            printf(" %s, ", symbol->parameters[j].par_name);
							
                        }
                    } 
					else 
                        printf(" %-40s |", "NoN");
                } 
				else 
                    printf(" %-11s | %-40s ", "NoN", "NoN");
				printf("\033[173G");
				printf("|");
                RefList *lines = symbol->lines;
                while (lines != NULL) {
                    printf(" %d,", lines->line_nbr);
                    lines = lines->next;
                }
				printf("\033[197G");
				printf("|");

                
                printf("\n");
                symbol = symbol->next;
            }
        }
    }
	printf("+===================================================================================================================================================================================================+\n");
	printf("\n\n");
}


   



// Type Functions

int set_type(char *name, int smb_type, int inf_type, int smb_dim, int x, int y) {
    // lookup entry
    SymbolInfo *currentSymbol = lookup(name);
    if (currentSymbol == NULL) {
        printf("In function set_type: Symbol not found\n");
        return -1;
    }

    // set "main" type
    currentSymbol->smb_type = smb_type;

    // if array or function

    currentSymbol->inf_type = inf_type;
    currentSymbol->smb_dim = smb_dim;
    currentSymbol->array_size.x = x;
    currentSymbol->array_size.y = y;
  

    return 0;
}

void set_val(char *name, char* val, int cur_scope) {
    int hashval = djb2_hash(name);
    SymbolInfo *entry = idf_table[hashval];

    // Look for the symbol in the symbol table
    while ((entry != NULL) && (strcmp(name, entry->smb_name) != 0)) {
        entry = entry->next;
    }

    // Check if the symbol is found
    if (entry != NULL) {
        // Check if the symbol is in the correct scope
        if (cur_scope == entry->scope) {
            // Set the value
            entry->val = val;
        } else {
            printf("Error: Symbol found, but not in the current scope\n");
        }
    } else {
        printf("Error: Symbol not found for setting value\n");
    }
}


char *get_val(char *name,int scopeid) {
    int hashval = djb2_hash(name);
	char* value;
	
	SymbolInfo *data = idf_table[hashval];
	while ((data != NULL) 
		&& (strcmp(name,data->smb_name) != 0)
		&& (scopeid != data->scope )) 
			data = data->next;
	
	if (data != NULL)
	{
		if (data->val != NULL)
		{
			value = data->val;
			return value;
		}
		else
			printf("Value not set\n");	
	}
	else
	{
		printf("get_value: Symbol not found\n");
		return NULL;
	}
	
}

Size get_size(char *name,int scopeid) {
    int hashval = djb2_hash(name);
	Size size;
	
	SymbolInfo *data = idf_table[hashval];
	while ((data != NULL) 
		&& (strcmp(name,data->smb_name) != 0)
		&& (scopeid != data->scope )) 
			data = data->next;
	
	if (data != NULL)
	{
		size.x = data->array_size.x;
		size.y = data->array_size.y;
		return size;
	}
	else
	{
		printf("get_size: Symbol not found\n");
		return size;
		
	}
	
}



int get_type(char *name, int scopeid) {
    /* lookup entry */
    SymbolInfo *currentSymbol = lookup(name);

    if(currentSymbol == NULL) {
        printf("In function get_type: symbol not found");
        return -1;   
    }

    /* Check if the symbol is in the correct scope */
    if (currentSymbol->scope != scopeid) {
        printf("In function get_type: symbol '%s' not found in scope %d\n", name, scopeid);
        return -1;
    }

    /* If "simple" type */
    if(currentSymbol->smb_type == INT_TYPE ||
       currentSymbol->smb_type == REAL_TYPE ||
       currentSymbol->smb_type == LOGC_TYPE  ||
       currentSymbol->smb_type == CHAR_TYPE) {
        return currentSymbol->smb_type;
    }

    /* If array or function */
    return currentSymbol->inf_type;
}



// Scope Management Functions

void hide_scope() {

    cur_scope--;
}


void incr_scope(){ /* go to next scope */
	cur_scope++;
}

int get_scope(){
	return cur_scope;
}


// Function Declaration and Parameters



// Function to define a parameter
Param def_param(int par_type, char *par_name) {
    Param parameter;
    parameter.par_type = par_type;
    parameter.par_name = strdup(par_name);
    return parameter;
}

// Function to declare a function with parameters
void func_declare(char *name, int ret_type, int num_of_pars, Param *parameters) {
    // Lookup entry
    SymbolInfo *currentSymbol = lookup(name);
	

    // If the type is not defined yet
    if (currentSymbol->smb_type == UNDEF) {
		
        // Entry is of function type
        currentSymbol->smb_type = FUNCTION_TYPE;

        // Return type is ret_type
        currentSymbol->inf_type = ret_type;

        // Parameter information
        currentSymbol->num_of_pars = num_of_pars;

        // Allocate memory for parameters
        currentSymbol->parameters = malloc(num_of_pars * sizeof(Param));
		
		int i;
		
        // Copy parameter details
		
        for (i = 0; i < num_of_pars; i++) {
            currentSymbol->parameters[i] = parameters[i];
			
        }
		

         // Success
    } else {
        printf("Function %s already declared!\n", name);
        //exit(1);
		
    }
}

float customAtoF(const char* str) 
	{
		float result = 0.0f;
		int sign = 1;
		int decimal = 0;
		float decimalPlace = 1.0f;

		// Handle sign
		if (*str == '-')
		{
			sign = -1;
			str++;
		} else if (*str == '+') 
		{
			str++;
		}

		// Process integer part
		while (*str >= '0' && *str <= '9') 
		{
			result = result * 10.0f + (*str - '0');
			str++;
		}

		// Process decimal part
		if (*str == '.') 
		{
			str++;

			while (*str >= '0' && *str <= '9')
			{
				result = result * 10.0f + (*str - '0');
				decimal++;
				str++;
			}

			// Adjust the result based on the number of decimal places
			while (decimal-- > 0) 
			{
				decimalPlace *= 10.0f;
			}
		}

		// Apply sign and adjust for decimal places
		result = result / decimalPlace * sign;

		return result;
	}
	
	
	// Function to convert a float to a string with fixed precision of 4
char* floatToString(float value) {
    // Determine the sign
    int isNegative = value < 0;
    if (isNegative) {
        value = -value;
    }

    // Extract integer part
    int intPart = (int)value;

    // Extract fractional part with fixed precision of 4
    int precision = 10000;
    int fracPart = (int)((value - intPart) * precision);

    // Count the number of digits in intPart
    int intDigits = 1;
    int temp = intPart;
    while (temp /= 10) {
        intDigits++;
    }

    // Count the number of digits in fracPart
    int fracDigits = 4; // Fixed precision of 4

    // Determine the length of the resulting string
    int length = (isNegative ? 1 : 0) + intDigits + 1 + fracDigits + 1; // +1 for potential negative sign, +1 for '.', +1 for null terminator

    // Allocate memory for the string
    char* result = (char*)malloc(length);

    // Build the string
    char* current = result;
    if (isNegative) {
        *current++ = '-';
    }

    // Convert intPart to string
    temp = intPart;
    int i;
    for (i = intDigits - 1; i >= 0; --i) {
        result[current - result + i] = '0' + temp % 10;
        temp /= 10;
    }
    current += intDigits;

    // Add decimal point
    *current++ = '.';

    // Convert fracPart to string
    for (i = 0; i < fracDigits; ++i) {
        result[current - result + fracDigits - i - 1] = '0' + fracPart % 10; // Corrected order of fractional digits
        fracPart /= 10;
    }
    current += fracDigits;

    // Null-terminate the string
    *current = '\0';

    return result;
}

char* extractFullPart(const char* floatString) {
    char* fullPart = NULL;

    // Convert the string to a floating-point number
    float floatValue = strtof(floatString, NULL);

    // Check if the conversion was successful
    if (floatValue != 0.0 || (floatValue == 0.0 && floatString[0] == '0')) {
        // Allocate memory for the full part string
        int fullPartLength = snprintf(NULL, 0, "%.0f", floatValue) + 1; // +1 for the null terminator
        fullPart = (char*)malloc(fullPartLength);

        // Convert the float to string with %.0f format specifier to get the full part
        snprintf(fullPart, fullPartLength, "%.0f", floatValue);
    }

    return fullPart;
}



void type_error(int type_1, int type_2, int op_type, int Line, int Col) {
    // Function to print the literal type string based on the token types
    const char* get_type_string(int type) {
        switch(type) {
            case UNDEF: return "UNDEFINED";
            case INT_TYPE: return "INTEGER";
            case REAL_TYPE: return "REAL";
            case LOGC_TYPE: return "LOGICAL";
            case CHAR_TYPE: return "CHARACTER";
            default: return "UNKNOWN";
        }
    }
	setColor(255, 0, 0);
    printf("\n\nType conflict between %s and %s using op type %d in Line %d and column %d\n",
           get_type_string(type_1), get_type_string(type_2), op_type, Line, Col);
	setColor(255, 255, 255);
    exit(1);
}




int get_result_type(int type_1, int type_2, int op_type, int Line, int Col){ /* type check and result type */
	switch(op_type){
		case NONE: /* type compatibility only, '1': compatible */
			// first type INT
			if(type_1 == INT_TYPE){
				// second type INT
				if(type_2 == INT_TYPE){
					return 1;
				}
				else{
					type_error(type_1, type_2, op_type, Line, Col);
				}
			}
			// first type REAL
			else if(type_1 == REAL_TYPE){
				// second type INT, REAL or CHAR
				if(type_2 == INT_TYPE || type_2 == REAL_TYPE){
					return 1;
				}
				else{
					type_error(type_1, type_2, op_type, Line, Col);
				}
			}
			// first type CHAR
			else if(type_1 == CHAR_TYPE){
				// second type INT or CHAR
				if(type_2 == CHAR_TYPE){
					return 1;
				}
				else{
					type_error(type_1, type_2, op_type, Line, Col);
				}
			}
			//first type LOGC
			else if(type_1 == LOGC_TYPE){
				// second type INT, REAL or CHAR
				if(type_2 == LOGC_TYPE){
					return 1;
				}
				else{
					type_error(type_1, type_2, op_type, Line, Col);
				}
			}
			else{
				type_error(type_1, type_2, op_type, Line, Col);
			}
			break;
		/* ---------------------------------------------------------- */
		case ARITHM_OP: /* arithmetic operator */
			// first type INT
			if(type_1 == INT_TYPE){
				// second type INT or CHAR
				if(type_2 == INT_TYPE){
					return INT_TYPE;
				}
				// second type REAL
				else if(type_2 == REAL_TYPE){
					return REAL_TYPE;
				}
				else{
					type_error(type_1, type_2, op_type, Line, Col);
				}
			}
			// first type REAL
			else if(type_1 == REAL_TYPE){
				// second type INT, REAL 
				if(type_2 == INT_TYPE || type_2 == REAL_TYPE){
					return REAL_TYPE;
				}
				else{
					type_error(type_1, type_2, op_type, Line, Col);
				}
			}
			else{
				type_error(type_1, type_2, op_type, Line, Col);
			}
			break;
		/* ---------------------------------------------------------- */
		case BOOL_OP: /* Boolean operator */
			// first type INT
			if(type_1 == LOGC_TYPE){
				// second type INT or CHAR
				if(type_2 == LOGC_TYPE){
					return LOGC_TYPE;
				}
				else{
					type_error(type_1, type_2, op_type, Line, Col);
				}
			}
		/* ---------------------------------------------------------- */
		case REL_OP: /* Relational operator */
			// first type INT
			if(type_1 == INT_TYPE){
				// second type INT, REAL or CHAR
				if(type_2 == INT_TYPE || type_2 == REAL_TYPE){
					return LOGC_TYPE;
				}
				else{
					type_error(type_1, type_2, op_type, Line, Col);
				}
			}
			else if(type_1 == REAL_TYPE){
				// second type INT, REAL or CHAR
				if(type_2 == INT_TYPE || type_2 == REAL_TYPE){         
					return LOGC_TYPE;
				}
				else{
					type_error(type_1, type_2, op_type, Line, Col);
				}
			}
			// first type CHAR
			else if(type_1 == CHAR_TYPE){
				// second type CHAR
				if(type_2 == CHAR_TYPE){
					return LOGC_TYPE;
				}
				else{
					type_error(type_1, type_2, op_type, Line, Col);
				}
			}
			else{
				type_error(type_1, type_2, op_type, Line, Col);
			}
			break;
		/* ---------------------------------------------------------- */
		case EQU_OP: /* Equality operator */
			// first type INT
			if(type_1 == INT_TYPE)
			{
				// second type INT 
				if(type_2 == INT_TYPE || type_2 == REAL_TYPE){
					return LOGC_TYPE;
				}
				else{
					type_error(type_1, type_2, op_type, Line, Col);
				}
					
			}
			
			// first type CHAR
			else if(type_1 == CHAR_TYPE){
				// second type INT or CHAR
				if(type_2 == CHAR_TYPE){
					return LOGC_TYPE;
				}
				else{
					type_error(type_1, type_2, op_type, Line, Col);
				}
			}
			// first type REAL
			else if(type_1 == REAL_TYPE){
				// second type INT or REAL
				if(type_2 == REAL_TYPE || type_2 == INT_TYPE){
					return LOGC_TYPE;
				}
				else{
					type_error(type_1, type_2, op_type, Line, Col);
				}
			}
			// first type LOGICAL
			else if(type_1 == LOGC_TYPE){
				// second type LOGICAL
				if(type_2 == LOGC_TYPE){
					return LOGC_TYPE;
				}
				else{
					type_error(type_1, type_2, op_type, Line, Col);
				}
			}
			else{
				type_error(type_1, type_2, op_type, Line, Col);
			}
			break;
		/* ---------------------------------------------------------- */
		default: /* wrong choice case */
			printf("Error in operator selection!\n");
			exit(1);
	}
}
 
int func_param_check(char *name, int num_of_pars, Param *parameters, int Line, int Col){ // check parameters
	int i, type_1, type_2;
	
	// lookup entry 
	SymbolInfo *currentSymbol = lookup(name);
	
	// check number of parameters 
	if(currentSymbol->num_of_pars != num_of_pars){
		setColor(255, 0, 0);
        printf("\n\nSemantic Error: Function call of %s has wrong number of parameters! at Line %d and Column %d\n",name, Line, Col);
        setColor(255, 255, 0);
        printf("<!> Nbr of params in declaration: %d != Nbr of params in instruction: %d \n\n",currentSymbol->num_of_pars, num_of_pars );
        setColor(255, 255, 255);
		exit(1);
	}
	
	// check if parameters are compatible 
	for(i = 0; i < num_of_pars; i++){
		// type of parameter in function declaration 
		type_1 = currentSymbol->parameters[i].par_type; 
		
		// type of parameter in function call
		type_2 = parameters[i].par_type; 
		
		// check compatibility for function call 
		get_result_type(type_1, type_2, NONE, Line, Col);
		// error occurs automatically in the function 
	}
	
	return 0; // success 
}




